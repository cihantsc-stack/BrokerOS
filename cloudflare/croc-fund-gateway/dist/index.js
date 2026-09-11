var __defProp = Object.defineProperty;
var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

// src/index.js
var CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
  "Content-Type": "application/json; charset=UTF-8"
};
var TEFAS_HISTORY_URL = "https://www.tefas.gov.tr/api/funds/fonFiyatBilgiGetir";
var index_default = {
  async fetch(request) {
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: CORS_HEADERS });
    }
    if (request.method !== "GET") {
      return json(
        {
          ok: false,
          available: false,
          error: "Sadece GET destekleniyor."
        },
        405
      );
    }
    try {
      const url = new URL(request.url);
      const action = String(url.searchParams.get("action") || "health").trim().toLowerCase();
      if (action === "health") {
        return json({
          ok: true,
          service: "CROC FUND GATEWAY",
          version: "V1",
          provider: "TEFAS",
          masterDecisionImpact: false,
          mockData: false,
          timestamp: (/* @__PURE__ */ new Date()).toISOString()
        });
      }
      if (action === "history") {
        const fundCode = cleanFundCode(url.searchParams.get("fund"));
        const period = cleanPeriod(url.searchParams.get("period"));
        if (!fundCode) {
          return json(
            {
              ok: false,
              available: false,
              error: "Gecerli fon kodu gerekli."
            },
            400
          );
        }
        return await fetchFundHistory(fundCode, period);
      }
      return json(
        {
          ok: false,
          available: false,
          error: "Bilinmeyen action.",
          supportedActions: ["health", "history"]
        },
        400
      );
    } catch (error) {
      return json(
        {
          ok: false,
          available: false,
          error: "Fund gateway hatasi.",
          detail: String(error?.message || error)
        },
        500
      );
    }
  }
};
async function fetchFundHistory(fundCode, period) {
  const body = JSON.stringify({
    fonKodu: fundCode,
    dil: "TR",
    periyod: period
  });
  let response;
  try {
    response = await fetch(TEFAS_HISTORY_URL, {
      method: "POST",
      headers: {
        "Accept": "application/json, text/plain, */*",
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0 (compatible; CROC-Fund-Gateway/1.0; +https://crocai.workers.dev)",
        "Referer": "https://www.tefas.gov.tr/",
        "Origin": "https://www.tefas.gov.tr"
      },
      body
    });
  } catch (error) {
    return json(
      {
        ok: false,
        available: false,
        provider: "TEFAS",
        fundCode,
        status: "TEFAS baglantisi kurulamadi.",
        detail: String(error?.message || error)
      },
      502
    );
  }
  const raw = await response.text();
  if (!response.ok) {
    return json(
      {
        ok: false,
        available: false,
        provider: "TEFAS",
        fundCode,
        status: `TEFAS HTTP ${response.status}`
      },
      502
    );
  }
  let decoded;
  try {
    decoded = JSON.parse(raw);
  } catch (_) {
    return json(
      {
        ok: false,
        available: false,
        provider: "TEFAS",
        fundCode,
        status: "TEFAS JSON cozumlenemedi."
      },
      502
    );
  }
  const sourceList = Array.isArray(decoded?.resultList) ? decoded.resultList : [];
  const prices = sourceList.map(normalizeHistoryItem).filter((item) => item !== null);
  if (prices.length === 0) {
    return json({
      ok: true,
      available: false,
      provider: "TEFAS",
      fundCode,
      period,
      status: "VERI BEKLENIYOR",
      count: 0,
      fundName: null,
      latest: null,
      prices: [],
      updatedAt: (/* @__PURE__ */ new Date()).toISOString()
    });
  }
  prices.sort((a, b) => a.date.localeCompare(b.date));
  const latest = prices[prices.length - 1];
  return json({
    ok: true,
    available: true,
    provider: "TEFAS",
    fundCode,
    fundName: latest.fundName,
    period,
    count: prices.length,
    latest: {
      date: latest.date,
      price: latest.price
    },
    prices,
    updatedAt: (/* @__PURE__ */ new Date()).toISOString(),
    masterDecisionImpact: false,
    mockData: false
  });
}
__name(fetchFundHistory, "fetchFundHistory");
function normalizeHistoryItem(item) {
  if (!item || typeof item !== "object") {
    return null;
  }
  const date = item.tarih ?? item.TARIH ?? item.date ?? null;
  const rawPrice = item.fiyat ?? item.FIYAT ?? item.price ?? null;
  const price = parseNumber(rawPrice);
  if (!date || !Number.isFinite(price) || price <= 0) {
    return null;
  }
  const fundCode = String(item.fonKodu ?? item.FONKODU ?? item.code ?? "").trim().toUpperCase();
  const fundName = String(item.fonUnvan ?? item.FONUNVAN ?? item.title ?? "").trim();
  return {
    date: String(date),
    price,
    fundCode,
    fundName: fundName || null
  };
}
__name(normalizeHistoryItem, "normalizeHistoryItem");
function parseNumber(value) {
  if (typeof value === "number") {
    return value;
  }
  if (typeof value !== "string") {
    return Number.NaN;
  }
  const normalized = value.trim().replace(/\./g, "").replace(",", ".");
  return Number.parseFloat(normalized);
}
__name(parseNumber, "parseNumber");
function cleanFundCode(value) {
  const code = String(value || "").trim().toUpperCase();
  return /^[A-Z0-9]{2,10}$/.test(code) ? code : "";
}
__name(cleanFundCode, "cleanFundCode");
function cleanPeriod(value) {
  const parsed = Number.parseInt(String(value || "12"), 10);
  if (!Number.isFinite(parsed)) {
    return 12;
  }
  return Math.min(60, Math.max(1, parsed));
}
__name(cleanPeriod, "cleanPeriod");
function json(payload, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: CORS_HEADERS
  });
}
__name(json, "json");
export {
  index_default as default
};
//# sourceMappingURL=index.js.map
