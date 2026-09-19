var worker_default = {
  async fetch(request, env) {
    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
      "Content-Type": "application/json; charset=UTF-8"
    };

    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    try {
      const url = new URL(request.url);

      const symbol = (
        url.searchParams.get("symbol") || "ASELS.IS"
      ).toUpperCase().trim();

      const mode = (
        url.searchParams.get("mode") || "market"
      ).toLowerCase().trim();

      if (!/^[A-Z0-9._=\^-]+$/.test(symbol)) {
        return new Response(
          JSON.stringify({
            ok: false,
            error: "GeÃ§ersiz sembol"
          }),
          {
            status: 400,
            headers: corsHeaders
          }
        );
      }

      // =========================================================
      // CROC V41 - RESMI MKK / KAP MODU
      // =========================================================
      if (mode === "kap") {
        const kapResult = await handleKapMode(url, env);

        return new Response(
          JSON.stringify(kapResult),
          {
            status: kapResult.ok ? 200 : (kapResult.statusCode || 502),
            headers: corsHeaders
          }
        );
      }

      // =========================================================
      // CANLI HABER MODU
      // =========================================================
      if (mode === "news") {
        const newsResult = await fetchYahooNews(symbol);

        return new Response(
          JSON.stringify(newsResult),
          {
            status: newsResult.ok ? 200 : 502,
            headers: corsHeaders
          }
        );
      }

      // =========================================================
      // MARKET MODU
      // =========================================================
      const range = url.searchParams.get("range") || "6mo";
      const interval = url.searchParams.get("interval") || "1d";

      const yahooUrl =
        `https://query1.finance.yahoo.com/v8/finance/chart/` +
        `${encodeURIComponent(symbol)}` +
        `?range=${encodeURIComponent(range)}` +
        `&interval=${encodeURIComponent(interval)}` +
        `&includePrePost=false&events=div%2Csplits`;

      const yahooResponse = await fetch(
        yahooUrl,
        {
          headers: yahooHeaders()
        }
      );

      const body = await yahooResponse.text();

      if (!yahooResponse.ok) {
        return new Response(
          JSON.stringify({
            ok: false,
            provider: "Yahoo Finance",
            symbol,
            status: yahooResponse.status,
            error: body
          }),
          {
            status: yahooResponse.status,
            headers: corsHeaders
          }
        );
      }

      const decoded = JSON.parse(body);
      const result = decoded?.chart?.result?.[0];

      if (!result) {
        return new Response(
          JSON.stringify({
            ok: false,
            provider: "Yahoo Finance",
            symbol,
            error: "Veri bulunamadÄ±"
          }),
          {
            status: 404,
            headers: corsHeaders
          }
        );
      }

      const timestamps = result.timestamp || [];
      const quote = result.indicators?.quote?.[0] || {};
      const adjclose =
        result.indicators?.adjclose?.[0]?.adjclose || [];

      const candles = timestamps
        .map((ts, i) => ({
          timestamp: ts,
          open: quote.open?.[i] ?? null,
          high: quote.high?.[i] ?? null,
          low: quote.low?.[i] ?? null,
          close: quote.close?.[i] ?? null,
          adjClose:
            adjclose?.[i] ??
            quote.close?.[i] ??
            null,
          volume: quote.volume?.[i] ?? null
        }))
        .filter((x) => x.close !== null);

      const meta = result.meta || {};

      const last =
        candles.length > 0
          ? candles[candles.length - 1]
          : null;

      const previous =
        candles.length > 1
          ? candles[candles.length - 2]
          : null;

      // CROC BIST:
      // Gunluk degisim Yahoo chartPreviousClose alanindan ALINMAZ.
      // Son mum bugunun canli mumudur.
      // Referans = bir onceki tamamlanmis gunluk mum kapanisi.
      const livePrice =
        meta.regularMarketPrice ??
        last?.close ??
        null;

      let previousSessionClose =
        previous?.close ?? null;

      // CROC V50.6 PREVIOUS SESSION FALLBACK
      // CROC_V50_6_INTRADAY_FALLBACK_START
      //
      // Yahoo BIST 1d serisinde bazen timestamp mevcut oldugu halde
      // OHLC degerleri null gelebiliyor. Candle parser bu satiri
      // elediginde eski bir seans "previous close" sanilabiliyor.
      //
      // Ham daily response icinde son gecerli gunden once null OHLC
      // seansi gorursek 1h Yahoo meta.previousClose ile referansi onar.

      if (interval === "1d") {
        try {
          const rawTimestamps = result?.timestamp ?? [];
          const rawQuote =
            result?.indicators?.quote?.[0] ?? null;

          let lastValidRawIndex = -1;

          if (rawQuote && rawTimestamps.length > 0) {
            for (let i = rawTimestamps.length - 1; i >= 0; i--) {
              const rawClose = rawQuote?.close?.[i];

              if (
                rawClose != null &&
                Number.isFinite(Number(rawClose))
              ) {
                lastValidRawIndex = i;
                break;
              }
            }
          }

          let hasMissingSessionBeforeLast = false;

          if (lastValidRawIndex > 0 && rawQuote) {
            for (let i = lastValidRawIndex - 1; i >= 0; i--) {
              const rawTs = rawTimestamps[i];

              if (rawTs == null) {
                continue;
              }

              const rawOpen = rawQuote?.open?.[i];
              const rawHigh = rawQuote?.high?.[i];
              const rawLow = rawQuote?.low?.[i];
              const rawClose = rawQuote?.close?.[i];

              const allOhlcMissing =
                rawOpen == null &&
                rawHigh == null &&
                rawLow == null &&
                rawClose == null;

              if (allOhlcMissing) {
                hasMissingSessionBeforeLast = true;
                break;
              }

              // Ilk gecerli onceki seansa geldik.
              break;
            }
          }

          if (hasMissingSessionBeforeLast) {
            const intradayParams =
              new URLSearchParams({
                range: "5d",
                interval: "1h",
                includePrePost: "false",
                events: "div,splits"
              });

            const intradayUrl =
              `https://query1.finance.yahoo.com/v8/finance/chart/${encodeURIComponent(symbol)}?${intradayParams.toString()}`;

            const intradayResponse =
              await fetch(intradayUrl, {
                headers: {
                  "User-Agent": "Mozilla/5.0",
                  "Accept": "application/json,text/plain,*/*"
                }
              });

            if (intradayResponse.ok) {
              const intradayJson =
                await intradayResponse.json();

              const intradayResult =
                intradayJson?.chart?.result?.[0];

              const fallbackPreviousClose =
                Number(intradayResult?.meta?.previousClose);

              if (
                Number.isFinite(fallbackPreviousClose) &&
                fallbackPreviousClose > 0
              ) {
                previousSessionClose =
                  fallbackPreviousClose;
              }
            }
          }
        } catch (_) {
          // Fallback hata verirse ana market endpoint'i bozulmaz.
          // Mevcut daily previousSessionClose korunur.
        }
      }

      // CROC_V50_6_INTRADAY_FALLBACK_END

      let changePercent = null;

      if (
        livePrice != null &&
        previousSessionClose != null &&
        previousSessionClose != 0
      ) {
        changePercent =
          ((livePrice - previousSessionClose) /
            previousSessionClose) *
          100;
      }

      return new Response(
        JSON.stringify({
          ok: true,
          provider: "CROC DATA GATEWAY / Yahoo Finance",
          symbol,
          currency: meta.currency ?? "TRY",
          exchange: meta.exchangeName ?? null,
          price: livePrice,
          previousClose: previousSessionClose,
          changePercent,
          marketTime: meta.regularMarketTime ?? null,
          candles
        }),
        {
          status: 200,
          headers: corsHeaders
        }
      );
    } catch (e) {
      return new Response(
        JSON.stringify({
          ok: false,
          error: String(e)
        }),
        {
          status: 500,
          headers: corsHeaders
        }
      );
    }
  }
};


// ===============================================================
// YAHOO NEWS
// ===============================================================

async function fetchYahooNews(symbol) {
  const cleanSymbol = symbol.replace(".IS", "");

  const targetSymbols = new Set([
    symbol.toUpperCase(),
    cleanSymbol.toUpperCase(),
    `${cleanSymbol}.IS`.toUpperCase()
  ]);

  const params = new URLSearchParams({
    q: symbol,
    quotesCount: "1",
    newsCount: "20",
    enableFuzzyQuery: "false",
    quotesQueryId: "tss_match_phrase_query",
    multiQuoteQueryId: "multi_quote_single_token_query",
    newsQueryId: "news_cie_vespa",
    enableCb: "false",
    enableNavLinks: "false",
    enableEnhancedTrivialQuery: "true",
    enableResearchReports: "false"
  });

  const yahooUrl =
    `https://query2.finance.yahoo.com/v1/finance/search?${params.toString()}`;

  const response = await fetch(
    yahooUrl,
    {
      headers: yahooHeaders()
    }
  );

  const raw = await response.text();

  if (!response.ok) {
    return {
      ok: false,
      mode: "news",
      provider: "Yahoo Finance News",
      symbol: cleanSymbol,
      available: false,
      score: 0,
      sentiment: "VERÄ° YOK",
      articleCount: 0,
      status: `Yahoo News HTTP ${response.status}`,
      headlines: []
    };
  }

  let decoded;

  try {
    decoded = JSON.parse(raw);
  } catch (_) {
    return {
      ok: false,
      mode: "news",
      provider: "Yahoo Finance News",
      symbol: cleanSymbol,
      available: false,
      score: 0,
      sentiment: "VERÄ° YOK",
      articleCount: 0,
      status: "Yahoo News JSON Ã§Ã¶zÃ¼mlenemedi",
      headlines: []
    };
  }

  const incoming =
    Array.isArray(decoded?.news)
      ? decoded.news
      : [];

  const nowSeconds =
    Math.floor(Date.now() / 1000);

  const sevenDays =
    7 * 24 * 60 * 60;

  const articles = incoming
    .map((item) => {
      const timestamp =
        Number(item?.providerPublishTime ?? 0);

      const title =
        String(item?.title ?? "").trim();

      const publisher =
        String(item?.publisher ?? "").trim();

      const link =
        String(item?.link ?? "").trim();

      const relatedTickers =
        Array.isArray(item?.relatedTickers)
          ? item.relatedTickers.map(
              (ticker) =>
                String(ticker)
                  .toUpperCase()
                  .trim()
            )
          : [];

      return {
        title,
        publisher,
        link,
        timestamp,
        relatedTickers
      };
    })
    .filter((item) => {
      if (!item.title) {
        return false;
      }

      if (
        item.timestamp > 0 &&
        nowSeconds - item.timestamp > sevenDays
      ) {
        return false;
      }

      const symbolMatch =
        item.relatedTickers.some(
          (ticker) =>
            targetSymbols.has(ticker)
        );

      if (!symbolMatch) {
        return false;
      }

      return true;
    })
    .slice(0, 10);

  if (articles.length === 0) {
    return {
      ok: true,
      mode: "news",
      provider:
        "CROC DATA GATEWAY / Yahoo Finance News",
      symbol: cleanSymbol,
      available: false,
      score: 0,
      sentiment: "VERÄ° BEKLENÄ°YOR",
      articleCount: 0,
      updatedAt: new Date().toISOString(),
      status:
        "Son 7 gÃ¼nde sembolle eÅŸleÅŸen haber bulunamadÄ±",
      headlines: []
    };
  }

  const scored =
    articles.map((article) => {
      const headlineScore =
        scoreHeadline(article.title);

      const ageHours =
        article.timestamp > 0
          ? Math.max(
              0,
              (nowSeconds - article.timestamp) / 3600
            )
          : 168;

      const freshness =
        ageHours <= 12
          ? 1.00
          : ageHours <= 24
          ? 0.90
          : ageHours <= 48
          ? 0.78
          : ageHours <= 72
          ? 0.65
          : 0.50;

      return {
        ...article,
        headlineScore,
        freshness
      };
    });

  let weightedTotal = 0;
  let totalWeight = 0;

  for (const item of scored) {
    weightedTotal +=
      item.headlineScore *
      item.freshness;

    totalWeight += item.freshness;
  }

  const average =
    totalWeight > 0
      ? weightedTotal / totalWeight
      : 50;

  const score =
    Math.max(
      1,
      Math.min(
        99,
        Math.round(average)
      )
    );

  const sentiment =
    score >= 75
      ? "GÃœÃ‡LÃœ POZÄ°TÄ°F"
      : score >= 60
      ? "POZÄ°TÄ°F"
      : score >= 45
      ? "NÃ–TR"
      : score >= 30
      ? "NEGATÄ°F"
      : "GÃœÃ‡LÃœ NEGATÄ°F";

  return {
    ok: true,
    mode: "news",
    provider:
      "CROC DATA GATEWAY / Yahoo Finance News",
    symbol: cleanSymbol,
    available: true,
    score,
    sentiment,
    articleCount: scored.length,
    updatedAt: new Date().toISOString(),
    status:
      `${scored.length} eÅŸleÅŸen haber analiz edildi`,
    headlines:
      scored.map((item) => ({
        title: item.title,
        publisher: item.publisher,
        link: item.link,
        publishedAt:
          item.timestamp > 0
            ? new Date(
                item.timestamp * 1000
              ).toISOString()
            : null,
        relatedTickers: item.relatedTickers,
        headlineScore:
          Math.round(item.headlineScore)
      }))
  };
}


// ===============================================================
// HABER SENTIMENT
// ===============================================================

function scoreHeadline(rawTitle) {
  const title =
    normalizeText(rawTitle);

  let score = 50;

  const strongPositive = [
    "rekor",
    "record",
    "strong growth",
    "beats expectations",
    "expectations beat",
    "new contract",
    "wins contract",
    "siparis aldi",
    "sozlesme imzaladi",
    "ihale kazandi",
    "kar artisi",
    "net kar artti",
    "temettu",
    "dividend",
    "upgrade",
    "hedef fiyat artirdi"
  ];

  const positive = [
    "artis",
    "yukselis",
    "buy",
    "positive",
    "growth",
    "profit",
    "kar",
    "siparis",
    "sozlesme",
    "yatirim",
    "investment",
    "ihracat",
    "export",
    "anlasma",
    "agreement",
    "guclu",
    "strong"
  ];

  const strongNegative = [
    "fraud",
    "iflas",
    "bankruptcy",
    "default",
    "sorusturma",
    "investigation",
    "ceza",
    "sanction",
    "downgrade",
    "zarar acikladi",
    "net zarar",
    "temerrut"
  ];

  const negative = [
    "dusuk",
    "dusus",
    "decline",
    "fall",
    "sell",
    "negative",
    "loss",
    "zarar",
    "risk",
    "baski",
    "pressure",
    "iptal",
    "cancel",
    "gecikme",
    "delay"
  ];

  for (const phrase of strongPositive) {
    if (title.includes(phrase)) {
      score += 12;
    }
  }

  for (const phrase of positive) {
    if (title.includes(phrase)) {
      score += 5;
    }
  }

  for (const phrase of strongNegative) {
    if (title.includes(phrase)) {
      score -= 14;
    }
  }

  for (const phrase of negative) {
    if (title.includes(phrase)) {
      score -= 6;
    }
  }

  return Math.max(
    15,
    Math.min(
      85,
      score
    )
  );
}


function normalizeText(value) {
  return String(value ?? "")
    .toLocaleLowerCase("tr-TR")
    .normalize("NFD")
    .replace(
      /[\u0300-\u036f]/g,
      ""
    )
    .replace(/Ä±/g, "i")
    .replace(/ÅŸ/g, "s")
    .replace(/ÄŸ/g, "g")
    .replace(/Ã¼/g, "u")
    .replace(/Ã¶/g, "o")
    .replace(/Ã§/g, "c");
}


function yahooHeaders() {
  return {
    "User-Agent":
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) " +
      "AppleWebKit/537.36 Chrome/150 Safari/537.36",

    "Accept":
      "application/json,text/plain,*/*"
  };
}
// ===============================================================
// CROC V41 - MKK / KAP INTELLIGENCE
// Cloudflare Secrets: MKK_API_KEY + MKK_API_SECRET
// ===============================================================

const MKK_KAP_BASE =
  "https://apigwdev.mkk.com.tr/api/vyk";


async function handleKapMode(url, env) {
  const action =
    String(
      url.searchParams.get("action") || "status"
    )
      .toLowerCase()
      .trim();

  if (!env?.MKK_API_KEY || !env?.MKK_API_SECRET) {
    return {
      ok: false,
      mode: "kap",
      provider: "MKK / KAP",
      statusCode: 500,
      error:
        "MKK_API_KEY veya MKK_API_SECRET Cloudflare Secret bulunamadÄ±."
    };
  }

  try {

    // =========================================================
    // STATUS
    // =========================================================

    if (action === "status") {
      const latest =
        await mkkGet(
          "/lastDisclosureIndex",
          env
        );

      return {
        ok: true,
        mode: "kap",
        action: "status",
        provider:
          "CROC DATA GATEWAY / MKK KAP",
        lastDisclosureIndex:
          String(
            latest?.lastDisclosureIndex ?? ""
          ),
        updatedAt:
          new Date().toISOString()
      };
    }


    // =========================================================
    // MEMBERS
    // =========================================================

    if (action === "members") {
      const members =
        await mkkGet(
          "/members",
          env
        );

      const list =
        Array.isArray(members)
          ? members
          : [];

      return {
        ok: true,
        mode: "kap",
        action: "members",
        provider:
          "CROC DATA GATEWAY / MKK KAP",

        count:
          list.length,

        members:
          list.map((item) => ({
            id:
              String(item?.id ?? ""),

            title:
              String(item?.title ?? ""),

            stockCode:
              String(item?.stockCode ?? ""),

            memberType:
              String(item?.memberType ?? ""),

            kfifUrl:
              String(item?.kfifUrl ?? "")
          })),

        updatedAt:
          new Date().toISOString()
      };
    }


    // =========================================================
    // MEMBER DETAIL
    // =========================================================

    if (action === "member-detail") {
      const id =
        String(
          url.searchParams.get("id") || ""
        ).trim();

      if (!/^\d{1,10}$/.test(id)) {
        return {
          ok: false,
          mode: "kap",
          action: "member-detail",
          statusCode: 400,
          error:
            "member-detail iÃ§in geÃ§erli id gerekli."
        };
      }

      const detail =
        await mkkGet(
          `/memberDetail/${encodeURIComponent(id)}`,
          env
        );
        const profile =
  parseMemberProfile(detail);
        try {
        const profileCacheKey =
          new Request(
            `https://profile-cache.croc.internal/member/${encodeURIComponent(id)}`,
            {
              method: "GET"
            }
          );

        const profileCache =
          caches.default;

        await profileCache.put(
          profileCacheKey,
          new Response(
            JSON.stringify(profile),
            {
              status: 200,
              headers: {
                "Content-Type":
                  "application/json",
                "Cache-Control":
                  "public, max-age=21600"
              }
            }
          )
        );
      } catch (_) {
        // Profil cache'e yazÄ±lamasa bile member-detail Ã§alÄ±ÅŸmaya devam eder.
      }

      return {
        ok: true,
        mode: "kap",
        action: "member-detail",
        provider:
          "CROC DATA GATEWAY / MKK KAP",
        id,
profile,
detail,
        updatedAt:
          new Date().toISOString()
      };
    }


    // =========================================================
    // LATEST
    // =========================================================

    if (action === "latest") {
      const latest =
        await mkkGet(
          "/lastDisclosureIndex",
          env
        );

      const lastIndex =
        String(
          latest?.lastDisclosureIndex ?? ""
        ).trim();

      if (!lastIndex) {
        return {
          ok: false,
          mode: "kap",
          statusCode: 502,
          error:
            "MKK son bildirim numarasÄ±nÄ± vermedi."
        };
      }

      const rows =
        await mkkGet(
          `/disclosures?disclosureIndex=${encodeURIComponent(lastIndex)}`,
          env
        );

      const items =
        Array.isArray(rows)
          ? rows
          : [];

      if (items.length === 0) {
        return {
          ok: false,
          mode: "kap",
          statusCode: 404,
          error:
            "Son KAP bildirimi bulunamadÄ±."
        };
      }

      const item =
        items[0];

      const disclosureIndex =
        String(
          item?.disclosureIndex ?? lastIndex
        );

      const subReport =
        Array.isArray(item?.subReportIds)
          ? String(
              item.subReportIds[0] || ""
            )
          : "";

      const params =
        new URLSearchParams({
          fileType: "html"
        });

      if (subReport) {
        params.set(
          "subReportList",
          subReport
        );
      }

      const detail =
        await mkkGet(
          `/disclosureDetail/${encodeURIComponent(disclosureIndex)}?${params.toString()}`,
          env
        );

      const parsed =
        parseKapDetail(detail);

      return {
        ok: true,
        mode: "kap",
        action: "latest",
        provider:
          "CROC DATA GATEWAY / MKK KAP",
        ...parsed
      };
    }


    // =========================================================
    // LATEST STOCK
    // =========================================================

    if (action === "latest-stock") {
      const latest =
        await mkkGet(
          "/lastDisclosureIndex",
          env
        );

      const lastIndex =
        Number(
          latest?.lastDisclosureIndex ?? 0
        );

      if (
        !Number.isFinite(lastIndex) ||
        lastIndex <= 0
      ) {
        return {
          ok: false,
          mode: "kap",
          statusCode: 502,
          error:
            "MKK son bildirim numarasÄ±nÄ± vermedi."
        };
      }

      const startIndex =
        Math.max(
          1,
          lastIndex - 49
        );

      const rows =
        await mkkGet(
          `/disclosures?disclosureIndex=${startIndex}`,
          env
        );

      const incoming =
        Array.isArray(rows)
          ? rows
          : [];

      const candidates =
        incoming
          .filter((item) => {
            const index =
              Number(
                item?.disclosureIndex ?? 0
              );

            if (
              !Number.isFinite(index) ||
              index > lastIndex
            ) {
              return false;
            }

            if (
              String(
                item?.disclosureClass ?? ""
              ).toUpperCase() !== "ODA"
            ) {
              return false;
            }

            if (
              item?.fundId != null ||
              item?.fundCode != null
            ) {
              return false;
            }

            const companyId =
              String(
                item?.companyId ?? ""
              );

            if (companyId === "51") {
              return false;
            }

            const title =
              normalizeText(
                item?.title ?? ""
              );

            if (
              title.includes(
                "kamuyu aydinlatma platformu"
              ) ||
              title.includes(
                "sermaye piyasasi kurulu"
              )
            ) {
              return false;
            }

            const subReports =
              Array.isArray(
                item?.subReportIds
              )
                ? item.subReportIds
                : [];

            const hasTestReport =
              subReports.some(
                (id) =>
                  normalizeText(id)
                    .includes(
                      "testnotification"
                    )
              );

            if (hasTestReport) {
              return false;
            }

            return true;
          })
          .sort(
            (a, b) =>
              Number(
                b?.disclosureIndex ?? 0
              ) -
              Number(
                a?.disclosureIndex ?? 0
              )
          );

      if (candidates.length === 0) {
        return {
          ok: false,
          mode: "kap",
          action: "latest-stock",
          statusCode: 404,
          error:
            "Son 50 KAP indexi iÃ§inde gerÃ§ek ÅŸirket ODA bildirimi bulunamadÄ±."
        };
      }

      const item =
        candidates[0];

      const disclosureIndex =
        String(
          item?.disclosureIndex ?? ""
        );

      const subReport =
        Array.isArray(
          item?.subReportIds
        )
          ? String(
              item.subReportIds[0] || ""
            )
          : "";

      const params =
        new URLSearchParams({
          fileType: "html"
        });

      if (subReport) {
        params.set(
          "subReportList",
          subReport
        );
      }

            const detail =
        await mkkGet(
          `/disclosureDetail/${encodeURIComponent(disclosureIndex)}?${params.toString()}`,
          env
        );

      const parsed =
        parseKapDetail(detail);

      // =========================================================
      // CROC COMPANY PROFILE
      // =========================================================

      let companyProfile = null;

      const companyId =
        String(
          item?.companyId ?? ""
        ).trim();

      if (/^\d{1,10}$/.test(companyId)) {
  try {
    const profileCacheKey =
      new Request(
        `https://profile-cache.croc.internal/member/${encodeURIComponent(companyId)}`,
        {
          method: "GET"
        }
      );

    const profileCache =
      caches.default;

    const cachedProfileResponse =
      await profileCache.match(
        profileCacheKey
      );

    if (cachedProfileResponse) {
      const cachedProfileText =
        await cachedProfileResponse.text();

      if (cachedProfileText.trim()) {
        companyProfile =
          JSON.parse(
            cachedProfileText
          );
      }
    }

  } catch (_) {
    companyProfile = null;
  }
  }


      return {
        ok: true,
        mode: "kap",
        action: "latest-stock",
        provider:
          "CROC DATA GATEWAY / MKK KAP",

        scan: {
          lastDisclosureIndex:
            String(lastIndex),

          startDisclosureIndex:
            String(startIndex),

          received:
            incoming.length,

          stockCandidates:
            candidates.length
        },

        companyId,
        companyProfile,

        ...parsed
      };
    }

    // =========================================================
    // FEED
    // =========================================================

    if (action === "feed") {
      const from =
        String(
          url.searchParams.get("from") ||
          url.searchParams.get(
            "disclosureIndex"
          ) ||
          ""
        ).trim();

      if (!/^\d{1,10}$/.test(from)) {
        return {
          ok: false,
          mode: "kap",
          statusCode: 400,
          error:
            "feed iÃ§in geÃ§erli from/disclosureIndex gerekli."
        };
      }

      const rows =
        await mkkGet(
          `/disclosures?disclosureIndex=${encodeURIComponent(from)}`,
          env
        );

      const items =
        (
          Array.isArray(rows)
            ? rows
            : []
        ).map((item) => ({
          disclosureIndex:
            String(
              item?.disclosureIndex ?? ""
            ),

          disclosureType:
            String(
              item?.disclosureType ?? ""
            ),

          disclosureClass:
            String(
              item?.disclosureClass ?? ""
            ),

          subReportIds:
            Array.isArray(
              item?.subReportIds
            )
              ? item.subReportIds.map(
                  String
                )
              : [],

          title:
            String(
              item?.title ?? ""
            ),

          companyId:
            String(
              item?.companyId ?? ""
            ),

          fundId:
            item?.fundId != null
              ? String(item.fundId)
              : null,

          fundCode:
            item?.fundCode != null
              ? String(item.fundCode)
              : null,

          acceptedDataFileTypes:
            Array.isArray(
              item?.acceptedDataFileTypes
            )
              ? item.acceptedDataFileTypes.map(
                  String
                )
              : []
        }));

      return {
        ok: true,
        mode: "kap",
        action: "feed",
        provider:
          "CROC DATA GATEWAY / MKK KAP",
        from,
        count:
          items.length,
        items,
        updatedAt:
          new Date().toISOString()
      };
    }


    // =========================================================
    // DETAIL
    // =========================================================

    if (action === "detail") {
      const index =
        String(
          url.searchParams.get("index") ||
          url.searchParams.get(
            "disclosureIndex"
          ) ||
          ""
        ).trim();

      const fileType =
        String(
          url.searchParams.get(
            "fileType"
          ) || "html"
        ).trim();

      const subReport =
        String(
          url.searchParams.get(
            "subReport"
          ) ||
          url.searchParams.get(
            "subReportList"
          ) ||
          ""
        ).trim();

      if (!/^\d{1,10}$/.test(index)) {
        return {
          ok: false,
          mode: "kap",
          statusCode: 400,
          error:
            "detail iÃ§in geÃ§erli index/disclosureIndex gerekli."
        };
      }

      const params =
        new URLSearchParams({
          fileType
        });

      if (subReport) {
        params.set(
          "subReportList",
          subReport
        );
      }

      const detail =
        await mkkGet(
          `/disclosureDetail/${encodeURIComponent(index)}?${params.toString()}`,
          env
        );

      const parsed =
        parseKapDetail(detail);

      return {
        ok: true,
        mode: "kap",
        action: "detail",
        provider:
          "CROC DATA GATEWAY / MKK KAP",
        ...parsed
      };
    }


    // =========================================================
    // BÄ°LÄ°NMEYEN ACTION
    // =========================================================

    return {
      ok: false,
      mode: "kap",
      statusCode: 400,
      error:
        `Bilinmeyen KAP action: ${action}`
    };

  } catch (error) {
    const statusCode =
      Number(
        error?.statusCode
      ) || 502;

    return {
      ok: false,
      mode: "kap",
      provider:
        "MKK / KAP",
      statusCode,
      error:
        String(
          error?.message ||
          error
        )
    };
  }
}

// ===============================================================
// MKK GET
// ===============================================================

async function mkkGet(path, env) {
  const apiKey =
    String(
      env?.MKK_API_KEY || ""
    ).trim();

  const apiSecret =
    String(
      env?.MKK_API_SECRET || ""
    ).trim();

  if (!apiKey || !apiSecret) {
    const error =
      new Error(
        "MKK_API_KEY veya MKK_API_SECRET Cloudflare Secret bulunamadÄ±."
      );

    error.statusCode = 500;
    throw error;
  }

  // =========================================================
  // CROC MKK CACHE
  // =========================================================

  const now = Date.now();

  let ttlSeconds = 60;

  if (path.includes("/lastDisclosureIndex")) {
    ttlSeconds = 20;
  } else if (path.includes("/disclosures?")) {
    ttlSeconds = 60;
  } else if (path.includes("/disclosureDetail/")) {
    ttlSeconds = 300;
  }

  // ---------------------------------------------------------
  // 1) HIZLI MEMORY CACHE
  // ---------------------------------------------------------

  if (!globalThis.__CROC_MKK_CACHE__) {
    globalThis.__CROC_MKK_CACHE__ =
      new Map();
  }

  const memoryCache =
    globalThis.__CROC_MKK_CACHE__;

  const memoryItem =
    memoryCache.get(path);

  if (
    memoryItem &&
    memoryItem.expiresAt > now
  ) {
    return memoryItem.data;
  }

  // SÃ¼resi geÃ§miÅŸse temizle
  if (memoryItem) {
    memoryCache.delete(path);
  }

  // ---------------------------------------------------------
  // 2) CLOUDFLARE EDGE CACHE
  // ---------------------------------------------------------

  const cacheKey =
    new Request(
      `https://mkk-cache.croc.internal${path}`,
      {
        method: "GET"
      }
    );

  try {
    const cache =
      caches.default;

    const cachedResponse =
      await cache.match(cacheKey);

    if (cachedResponse) {
      const cachedText =
        await cachedResponse.text();

      if (cachedText.trim()) {
        const cachedData =
          JSON.parse(cachedText);

        memoryCache.set(
          path,
          {
            data: cachedData,
            expiresAt:
              now + ttlSeconds * 1000
          }
        );

        return cachedData;
      }
    }
  } catch (_) {
    // Preview ortamÄ±nda cache Ã§alÄ±ÅŸmazsa
    // MKK isteÄŸine normal ÅŸekilde devam et.
  }

  // =========================================================
  // MKK BASIC AUTH
  // =========================================================

  const credentials =
    `${apiKey}:${apiSecret}`;

  const bytes =
    new TextEncoder().encode(
      credentials
    );

  let binary = "";

  for (const byte of bytes) {
    binary +=
      String.fromCharCode(byte);
  }

  const authorization =
    `Basic ${btoa(binary)}`;

  // =========================================================
  // MKK REQUEST
  // =========================================================

  const response =
    await fetch(
      `${MKK_KAP_BASE}${path}`,
      {
        method: "GET",
        headers: {
          "Accept":
            "application/json",

          "Content-Type":
            "application/json",

          "Authorization":
            authorization
        }
      }
    );

  const raw =
    await response.text();

  // =========================================================
  // HATA
  // =========================================================

  if (!response.ok) {
    const error =
      new Error(
        `MKK KAP HTTP ${response.status}: ${raw.slice(0, 600)}`
      );

    error.statusCode =
      response.status;

    throw error;
  }

  if (!raw.trim()) {
    return null;
  }

  // =========================================================
  // JSON
  // =========================================================

  let data;

  try {
    data =
      JSON.parse(raw);

  } catch (_) {
    const error =
      new Error(
        "MKK KAP yanÄ±tÄ± JSON olarak Ã§Ã¶zÃ¼mlenemedi."
      );

    error.statusCode = 502;

    throw error;
  }

  // =========================================================
  // MEMORY CACHE'E YAZ
  // =========================================================

  memoryCache.set(
    path,
    {
      data,
      expiresAt:
        now + ttlSeconds * 1000
    }
  );

  // =========================================================
  // CLOUDFLARE CACHE'E YAZ
  // =========================================================

  try {
    const cache =
      caches.default;

    const cacheResponse =
      new Response(
        JSON.stringify(data),
        {
          status: 200,
          headers: {
            "Content-Type":
              "application/json",

            "Cache-Control":
              `public, max-age=${ttlSeconds}`
          }
        }
      );

    await cache.put(
      cacheKey,
      cacheResponse
    );

  } catch (_) {
    // Cache yazÄ±lamasa bile uygulama Ã§alÄ±ÅŸmaya devam eder.
  }

  return data;
}


// ===============================================================
// KAP DETAIL PARSER
// ===============================================================

function parseKapDetail(detail) {
  const subject =
    String(
      detail?.subject?.tr ??
      detail?.subject?.en ??
      ""
    ).trim();

  const summary =
    String(
      detail?.summary?.tr ??
      detail?.summary?.en ??
      ""
    ).trim();

  const symbol =
    Array.isArray(
      detail?.senderExchCodes
    )
      ? String(
          detail.senderExchCodes[0] || ""
        )
      : "";

  const htmlMessages =
    Array.isArray(
      detail?.htmlMessages
    )
      ? detail.htmlMessages
      : [];

  const decodedReports =
    htmlMessages.map((message) => {
      const base64 =
        String(
          message?.tr ||
          message?.en ||
          ""
        ).trim();

      const html =
        base64
          ? decodeBase64Utf8(base64)
          : "";

      return {
        id:
          String(
            message?.id || ""
          ),

        text:
          htmlToPlainText(html)
      };
    });

  const reportText =
    decodedReports
      .map(
        (item) => item.text
      )
      .filter(Boolean)
      .join("\n\n");

  const analysisText =
    [
      subject,
      summary,
      reportText
    ]
      .filter(Boolean)
      .join(" ");

  const impact =
    scoreKapImpact(
      analysisText,
      subject
    );

  const amounts =
    extractMoneyAmounts(
      analysisText
    );

  return {
    disclosureIndex:
      String(
        detail?.disclosureIndex ?? ""
      ),

    symbol,

    senderId:
      String(
        detail?.senderId ?? ""
      ),

    senderTitle:
      String(
        detail?.senderTitle ?? ""
      ),

    disclosureReason:
      String(
        detail?.disclosureReason ?? ""
      ),

    disclosureType:
      String(
        detail?.disclosureType ?? ""
      ),

    disclosureClass:
      String(
        detail?.disclosureClass ?? ""
      ),

    subject,
    summary,

    time:
      String(
        detail?.time ?? ""
      ),

    link:
      String(
        detail?.link ?? ""
      ),

    attachmentUrls:
      Array.isArray(
        detail?.attachmentUrls
      )
        ? detail.attachmentUrls.map(
            String
          )
        : [],

    reports:
      decodedReports,

    plainText:
      reportText,

    amounts,

    impact,

    updatedAt:
      new Date().toISOString()
  };
}
function parseMemberProfile(detail) {
  const rows =
    Array.isArray(detail)
      ? detail
      : [];

  const getByKey = (key) =>
    rows.find(
      (item) =>
        String(item?.key || "") === key
    )?.value ?? null;

  const parseNumberTr = (value) => {
    if (value == null) {
      return null;
    }

    const text =
      String(value)
        .replace(/\./g, "")
        .replace(",", ".")
        .trim();

    const number =
      Number(text);

    return Number.isFinite(number)
      ? number
      : null;
  };

  const sector =
    String(
      getByKey("kpy41_acc2_sektor") || ""
    ).trim();

  const market =
    String(
      getByKey("kpy41_acc3_sermaye_arac_pazar") || ""
    ).trim();

  const indices =
    String(
      getByKey("kpy41_acc3_endeksler") || ""
    ).trim();

  const paidInCapital =
    parseNumberTr(
      getByKey("kpy41_acc5_odenmis_sermaye")
    );

  const authorizedCapital =
    parseNumberTr(
      getByKey("kpy41_acc5_kayitli_sermaye_tavani")
    );

  const shareholdersRaw =
    getByKey(
      "kpy41_acc5_sermayede_dogrudan"
    );

  const shareholders =
    Array.isArray(shareholdersRaw)
      ? shareholdersRaw
      : [];

  const realShareholders =
    shareholders.filter((item) => {
      const name =
        normalizeText(
          item?.shareholder || ""
        );

      return (
        name &&
        name !== "toplam" &&
        name !== "diger"
      );
    });

  const mainShareholder =
    realShareholders
      .map((item) => ({
        name:
          String(
            item?.shareholder || ""
          ).trim(),

        ratio:
          parseNumberTr(
            item?.ratioInCapital
          )
      }))
      .filter(
        (item) =>
          item.name &&
          item.ratio != null
      )
      .sort(
        (a, b) =>
          b.ratio - a.ratio
      )[0] || null;

  return {
    sector,
    market,
    paidInCapital,
    authorizedCapital,

    bist30:
      indices.includes("BIST 30"),

    bist50:
      indices.includes("BIST 50"),

    bist100:
      indices.includes("BIST 100"),

    indices,

    mainShareholder:
      mainShareholder?.name || "",

    mainShareholderRatio:
      mainShareholder?.ratio ?? null
  };
}

// ===============================================================
// BASE64 -> UTF8
// ===============================================================

function decodeBase64Utf8(value) {
  try {
    const binary =
      atob(value);

    const bytes =
      Uint8Array.from(
        binary,
        (char) =>
          char.charCodeAt(0)
      );

    return new TextDecoder(
      "utf-8"
    ).decode(bytes);

  } catch (_) {
    return "";
  }
}


// ===============================================================
// HTML -> TEMIZ METIN
// ===============================================================

function htmlToPlainText(html) {
  if (!html) {
    return "";
  }

  return decodeHtmlEntities(
    String(html)
      .replace(
        /<style[\s\S]*?<\/style>/gi,
        " "
      )
      .replace(
        /<script[\s\S]*?<\/script>/gi,
        " "
      )
      .replace(
        /<br\s*\/?>/gi,
        "\n"
      )
      .replace(
        /<\/(p|div|tr|li|h[1-6]|table)>/gi,
        "\n"
      )
      .replace(
        /<[^>]+>/g,
        " "
      )
      .replace(
        /[ \t]+/g,
        " "
      )
      .replace(
        /\n[ \t]+/g,
        "\n"
      )
      .replace(
        /\n{3,}/g,
        "\n\n"
      )
      .trim()
  );
}


function decodeHtmlEntities(value) {
  return String(value)
    .replace(/&nbsp;/gi, " ")
    .replace(/&amp;/gi, "&")
    .replace(/&quot;/gi, '"')
    .replace(/&#39;/gi, "'")
    .replace(/&lt;/gi, "<")
    .replace(/&gt;/gi, ">");
}


// ===============================================================
// PARA TUTARLARINI BUL
// ===============================================================

function extractMoneyAmounts(rawText) {
  const text =
    String(rawText || "");

  const normalized =
    normalizeText(text);

  const result = [];

  const regex =
    /(\d{1,3}(?:[.\s]\d{3})*(?:,\d+)?|\d+(?:[.,]\d+)?)\s*(bin|milyon|milyar)?\s*(abd\s*dolar[iÄ±]?|usd|us\$|eur|euro|tl|try|â‚º)/gi;

  let match;

  while (
    (match = regex.exec(normalized)) !== null
  ) {
    const rawNumber =
      String(match[1] || "")
        .trim();

    const scaleText =
      String(match[2] || "")
        .trim();

    const currencyText =
      String(match[3] || "")
        .trim();

    // ---------------------------------------------------------
    // SAYIYI NORMALIZE ET
    // ---------------------------------------------------------

    let numericText =
      rawNumber
        .replace(/\s/g, "");

    // TÃ¼rkÃ§e sayÄ± biÃ§imi:
    // 65,87  -> 65.87
    // 1.250,50 -> 1250.50
    if (
      numericText.includes(",") &&
      numericText.includes(".")
    ) {
      numericText =
        numericText
          .replace(/\./g, "")
          .replace(",", ".");
    } else if (
      numericText.includes(",")
    ) {
      numericText =
        numericText.replace(",", ".");
    } else {
      // 1.250.000 gibi binlik ayÄ±rÄ±cÄ±larÄ± temizle.
      const dotCount =
        (numericText.match(/\./g) || [])
          .length;

      if (dotCount > 1) {
        numericText =
          numericText.replace(/\./g, "");
      }
    }

    const baseValue =
      Number(numericText);

    if (
      !Number.isFinite(baseValue) ||
      baseValue <= 0
    ) {
      continue;
    }

    // ---------------------------------------------------------
    // Ã–LÃ‡EK
    // ---------------------------------------------------------

    let multiplier = 1;
    let scale = "BÄ°RÄ°M";

    if (scaleText === "bin") {
      multiplier = 1_000;
      scale = "BÄ°N";
    } else if (scaleText === "milyon") {
      multiplier = 1_000_000;
      scale = "MÄ°LYON";
    } else if (scaleText === "milyar") {
      multiplier = 1_000_000_000;
      scale = "MÄ°LYAR";
    }

    const value =
      baseValue * multiplier;

    // ---------------------------------------------------------
    // PARA BÄ°RÄ°MÄ°
    // ---------------------------------------------------------

    let currency = "";

    if (
      currencyText === "usd" ||
      currencyText === "us$" ||
      currencyText.includes("abd dolar")
    ) {
      currency = "USD";
    } else if (
      currencyText === "eur" ||
      currencyText === "euro"
    ) {
      currency = "EUR";
    } else if (
      currencyText === "tl" ||
      currencyText === "try" ||
      currencyText === "â‚º"
    ) {
      currency = "TRY";
    }

    if (!currency) {
      continue;
    }

    const raw =
      `${match[1]}${scaleText ? " " + scaleText : ""} ${match[3]}`
        .replace(/\s+/g, " ")
        .trim();

    const item = {
      raw,
      value,
      currency,
      scale
    };

    const duplicate =
      result.some(
        (x) =>
          x.value === item.value &&
          x.currency === item.currency
      );

    if (!duplicate) {
      result.push(item);
    }

    if (result.length >= 10) {
      break;
    }
  }

  return result;
}


// ===============================================================
// CROC KAP ETKI PUANI
// ===============================================================

function scoreKapImpact(rawText, subject) {
  const text = normalizeText(
    `${subject || ""} ${rawText || ""}`
  );

  let score = 50;

  const reasons = [];
  const eventTypes = [];

  const addReason = (reason) => {
    if (
      reason &&
      !reasons.includes(reason)
    ) {
      reasons.push(reason);
    }
  };

  const addEvent = (event) => {
    if (
      event &&
      !eventTypes.includes(event)
    ) {
      eventTypes.push(event);
    }
  };

  const hasAny = (phrases) =>
    phrases.some(
      (phrase) =>
        text.includes(
          normalizeText(phrase)
        )
    );

  // =========================================================
  // PARASAL BÃœYÃœKLÃœK
  // =========================================================

  const detectedAmounts =
    extractMoneyAmounts(rawText);

  const tryAmounts =
    detectedAmounts
      .filter(
        (item) =>
          item.currency === "TRY"
      )
      .sort(
        (a, b) =>
          b.value - a.value
      );

  const strongestTryAmount =
    tryAmounts.length > 0
      ? tryAmounts[0]
      : null;

  let moneyBonus = 0;
  let moneyLevel = "YOK";

  if (strongestTryAmount) {
    const value =
      strongestTryAmount.value;

    if (value >= 1_000_000_000) {
      moneyBonus = 10;
      moneyLevel = "Ã‡OK YÃœKSEK";
    } else if (value >= 250_000_000) {
      moneyBonus = 8;
      moneyLevel = "YÃœKSEK";
    } else if (value >= 50_000_000) {
      moneyBonus = 5;
      moneyLevel = "ORTA-YÃœKSEK";
    } else if (value >= 10_000_000) {
      moneyBonus = 3;
      moneyLevel = "ORTA";
    } else if (value >= 1_000_000) {
      moneyBonus = 1;
      moneyLevel = "DÃœÅÃœK";
    }
  }

  // Para bonusu sadece ekonomik olarak pozitif olaylarda uygulanacak.
  let allowPositiveMoneyBonus = false;

  // =========================================================
  // BAÄLAM
  // =========================================================

  const isInvestorRelations =
    hasAny([
      "yatÄ±rÄ±mcÄ± iliÅŸkileri",
      "yatirimci iliskileri",
      "investor relations"
    ]);

  const isExecutiveDeparture =
    hasAny([
      "gÃ¶revinden ayrÄ±l",
      "gorevinden ayril",
      "istifa",
      "istifaen",
      "resignation",
      "resign"
    ]);

  // =========================================================
  // YENÄ° Ä°Å
  // =========================================================

  if (
    hasAny([
      "yeni iÅŸ iliÅŸkisi",
      "yeni is iliskisi",
      "yeni iÅŸ anlaÅŸmasÄ±"
    ])
  ) {
    score += 15;
    allowPositiveMoneyBonus = true;

    addEvent(
      "YENÄ° Ä°Å Ä°LÄ°ÅKÄ°SÄ°"
    );

    addReason(
      "Yeni iÅŸ iliÅŸkisi"
    );
  }

  // =========================================================
  // SÃ–ZLEÅME
  // =========================================================

  if (
    hasAny([
      "sÃ¶zleÅŸme imzalandÄ±",
      "sozlesme imzalandi",
      "sÃ¶zleÅŸme imzalanmÄ±ÅŸtÄ±r",
      "sozlesme imzalanmistir",
      "sÃ¶zleÅŸme bedeli",
      "sozlesme bedeli"
    ])
  ) {
    score += 15;
    allowPositiveMoneyBonus = true;

    addEvent(
      "YENÄ° SÃ–ZLEÅME"
    );

    addReason(
      "Yeni sÃ¶zleÅŸme"
    );
  }

  // =========================================================
  // Ä°HALE
  // =========================================================

  if (
    hasAny([
      "ihale kazan",
      "ihalenin uhdesinde",
      "ihale uhdesinde",
      "ihale sonucu ÅŸirketimiz lehine"
    ])
  ) {
    score += 16;
    allowPositiveMoneyBonus = true;

    addEvent(
      "Ä°HALE KAZANIMI"
    );

    addReason(
      "Ä°hale kazanÄ±mÄ±"
    );
  }

  if (
    hasAny([
      "ihale iptal",
      "ihalenin iptali",
      "ihale iptal edildi"
    ])
  ) {
    score -= 15;

    addEvent(
      "Ä°HALE Ä°PTALÄ°"
    );

    addReason(
      "Ä°hale iptali"
    );
  }

  // =========================================================
  // SÄ°PARÄ°Å
  // =========================================================

  if (
    hasAny([
      "yeni sipariÅŸ",
      "yeni siparis",
      "sipariÅŸ alÄ±nmÄ±ÅŸtÄ±r",
      "siparis alinmistir",
      "sipariÅŸ aldÄ±",
      "siparis aldi"
    ])
  ) {
    score += 13;
    allowPositiveMoneyBonus = true;

    addEvent(
      "YENÄ° SÄ°PARÄ°Å"
    );

    addReason(
      "Yeni sipariÅŸ"
    );
  }

  if (
    hasAny([
      "sipariÅŸ iptal",
      "siparis iptal",
      "sipariÅŸin iptali"
    ])
  ) {
    score -= 15;

    addEvent(
      "SÄ°PARÄ°Å Ä°PTALÄ°"
    );

    addReason(
      "SipariÅŸ iptali"
    );
  }

  // =========================================================
  // Ä°HRACAT
  // =========================================================

  if (
    hasAny([
      "ihracat sÃ¶zleÅŸmesi",
      "ihracat sozlesmesi",
      "ihracat anlaÅŸmasÄ±",
      "ihracat anlasmasi",
      "yurt dÄ±ÅŸÄ± satÄ±ÅŸ sÃ¶zleÅŸmesi",
      "yurt disi satis sozlesmesi"
    ])
  ) {
    score += 10;
    allowPositiveMoneyBonus = true;

    addEvent(
      "Ä°HRACAT"
    );

    addReason(
      "Ä°hracat anlaÅŸmasÄ±"
    );
  }

  // =========================================================
  // YATIRIM
  // =========================================================

  if (
    !isInvestorRelations &&
    hasAny([
      "yatÄ±rÄ±m kararÄ±",
      "yatirim karari",
      "yeni yatÄ±rÄ±m",
      "yeni yatirim",
      "yatÄ±rÄ±m projesi",
      "yatirim projesi",
      "yatÄ±rÄ±m teÅŸvik",
      "yatirim tesvik"
    ])
  ) {
    score += 9;

    addEvent(
      "YATIRIM"
    );

    addReason(
      "Yeni yatÄ±rÄ±m"
    );
  }

  // =========================================================
  // KAPASÄ°TE / ÃœRETÄ°M
  // =========================================================

  if (
    hasAny([
      "kapasite artÄ±ÅŸÄ±",
      "kapasite artisi",
      "kapasite artÄ±rÄ±mÄ±",
      "kapasite artirimi"
    ])
  ) {
    score += 10;

    addEvent(
      "KAPASÄ°TE ARTIÅI"
    );

    addReason(
      "Kapasite artÄ±ÅŸÄ±"
    );
  }

  if (
    hasAny([
      "yeni fabrika",
      "yeni tesis",
      "Ã¼retime baÅŸlan",
      "uretime baslan",
      "Ã¼retim tesisi"
    ])
  ) {
    score += 10;

    addEvent(
      "ÃœRETÄ°M YATIRIMI"
    );

    addReason(
      "Ãœretim yatÄ±rÄ±mÄ±"
    );
  }

  // =========================================================
  // TEMETTÃœ
  // =========================================================

  if (
    hasAny([
      "kar payÄ± daÄŸÄ±tÄ±m",
      "kar payi dagitim",
      "temettÃ¼",
      "temettu"
    ])
  ) {
    score += 8;

    addEvent(
      "TEMETTÃœ"
    );

    addReason(
      "TemettÃ¼"
    );
  }

  // =========================================================
  // SERMAYE
  // =========================================================

  if (
    hasAny([
      "bedelsiz sermaye",
      "bedelsiz artÄ±rÄ±m",
      "bedelsiz artirim",
      "iÃ§ kaynaklardan sermaye artÄ±rÄ±mÄ±",
      "ic kaynaklardan sermaye artirimi"
    ])
  ) {
    score += 8;

    addEvent(
      "BEDELSÄ°Z SERMAYE"
    );

    addReason(
      "Bedelsiz sermaye artÄ±rÄ±mÄ±"
    );
  }

  if (
    hasAny([
      "bedelli sermaye",
      "bedelli artÄ±rÄ±m",
      "bedelli artirim",
      "nakit sermaye artÄ±rÄ±mÄ±",
      "nakit sermaye artirimi"
    ])
  ) {
    score -= 5;

    addEvent(
      "BEDELLÄ° SERMAYE"
    );

    addReason(
      "Bedelli sermaye artÄ±rÄ±mÄ±"
    );
  }

  // =========================================================
  // PAY GERÄ° ALIM
  // =========================================================

  if (
    hasAny([
      "pay geri alÄ±m",
      "pay geri alim",
      "hisse geri alÄ±m",
      "hisse geri alim"
    ])
  ) {
    score += 7;

    addEvent(
      "PAY GERÄ° ALIMI"
    );

    addReason(
      "Pay geri alÄ±mÄ±"
    );
  }

  // =========================================================
  // BORÃ‡
  // =========================================================

  if (
    hasAny([
      "borÃ§ kapatÄ±ldÄ±",
      "borc kapatildi",
      "borÃ§ Ã¶dendi",
      "borc odendi",
      "kredi borcu kapat"
    ])
  ) {
    score += 8;

    addEvent(
      "BORÃ‡ AZALIÅI"
    );

    addReason(
      "BorÃ§ azalmasÄ±"
    );
  }

  if (
    hasAny([
      "temerrÃ¼t",
      "temerrut",
      "Ã¶deme gÃ¼Ã§lÃ¼ÄŸÃ¼",
      "odeme guclugu"
    ])
  ) {
    score -= 20;

    addEvent(
      "Ã–DEME RÄ°SKÄ°"
    );

    addReason(
      "Ã–deme riski"
    );
  }

  // =========================================================
  // FÄ°NANSAL SONUÃ‡
  // =========================================================

  if (
    hasAny([
      "net kar arttÄ±",
      "net kar artti",
      "kar artÄ±ÅŸÄ±",
      "kar artisi",
      "rekor kar"
    ])
  ) {
    score += 12;

    addEvent(
      "KÃ‚R ARTIÅI"
    );

    addReason(
      "KÃ¢r artÄ±ÅŸÄ±"
    );
  }

  if (
    hasAny([
      "net zarar",
      "dÃ¶nem zararÄ±",
      "donem zarari",
      "zarar artÄ±ÅŸÄ±",
      "zarar artisi"
    ])
  ) {
    score -= 12;

    addEvent(
      "FÄ°NANSAL ZARAR"
    );

    addReason(
      "Finansal zarar"
    );
  }

  // =========================================================
  // YÃ–NETÄ°M
  // =========================================================

  if (isExecutiveDeparture) {
    score -= 5;

    addEvent(
      "YÃ–NETÄ°CÄ° AYRILIÄI"
    );

    addReason(
      "YÃ¶netici ayrÄ±lÄ±ÄŸÄ±"
    );
  }

  // =========================================================
  // HUKUK / CEZA
  // =========================================================

  if (
    hasAny([
      "dava aÃ§Ä±ldÄ±",
      "dava acildi",
      "dava konusu",
      "hukuki sÃ¼reÃ§",
      "hukuki surec",
      "mahkeme"
    ])
  ) {
    score -= 7;

    addEvent(
      "HUKUKÄ° SÃœREÃ‡"
    );

    addReason(
      "Hukuki sÃ¼reÃ§"
    );
  }

  if (
    hasAny([
      "idari para cezasÄ±",
      "idari para cezasi",
      "ceza uygulan",
      "para cezasÄ±",
      "para cezasi"
    ])
  ) {
    score -= 12;

    addEvent(
      "CEZA"
    );

    addReason(
      "Ceza"
    );
  }

  if (
    hasAny([
      "soruÅŸturma",
      "sorusturma",
      "inceleme baÅŸlat",
      "inceleme baslat"
    ])
  ) {
    score -= 10;

    addEvent(
      "SORUÅTURMA"
    );

    addReason(
      "SoruÅŸturma"
    );
  }

  // =========================================================
  // FESÄ°H / DURMA / Ä°FLAS
  // =========================================================

  if (
    hasAny([
      "sÃ¶zleÅŸme feshi",
      "sozlesme feshi",
      "sÃ¶zleÅŸme feshedildi",
      "sozlesme feshedildi"
    ])
  ) {
    score -= 16;

    addEvent(
      "SÃ–ZLEÅME FESHÄ°"
    );

    addReason(
      "SÃ¶zleÅŸme feshi"
    );
  }

  if (
    hasAny([
      "faaliyet durdur",
      "Ã¼retim durdur",
      "uretim durdur",
      "fabrika kapat"
    ])
  ) {
    score -= 20;

    addEvent(
      "FAALÄ°YET DURMASI"
    );

    addReason(
      "Faaliyet/Ã¼retim durmasÄ±"
    );
  }

  if (
    hasAny([
      "iflas",
      "konkordato"
    ])
  ) {
    score -= 30;

    addEvent(
      "FÄ°NANSAL SIKINTI"
    );

    addReason(
      "Finansal sÄ±kÄ±ntÄ±"
    );
  }

  // =========================================================
  // PARA BONUSUNU EN SON UYGULA
  // =========================================================

  let appliedMoneyBonus = 0;

  if (
    allowPositiveMoneyBonus &&
    strongestTryAmount &&
    moneyBonus > 0
  ) {
    appliedMoneyBonus =
      moneyBonus;

    score +=
      appliedMoneyBonus;

    addReason(
      `Parasal bÃ¼yÃ¼klÃ¼k: ${moneyLevel}`
    );
  }

  // =========================================================
  // SONUÃ‡
  // =========================================================

  score = Math.max(
    0,
    Math.min(
      100,
      Math.round(score)
    )
  );

  let sentiment = "NÃ–TR";

  if (score >= 80) {
    sentiment =
      "GÃœÃ‡LÃœ POZÄ°TÄ°F";
  } else if (score >= 60) {
    sentiment =
      "POZÄ°TÄ°F";
  } else if (score >= 45) {
    sentiment =
      "NÃ–TR";
  } else if (score >= 30) {
    sentiment =
      "NEGATÄ°F";
  } else {
    sentiment =
      "GÃœÃ‡LÃœ NEGATÄ°F";
  }

  let importance =
    "ORTA";

  const distance =
    Math.abs(
      score - 50
    );

  if (distance >= 25) {
    importance =
      "YÃœKSEK";
  } else if (distance <= 5) {
    importance =
      "DÃœÅÃœK";
  }

  return {
    score,
    sentiment,
    importance,

    eventTypes:
      eventTypes.slice(0, 5),

    reasons:
      reasons.slice(0, 6),

    moneyImpact: {
      detected:
        detectedAmounts.length > 0,

      strongestTryAmount:
        strongestTryAmount,

      level:
        strongestTryAmount
          ? moneyLevel
          : "YOK",

      bonus:
        appliedMoneyBonus
    }
  };
}
export {
  worker_default as default
};           


