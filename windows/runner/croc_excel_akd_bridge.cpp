#include "croc_excel_akd_bridge.h"

#include <oleacc.h>
#include <oleauto.h>
#include <windows.h>

#include <algorithm>
#include <cwctype>
#include <string>
#include <vector>

namespace {

constexpr wchar_t kWorkbookName[] = L"CROC_MATRIKS_AKD_LIVE.XLSX";
constexpr wchar_t kWorksheetName[] = L"Sayfa1";

std::wstring Upper(std::wstring value) {
  std::transform(value.begin(), value.end(), value.begin(),
                 [](wchar_t c) { return std::towupper(c); });
  return value;
}

std::string Utf8(const std::wstring& value) {
  if (value.empty()) return {};
  const int size = WideCharToMultiByte(CP_UTF8, 0, value.data(),
                                       static_cast<int>(value.size()), nullptr,
                                       0, nullptr, nullptr);
  std::string result(size, '\0');
  WideCharToMultiByte(CP_UTF8, 0, value.data(), static_cast<int>(value.size()),
                      result.data(), size, nullptr, nullptr);
  return result;
}

std::wstring VariantString(const VARIANT& value) {
  VARIANT converted;
  VariantInit(&converted);
  if (FAILED(VariantChangeType(&converted, const_cast<VARIANT*>(&value), 0,
                               VT_BSTR))) {
    return {};
  }
  std::wstring result =
      converted.bstrVal ? std::wstring(converted.bstrVal) : std::wstring();
  VariantClear(&converted);
  return result;
}

bool VariantDouble(const VARIANT& value, double* result) {
  VARIANT converted;
  VariantInit(&converted);
  if (FAILED(VariantChangeType(&converted, const_cast<VARIANT*>(&value), 0,
                               VT_R8))) {
    return false;
  }
  *result = converted.dblVal;
  VariantClear(&converted);
  return true;
}

HRESULT GetProperty(IDispatch* object, const wchar_t* name, VARIANT* result) {
  DISPID id;
  LPOLESTR names[] = {const_cast<LPOLESTR>(name)};
  HRESULT hr = object->GetIDsOfNames(IID_NULL, names, 1, LOCALE_USER_DEFAULT,
                                     &id);
  if (FAILED(hr)) return hr;

  DISPPARAMS params = {};
  VariantInit(result);
  return object->Invoke(id, IID_NULL, LOCALE_USER_DEFAULT,
                        DISPATCH_PROPERTYGET, &params, result, nullptr, nullptr);
}

HRESULT GetIndexedProperty(IDispatch* object, const wchar_t* name,
                           const VARIANT& index, VARIANT* result) {
  DISPID id;
  LPOLESTR names[] = {const_cast<LPOLESTR>(name)};
  HRESULT hr = object->GetIDsOfNames(IID_NULL, names, 1, LOCALE_USER_DEFAULT,
                                     &id);
  if (FAILED(hr)) return hr;

  VARIANTARG arg;
  VariantInit(&arg);
  VariantCopy(&arg, const_cast<VARIANT*>(&index));
  DISPPARAMS params = {&arg, nullptr, 1, 0};
  VariantInit(result);
  hr = object->Invoke(id, IID_NULL, LOCALE_USER_DEFAULT, DISPATCH_PROPERTYGET,
                      &params, result, nullptr, nullptr);
  VariantClear(&arg);
  return hr;
}

HRESULT CallRange(IDispatch* sheet, const wchar_t* address, VARIANT* result) {
  VARIANT index;
  VariantInit(&index);
  index.vt = VT_BSTR;
  index.bstrVal = SysAllocString(address);
  HRESULT hr = GetIndexedProperty(sheet, L"Range", index, result);
  VariantClear(&index);
  return hr;
}

IDispatch* DispatchFrom(VARIANT* value) {
  if (value->vt != VT_DISPATCH || !value->pdispVal) return nullptr;
  IDispatch* result = value->pdispVal;
  result->AddRef();
  return result;
}

std::wstring ReadCellString(IDispatch* sheet, const wchar_t* address) {
  VARIANT range_value;
  if (FAILED(CallRange(sheet, address, &range_value))) return {};
  IDispatch* range = DispatchFrom(&range_value);
  VariantClear(&range_value);
  if (!range) return {};

  VARIANT value;
  const HRESULT hr = GetProperty(range, L"Value2", &value);
  range->Release();
  if (FAILED(hr)) return {};

  const std::wstring result = VariantString(value);
  VariantClear(&value);
  return result;
}

bool ReadCellDouble(IDispatch* sheet, const wchar_t* address, double* result) {
  VARIANT range_value;
  if (FAILED(CallRange(sheet, address, &range_value))) return false;
  IDispatch* range = DispatchFrom(&range_value);
  VariantClear(&range_value);
  if (!range) return false;

  VARIANT value;
  const HRESULT hr = GetProperty(range, L"Value2", &value);
  range->Release();
  if (FAILED(hr)) return false;

  const bool ok = VariantDouble(value, result);
  VariantClear(&value);
  return ok;
}

BOOL CALLBACK FindExcel7(HWND hwnd, LPARAM lparam) {
  wchar_t class_name[64] = {};
  GetClassNameW(hwnd, class_name, 64);
  if (wcscmp(class_name, L"EXCEL7") == 0) {
    reinterpret_cast<std::vector<HWND>*>(lparam)->push_back(hwnd);
  }
  return TRUE;
}

IDispatch* ExcelApplicationFromWindow(HWND excel7) {
  IDispatch* native = nullptr;
  const HRESULT hr = AccessibleObjectFromWindow(
      excel7, static_cast<DWORD>(OBJID_NATIVEOM), IID_IDispatch,
      reinterpret_cast<void**>(&native));
  if (FAILED(hr) || !native) return nullptr;

  VARIANT application;
  const HRESULT app_hr = GetProperty(native, L"Application", &application);
  native->Release();
  if (FAILED(app_hr)) return nullptr;

  IDispatch* result = DispatchFrom(&application);
  VariantClear(&application);
  return result;
}

IDispatch* FindWorkbook(IDispatch* application) {
  VARIANT workbooks_value;
  if (FAILED(GetProperty(application, L"Workbooks", &workbooks_value))) {
    return nullptr;
  }
  IDispatch* workbooks = DispatchFrom(&workbooks_value);
  VariantClear(&workbooks_value);
  if (!workbooks) return nullptr;

  VARIANT count_value;
  if (FAILED(GetProperty(workbooks, L"Count", &count_value))) {
    workbooks->Release();
    return nullptr;
  }
  VARIANT count_number;
  VariantInit(&count_number);
  if (FAILED(VariantChangeType(&count_number, &count_value, 0, VT_I4))) {
    VariantClear(&count_value);
    workbooks->Release();
    return nullptr;
  }
  const long count = count_number.lVal;
  VariantClear(&count_number);
  VariantClear(&count_value);

  IDispatch* found = nullptr;
  for (long i = 1; i <= count && !found; ++i) {
    VARIANT index;
    VariantInit(&index);
    index.vt = VT_I4;
    index.lVal = i;

    VARIANT workbook_value;
    if (SUCCEEDED(GetIndexedProperty(workbooks, L"Item", index,
                                     &workbook_value))) {
      IDispatch* workbook = DispatchFrom(&workbook_value);
      VariantClear(&workbook_value);
      if (workbook) {
        VARIANT name_value;
        if (SUCCEEDED(GetProperty(workbook, L"Name", &name_value))) {
          const std::wstring name = Upper(VariantString(name_value));
          VariantClear(&name_value);
          if (name == kWorkbookName) {
            found = workbook;
          } else {
            workbook->Release();
          }
        } else {
          workbook->Release();
        }
      }
    }
  }

  workbooks->Release();
  return found;
}

IDispatch* FindWorksheet(IDispatch* workbook) {
  VARIANT worksheets_value;
  if (FAILED(GetProperty(workbook, L"Worksheets", &worksheets_value))) {
    return nullptr;
  }
  IDispatch* worksheets = DispatchFrom(&worksheets_value);
  VariantClear(&worksheets_value);
  if (!worksheets) return nullptr;

  VARIANT index;
  VariantInit(&index);
  index.vt = VT_BSTR;
  index.bstrVal = SysAllocString(kWorksheetName);

  VARIANT sheet_value;
  IDispatch* sheet = nullptr;
  if (SUCCEEDED(GetIndexedProperty(worksheets, L"Item", index, &sheet_value))) {
    sheet = DispatchFrom(&sheet_value);
    VariantClear(&sheet_value);
  }
  VariantClear(&index);
  worksheets->Release();
  return sheet;
}

}  // namespace

std::optional<flutter::EncodableMap> ReadCrocMatriksAkdSnapshot(
    std::string* error) {
  std::vector<HWND> excel7_windows;
  EnumWindows(
      [](HWND hwnd, LPARAM lparam) -> BOOL {
        wchar_t class_name[64] = {};
        GetClassNameW(hwnd, class_name, 64);
        if (wcscmp(class_name, L"XLMAIN") == 0) {
          EnumChildWindows(hwnd, FindExcel7, lparam);
        }
        return TRUE;
      },
      reinterpret_cast<LPARAM>(&excel7_windows));

  IDispatch* workbook = nullptr;
  IDispatch* application = nullptr;
  for (HWND excel7 : excel7_windows) {
    application = ExcelApplicationFromWindow(excel7);
    if (!application) continue;
    workbook = FindWorkbook(application);
    if (workbook) break;
    application->Release();
    application = nullptr;
  }

  if (!workbook || !application) {
    if (error) *error = "CROC_MATRIKS_AKD_LIVE.xlsx acik Excel'de bulunamadi.";
    return std::nullopt;
  }

  IDispatch* sheet = FindWorksheet(workbook);
  workbook->Release();
  application->Release();
  if (!sheet) {
    if (error) *error = "Sayfa1 bulunamadi.";
    return std::nullopt;
  }

  const std::string symbol = Utf8(ReadCellString(sheet, L"C2"));
  if (symbol.empty() || symbol == "Veri Bekleniyor!") {
    sheet->Release();
    if (error) *error = "Matriks RTD verisi henuz hazir degil.";
    return std::nullopt;
  }

  flutter::EncodableList buyers;
  flutter::EncodableList sellers;

  for (int row = 2; row <= 30; ++row) {
    const std::wstring row_text = std::to_wstring(row);
    const std::wstring buyer_name =
        ReadCellString(sheet, (L"D" + row_text).c_str());
    const std::wstring seller_name =
        ReadCellString(sheet, (L"F" + row_text).c_str());

    double buyer_net = 0;
    double seller_net = 0;

    if (!buyer_name.empty() &&
        ReadCellDouble(sheet, (L"E" + row_text).c_str(), &buyer_net)) {
      buyers.push_back(flutter::EncodableMap{
          {flutter::EncodableValue("institution"),
           flutter::EncodableValue(Utf8(buyer_name))},
          {flutter::EncodableValue("netLots"),
           flutter::EncodableValue(buyer_net)},
      });
    }

    if (!seller_name.empty() &&
        ReadCellDouble(sheet, (L"G" + row_text).c_str(), &seller_net)) {
      sellers.push_back(flutter::EncodableMap{
          {flutter::EncodableValue("institution"),
           flutter::EncodableValue(Utf8(seller_name))},
          {flutter::EncodableValue("netLots"),
           flutter::EncodableValue(seller_net)},
      });
    }
  }

  sheet->Release();

  return flutter::EncodableMap{
      {flutter::EncodableValue("symbol"), flutter::EncodableValue(symbol)},
      {flutter::EncodableValue("buyers"), flutter::EncodableValue(buyers)},
      {flutter::EncodableValue("sellers"), flutter::EncodableValue(sellers)},
  };
}
