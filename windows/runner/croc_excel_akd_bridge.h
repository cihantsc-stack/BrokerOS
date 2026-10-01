#ifndef RUNNER_CROC_EXCEL_AKD_BRIDGE_H_
#define RUNNER_CROC_EXCEL_AKD_BRIDGE_H_

#include <flutter/encodable_value.h>

#include <optional>
#include <string>

std::optional<flutter::EncodableMap> ReadCrocMatriksAkdSnapshot(
    std::string* error);

#endif  // RUNNER_CROC_EXCEL_AKD_BRIDGE_H_
