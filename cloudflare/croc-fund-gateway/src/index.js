const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
  "Content-Type": "application/json; charset=UTF-8",
};

const TEFAS_HISTORY_URL =
  "https://www.tefas.gov.tr/api/funds/fonFiyatBilgiGetir";
const TEFAS_CATALOG_URL =
  "https://www.tefas.gov.tr/api/funds/fonGnlBlgSiraliGetir";

const FONAPI_BASE_URL = "https://api.fonapi.dev";

const CATALOG_CACHE_TTL_MS = 15 * 60 * 1000;
let catalogCache = {
  expiresAt: 0,
  sourceDate: null,
  items: [],
};

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: CORS_HEADERS });
    }

    if (request.method !== "GET") {
      return json(
        {
          ok: false,
          available: false,
          error: "Sadece GET destekleniyor.",
        },
        405,
      );
    }

    try {
      const url = new URL(request.url);
      const action = String(url.searchParams.get("action") || "health")
        .trim()
        .toLowerCase();

      if (action === "health") {
        return json({
          ok: true,
          service: "CROC FUND GATEWAY",
          version: "V2.4",
          provider: "TEFAS",
          supportedActions: ["health", "history", "search", "date-search", "flow", "flow-summary", "holdings", "stock-funds", "snapshot-pilot", "snapshot-status", "stock-funds-kv", "fund-movement", "snapshot-batch", "snapshot-batch-status", "rebuild-stock-index", "monthly-refresh", "monthly-refresh-status", "fund-radar", "catalog-debug"],
          masterDecisionImpact: false,
          mockData: false,
          timestamp: new Date().toISOString(),
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
              error: "Gecerli fon kodu gerekli.",
            },
            400,
          );
        }

        return await fetchFundHistory(fundCode, period);
      }

      if (action === "search") {
        const query = cleanSearchQuery(url.searchParams.get("q"));
        const limit = cleanLimit(url.searchParams.get("limit"));

        if (!query) {
          return json({
            ok: true,
            available: true,
            provider: "TEFAS",
            query: "",
            count: 0,
            results: [],
            mockData: false,
            masterDecisionImpact: false,
          });
        }

        return await searchFunds(query, limit);
      }

      if (action === "date-search") {
        const fundCode = cleanFundCode(
          url.searchParams.get("fund") || url.searchParams.get("q")
        );

        const requestedDate = String(url.searchParams.get("date") || "")
          .trim()
          .replace(/[^0-9]/g, "")
          .slice(0, 8);

        if (!fundCode || requestedDate.length !== 8) {
          return json(
            {
              ok: false,
              available: false,
              error: "Gecerli fund ve date gerekli.",
              mockData: false,
              masterDecisionImpact: false,
            },
            400,
          );
        }

        return await searchFundForDate(fundCode, requestedDate);
      }

      if (action === "flow") {
        const fundCode = cleanFundCode(url.searchParams.get("fund"));
        const periodMonths = cleanFlowPeriod(url.searchParams.get("period"));

        if (!fundCode) {
          return json(
            {
              ok: false,
              available: false,
              error: "Gecerli fon kodu gerekli.",
              mockData: false,
              masterDecisionImpact: false,
            },
            400,
          );
        }

        return await fetchFundFlow(fundCode, periodMonths);
      }

      if (action === "flow-summary") {
        const fundCode = cleanFundCode(url.searchParams.get("fund"));

        if (!fundCode) {
          return json(
            {
              ok: false,
              available: false,
              error: "Gecerli fon kodu gerekli.",
              mockData: false,
              masterDecisionImpact: false,
            },
            400,
          );
        }

        return await fetchFundFlowSummary(fundCode);
      }
      if (action === "holdings") {
        const fundCode = cleanFundCode(url.searchParams.get("fund"));
        const requestedPeriod = String(url.searchParams.get("period") || "")
          .trim()
          .slice(0, 7);

        if (!fundCode) {
          return json(
            {
              ok: false,
              available: false,
              error: "Gecerli fon kodu gerekli.",
              mockData: false,
              masterDecisionImpact: false,
            },
            400,
          );
        }

        return await fetchFundHoldings(
          fundCode,
          requestedPeriod,
          env?.FONAPI_KEY,
        );
      }
      if (action === "stock-funds") {
        const symbol = cleanStockSymbol(url.searchParams.get("symbol"));

        if (!symbol) {
          return json(
            {
              ok: false,
              available: false,
              error: "Gecerli hisse kodu gerekli.",
              mockData: false,
              masterDecisionImpact: false,
            },
            400,
          );
        }

        return await fetchStockFundsPilot(
          symbol,
          env?.FONAPI_KEY,
        );
      }
      if (action === "snapshot-pilot") {
        return await buildPilotHoldingsSnapshot(
          env?.FONAPI_KEY,
          env?.CROC_FUND_HOLDINGS,
        );
      }

      if (action === "snapshot-status") {
        return await getHoldingsSnapshotStatus(
          env?.CROC_FUND_HOLDINGS,
        );
      }

      if (action === "stock-funds-kv") {
        const symbol = cleanStockSymbol(
          url.searchParams.get("symbol"),
        );

        if (!symbol) {
          return json(
            {
              ok: false,
              available: false,
              error: "Gecerli hisse kodu gerekli.",
              mockData: false,
              masterDecisionImpact: false,
            },
            400,
          );
        }

        return await fetchStockFundsFromKv(
          symbol,
          env?.CROC_FUND_HOLDINGS,
        );
      }
      if (action === "fund-movement") {
        const symbol = cleanStockSymbol(
          url.searchParams.get("symbol"),
        );

        if (!symbol) {
          return json(
            {
              ok: false,
              available: false,
              error: "Gecerli hisse kodu gerekli.",
              mockData: false,
              masterDecisionImpact: false,
            },
            400,
          );
        }

        return await analyzeFundMovement(
          symbol,
          env?.CROC_FUND_HOLDINGS,
        );
      }
      if (action === "snapshot-batch") {
        const startRaw = Number(url.searchParams.get("start") || 0);
        const limitRaw = Number(url.searchParams.get("limit") || 25);

        const start =
          Number.isFinite(startRaw) && startRaw >= 0
            ? Math.floor(startRaw)
            : 0;

        const limit =
          Number.isFinite(limitRaw)
            ? Math.min(25, Math.max(1, Math.floor(limitRaw)))
            : 25;

        return await buildPriorityFundBatch(
          start,
          limit,
          env?.FONAPI_KEY,
          env?.CROC_FUND_HOLDINGS,
        );
      }

      if (action === "snapshot-batch-status") {
        return await getPriorityBatchStatus(
          env?.CROC_FUND_HOLDINGS,
        );
      }
      if (action === "rebuild-stock-index") {
        return await rebuildPriorityStockIndex(
          env?.CROC_FUND_HOLDINGS,
        );
      }
      if (action === "monthly-refresh") {
        const period =
          String(url.searchParams.get("period") || "")
            .trim();

        if (!/^\d{4}-\d{2}$/.test(period)) {
          return json(
            {
              ok: false,
              available: false,
              error: "period YYYY-MM formatinda gerekli.",
              mockData: false,
              masterDecisionImpact: false,
            },
            400,
          );
        }

        const startRaw =
          Number(url.searchParams.get("start") || 0);

        const limitRaw =
          Number(url.searchParams.get("limit") || 25);

        const start =
          Number.isFinite(startRaw) && startRaw >= 0
            ? Math.floor(startRaw)
            : 0;

        const limit =
          Number.isFinite(limitRaw)
            ? Math.min(
                25,
                Math.max(1, Math.floor(limitRaw)),
              )
            : 25;

        return await refreshPriorityFundPeriod(
          period,
          start,
          limit,
          env?.FONAPI_KEY,
          env?.CROC_FUND_HOLDINGS,
        );
      }

      if (action === "monthly-refresh-status") {
        const period =
          String(url.searchParams.get("period") || "")
            .trim();

        if (!/^\d{4}-\d{2}$/.test(period)) {
          return json(
            {
              ok: false,
              available: false,
              error: "period YYYY-MM formatinda gerekli.",
            },
            400,
          );
        }

        return await getMonthlyRefreshStatus(
          period,
          env?.CROC_FUND_HOLDINGS,
        );
      }
      if (action === "fund-radar") {
        const symbol = cleanStockSymbol(
          url.searchParams.get("symbol"),
        );

        if (!symbol) {
          return json(
            {
              ok: false,
              available: false,
              error: "Gecerli hisse kodu gerekli.",
              mockData: false,
              masterDecisionImpact: false,
            },
            400,
          );
        }

        return await buildFundRadarResult(
          symbol,
          env?.CROC_FUND_HOLDINGS,
        );
      }









      if (action === "catalog-debug") {
        const requestedDate = String(url.searchParams.get("date") || "20260910")
          .trim()
          .replace(/[^0-9]/g, "")
          .slice(0, 8);
        return await debugCatalog(requestedDate || "20260910");
      }

      return json(
        {
          ok: false,
          available: false,
          error: "Bilinmeyen action.",
          supportedActions: ["health", "history", "search", "date-search", "flow", "flow-summary", "holdings", "stock-funds", "snapshot-pilot", "snapshot-status", "stock-funds-kv", "fund-movement", "snapshot-batch", "snapshot-batch-status", "rebuild-stock-index", "monthly-refresh", "monthly-refresh-status", "fund-radar", "catalog-debug"],
        },
        400,
      );
    } catch (error) {
      return json(
        {
          ok: false,
          available: false,
          error: "Fund gateway hatasi.",
          detail: String(error?.message || error),
        },
        500,
      );
    }
  },
};

async function debugCatalog(tefasDate) {
  const body = buildCatalogBody(tefasDate);

  try {
    const response = await fetch(TEFAS_CATALOG_URL, {
      method: "POST",
      headers: tefasHeaders(),
      body,
    });

    const raw = await response.text();
    let decoded = null;
    try {
      decoded = JSON.parse(raw);
    } catch (_) {}

    return json({
      ok: true,
      provider: "TEFAS",
      test: "catalog-debug",
      requestedDate: tefasDate,
      upstreamStatus: response.status,
      upstreamOk: response.ok,
      contentType: response.headers.get("content-type"),
      rawLength: raw.length,
      errorCode: decoded?.errorCode ?? null,
      errorMessage: decoded?.errorMessage ?? null,
      totalCount: decoded?.toplamSayi ?? null,
      resultCount: Array.isArray(decoded?.resultList)
        ? decoded.resultList.length
        : null,
      preview: raw.slice(0, 700),
      mockData: false,
      masterDecisionImpact: false,
    });
  } catch (error) {
    return json({
      ok: false,
      provider: "TEFAS",
      test: "catalog-debug",
      requestedDate: tefasDate,
      fetchError: String(error?.message || error),
      mockData: false,
      masterDecisionImpact: false,
    });
  }
}

async function searchFunds(query, limit) {
  const catalog = await getLatestCatalog();

  if (!catalog.available) {
    return json(
      {
        ok: false,
        available: false,
        provider: "TEFAS",
        query,
        status: catalog.status,
        results: [],
        mockData: false,
        masterDecisionImpact: false,
      },
      502,
    );
  }

  const normalizedQuery = normalizeSearchText(query);

  const ranked = catalog.items
    .map((item) => {
      const code = normalizeSearchText(item.fundCode);
      const name = normalizeSearchText(item.fundName);

      let rank = 99;
      if (code === normalizedQuery) rank = 0;
      else if (code.startsWith(normalizedQuery)) rank = 1;
      else if (name.startsWith(normalizedQuery)) rank = 2;
      else if (code.includes(normalizedQuery)) rank = 3;
      else if (name.includes(normalizedQuery)) rank = 4;

      return { item, rank };
    })
    .filter((entry) => entry.rank < 99)
    .sort((a, b) => {
      if (a.rank !== b.rank) return a.rank - b.rank;
      return a.item.fundCode.localeCompare(b.item.fundCode, "tr");
    })
    .slice(0, limit)
    .map((entry) => entry.item);

  return json({
    ok: true,
    available: true,
    provider: "TEFAS",
    sourceDate: catalog.sourceDate,
    catalogCount: catalog.items.length,
    query,
    count: ranked.length,
    results: ranked,
    updatedAt: new Date().toISOString(),
    mockData: false,
    masterDecisionImpact: false,
  });
}

async function getLatestCatalog() {
  const now = Date.now();

  if (
    catalogCache.items.length > 0 &&
    catalogCache.expiresAt > now &&
    catalogCache.sourceDate
  ) {
    return {
      available: true,
      sourceDate: catalogCache.sourceDate,
      items: catalogCache.items,
    };
  }

  const today = new Date();
  const datesToTry = [];

  for (let offset = 0; offset <= 10; offset++) {
    const date = new Date(today);
    date.setUTCDate(date.getUTCDate() - offset);
    datesToTry.push(formatTefasDate(date));
  }

  if (!datesToTry.includes("20260910")) {
    datesToTry.push("20260910");
  }

  for (const tefasDate of datesToTry) {
    const response = await fetchCatalogForDate(tefasDate);

    if (response.items.length > 0) {
      catalogCache = {
        expiresAt: now + CATALOG_CACHE_TTL_MS,
        sourceDate: response.sourceDate,
        items: response.items,
      };

      return {
        available: true,
        sourceDate: response.sourceDate,
        items: response.items,
      };
    }
  }

  return {
    available: false,
    sourceDate: null,
    items: [],
    status: "TEFAS fon katalogu bulunamadi.",
  };
}

function buildCatalogBody(tefasDate) {
  return JSON.stringify({
    fonTipi: "YAT",
    fonKodu: "",
    aramaMetni: "",
    fonTurKod: "",
    fonGrubu: "",
    sFonTurKod: "",
    fonTurAciklama: "",
    kurucuKod: "",
    basTarih: tefasDate,
    bitTarih: tefasDate,
    basSira: 1,
    bitSira: 100000,
    dil: "TR",
    fonKod: "",
    fonGrup: "",
    fonUnvanTip: "",
  });
}

async function fetchCatalogForDate(tefasDate) {
  const body = buildCatalogBody(tefasDate);

  let response;

  try {
    response = await fetch(TEFAS_CATALOG_URL, {
      method: "POST",
      headers: tefasHeaders(),
      body,
    });
  } catch (_) {
    return { sourceDate: null, items: [] };
  }

  if (!response.ok) {
    return { sourceDate: null, items: [] };
  }

  let decoded;

  try {
    decoded = JSON.parse(await response.text());
  } catch (_) {
    return { sourceDate: null, items: [] };
  }

  const sourceList = Array.isArray(decoded?.resultList)
    ? decoded.resultList
    : [];

  const items = sourceList
    .map(normalizeCatalogItem)
    .filter((item) => item !== null);

  return {
    sourceDate: items.length > 0 ? items[0].date : null,
    items,
  };
}

async function fetchFundHistory(fundCode, period) {
  const body = JSON.stringify({
    fonKodu: fundCode,
    dil: "TR",
    periyod: period,
  });

  let response;

  try {
    response = await fetch(TEFAS_HISTORY_URL, {
      method: "POST",
      headers: tefasHeaders(),
      body,
    });
  } catch (error) {
    return json(
      {
        ok: false,
        available: false,
        provider: "TEFAS",
        fundCode,
        status: "TEFAS baglantisi kurulamadi.",
        detail: String(error?.message || error),
      },
      502,
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
        status: `TEFAS HTTP ${response.status}`,
      },
      502,
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
        status: "TEFAS JSON cozumlenemedi.",
      },
      502,
    );
  }

  const sourceList = Array.isArray(decoded?.resultList)
    ? decoded.resultList
    : [];

  const prices = sourceList
    .map(normalizeHistoryItem)
    .filter((item) => item !== null);

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
      updatedAt: new Date().toISOString(),
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
      price: latest.price,
    },
    prices,
    updatedAt: new Date().toISOString(),
    masterDecisionImpact: false,
    mockData: false,
  });
}

async function fetchFundHoldings(
  fundCode,
  requestedPeriod,
  apiKey,
) {
  if (!apiKey) {
    return json(
      {
        ok: false,
        available: false,
        provider: "FONAPI / KAP",
        fundCode,
        status: "FONAPI_KEY Worker secret bulunamadi.",
        mockData: false,
        masterDecisionImpact: false,
      },
      500,
    );
  }

  let endpoint =
    `${FONAPI_BASE_URL}/api/funds/${encodeURIComponent(fundCode)}/holdings`;

  if (/^\d{4}-\d{2}$/.test(requestedPeriod)) {
    endpoint += `?period=${encodeURIComponent(requestedPeriod)}`;
  }

  let response;

  try {
    response = await fetch(endpoint, {
      method: "GET",
      headers: {
        Accept: "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
    });
  } catch (error) {
    return json(
      {
        ok: false,
        available: false,
        provider: "FONAPI / KAP",
        fundCode,
        requestedPeriod: requestedPeriod || null,
        status: "FonAPI baglantisi kurulamadi.",
        detail: String(error?.message || error),
        mockData: false,
        masterDecisionImpact: false,
      },
      502,
    );
  }

  const raw = await response.text();

  let decoded;

  try {
    decoded = JSON.parse(raw);
  } catch (_) {
    return json(
      {
        ok: false,
        available: false,
        provider: "FONAPI / KAP",
        fundCode,
        requestedPeriod: requestedPeriod || null,
        status: "FonAPI JSON cozumlenemedi.",
        upstreamStatus: response.status,
        mockData: false,
        masterDecisionImpact: false,
      },
      502,
    );
  }

  if (!response.ok || decoded?.success !== true) {
    return json(
      {
        ok: false,
        available: false,
        provider: "FONAPI / KAP",
        fundCode,
        requestedPeriod: requestedPeriod || null,
        status:
          decoded?.message ||
          decoded?.error ||
          `FonAPI HTTP ${response.status}`,
        upstreamStatus: response.status,
        mockData: false,
        masterDecisionImpact: false,
      },
      502,
    );
  }

  const data = decoded?.data || {};
  const rawItems = Array.isArray(data?.items) ? data.items : [];

  const items = rawItems
    .map((item) => {
      if (!item || typeof item !== "object") {
        return null;
      }

      const symbol = String(item.symbol || "").trim().toUpperCase();
      const type = String(item.type || "").trim().toLowerCase();

      if (!symbol) {
        return null;
      }

      return {
        symbol,
        name:
          item.name === null || item.name === undefined
            ? null
            : String(item.name),
        isin:
          item.isin === null || item.isin === undefined
            ? null
            : String(item.isin),
        type,
        weight: safeNumber(item.weight),
        fpdWeight: safeNumber(item.fpdWeight),
        value: safeNumber(item.value),
        nominal: safeNumber(item.nominal),
      };
    })
    .filter((item) => item !== null);

  const stocks = items.filter((item) => item.type === "stock");

  return json({
    ok: true,
    available: items.length > 0,
    provider: "FONAPI / KAP",
    fundCode: String(data?.code || fundCode).trim().toUpperCase(),
    period: data?.period ?? null,
    requestedPeriod: requestedPeriod || null,
    publishDate: data?.publishDate ?? null,
    status: data?.status ?? null,
    itemCount: items.length,
    stockCount: stocks.length,
    items,
    validation: data?.validation ?? null,
    periods: Array.isArray(data?.periods) ? data.periods : [],
    kapUrl: data?.kapUrl ?? null,
    cached: data?.cached === true,
    mockData: false,

    // V1 sadece gercek holdings verisini tasir.
    // Hisse Master Decision skoruna henuz bagli DEGIL.
    masterDecisionImpact: false,

    updatedAt: new Date().toISOString(),
  });
}

const STOCK_FUNDS_PILOT_CODES = [
  "TI2",
  "ADP",
  "AAV",
  "ACC",
  "AEV",
  "AEH",
  "AH5",
  "AGH",
];

const STOCK_FUNDS_CACHE_TTL_MS = 30 * 60 * 1000;

let stockFundsPilotCache = {
  expiresAt: 0,
  funds: new Map(),
};

async function loadPilotFundHolding(fundCode, apiKey) {
  const now = Date.now();

  if (
    stockFundsPilotCache.expiresAt > now &&
    stockFundsPilotCache.funds.has(fundCode)
  ) {
    return {
      cached: true,
      data: stockFundsPilotCache.funds.get(fundCode),
    };
  }

  const endpoint =
    `${FONAPI_BASE_URL}/api/funds/${encodeURIComponent(fundCode)}/holdings`;

  const response = await fetch(endpoint, {
    method: "GET",
    headers: {
      Accept: "application/json",
      Authorization: `Bearer ${apiKey}`,
    },
  });

  const raw = await response.text();

  let decoded = null;

  try {
    decoded = JSON.parse(raw);
  } catch (_) {}

  if (
    !response.ok ||
    decoded?.success !== true ||
    !decoded?.data
  ) {
    throw new Error(`FONAPI_${response.status}`);
  }

  stockFundsPilotCache.funds.set(
    fundCode,
    decoded.data,
  );

  stockFundsPilotCache.expiresAt =
    Date.now() + STOCK_FUNDS_CACHE_TTL_MS;

  return {
    cached: false,
    data: decoded.data,
  };
}

async function fetchStockFundsPilot(symbol, apiKey) {
  if (!apiKey) {
    return json(
      {
        ok: false,
        available: false,
        provider: "FONAPI / KAP",
        symbol,
        status: "FONAPI_KEY Worker secret bulunamadi.",
        mockData: false,
        masterDecisionImpact: false,
      },
      500,
    );
  }

  const rawResults = [];
  const failedFunds = [];

  let apiFetchCount = 0;
  let cacheHitCount = 0;

  for (const fundCode of STOCK_FUNDS_PILOT_CODES) {
    try {
      const loaded =
        await loadPilotFundHolding(
          fundCode,
          apiKey,
        );

      if (loaded.cached) {
        cacheHitCount++;
      } else {
        apiFetchCount++;
      }

      rawResults.push({
        fundCode,
        data: loaded.data,
      });
    } catch (error) {
      failedFunds.push({
        fundCode,
        status: String(error?.message || error),
      });
    }

    await new Promise((resolve) => setTimeout(resolve, 80));
  }

  const validPeriods = rawResults
    .map((entry) => String(entry.data?.period || "").trim())
    .filter((period) => /^\d{4}-\d{2}$/.test(period))
    .sort()
    .reverse();

  const activePeriod =
    validPeriods.length > 0
      ? validPeriods[0]
      : null;

  const matches = [];
  const staleFunds = [];
  const unavailableFunds = [];
  const checkedFunds = [];

  for (const entry of rawResults) {
    const fundCode = entry.fundCode;
    const data = entry.data || {};

    const period =
      String(data?.period || "").trim() || null;

    checkedFunds.push({
      fundCode,
      period,
      publishDate: data?.publishDate ?? null,
    });

    if (!period) {
      unavailableFunds.push({
        fundCode,
        period: null,
        publishDate: data?.publishDate ?? null,
        reason: "PERIOD_YOK",
      });

      continue;
    }

    if (activePeriod && period !== activePeriod) {
      staleFunds.push({
        fundCode,
        period,
        publishDate: data?.publishDate ?? null,
      });

      continue;
    }

    const items =
      Array.isArray(data?.items)
        ? data.items
        : [];

    const item = items.find((candidate) => {
      if (!candidate || typeof candidate !== "object") {
        return false;
      }

      if (
        String(candidate.type || "")
          .trim()
          .toLowerCase() !== "stock"
      ) {
        return false;
      }

      return (
        String(candidate.symbol || "")
          .trim()
          .toUpperCase() === symbol
      );
    });

    if (!item) {
      continue;
    }

    const nominal = safeNumber(item.nominal);
    const value = safeNumber(item.value);
    const weight = safeNumber(item.weight);
    const fpdWeight = safeNumber(item.fpdWeight);

    const meaningful =
      (nominal !== null && nominal >= 1) ||
      (value !== null && value >= 1000) ||
      (weight !== null && weight >= 0.01);

    if (!meaningful) {
      continue;
    }

    matches.push({
      fundCode,
      period,
      publishDate: data?.publishDate ?? null,
      weight,
      fpdWeight,
      value,
      nominal,
    });
  }

  matches.sort(
    (a, b) =>
      Number(b.value || 0) -
      Number(a.value || 0),
  );

  const totalValue = matches.reduce(
    (sum, item) =>
      sum + Number(item.value || 0),
    0,
  );

  const totalNominal = matches.reduce(
    (sum, item) =>
      sum + Number(item.nominal || 0),
    0,
  );

  const averageWeight =
    matches.length > 0
      ? matches.reduce(
            (sum, item) =>
              sum + Number(item.weight || 0),
            0,
          ) / matches.length
      : 0;

  return json({
    ok: true,
    available: matches.length > 0,
    provider: "FONAPI / KAP",
    symbol,

    coverage: "PILOT",
    coverageWarning:
      "Bu sonuc tum fon evrenini kapsamaz. Yalnizca pilot fon sepeti taranmistir.",

    activePeriod,

    scannedFundCount:
      STOCK_FUNDS_PILOT_CODES.length,

    successfulFundCount:
      rawResults.length,

    failedFundCount:
      failedFunds.length,

    holderFundCount:
      matches.length,

    staleFundCount:
      staleFunds.length,

    unavailableFundCount:
      unavailableFunds.length,

    cache: {
      ttlMinutes: 30,
      apiFetchCount,
      cacheHitCount,
    },

    summary: {
      totalValue,
      totalNominal,
      averageWeight:
        Math.round(averageWeight * 1000) / 1000,
    },

    funds: matches,
    staleFunds,
    unavailableFunds,
    checkedFunds,
    failedFunds,

    mockData: false,
    masterDecisionImpact: false,

    updatedAt: new Date().toISOString(),
  });
}

function cleanStockSymbol(value) {
  const symbol = String(value || "")
    .trim()
    .toUpperCase();

  return /^[A-Z0-9]{2,10}$/.test(symbol)
    ? symbol
    : "";
}

async function buildPilotHoldingsSnapshot(
  apiKey,
  kv,
) {
  if (!apiKey) {
    return json(
      {
        ok: false,
        available: false,
        status: "FONAPI_KEY Worker secret bulunamadi.",
        mockData: false,
        masterDecisionImpact: false,
      },
      500,
    );
  }

  if (!kv) {
    return json(
      {
        ok: false,
        available: false,
        status: "CROC_FUND_HOLDINGS KV binding bulunamadi.",
        mockData: false,
        masterDecisionImpact: false,
      },
      500,
    );
  }

  const fetched = [];
  const failedFunds = [];
  const unavailableFunds = [];

  for (const fundCode of STOCK_FUNDS_PILOT_CODES) {
    const endpoint =
      `${FONAPI_BASE_URL}/api/funds/${encodeURIComponent(fundCode)}/holdings`;

    try {
      const response = await fetch(endpoint, {
        method: "GET",
        headers: {
          Accept: "application/json",
          Authorization: `Bearer ${apiKey}`,
        },
      });

      const raw = await response.text();

      let decoded = null;

      try {
        decoded = JSON.parse(raw);
      } catch (_) {}

      if (
        !response.ok ||
        decoded?.success !== true ||
        !decoded?.data
      ) {
        failedFunds.push({
          fundCode,
          status: response.status,
        });

        continue;
      }

      const data = decoded.data;
      const period =
        String(data?.period || "").trim();

      if (!/^\d{4}-\d{2}$/.test(period)) {
        unavailableFunds.push({
          fundCode,
          period: null,
          reason: "PERIOD_YOK",
        });

        continue;
      }

      fetched.push({
        fundCode,
        period,
        data,
      });
    } catch (error) {
      failedFunds.push({
        fundCode,
        status: "FETCH_ERROR",
        detail: String(error?.message || error),
      });
    }

    await new Promise(
      (resolve) => setTimeout(resolve, 120),
    );
  }

  const periods = Array.from(
    new Set(
      fetched.map((entry) => entry.period),
    ),
  ).sort();

  if (periods.length === 0) {
    return json({
      ok: false,
      available: false,
      provider: "FONAPI / KAP",
      status: "Gecerli holdings donemi bulunamadi.",
      failedFunds,
      unavailableFunds,
      mockData: false,
      masterDecisionImpact: false,
    });
  }

  const periodSummaries = [];

  for (const period of periods) {
    const periodFunds =
      fetched.filter(
        (entry) => entry.period === period,
      );

    const stockIndex = new Map();

    for (const entry of periodFunds) {
      const fundCode = entry.fundCode;
      const data = entry.data;

      const items =
        Array.isArray(data?.items)
          ? data.items
          : [];

      const normalizedStocks = [];

      for (const item of items) {
        if (!item || typeof item !== "object") {
          continue;
        }

        if (
          String(item.type || "")
            .trim()
            .toLowerCase() !== "stock"
        ) {
          continue;
        }

        const symbol =
          String(item.symbol || "")
            .trim()
            .toUpperCase();

        if (!symbol) {
          continue;
        }

        const weight = safeNumber(item.weight);
        const fpdWeight = safeNumber(item.fpdWeight);
        const value = safeNumber(item.value);
        const nominal = safeNumber(item.nominal);

        const meaningful =
          (nominal !== null && nominal >= 1) ||
          (value !== null && value >= 1000) ||
          (weight !== null && weight >= 0.01);

        if (!meaningful) {
          continue;
        }

        const position = {
          fundCode,
          period,
          publishDate: data?.publishDate ?? null,
          symbol,
          name:
            item.name === null ||
            item.name === undefined
              ? null
              : String(item.name),
          isin:
            item.isin === null ||
            item.isin === undefined
              ? null
              : String(item.isin),
          weight,
          fpdWeight,
          value,
          nominal,
        };

        normalizedStocks.push(position);

        if (!stockIndex.has(symbol)) {
          stockIndex.set(symbol, []);
        }

        stockIndex.get(symbol).push(position);
      }

      await kv.put(
        `fund:${period}:${fundCode}`,
        JSON.stringify({
          fundCode,
          period,
          publishDate: data?.publishDate ?? null,
          positions: normalizedStocks,
          updatedAt: new Date().toISOString(),
        }),
      );
    }

    const symbols =
      Array.from(stockIndex.keys()).sort();

    for (const symbol of symbols) {
      const positions =
        stockIndex.get(symbol) || [];

      positions.sort(
        (a, b) =>
          Number(b.value || 0) -
          Number(a.value || 0),
      );

      const totalValue =
        positions.reduce(
          (sum, item) =>
            sum + Number(item.value || 0),
          0,
        );

      const totalNominal =
        positions.reduce(
          (sum, item) =>
            sum + Number(item.nominal || 0),
          0,
        );

      const averageWeight =
        positions.length > 0
          ? positions.reduce(
                (sum, item) =>
                  sum + Number(item.weight || 0),
                0,
              ) / positions.length
          : 0;

      await kv.put(
        `stock:${period}:${symbol}`,
        JSON.stringify({
          symbol,
          period,
          holderFundCount:
            positions.length,
          summary: {
            totalValue,
            totalNominal,
            averageWeight:
              Math.round(
                averageWeight * 1000,
              ) / 1000,
          },
          funds: positions,
          updatedAt:
            new Date().toISOString(),
        }),
      );
    }

    const meta = {
      period,
      coverage: "PILOT",
      fundCount: periodFunds.length,
      activeFunds:
        periodFunds.map(
          (entry) => entry.fundCode,
        ),
      stockSymbolCount:
        symbols.length,
      symbols,
      createdAt:
        new Date().toISOString(),
    };

    await kv.put(
      `meta:${period}`,
      JSON.stringify(meta),
    );

    periodSummaries.push({
      period,
      fundCount: periodFunds.length,
      stockSymbolCount:
        symbols.length,
      activeFunds:
        periodFunds.map(
          (entry) => entry.fundCode,
        ),
    });
  }

  const activePeriod =
    periods[periods.length - 1];

  await kv.put(
    "periods",
    JSON.stringify(periods),
  );

  await kv.put(
    "active-period",
    activePeriod,
  );

  return json({
    ok: true,
    available: true,
    provider:
      "FONAPI / KAP + CLOUDFLARE KV",
    snapshot: true,
    coverage: "PILOT",

    periods,
    activePeriod,

    scannedFundCount:
      STOCK_FUNDS_PILOT_CODES.length,

    storedFundCount:
      fetched.length,

    unavailableFundCount:
      unavailableFunds.length,

    failedFundCount:
      failedFunds.length,

    periodSummaries,

    unavailableFunds,
    failedFunds,

    mockData: false,
    masterDecisionImpact: false,

    updatedAt:
      new Date().toISOString(),
  });
}


async function getHoldingsSnapshotStatus(kv) {
  if (!kv) {
    return json(
      {
        ok: false,
        available: false,
        status:
          "CROC_FUND_HOLDINGS KV binding bulunamadi.",
      },
      500,
    );
  }

  const activePeriod =
    await kv.get("active-period");

  if (!activePeriod) {
    return json({
      ok: true,
      available: false,
      status: "Snapshot henuz olusturulmadi.",
      mockData: false,
      masterDecisionImpact: false,
    });
  }

  const metaRaw =
    await kv.get(`meta:${activePeriod}`);

  let meta = null;

  try {
    meta =
      metaRaw ? JSON.parse(metaRaw) : null;
  } catch (_) {}

  return json({
    ok: true,
    available: meta !== null,
    provider: "CLOUDFLARE KV",
    activePeriod,
    meta,
    mockData: false,
    masterDecisionImpact: false,
    updatedAt: new Date().toISOString(),
  });
}


async function fetchStockFundsFromKv(
  symbol,
  kv,
) {
  if (!kv) {
    return json(
      {
        ok: false,
        available: false,
        status:
          "CROC_FUND_HOLDINGS KV binding bulunamadi.",
        symbol,
      },
      500,
    );
  }

  const activePeriod =
    await kv.get("active-period");

  if (!activePeriod) {
    return json({
      ok: true,
      available: false,
      provider: "CLOUDFLARE KV",
      symbol,
      status: "Snapshot henuz olusturulmadi.",
      funds: [],
      mockData: false,
      masterDecisionImpact: false,
    });
  }

  const raw =
    await kv.get(
      `stock:${activePeriod}:${symbol}`,
    );

  if (!raw) {
    return json({
      ok: true,
      available: false,
      provider: "CLOUDFLARE KV",
      symbol,
      activePeriod,
      holderFundCount: 0,
      funds: [],
      coverage: "PRIORITY_150_PARTIAL",
      mockData: false,
      masterDecisionImpact: false,
      updatedAt: new Date().toISOString(),
    });
  }

  let data;

  try {
    data = JSON.parse(raw);
  } catch (_) {
    return json(
      {
        ok: false,
        available: false,
        provider: "CLOUDFLARE KV",
        symbol,
        status: "KV JSON cozumlenemedi.",
      },
      500,
    );
  }

  return json({
    ok: true,
    available: true,
    provider: "CLOUDFLARE KV",
    coverage: "PRIORITY_150_PARTIAL",
    symbol,
    activePeriod,
    holderFundCount:
      data?.holderFundCount ?? 0,
    summary:
      data?.summary ?? null,
    funds:
      Array.isArray(data?.funds)
        ? data.funds
        : [],
    source:
      "CROC FUND HOLDINGS SNAPSHOT",
    apiFetchCount: 0,
    mockData: false,
    masterDecisionImpact: false,
    updatedAt: new Date().toISOString(),
  });
}

async function analyzeFundMovement(
  symbol,
  kv,
) {
  if (!kv) {
    return json(
      {
        ok: false,
        available: false,
        status:
          "CROC_FUND_HOLDINGS KV binding bulunamadi.",
        symbol,
        mockData: false,
        masterDecisionImpact: false,
      },
      500,
    );
  }

  const periodsRaw =
    await kv.get("periods");

  let periods = [];

  try {
    periods =
      periodsRaw
        ? JSON.parse(periodsRaw)
        : [];
  } catch (_) {
    periods = [];
  }

  periods = periods
    .map((item) => String(item || "").trim())
    .filter((item) => /^\d{4}-\d{2}$/.test(item))
    .sort();

  if (periods.length < 2) {
    return json({
      ok: true,
      available: false,
      provider: "CROC KV FUND SNAPSHOTS",
      coverage: "PRIORITY_150_PARTIAL",
      symbol,
      periods,
      reason: "EN_AZ_IKI_DONEM_GEREKLI",
      apiFetchCount: 0,
      mockData: false,
      masterDecisionImpact: false,
    });
  }

  const activePeriod =
    periods[periods.length - 1];

  const previousPeriod =
    periods[periods.length - 2];

  const activeMetaRaw =
    await kv.get(`meta:${activePeriod}`);

  const previousMetaRaw =
    await kv.get(`meta:${previousPeriod}`);

  let activeMeta = null;
  let previousMeta = null;

  try {
    activeMeta =
      activeMetaRaw
        ? JSON.parse(activeMetaRaw)
        : null;

    previousMeta =
      previousMetaRaw
        ? JSON.parse(previousMetaRaw)
        : null;
  } catch (_) {}

  const activeFunds =
    Array.isArray(activeMeta?.activeFunds)
      ? activeMeta.activeFunds
          .map((x) => String(x || "").trim().toUpperCase())
          .filter(Boolean)
      : [];

  const previousFunds =
    Array.isArray(previousMeta?.activeFunds)
      ? previousMeta.activeFunds
          .map((x) => String(x || "").trim().toUpperCase())
          .filter(Boolean)
      : [];

  const previousFundSet =
    new Set(previousFunds);

  const activeFundSet =
    new Set(activeFunds);

  const comparableFunds =
    activeFunds.filter(
      (fundCode) =>
        previousFundSet.has(fundCode),
    );

  const missingInCurrent =
    previousFunds.filter(
      (fundCode) =>
        !activeFundSet.has(fundCode),
    );

  const missingInPrevious =
    activeFunds.filter(
      (fundCode) =>
        !previousFundSet.has(fundCode),
    );

  if (comparableFunds.length === 0) {
    return json({
      ok: true,
      available: false,
      provider: "CROC KV FUND SNAPSHOTS",
      coverage: "PRIORITY_150_PARTIAL",

      symbol,
      previousPeriod,
      activePeriod,

      periodCoverage: {
        previousFundCount:
          previousFunds.length,
        activeFundCount:
          activeFunds.length,
        comparableFundCount: 0,
      },

      reason:
        "ORTAK_FON_SNAPSHOT_YOK",

      dataGuard: {
        missingInCurrent,
        missingInPrevious,
      },

      apiFetchCount: 0,
      mockData: false,
      masterDecisionImpact: false,

      updatedAt:
        new Date().toISOString(),
    });
  }

  const currentRaw =
    await kv.get(
      `stock:${activePeriod}:${symbol}`,
    );

  const previousRaw =
    await kv.get(
      `stock:${previousPeriod}:${symbol}`,
    );

  let currentData = {
    funds: [],
  };

  let previousData = {
    funds: [],
  };

  try {
    if (currentRaw) {
      currentData =
        JSON.parse(currentRaw);
    }

    if (previousRaw) {
      previousData =
        JSON.parse(previousRaw);
    }
  } catch (_) {
    return json(
      {
        ok: false,
        available: false,
        provider: "CROC KV FUND SNAPSHOTS",
        symbol,
        status:
          "KV JSON cozumlenemedi.",
        apiFetchCount: 0,
        mockData: false,
        masterDecisionImpact: false,
      },
      500,
    );
  }

  const currentFunds =
    Array.isArray(currentData?.funds)
      ? currentData.funds
      : [];

  const previousFundsData =
    Array.isArray(previousData?.funds)
      ? previousData.funds
      : [];

  const movements = [];

  for (const fundCode of comparableFunds) {
    const current =
      currentFunds.find(
        (item) =>
          String(item?.fundCode || "")
            .trim()
            .toUpperCase() === fundCode,
      ) || null;

    const previous =
      previousFundsData.find(
        (item) =>
          String(item?.fundCode || "")
            .trim()
            .toUpperCase() === fundCode,
      ) || null;

    // Fon iki donemde de raporlu.
    // Hisse iki donemde de yoksa hareket yok.
    if (!current && !previous) {
      continue;
    }

    const currentNominal =
      Number(current?.nominal || 0);

    const previousNominal =
      Number(previous?.nominal || 0);

    const currentWeight =
      Number(current?.weight || 0);

    const previousWeight =
      Number(previous?.weight || 0);

    const currentValue =
      Number(current?.value || 0);

    const previousValue =
      Number(previous?.value || 0);

    const nominalDelta =
      currentNominal -
      previousNominal;

    const weightDelta =
      currentWeight -
      previousWeight;

    const valueDelta =
      currentValue -
      previousValue;

    let nominalDeltaPct = null;

    if (previousNominal > 0) {
      nominalDeltaPct =
        (nominalDelta /
          previousNominal) *
        100;
    }

    let classification = "NOTR";

    if (!previous && current) {
      classification = "YENI GIRIS";
    } else if (previous && !current) {
      classification = "TAM CIKIS";
    } else {
      // Nominal varsa nominal ana sinyal.
      // Nominal upstream'de 0 ise agirlik degisimi fallback.
      const hasNominalSignal =
        previousNominal > 0 &&
        currentNominal > 0 &&
        nominalDeltaPct !== null;

      if (
        (hasNominalSignal &&
          nominalDeltaPct >= 25) ||
        weightDelta >= 2
      ) {
        classification =
          "AGRESIF ARTIRIM";
      } else if (
        (hasNominalSignal &&
          nominalDeltaPct >= 5) ||
        weightDelta >= 0.5
      ) {
        classification =
          "ARTIRIM";
      } else if (
        (hasNominalSignal &&
          nominalDeltaPct <= -25) ||
        weightDelta <= -2
      ) {
        classification =
          "AGRESIF AZALTIM";
      } else if (
        (hasNominalSignal &&
          nominalDeltaPct <= -5) ||
        weightDelta <= -0.5
      ) {
        classification =
          "AZALTIM";
      }
    }

    movements.push({
      fundCode,

      previous:
        previous
          ? {
              nominal:
                previousNominal,
              weight:
                previousWeight,
              value:
                previousValue,
            }
          : null,

      current:
        current
          ? {
              nominal:
                currentNominal,
              weight:
                currentWeight,
              value:
                currentValue,
            }
          : null,

      delta: {
        nominal:
          nominalDelta,

        nominalPct:
          nominalDeltaPct === null
            ? null
            : Math.round(
                nominalDeltaPct *
                  100,
              ) / 100,

        weight:
          Math.round(
            weightDelta * 1000,
          ) / 1000,

        value:
          valueDelta,
      },

      classification,
    });
  }

  if (movements.length === 0) {
    return json({
      ok: true,
      available: false,

      provider:
        "CROC KV FUND SNAPSHOTS",

      coverage:
        "PRIORITY_150_PARTIAL",

      symbol,
      previousPeriod,
      activePeriod,

      reason:
        "KARSILASTIRILABILIR_HISSE_POZISYONU_YOK",

      periodCoverage: {
        previousFundCount:
          previousFunds.length,
        activeFundCount:
          activeFunds.length,
        comparableFundCount:
          comparableFunds.length,
      },

      comparableFunds,

      dataGuard: {
        missingInCurrent,
        missingInPrevious,
      },

      apiFetchCount: 0,
      mockData: false,
      masterDecisionImpact: false,

      updatedAt:
        new Date().toISOString(),
    });
  }

  const increaseLabels =
    new Set([
      "YENI GIRIS",
      "ARTIRIM",
      "AGRESIF ARTIRIM",
    ]);

  const decreaseLabels =
    new Set([
      "TAM CIKIS",
      "AZALTIM",
      "AGRESIF AZALTIM",
    ]);

  const increaseCount =
    movements.filter(
      (item) =>
        increaseLabels.has(
          item.classification,
        ),
    ).length;

  const decreaseCount =
    movements.filter(
      (item) =>
        decreaseLabels.has(
          item.classification,
        ),
    ).length;

  const neutralCount =
    movements.length -
    increaseCount -
    decreaseCount;

  const newEntryCount =
    movements.filter(
      (item) =>
        item.classification ===
        "YENI GIRIS",
    ).length;

  const exitCount =
    movements.filter(
      (item) =>
        item.classification ===
        "TAM CIKIS",
    ).length;

  const aggressiveIncreaseCount =
    movements.filter(
      (item) =>
        item.classification ===
        "AGRESIF ARTIRIM",
    ).length;

  const aggressiveDecreaseCount =
    movements.filter(
      (item) =>
        item.classification ===
        "AGRESIF AZALTIM",
    ).length;

  const netValueChange =
    movements.reduce(
      (sum, item) =>
        sum +
        Number(
          item?.delta?.value || 0,
        ),
      0,
    );

  const netNominalChange =
    movements.reduce(
      (sum, item) =>
        sum +
        Number(
          item?.delta?.nominal || 0,
        ),
      0,
    );

  const rawConsensus =
    movements.length > 0
      ? 50 +
        (
          (increaseCount -
            decreaseCount) /
          movements.length
        ) *
          50
      : 50;

  const consensusScore =
    Math.max(
      0,
      Math.min(
        100,
        Math.round(rawConsensus),
      ),
    );

  let consensusLabel = "NOTR";

  if (consensusScore >= 75) {
    consensusLabel =
      "GUCLU FON BIRIKIMI";
  } else if (consensusScore >= 60) {
    consensusLabel =
      "FON BIRIKIMI";
  } else if (consensusScore <= 25) {
    consensusLabel =
      "GUCLU FON BOSALTIMI";
  } else if (consensusScore <= 40) {
    consensusLabel =
      "FON BOSALTIMI";
  }

  movements.sort(
    (a, b) =>
      Math.abs(
        Number(b?.delta?.value || 0),
      ) -
      Math.abs(
        Number(a?.delta?.value || 0),
      ),
  );

  return json({
    ok: true,
    available: true,

    provider:
      "CROC KV FUND SNAPSHOTS",

    coverage:
      "PRIORITY_150_PARTIAL",

    symbol,

    previousPeriod,
    activePeriod,

    periodCoverage: {
      previousFundCount:
        previousFunds.length,
      activeFundCount:
        activeFunds.length,
      comparableFundCount:
        comparableFunds.length,
    },

    summary: {
      movementFundCount:
        movements.length,

      increaseCount,
      decreaseCount,
      neutralCount,

      newEntryCount,
      exitCount,

      aggressiveIncreaseCount,
      aggressiveDecreaseCount,

      netValueChange,
      netNominalChange,

      consensusScore,
      consensusLabel,
    },

    movements,

    dataGuard: {
      missingInCurrent,
      missingInPrevious,
    },

    apiFetchCount: 0,

    mockData: false,

    // Henuz Master Decision'a BAGLI DEGIL.
    masterDecisionImpact: false,

    updatedAt:
      new Date().toISOString(),
  });
}

async function refreshPriorityFundPeriod(
  period,
  start,
  limit,
  apiKey,
  kv,
) {
  if (!apiKey) {
    return json(
      {
        ok: false,
        available: false,
        status:
          "FONAPI_KEY Worker secret bulunamadi.",
        mockData: false,
        masterDecisionImpact: false,
      },
      500,
    );
  }

  if (!kv) {
    return json(
      {
        ok: false,
        available: false,
        status:
          "CROC_FUND_HOLDINGS KV binding bulunamadi.",
        mockData: false,
        masterDecisionImpact: false,
      },
      500,
    );
  }

  const universeRaw =
    await kv.get("universe:priority150");

  if (!universeRaw) {
    return json(
      {
        ok: false,
        available: false,
        status:
          "Priority 150 universe bulunamadi.",
      },
      404,
    );
  }

  let universe = null;

  try {
    universe =
      JSON.parse(
        String(universeRaw)
          .replace(/^\uFEFF/, ""),
      );
  } catch (_) {
    return json(
      {
        ok: false,
        available: false,
        status:
          "Priority 150 universe JSON bozuk.",
      },
      500,
    );
  }

  const codes =
    Array.isArray(universe?.codes)
      ? universe.codes
          .map((code) =>
            String(code || "")
              .trim()
              .toUpperCase(),
          )
          .filter(Boolean)
      : [];

  const selected =
    codes.slice(
      start,
      start + limit,
    );

  if (selected.length === 0) {
    return json({
      ok: true,
      available: false,
      reason: "BATCH_BOS",
      period,
      totalUniverse: codes.length,
      start,
      limit,
      apiFetchCount: 0,
      mockData: false,
      masterDecisionImpact: false,
    });
  }

  const stored = [];
  const skipped = [];
  const notPublished = [];
  const failed = [];

  let apiCallCount = 0;
  let quotaStopped = false;
  let stoppedFund = null;

  for (const fundCode of selected) {
    const fundKey =
      `fund:${period}:${fundCode}`;

    const existing =
      await kv.get(fundKey);

    // Bu fon bu donem icin zaten varsa
    // API'ye tekrar gitme.
    if (existing) {
      skipped.push({
        fundCode,
        period,
        reason:
          "TARGET_PERIOD_ALREADY_STORED",
      });

      continue;
    }

    const endpoint =
      `${FONAPI_BASE_URL}/api/funds/` +
      `${encodeURIComponent(fundCode)}` +
      `/holdings?period=${encodeURIComponent(period)}`;

    let response = null;

    try {
      response =
        await fetch(endpoint, {
          method: "GET",
          headers: {
            Accept:
              "application/json",
            Authorization:
              `Bearer ${apiKey}`,
          },
        });

      apiCallCount++;
    } catch (error) {
      failed.push({
        fundCode,
        period,
        status:
          "FETCH_ERROR",
        detail:
          String(
            error?.message || error,
          ),
      });

      continue;
    }

    if (response.status === 429) {
      quotaStopped = true;
      stoppedFund = fundCode;

      failed.push({
        fundCode,
        period,
        status: 429,
        reason:
          "RATE_OR_QUOTA_LIMIT",
      });

      break;
    }

    if (response.status === 401) {
      stoppedFund = fundCode;

      failed.push({
        fundCode,
        period,
        status: 401,
        reason:
          "API_KEY_REJECTED",
      });

      break;
    }

    const raw =
      await response.text();

    let decoded = null;

    try {
      decoded =
        JSON.parse(raw);
    } catch (_) {}

    if (
      !response.ok ||
      decoded?.success !== true ||
      !decoded?.data
    ) {
      notPublished.push({
        fundCode,
        requestedPeriod:
          period,
        status:
          response.status,
        reason:
          "TARGET_PERIOD_NOT_AVAILABLE",
      });

      continue;
    }

    const data =
      decoded.data;

    const returnedPeriod =
      String(
        data?.period || "",
      ).trim();

    // Cok kritik guard:
    // Eylul istedik ama API Agustos dondurduyse
    // Eylul diye KAYDETME.
    if (returnedPeriod !== period) {
      notPublished.push({
        fundCode,
        requestedPeriod:
          period,
        returnedPeriod:
          returnedPeriod || null,
        reason:
          "TARGET_PERIOD_NOT_AVAILABLE",
      });

      continue;
    }

    const items =
      Array.isArray(data?.items)
        ? data.items
        : [];

    const positions = [];

    for (const item of items) {
      if (
        !item ||
        typeof item !== "object"
      ) {
        continue;
      }

      if (
        String(item.type || "")
          .trim()
          .toLowerCase() !==
        "stock"
      ) {
        continue;
      }

      const symbol =
        String(item.symbol || "")
          .trim()
          .toUpperCase();

      if (!symbol) {
        continue;
      }

      const weight =
        safeNumber(
          item.weight,
        );

      const fpdWeight =
        safeNumber(
          item.fpdWeight,
        );

      const value =
        safeNumber(
          item.value,
        );

      const nominal =
        safeNumber(
          item.nominal,
        );

      const meaningful =
        (
          nominal !== null &&
          nominal >= 1
        ) ||
        (
          value !== null &&
          value >= 1000
        ) ||
        (
          weight !== null &&
          weight >= 0.01
        );

      if (!meaningful) {
        continue;
      }

      positions.push({
        fundCode,
        period,
        publishDate:
          data?.publishDate ??
          null,

        symbol,

        name:
          item.name === null ||
          item.name === undefined
            ? null
            : String(item.name),

        isin:
          item.isin === null ||
          item.isin === undefined
            ? null
            : String(item.isin),

        weight,
        fpdWeight,
        value,
        nominal,
      });
    }

    const storedAt =
      new Date().toISOString();

    await kv.put(
      fundKey,
      JSON.stringify({
        fundCode,
        period,

        publishDate:
          data?.publishDate ??
          null,

        positions,

        source:
          "FONAPI / KAP",

        refreshMode:
          "MONTHLY",

        updatedAt:
          storedAt,
      }),
    );

    // Period-bazli marker.
    // Eski period-agnostic marker'a dokunmuyoruz.
    await kv.put(
      `scan:priority150:${period}:${fundCode}`,
      JSON.stringify({
        fundCode,
        period,
        stockCount:
          positions.length,
        status:
          "STORED",
        scannedAt:
          storedAt,
      }),
    );

    stored.push({
      fundCode,
      period,
      stockCount:
        positions.length,
      status:
        "STORED",
    });

    await new Promise(
      (resolve) =>
        setTimeout(
          resolve,
          120,
        ),
    );
  }

  const progress = {
    universe:
      "priority150",

    period,

    totalUniverse:
      codes.length,

    batchStart:
      start,

    batchLimit:
      limit,

    requestedCount:
      selected.length,

    apiCallCount,

    storedCount:
      stored.length,

    skippedCount:
      skipped.length,

    notPublishedCount:
      notPublished.length,

    failedCount:
      failed.length,

    quotaStopped,

    stoppedFund,

    // Kota durduysa AYNI batch'i
    // daha sonra tekrar calistir.
    // Kaydedilenler otomatik skip edilir.
    nextStart:
      quotaStopped
        ? start
        : Math.min(
            start +
              selected.length,
            codes.length,
          ),

    completed:
      !quotaStopped &&
      start +
        selected.length >=
        codes.length,

    updatedAt:
      new Date().toISOString(),
  };

  await kv.put(
    `refresh:${period}:last`,
    JSON.stringify(
      progress,
    ),
  );

  return json({
    ok: true,
    available: true,

    provider:
      "FONAPI / KAP + CLOUDFLARE KV",

    coverage:
      "PRIORITY_150_MONTHLY",

    progress,

    stored,
    skipped,
    notPublished,
    failed,

    mockData: false,
    masterDecisionImpact: false,
  });
}


async function getMonthlyRefreshStatus(
  period,
  kv,
) {
  if (!kv) {
    return json(
      {
        ok: false,
        available: false,
        status:
          "CROC_FUND_HOLDINGS KV binding bulunamadi.",
      },
      500,
    );
  }

  const universeRaw =
    await kv.get(
      "universe:priority150",
    );

  let universe = null;

  try {
    universe =
      universeRaw
        ? JSON.parse(
            String(
              universeRaw,
            ).replace(
              /^\uFEFF/,
              "",
            ),
          )
        : null;
  } catch (_) {}

  const universeCodes =
    Array.isArray(
      universe?.codes,
    )
      ? universe.codes
          .map((code) =>
            String(code || "")
              .trim()
              .toUpperCase(),
          )
          .filter(Boolean)
      : [];

  const universeSet =
    new Set(
      universeCodes,
    );

  const storedCodes = [];

  let cursor =
    undefined;

  do {
    const page =
      await kv.list({
        prefix:
          `fund:${period}:`,
        cursor,
        limit: 1000,
      });

    for (
      const key
      of page.keys || []
    ) {
      const code =
        String(key.name)
          .replace(
            `fund:${period}:`,
            "",
          )
          .trim()
          .toUpperCase();

      if (
        code &&
        universeSet.has(code)
      ) {
        storedCodes.push(
          code,
        );
      }
    }

    if (
      page.list_complete
    ) {
      cursor =
        undefined;
    } else {
      cursor =
        page.cursor;
    }
  } while (cursor);

  const storedSet =
    new Set(
      storedCodes,
    );

  const missingCodes =
    universeCodes.filter(
      (code) =>
        !storedSet.has(code),
    );

  const lastRaw =
    await kv.get(
      `refresh:${period}:last`,
    );

  let last = null;

  try {
    last =
      lastRaw
        ? JSON.parse(lastRaw)
        : null;
  } catch (_) {}

  return json({
    ok: true,
    available: true,

    provider:
      "CLOUDFLARE KV",

    coverage:
      "PRIORITY_150_MONTHLY",

    period,

    universeCount:
      universeCodes.length,

    storedCount:
      storedSet.size,

    missingCount:
      missingCodes.length,

    missingCodes,

    lastRefresh:
      last,

    apiFetchCount: 0,

    mockData: false,
    masterDecisionImpact: false,

    updatedAt:
      new Date().toISOString(),
  });
}

async function buildFundRadarResult(
  symbol,
  kv,
) {
  if (!kv) {
    return json(
      {
        ok: false,
        available: false,
        status:
          "CROC_FUND_HOLDINGS KV binding bulunamadi.",
        symbol,
        mockData: false,
        masterDecisionImpact: false,
      },
      500,
    );
  }

  const activePeriod =
    await kv.get("active-period");

  if (!activePeriod) {
    return json({
      ok: true,
      available: false,
      provider:
        "CROC KV FUND SNAPSHOTS",
      symbol,
      reason:
        "AKTIF_DONEM_YOK",
      apiFetchCount: 0,
      kvWriteCount: 0,
      mockData: false,
      masterDecisionImpact: false,
    });
  }


  // ----------------------------------------------------------
  // HISSE -> FON INDEKSI
  // ----------------------------------------------------------

  const stockRaw =
    await kv.get(
      `stock:${activePeriod}:${symbol}`,
    );

  let stockData = null;

  try {
    stockData =
      stockRaw
        ? JSON.parse(stockRaw)
        : null;
  } catch (_) {
    return json(
      {
        ok: false,
        available: false,
        provider:
          "CROC KV FUND SNAPSHOTS",
        symbol,
        status:
          "STOCK INDEX JSON cozumlenemedi.",
        apiFetchCount: 0,
        kvWriteCount: 0,
        mockData: false,
        masterDecisionImpact: false,
      },
      500,
    );
  }


  // ----------------------------------------------------------
  // PRIORITY 150 COVERAGE
  // ----------------------------------------------------------

  const universeRaw =
    await kv.get(
      "universe:priority150",
    );

  let universe = null;

  try {
    universe =
      universeRaw
        ? JSON.parse(
            String(universeRaw)
              .replace(/^\uFEFF/, ""),
          )
        : null;
  } catch (_) {}

  const universeCodes =
    Array.isArray(universe?.codes)
      ? universe.codes
          .map((code) =>
            String(code || "")
              .trim()
              .toUpperCase(),
          )
          .filter(Boolean)
      : [];

  const universeSet =
    new Set(universeCodes);


  const metaRaw =
    await kv.get(
      `meta:${activePeriod}`,
    );

  let meta = null;

  try {
    meta =
      metaRaw
        ? JSON.parse(metaRaw)
        : null;
  } catch (_) {}

  const activeFunds =
    Array.isArray(meta?.activeFunds)
      ? meta.activeFunds
          .map((code) =>
            String(code || "")
              .trim()
              .toUpperCase(),
          )
          .filter(Boolean)
      : [];

  const scannedPriorityFunds =
    activeFunds.filter(
      (code) =>
        universeSet.has(code),
    );

  const universeCount =
    universeCodes.length;

  const scannedPriorityCount =
    scannedPriorityFunds.length;

  const coveragePct =
    universeCount > 0
      ? Math.round(
          (
            scannedPriorityCount /
            universeCount
          ) *
            1000,
        ) / 10
      : 0;


  // ----------------------------------------------------------
  // HISSE POZISYON OZETI
  // ----------------------------------------------------------

  const funds =
    Array.isArray(stockData?.funds)
      ? stockData.funds
      : [];

  const priorityFunds =
    funds.filter((item) =>
      universeSet.has(
        String(item?.fundCode || "")
          .trim()
          .toUpperCase(),
      ),
    );

  const holderFundCount =
    priorityFunds.length;

  const totalValue =
    priorityFunds.reduce(
      (sum, item) =>
        sum +
        Number(item?.value || 0),
      0,
    );

  const totalNominal =
    priorityFunds.reduce(
      (sum, item) =>
        sum +
        Number(item?.nominal || 0),
      0,
    );

  const averageWeight =
    holderFundCount > 0
      ? priorityFunds.reduce(
            (sum, item) =>
              sum +
              Number(
                item?.weight || 0,
              ),
            0,
          ) /
          holderFundCount
      : 0;


  // ----------------------------------------------------------
  // FON ILGI ETIKETI
  // Sadece urun ici siniflandirma.
  // Yatirim tavsiyesi degildir.
  // ----------------------------------------------------------

  let interestLabel =
    "VERI YOK";

  if (holderFundCount >= 20) {
    interestLabel =
      "GUCLU";
  } else if (
    holderFundCount >= 10
  ) {
    interestLabel =
      "ORTA-GUCLU";
  } else if (
    holderFundCount >= 5
  ) {
    interestLabel =
      "ORTA";
  } else if (
    holderFundCount > 0
  ) {
    interestLabel =
      "SINIRLI";
  }


  // ----------------------------------------------------------
  // EN BUYUK 10 FON
  // ----------------------------------------------------------

  const topFunds =
    [...priorityFunds]
      .sort(
        (a, b) =>
          Number(b?.value || 0) -
          Number(a?.value || 0),
      )
      .slice(0, 10)
      .map((item) => ({
        fundCode:
          item?.fundCode ?? null,

        value:
          Number(
            item?.value || 0,
          ),

        nominal:
          Number(
            item?.nominal || 0,
          ),

        weight:
          Number(
            item?.weight || 0,
          ),

        publishDate:
          item?.publishDate ??
          null,
      }));


  // ----------------------------------------------------------
  // MEVCUT FUND MOVEMENT MOTORUNU OKU
  // Bu fonksiyon da SADECE KV READ yapar.
  // ----------------------------------------------------------

  let movement = null;

  try {
    const movementResponse =
      await analyzeFundMovement(
        symbol,
        kv,
      );

    movement =
      await movementResponse
        .clone()
        .json();
  } catch (_) {
    movement = null;
  }


  const movementAvailable =
    movement?.available === true;

  const movementSummary =
    movementAvailable
      ? movement?.summary ?? null
      : null;

  const movementReason =
    movementAvailable
      ? null
      : (
          movement?.reason ??
          "HAREKET_VERISI_YOK"
        );


  // ----------------------------------------------------------
  // RADAR SONUCU
  // ----------------------------------------------------------

  return json({
    ok: true,

    available:
      holderFundCount > 0,

    provider:
      "CROC KV FUND SNAPSHOTS",

    coverage:
      "PRIORITY_150_PARTIAL",

    symbol,

    activePeriod,

    fundInterest: {
      label:
        interestLabel,

      holderFundCount,

      totalValue,

      totalNominal,

      averageWeight:
        Math.round(
          averageWeight * 1000,
        ) / 1000,
    },

    coverageStatus: {
      universe:
        "PRIORITY_150",

      universeCount,

      scannedPriorityCount,

      missingPriorityCount:
        Math.max(
          0,
          universeCount -
          scannedPriorityCount,
        ),

      coveragePct,

      partial:
        scannedPriorityCount <
        universeCount,
    },

    topFunds,

    aggressiveFundMovement: {
      available:
        movementAvailable,

      previousPeriod:
        movement?.previousPeriod ??
        null,

      activePeriod:
        movement?.activePeriod ??
        activePeriod,

      summary:
        movementSummary,

      reason:
        movementReason,

      periodCoverage:
        movement?.periodCoverage ??
        null,
    },

    dataQuality: {
      mockData: false,

      syntheticData: false,

      apiFetchCount: 0,

      kvWriteCount: 0,

      partialCoverage:
        scannedPriorityCount <
        universeCount,
    },

    // HENUZ MASTER'A ETKI YOK.
    masterDecisionImpact: false,

    updatedAt:
      new Date().toISOString(),
  });
}

function cleanFlowPeriod(value) {
  const raw = String(value || "1A").trim().toUpperCase();

  if (raw === "1A" || raw === "1M") return 1;
  if (raw === "3A" || raw === "3M") return 3;
  if (raw === "6A" || raw === "6M") return 6;
  if (raw === "1Y" || raw === "12A" || raw === "12M") return 12;

  const numeric = Number.parseInt(raw.replace(/[^0-9]/g, ""), 10);

  if ([1, 3, 6, 12].includes(numeric)) {
    return numeric;
  }

  return 1;
}

function parseIsoDate(value) {
  const raw = String(value || "").trim();

  if (!/^\d{4}-\d{2}-\d{2}$/.test(raw)) {
    return null;
  }

  const date = new Date(`${raw}T00:00:00Z`);

  return Number.isNaN(date.getTime()) ? null : date;
}

function shiftMonths(date, months) {
  const result = new Date(date);
  result.setUTCMonth(result.getUTCMonth() - months);
  return result;
}

async function fetchCatalogNearDate(date, maxBackDays = 10) {
  for (let offset = 0; offset <= maxBackDays; offset++) {
    const candidate = new Date(date);
    candidate.setUTCDate(candidate.getUTCDate() - offset);

    const response = await fetchCatalogForDate(formatTefasDate(candidate));

    if (response.items.length > 0) {
      return response;
    }
  }

  return {
    sourceDate: null,
    items: [],
  };
}

function findFundInCatalog(items, fundCode) {
  const code = cleanFundCode(fundCode);

  return (
    items.find(
      (item) => cleanFundCode(item?.fundCode) === code,
    ) || null
  );
}

async function searchFundForDate(fundCode, requestedDate) {
  const rawDate =
    `${requestedDate.slice(0, 4)}-` +
    `${requestedDate.slice(4, 6)}-` +
    `${requestedDate.slice(6, 8)}`;

  const date = parseIsoDate(rawDate);

  if (!date) {
    return json(
      {
        ok: false,
        available: false,
        error: "Gecersiz tarih.",
        mockData: false,
        masterDecisionImpact: false,
      },
      400,
    );
  }

  const catalog = await fetchCatalogNearDate(date, 7);
  const item = findFundInCatalog(catalog.items, fundCode);

  if (!item) {
    return json({
      ok: true,
      available: false,
      provider: "TEFAS",
      fundCode,
      requestedDate,
      sourceDate: catalog.sourceDate,
      result: null,
      status: "Fon ilgili tarih katalogunda bulunamadi.",
      mockData: false,
      masterDecisionImpact: false,
    });
  }

  return json({
    ok: true,
    available: true,
    provider: "TEFAS",
    fundCode: item.fundCode,
    fundName: item.fundName,
    requestedDate,
    sourceDate: catalog.sourceDate,
    result: item,
    mockData: false,
    masterDecisionImpact: false,
    updatedAt: new Date().toISOString(),
  });
}

async function fetchFundFlow(fundCode, periodMonths) {
  const latestCatalog = await getLatestCatalog();

  if (!latestCatalog.available || latestCatalog.items.length === 0) {
    return json(
      {
        ok: false,
        available: false,
        provider: "TEFAS",
        fundCode,
        status: "Guncel TEFAS katalogu alinamadi.",
        mockData: false,
        masterDecisionImpact: false,
      },
      502,
    );
  }

  const endItem = findFundInCatalog(latestCatalog.items, fundCode);

  if (!endItem) {
    return json({
      ok: true,
      available: false,
      provider: "TEFAS",
      fundCode,
      status: "Fon guncel katalogda bulunamadi.",
      mockData: false,
      masterDecisionImpact: false,
    });
  }

  const endDate = parseIsoDate(endItem.date);

  if (!endDate) {
    return json({
      ok: false,
      available: false,
      provider: "TEFAS",
      fundCode,
      status: "Guncel fon tarihi cozumlenemedi.",
      mockData: false,
      masterDecisionImpact: false,
    });
  }

  const targetStartDate = shiftMonths(endDate, periodMonths);
  const startCatalog = await fetchCatalogNearDate(targetStartDate, 10);
  const startItem = findFundInCatalog(startCatalog.items, fundCode);

  if (!startItem) {
    return json({
      ok: true,
      available: false,
      provider: "TEFAS",
      fundCode,
      fundName: endItem.fundName,
      periodMonths,
      status: "Baslangic tarihine ait fon verisi bulunamadi.",
      mockData: false,
      masterDecisionImpact: false,
    });
  }

  const startPrice = Number(startItem.price || 0);
  const endPrice = Number(endItem.price || 0);

  const startPortfolio = Number(startItem.portfolioSize || 0);
  const endPortfolio = Number(endItem.portfolioSize ||0);

  const startInvestors = Number(startItem.investorCount || 0);
  const endInvestors = Number(endItem.investorCount ||0);

  const priceReturnPct =
    startPrice > 0
      ? ((endPrice / startPrice) - 1) * 100
      : null;

  const portfolioChangePct =
    startPortfolio > 0
      ? ((endPortfolio / startPortfolio) - 1) * 100
      : null;

  const investorChangePct =
    startInvestors > 0
      ? ((endInvestors / startInvestors) - 1) * 100
      : null;

  const expectedPortfolioWithoutFlow =
    startPortfolio > 0 && startPrice > 0
      ? startPortfolio * (endPrice / startPrice)
      : null;

  const estimatedNetFlow =
    expectedPortfolioWithoutFlow !== null
      ? endPortfolio - expectedPortfolioWithoutFlow
      : null;

  const estimatedNetFlowPct =
    expectedPortfolioWithoutFlow &&
    expectedPortfolioWithoutFlow > 0 &&
    estimatedNetFlow !== null
      ? (estimatedNetFlow / expectedPortfolioWithoutFlow) * 100
      : null;

  let flowDirection = "VERI YETERSIZ";
  let flowScore = 0;

  if (estimatedNetFlowPct !== null) {
    if (estimatedNetFlowPct >= 10) {
      flowDirection = "GUCLU GIRIS";
      flowScore = 90;
    } else if (estimatedNetFlowPct >= 3) {
      flowDirection = "GIRIS";
      flowScore = 72;
    } else if (estimatedNetFlowPct > -3) {
      flowDirection = "NOTR";
      flowScore = 50;
    } else if (estimatedNetFlowPct > -10) {
      flowDirection = "CIKIS";
      flowScore = 28;
    } else {
      flowDirection = "GUCLU CIKIS";
      flowScore = 10;
    }
  }

  return json({
    ok: true,
    available: true,
    provider: "TEFAS",
    fundCode: endItem.fundCode,
    fundName: endItem.fundName,
    periodMonths,

    start: {
      date: startItem.date,
      price: startItem.price,
      investorCount: startItem.investorCount,
      portfolioSize: startItem.portfolioSize,
    },

    end: {
      date: endItem.date,
      price: endItem.price,
      investorCount: endItem.investorCount,
      portfolioSize: endItem.portfolioSize,
    },

    metrics: {
      priceReturnPct,
      portfolioChangePct,
      investorChangePct,
      estimatedNetFlow,
      estimatedNetFlowPct,
      flowDirection,
      flowScore,
    },

    methodology:
      "EstimatedNetFlow = EndPortfolio - (StartPortfolio * EndPrice / StartPrice)",

    mockData: false,

    // Bu V1 fon-bazli akistir.
    // Hisse Master Decision motoruna bagli DEGIL.
    masterDecisionImpact: false,

    updatedAt: new Date().toISOString(),
  });
}

async function fetchFundFlowSummary(fundCode) {
  const periods = [
    { key: "1A", months: 1, weight: 0.35 },
    { key: "3A", months: 3, weight: 0.30 },
    { key: "6A", months: 6, weight: 0.20 },
    { key: "1Y", months: 12, weight: 0.15 },
  ];

  const payloads = [];

  for (const period of periods) {
    const response = await fetchFundFlow(fundCode, period.months);

    try {
      payloads.push(await response.json());
    } catch (_) {
      payloads.push(null);
    }

    await new Promise((resolve) => setTimeout(resolve, 250));
  }

  const results = {};
  let weightedScore = 0;
  let usedWeight = 0;
  let fundName = null;

  for (let i = 0; i < periods.length; i++) {
    const period = periods[i];
    const payload = payloads[i];

    if (
      payload &&
      payload.ok === true &&
      payload.available === true &&
      payload.metrics &&
      Number.isFinite(Number(payload.metrics.flowScore))
    ) {
      const score = Number(payload.metrics.flowScore);

      weightedScore += score * period.weight;
      usedWeight += period.weight;

      fundName = fundName || payload.fundName || null;

      results[period.key] = {
        available: true,
        periodMonths: period.months,
        weight: period.weight,
        start: payload.start ?? null,
        end: payload.end ?? null,
        metrics: payload.metrics,
      };
    } else {
      results[period.key] = {
        available: false,
        periodMonths: period.months,
        weight: period.weight,
        status:
          payload?.status ||
          payload?.error ||
          "Akis verisi bulunamadi.",
      };
    }
  }

  if (usedWeight <= 0) {
    return json({
      ok: true,
      available: false,
      provider: "TEFAS",
      fundCode,
      fundName,
      status: "Fund Flow Summary icin yeterli veri yok.",
      periods: results,
      mockData: false,
      masterDecisionImpact: false,
      updatedAt: new Date().toISOString(),
    });
  }

  const rawScore = weightedScore / usedWeight;
  const score = Math.round(rawScore * 10) / 10;

  let direction = "NOTR";
  if (score >= 80) {
    direction = "GUCLU GIRIS";
  } else if (score >= 60) {
    direction = "GIRIS";
  } else if (score >= 40) {
    direction = "NOTR";
  } else if (score >= 25) {
    direction = "CIKIS";
  } else {
    direction = "GUCLU CIKIS";
  }

  let trendLabel = "NOTR";
  if (score >= 80) {
    trendLabel = "COK GUCLU";
  } else if (score >= 60) {
    trendLabel = "GUCLU";
  } else if (score >= 40) {
    trendLabel = "NOTR";
  } else if (score >= 25) {
    trendLabel = "ZAYIF";
  } else {
    trendLabel = "COK ZAYIF";
  }

  return json({
    ok: true,
    available: true,
    provider: "TEFAS",
    fundCode,
    fundName,
    score,
    direction,
    trendLabel,
    weights: {
      "1A": 0.35,
      "3A": 0.30,
      "6A": 0.20,
      "1Y": 0.15,
    },
    periods: results,
    methodology:
      "CROC Fund Flow Score = 1A*0.35 + 3A*0.30 + 6A*0.20 + 1Y*0.15",
    mockData: false,
    masterDecisionImpact: false,
    updatedAt: new Date().toISOString(),
  });
}

function normalizeCatalogItem(item) {
  if (!item || typeof item !== "object") {
    return null;
  }

  const fundCode = String(item.fonKodu ?? "").trim().toUpperCase();
  const fundName = String(item.fonUnvan ?? "").trim();
  const date = String(item.tarih ?? "").trim();

  if (!fundCode || !fundName) {
    return null;
  }

  return {
    fundCode,
    fundName,
    date: date || null,
    price: safeNumber(item.fiyat),
    investorCount: safeInteger(item.kisiSayisi),
    portfolioSize: safeNumber(item.portfoyBuyukluk),
    isFreeFund: normalizeSearchText(fundName).includes("SERBEST"),
  };
}

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

  const fundCode = String(
    item.fonKodu ?? item.FONKODU ?? item.code ?? "",
  )
    .trim()
    .toUpperCase();

  const fundName = String(
    item.fonUnvan ?? item.FONUNVAN ?? item.title ?? "",
  ).trim();

  return {
    date: String(date),
    price,
    fundCode,
    fundName: fundName || null,
  };
}

function tefasHeaders() {
  return {
    Accept: "application/json, text/plain, */*",
    "Content-Type": "application/json",
    "User-Agent":
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/152.0.0.0 Safari/537.36",
    Referer: "https://www.tefas.gov.tr/tr/fon-verileri",
    Origin: "https://www.tefas.gov.tr",
  };
}

function normalizeSearchText(value) {
  return String(value || "")
    .trim()
    .toLocaleUpperCase("tr-TR")
    .replace(/Ã„Â°/g, "I")
    .replace(/Ã…Å“/g, "U")
    .replace(/Ãƒâ€“/g, "O")
    .replace(/Ãƒâ€¡/g, "C");
}

function cleanSearchQuery(value) {
  return String(value || "").trim().slice(0, 80);
}

function cleanLimit(value) {
  const parsed = Number.parseInt(String(value || "15"), 10);
  if (!Number.isFinite(parsed)) return 15;
  return Math.min(50, Math.max(1, parsed));
}

function formatTefasDate(date) {
  const year = date.getUTCFullYear().toString();
  const month = (date.getUTCMonth() + 1).toString().padStart(2, "0");
  const day = date.getUTCDate().toString().padStart(2,"0");
  return `${year}${month}${day}`;
}

function safeNumber(value) {
  const parsed = parseNumber(value);
  return Number.isFinite(parsed) ? parsed : null;
}

function safeInteger(value) {
  const parsed = Number.parseInt(String(value ?? ""), 10);
  return Number.isFinite(parsed) ? parsed : null;
}

function parseNumber(value) {
  if (typeof value === "number") {
    return value;
  }

  if (typeof value !== "string") {
    return Number.NaN;
  }

  const normalized = value
    .trim()
    .replace(/\./g, "")
    .replace(",", ".");

  return Number.parseFloat(normalized);
}

function cleanFundCode(value) {
  const code = String(value || "")
    .trim()
    .toUpperCase();

  return /^[A-Z0-9]{2,10}$/.test(code) ? code : "";
}

function cleanPeriod(value) {
  const parsed = Number.parseInt(String(value || "12"), 10);

  if (!Number.isFinite(parsed)) {
    return 12;
  }

  return Math.min(60, Math.max(1, parsed));
}

function json(payload, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: CORS_HEADERS,
  });
}












