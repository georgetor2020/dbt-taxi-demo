{{ config(
    materialized='table',
    pre_hook=['SET spark.sql.legacy.allowNonEmptyLocationInCTAS =true']
) }}

WITH source_avg as (
    SELECT avg((CAST(tpep_dropoff_datetime as LONG) - CAST(tpep_pickup_datetime as LONG))/60) as avg_duration
    , avg(passenger_count) as avg_passenger_count 
    , avg(trip_distance) as avg_trip_distance 
    , avg(total_amount) as avg_total_amount
    , year(CAST(tpep_dropoff_datetime as timestamp)) as year
    , month(CAST(tpep_dropoff_datetime as timestamp)) as month
    , payment_type as type
    FROM {{ source('data_source', 'tripdata') }}
    --WHERE year = "2022"
    WHERE tpep_dropoff_datetime is not null
    GROUP BY 5, 6, 7
    --GROUP BY 5
) 
SELECT *
FROM source_avg