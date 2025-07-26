-- File: models/silver_metrics/silver_nyctaxi_avg_metrics.sql

{{ config(
    materialized='table',
    pre_hook=['SET spark.sql.legacy.allowNonEmptyLocationInCTAS = true']
) }}

WITH source_avg AS (
    SELECT
        AVG((CAST(tpep_dropoff_datetime AS LONG) - CAST(tpep_pickup_datetime AS LONG)) / 60) AS avg_duration_minutes,
        AVG(passenger_count) AS avg_passenger_count,
        AVG(trip_distance) AS avg_trip_distance,
        AVG(total_amount) AS avg_total_amount,
        YEAR(CAST(tpep_dropoff_datetime AS TIMESTAMP)) AS trip_year,
        MONTH(CAST(tpep_dropoff_datetime AS TIMESTAMP)) AS trip_month,
        payment_type AS payment_type_code
    FROM {{ source('data_source', 'yellow_tripdata') }} -- <<< THIS IS THE CRITICAL LINE THAT MUST BE CORRECT
    WHERE
        YEAR(CAST(tpep_dropoff_datetime AS TIMESTAMP)) = 2024 -- Use integer for year
        AND tpep_dropoff_datetime IS NOT NULL -- Combine WHERE clauses with AND
    GROUP BY
        YEAR(CAST(tpep_dropoff_datetime AS TIMESTAMP)), -- Group by full expression or aliases
        MONTH(CAST(tpep_dropoff_datetime AS TIMESTAMP)),
        payment_type
)

SELECT *
FROM source_avg