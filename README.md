# Revenue & Retention Analytics

A reproducible consulting-style portfolio project using **Python, pandas, SQL, DuckDB and matplotlib**.

**Business question:** What share of sales comes from second and subsequent orders, which customer groups come back, and which actions do the data support?

[Executive summary](reports/executive-summary.md) | [SQL models](sql) | [Methodology](docs/methodology.md) | [Data dictionary](docs/data-dictionary.md)

## At a glance

| Evidence | Observed result |
|---|---|
| Scope | 18,491 orders and 4,337 identified customers from UCI Online Retail |
| Sales after the first observed order | **78.88%** of positive sales - distinct from all sales made by repeat buyers |
| Mature-cohort 90-day repeat rate | **47.45%** pooled rate, with complete follow-up required |
| Delivery | Reproducible Python/SQL pipeline, charts, CSV outputs and business recommendations |

The figures describe the historical dataset; they are not forecasts or measured business uplift.

![Revenue and retention dashboard overview](reports/figures/dashboard.png)

## Repository guide

```text
analysis/   Pipeline and adversarial SQL tests
sql/        Order-grain models, revenue definitions, cohorts and RFM
reports/    Executive summary, computed tables and figures
docs/       Data dictionary, methodology and verification notes
```

<details>
<summary><strong>Run locally on Windows (PowerShell)</strong></summary>

## Run on Windows (PowerShell)

Tested with Python 3.14.6 on Windows. Install Python 3.14 and Git, then open PowerShell in the repository root (the folder containing this README). No PowerShell activation or database server is required.

For the exact recorded dependency environment, use `requirements-lock.txt` in place of `requirements.txt`.

```powershell
python3.14.exe -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe analysis\run.py
```

If your installation provides the Python launcher instead, use `py -3.14 -m venv .venv` for the first command. Both forms create the same local environment. Every subsequent command runs from the repository root.

The script downloads the original UCI workbook automatically on first run and reuses it afterwards. If download is blocked, [download the UCI ZIP](https://archive.ics.uci.edu/static/public/352/online+retail.zip), extract **Online Retail.xlsx** into `data/raw/`, and rerun. Do not rename the workbook. No Kaggle account required. Dependencies require internet on initial installation.

</details>

<details>
<summary><strong>Detailed findings, charts and interpretation</strong></summary>

## Results and visual story

The five headline findings and three evidence-linked recommendations are in [Executive summary](reports/executive-summary.md), generated directly from computed tables on every run. Evidence filenames below refer to `reports/`.

<!-- FINDINGS:START -->

1. **78.88%** of GBP **8,702,879.23** positive sales comes from the second observed order onward (GBP **6,864,616.10**). Evidence: `kpis.csv`, `sql/02_revenue.sql`.
2. Customers with at least two observed orders generate **92.95%** of sales (**GBP 8,088,980.94**), INCLUDING their first orders. **2,843/4,337 customers (65.55%)** are repeat buyers. This differs from finding 1 by **14.07 percentage points**. Evidence: `rfm.csv`, `kpis.csv`.
3. Mature cohorts have a pooled 90-day repeat rate of **47.45%**. Highest: **2010-12**, **59.55%** (527/885); lowest: **2011-05**, **38.38%** (109/284). Evidence: `cohorts.csv`. Seasonality and left truncation prevent a causal ranking of acquisition quality.
4. **603 repeat customers** have not bought for more than 90 days. They generated GBP **677,953.16**, **7.79%** of historical sales. Evidence: `rfm.csv`, `segments.csv`. This is an inactivity proxy, not a churn probability.
5. The high-sales / low-repeat screen flags **149 products**. The highest-revenue flagged SKU is **22423 (REGENCY CAKESTAND 3 TIER)**: GBP **142,137.25** sales, **425/691 mature buyers (61.51%)** who placed another order within 90 days of their first purchase of that SKU; **190** buyers lack follow-up. High sales threshold: **GBP 7,093.72**; low repeat threshold: **67.31%**. Evidence: `product_priorities.csv`, `product_followup.csv`. Buyers can appear under multiple SKUs; these counts are not additive.

### Additional product diagnosis: all buyers, not only first baskets

Anchor each customer/SKU at the first observed purchase of that SKU; follow for 90 elapsed days, requiring anchor + 90 days < exclusive observation cutoff. The outcome counts customers who placed another order within 90 days, even if the later invoice contains a different SKU. Each customer counts once per SKU. Censored buyers are excluded from the rate and explicitly counted. Among products with >=50 eligible buyers, high revenue means >= the 75th percentile of all-window product sales; low repeat means below the median product repeat rate. Thresholds are descriptive screening rules, not statistical significance or causal effects. See `product_followup.csv` and `product_priorities.csv`.

| SKU | Product | Sales GBP | All buyers | Eligible 90d | Censored | Customers who placed another order within 90 days | Repeat 90d |
|---|---|---:|---:|---:|---:|---:|---:|
| 22423 | REGENCY CAKESTAND 3 TIER | 142,137.25 | 881 | 691 | 190 | 425 | 61.51% |
| 85123A | CREAM HANGING HEART T-LIGHT HOLDER | 100,544.50 | 856 | 690 | 166 | 405 | 58.70% |
| 85099B | JUMBO BAG RED RETROSPOT | 85,019.74 | 635 | 471 | 164 | 307 | 65.18% |
| 47566 | PARTY BUNTING | 68,785.23 | 708 | 610 | 98 | 388 | 63.61% |
| 84879 | ASSORTED COLOUR BIRD ORNAMENT | 56,385.99 | 678 | 481 | 197 | 305 | 63.41% |
| 22502 | PICNIC BASKET WICKER 60 PIECES | 47,348.35 | 175 | 173 | 2 | 106 | 61.27% |
| 22386 | JUMBO BAG PINK POLKADOT | 37,236.46 | 372 | 292 | 80 | 194 | 66.44% |
| 22197 | POPCORN HOLDER | 37,111.08 | 407 | 286 | 121 | 175 | 61.19% |
| 82484 | WOOD BLACK BOARD ANT WHITE FINISH | 34,414.71 | 285 | 228 | 57 | 141 | 61.84% |
| 22720 | SET OF 3 CAKE TINS PANTRY DESIGN  | 33,230.30 | 640 | 480 | 160 | 309 | 64.38% |

Top 10 flagged products by sales shown; full screening list: `product_priorities.csv`.

<!-- FINDINGS:END -->

![Revenue after first order](reports/figures/revenue.png)
![Two repeat revenue definitions side by side](reports/figures/revenue_comparison.png)
![Mature cohort comparison](reports/figures/cohorts.png)
![RFM segments](reports/figures/segments.png)
![Product associations](reports/figures/products.png)
![Product follow-up among all SKU buyers](reports/figures/product_followup.png)

The original 78.9% chart is preserved. The adjacent comparison also includes all orders (including first) from customers with at least two orders. Both share the same positive-sales denominator. Product priorities now cover all SKU buyers with complete 90-day follow-up, not only first-basket buyers. See [added methodology and RFM verification](docs/review-methodology.md) and the [portfolio deliverable review](docs/pdf-deliverables-review.md). A static dashboard overview is available at `reports/figures/dashboard.png`.

The first chart answers the main question. Only second and subsequent invoices enter the repeat numerator; the first invoice of a future repeater remains in first-order sales. Revenue is positive sales among identified customers, **before credits**, not total-store net revenue.

The cohort chart shows cumulative second-purchase probability within elapsed days of first observed order. It omits cells without complete monthly-cohort follow-up. Grey is unknown, not zero. December 2010 includes existing clients whose earlier history is unavailable. Compare common eligible cohorts across horizons; do not treat a higher 90-day rate than 30-day rate as improvement in acquisition quality.

</details>

## Query from VS Code

Install **SQLTools** (`mtxr.sqltools`) and **DuckDB for SQLTools** (`MaksimPeterburgskiy.duckdb-for-sqltools`). After running the Python pipeline once, use **SQLTools: Connect** and select the existing **DuckDB** connection defined in `.vscode/settings.json`; no new connection is needed. It opens `data/processed/retail.duckdb` in read-only mode using a workspace-relative path. Select a query and run **SQLTools Connection: Run Query**. For example, `SELECT COUNT(*) FROM orders;` should return **18,491**. Disconnect SQLTools before rebuilding the database with Python. SQL files use the SQL language mode rather than PL/SQL.

## Reproducible assets

- `analysis/run.py`: download, pandas preparation, SQL execution, validation, plots and summary.
- `sql/01_orders.sql` to `07_basket_affinity.sql`: order-grain modeling, two repeat-revenue definitions, mature cohorts, RFM, first-basket associations, all-buyer product follow-up and basket affinity.
- `data/raw/`: original workbook, excluded from Git.
- `data/processed/`: sales CSV and a persistent DuckDB database, excluded from Git.
- `reports/`: CSV results, PNG charts, source fingerprint, checks and executive summary.
- [Data dictionary](docs/data-dictionary.md) and [Methodology](docs/methodology.md): grains, definitions, exclusions and limitations.

To query locally without a DuckDB CLI:

```powershell
.\.venv\Scripts\python.exe -c "import duckdb; c=duckdb.connect('data/processed/retail.duckdb', read_only=True); print(c.sql('SELECT segment, count(*) AS customers FROM customer_rfm GROUP BY segment').df().to_string(index=False))"
```

Run the six adversarial SQL tests (including both revenue definitions, RFM boundaries and product censoring):

```powershell
.\.venv\Scripts\python.exe -m unittest discover -s analysis -p 'test_*.py'
```

Re-running rebuilds derived database tables and reports. All checks execute in the pipeline and fail the run if broken. Integer-pence line totals must equal order totals exactly; joining RFM must preserve both revenue and invoice count. Independent pandas calculations verify SQL ranking and each cohort cell. The source must contain repeat orders and more than 180 days of history.

## Interpretation and limitations

CustomerID is documented by UCI; missing IDs are excluded, not imputed. Exact duplicates are removed as an explicit assumption. C invoices and negative quantities are separated; no reliable original-order linkage is available, so credits are reported separately rather than assigned to arbitrary purchase ranks. The final partial date is excluded. Product codes have no documented categories; no categories, payment records, margins or churn labels are invented. RFM inactivity is a transparent outreach heuristic, not a predictive churn model. Recommendations propose controlled tests rather than promise causal uplift.

## Source and attribution

Chen, D. (2015). **Online Retail**. UCI Machine Learning Repository. [DOI: 10.24432/C5BW33](https://doi.org/10.24432/C5BW33). [Documentation](https://archive.ics.uci.edu/dataset/352/online-retail). **CC BY 4.0**. Actual transactions from a UK gift retailer, 2010–2011; many clients are wholesalers. This project uses real data, not synthetic data. Historical results should not be extrapolated to a present-day retailer without validation.
