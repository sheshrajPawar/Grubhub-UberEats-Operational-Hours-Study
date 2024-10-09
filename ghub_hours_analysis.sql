## Step 1: View All Fields
  
SELECT * FROM `project2_dataset2.kitchen_hours_api2` LIMIT 5;

## Step 2: Extract JSON Keys in a simplified form
  
WITH key_extraction AS (
  SELECT 
    JSON_EXTRACT(response_data, '$.availability_by_service.STANDARD.schedule') AS schedule_info
  FROM 
    `project2_dataset2.kitchen_hours_api2`
  WHERE response_data IS NOT NULL
)
SELECT DISTINCT JSON_EXTRACT_SCALAR(schedule_info, '$.days[0]') AS day_key
FROM key_extraction;

## Step 3: Extract Business Hours from Nested JSON

WITH schedule_info AS (
  SELECT
    JSON_EXTRACT_SCALAR(schedule_item, '$.days[0]') AS weekday,
    JSON_EXTRACT_SCALAR(schedule_item, '$.opening_time') AS start_time,
    JSON_EXTRACT_SCALAR(schedule_item, '$.closing_time') AS end_time
  FROM `project2_dataset2.kitchen_hours_api2`,
    UNNEST(JSON_EXTRACT(response_data, '$.availability_by_service.STANDARD.schedule')) AS schedule_item
)
SELECT weekday, start_time, end_time
FROM schedule_info;

## Step 4: Create a Function to Extract Operating Hours

CREATE FUNCTION ExtractHoursAPI2(json_input STRING)
RETURNS ARRAY<STRING>
LANGUAGE js AS """
  let schedules = JSON.parse(json_input).availability_by_service.STANDARD.schedule;
  return schedules.map(item => `${item.days[0]}: ${item.opening_time}-${item.closing_time}`);
""";

SELECT
  response_data,
  ExtractHoursAPI2(response_data) AS business_hours
FROM `project2_dataset2.kitchen_hours_api2`;













