# CROC signal report reference — 2026-09-28

User-provided screenshot of end-of-day group report. This is an **example/reference**, not an independently audited or backtested dataset.

- BIST XU100 daily: -2.38%; XU030 daily: -1.87%.
- Signals (score 80+): 12, covering 11 stocks; 12 entry-eligible.
- Average plan return excluding costs: -0.39%.
- TP1 touched: 4/12; TP2: 0; stopped: 8/12.
- Hypothetical close-only average: -3.14%; 4/12 positive.
- Report assumptions: entry at signal price; sell half at TP1 and move remaining stop to entry; 0.75-unit trailing stop for remaining half toward TP2; close any open remainder at session close; 1-minute candles; stop triggered when low touches threshold; commissions and slippage excluded.
- Important: TP1 touch is **not** the same as profitable full-position close. Outcomes depend on execution ordering and candle resolution. Duplicate symbol MIATK has two distinct signals at 10:17 and 17:18.
- Notable examples: MIATK 10:17 plan +1.80% vs close-only -12.03%; MIATK 17:18 plan -2.69%; ODAS 10:13 stop 10:24; KUYAS 10:20 stop 10:25.
- Use this as a **report-layout and accounting specification**, never as proof of future performance or representative win rate. Distinguish report plan outcome from realized brokerage execution.
