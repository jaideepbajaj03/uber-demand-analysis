# Uber Ride Demand & Service Gap Analysis

## Overview
Analysis of Uber ride-sharing data (July 11-15, 2016) to identify demand patterns and service gaps across pickup locations and times. The goal was to uncover **where and when** the service struggles most, and what that reveals about operational priorities.

## Dataset
- **Source:** Uber_Request_Data.csv
- **Rows:** 6,745 transactions
- **Date Range:** July 11-15, 2016 (5 days)
- **Locations:** Airport, City
- **Statuses:** Trip Completed (42%), Cancelled (19%), No Cars Available (39%)

### Known Data Issues & Handling
- **Mixed date formats:** Some rows had `DD/MM/YYYY HH:MM` format, others `DD-MM-YYYY HH:MM:SS`. Fixed in SQL using `CASE WHEN` + `STR_TO_DATE()` with format detection.
- **No timestamp component on Drop timestamps for cancelled/no-car rows:** Resulted in blank values. Handled in Power BI by replacing errors with null rather than attempting invalid calculations.

## Key Questions Asked
1. What's the overall breakdown of trip statuses?
2. Which pickup point sees more requests?
3. At what hours is demand highest?
4. What's the average trip duration?
5. How do failure modes (cancellations vs no-cars) differ by location?
6. When does the "no cars available" problem spike?

## Methodology

### SQL Layer
- Wrote 7 queries in MySQL covering status counts, location breakdown, hourly demand, trip duration, and failure-mode analysis
- Used window functions (`SUM() OVER PARTITION BY`) to calculate percentage-of-total per location
- Used `TIMESTAMPDIFF()` for duration calculations with proper date format handling

### Excel Layer
- Built 4 pivot charts: status breakdown, pickup×status cross-tab (100% stacked), hourly demand trend, combined demand+no-cars line chart
- Used conditional formatting and data validation to spot inconsistencies

### Power BI Layer
- Imported cleaned data; created 4 KPI cards (Total Requests, Completion Rate %, Avg Trip Duration, Cancellation Rate %)
- Built 4 interactive visuals: donut (status), 100% stacked bar (location×status), line chart (hourly trend), stacked column (daily breakdown)
- Added pickup-point slicer for cross-filtering all charts and KPIs
- Applied consistent blue theme throughout

## Key Insights

1. **Airport's dominant failure mode = supply shortage.** 52.9% of Airport requests get no car available, vs only 6.1% cancellation. This is a supply-side problem (need more drivers at Airport).

2. **City's dominant failure mode = customer cancellation.** 30.4% of City requests are cancelled, vs only 26.7% no-cars. This suggests demand uncertainty or customer friction (maybe longer wait times make people bail).

3. **Evening rush (5-10pm, hours 17-22) drives simultaneous peak demand AND peak failures.** Hour 18 (6pm) has 510 total requests and 322 "no cars available" — the system is visibly strained at this exact time window across both locations.

4. **Trip duration doesn't vary by location.** Airport averages 51.95 min, City 52.26 min — essentially identical. The difference between locations is *whether a ride happens*, not *how long it takes*.

5. **5-day pattern repeats consistently.** The evening rush and location-specific failure modes repeat each day in the data, suggesting these are structural problems, not one-off anomalies.

## Trade-offs & Limitations
- **5-day dataset is short** — patterns are clear but seasonal/weekly effects unknown
- **No surge pricing or driver-supply data** — can't determine if supply shortage is a pricing/incentive issue or pure capacity constraint
- **No customer context** — can't segment by repeat vs new customers, loyalty, etc.

## Files Included
- `uber_queries.sql` — all 7 queries with comments
- `uber_analysis.xlsx` — pivot tables and charts
- `uber_dashboard.pbix` — Power BI dashboard with slicers

## Tools & Skills Demonstrated
- **SQL:** CASE WHEN for conditional logic, window functions (SUM OVER), TIMESTAMPDIFF for duration, GROUP BY with ORDER BY for ranking
- **Excel:** Pivot tables, conditional formatting, 100% stacked charts, data validation
- **Power BI:** DAX measures (SUM, DIVIDE, COUNT), slicers with cross-filtering, multi-visual dashboard design

------------------------------------------------------------------------------------------------------------------------------------------------------------