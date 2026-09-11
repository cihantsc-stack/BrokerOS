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

const CATALOG_CACHE_TTL_MS = 15 * 60 * 1000;
let catalogCache = {
  expiresAt: 0,
  sourceDate: null,
  items: [],
};

export default {
  async fetch(request) {
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
          version: "V2.1",
          provider: "TEFAS",
          supportedActions: ["health", "history", "search"],
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

      return json(
        {
          ok: false,
          available: false,
          error: "Bilinmeyen action.",
          supportedActions: ["health", "history", "search"],
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

  const candidates = buildCatalogDateCandidates();

  for (const tefasDate of candidates) {
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

function buildCatalogDateCandidates() {
  const result = [];
  const seen = new Set();
  const now = new Date();

  for (let offset = 0; offset <= 10; offset++) {
    const date = new Date(
      Date.UTC(
        now.getUTCFullYear(),
        now.getUTCMonth(),
        now.getUTCDate() - offset,
      ),
    );
    const value = formatTefasDate(date);
    if (!seen.has(value)) {
      seen.add(value);
      result.push(value);
    }
  }

  // 2026-09-10: live-tested TEFAS publication date in this project.
  // This is a bounded fallback only; normal operation always tries recent dates first.
  if (!seen.has("20260910")) {
    result.push("20260910");
  }

  return result;
}

async function fetchCatalogForDate(tefasDate) {
  const body = JSON.stringify({
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
      "Mozilla/5.0 (compatible; CROC-Fund-Gateway/2.1; +https://crocai.workers.dev)",
    Referer: "https://www.tefas.gov.tr/tr/fon-verileri",
    Origin: "https://www.tefas.gov.tr",
  };
}

function normalizeSearchText(value) {
  return String(value || "")
    .trim()
    .toLocaleUpperCase("tr-TR")
    .replace(/İ/g, "I")
    .replace(/Ş/g, "S")
    .replace(/Ğ/g, "G")
    .replace(/Ü/g, "U")
    .replace(/Ö/g, "O")
    .replace(/Ç/g, "C");
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
  const day = date.getUTCDate().toString().padStart(2, "0");
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
