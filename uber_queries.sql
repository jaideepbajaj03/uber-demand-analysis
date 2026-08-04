-- ============================================================================
-- UBER RIDE DEMAND & SERVICE GAP ANALYSIS
-- Dataset: Uber_Request_Data.csv (July 11-15, 2016)
-- ============================================================================

-- Database setup
CREATE DATABASE IF NOT EXISTS uber;
USE uber;

-- ============================================================================
-- QUERY 1: Overall Status Distribution
-- ============================================================================
-- What is the breakdown of trip outcomes (completed vs cancelled vs no cars)?

SELECT 
    trip_Status,
    COUNT(Request_id) AS Total_requests
FROM uberd1
GROUP BY trip_Status
ORDER BY Total_requests DESC;

-- ============================================================================
-- QUERY 2: Requests by Pickup Point
-- ============================================================================
-- Which pickup location receives more requests (Airport vs City)?

SELECT 
    Pickup,
    COUNT(Request_id) AS Total_requests
FROM uberd1
GROUP BY Pickup
ORDER BY Total_requests DESC;

-- ============================================================================
-- QUERY 3: Busiest Request Hours
-- ============================================================================
-- At what hours of the day is demand highest?
-- Note: Handles mixed date formats (DD/MM/YYYY HH:MM vs DD-MM-YYYY HH:MM:SS)

SELECT 
    HOUR(
        CASE 
            WHEN Request_timestamp LIKE '%/%' THEN STR_TO_DATE(Request_timestamp, '%d/%m/%Y %H:%i')
            WHEN Request_timestamp LIKE '%-%' THEN STR_TO_DATE(Request_timestamp, '%d-%m-%Y %H:%i:%s')
        END
    ) AS request_hour,
    COUNT(Request_id) AS total_requests
FROM uberd1
GROUP BY request_hour
ORDER BY total_requests DESC;

-- ============================================================================
-- QUERY 4: Average Trip Duration (Completed Trips Only)
-- ============================================================================
-- How long does the average completed trip take?
-- Note: Only includes "Trip Completed" status; handles mixed date formats

SELECT 
    ROUND(AVG(
        TIMESTAMPDIFF(
            MINUTE,
            CASE
                WHEN Request_timestamp LIKE '%/%' THEN STR_TO_DATE(Request_timestamp, '%d/%m/%Y %H:%i')
                WHEN Request_timestamp LIKE '%-%' THEN STR_TO_DATE(Request_timestamp, '%d-%m-%Y %H:%i:%s')
            END,
            CASE
                WHEN Drop_timestamp LIKE '%/%' THEN STR_TO_DATE(Drop_timestamp, '%d/%m/%Y %H:%i')
                WHEN Drop_timestamp LIKE '%-%' THEN STR_TO_DATE(Drop_timestamp, '%d-%m-%Y %H:%i:%s')
            END
        )
    ), 2) AS avg_trip_duration_mins
FROM uberd1
WHERE trip_Status = 'Trip Completed';

-- ============================================================================
-- QUERY 5: Failure Rate by Pickup Point (Window Function)
-- ============================================================================
-- How do cancellation and no-cars-available rates differ by location?
-- Shows percentage breakdown per pickup point using window functions

SELECT 
    Pickup,
    trip_Status,
    COUNT(Request_id) AS status_count,
    SUM(COUNT(Request_id)) OVER (PARTITION BY Pickup) AS pickup_total,
    ROUND(
        COUNT(Request_id) / SUM(COUNT(Request_id)) OVER (PARTITION BY Pickup) * 100, 
        2
    ) AS percent_of_pickup_total
FROM uberd1
GROUP BY Pickup, trip_Status
ORDER BY Pickup, status_count DESC;

-- ============================================================================
-- QUERY 6: "No Cars Available" Spike by Hour
-- ============================================================================
-- At what hours does the supply-demand gap (no cars) spike most?
-- Helps identify peak operational strain times

SELECT 
    HOUR(
        CASE 
            WHEN Request_timestamp LIKE '%/%' THEN STR_TO_DATE(Request_timestamp, '%d/%m/%Y %H:%i')
            WHEN Request_timestamp LIKE '%-%' THEN STR_TO_DATE(Request_timestamp, '%d-%m-%Y %H:%i:%s')
        END
    ) AS request_hour,
    COUNT(Request_id) AS no_cars_count
FROM uberd1
WHERE trip_Status = 'No Cars Available'
GROUP BY request_hour
ORDER BY request_hour;

-- ============================================================================
-- QUERY 7: Average Trip Duration by Pickup Point
-- ============================================================================
-- Does trip duration vary between Airport and City locations?

SELECT 
    Pickup,
    ROUND(AVG(
        TIMESTAMPDIFF(
            MINUTE,
            CASE
                WHEN Request_timestamp LIKE '%/%' THEN STR_TO_DATE(Request_timestamp, '%d/%m/%Y %H:%i')
                WHEN Request_timestamp LIKE '%-%' THEN STR_TO_DATE(Request_timestamp, '%d-%m-%Y %H:%i:%s')
            END,
            CASE
                WHEN Drop_timestamp LIKE '%/%' THEN STR_TO_DATE(Drop_timestamp, '%d/%m/%Y %H:%i')
                WHEN Drop_timestamp LIKE '%-%' THEN STR_TO_DATE(Drop_timestamp, '%d-%m-%Y %H:%i:%s')
            END
        )
    ), 2) AS avg_trip_duration_mins
FROM uberd1
WHERE trip_Status = 'Trip Completed'
GROUP BY Pickup
ORDER BY Pickup;

-- ================================================END======================================================= --