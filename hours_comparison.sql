WITH gh_hours AS (
  SELECT 
    JSON_EXTRACT(response, '$["restaurant_slug"]') AS gh_slug,
    JSON_EXTRACT(response, '$["business_hours"]') AS gh_business_hours
  FROM `project.dataset1.virtual_kitchen_gh_hours`
),
ue_hours AS (
  SELECT
    JSON_EXTRACT(menu_data, '$[0]["identifier"]') AS ue_identifier,
    JSON_EXTRACT(menu_data, '$[0]["hours"]["open"]') AS ue_open_time,
    JSON_EXTRACT(menu_data, '$[0]["hours"]["close"]') AS ue_close_time
  FROM `project.dataset1.virtual_kitchen_ue_hours`
),
merged_hours AS (
  SELECT
    gh_slug,
    gh_business_hours,
    ue_identifier,
    ue_open_time,
    ue_close_time
  FROM gh_hours
  JOIN ue_hours 
    ON JSON_EXTRACT(gh_business_hours, '$[0]') = ue_identifier
)
SELECT
  gh_slug,
  JSON_EXTRACT(gh_business_hours, '$[0]') AS gh_hours_string,
  ue_identifier,  
  ue_open_time,
  ue_close_time,
  CASE
    WHEN PARSE_TIMESTAMP('%H:%M', JSON_EXTRACT(gh_business_hours, '$[1]')) BETWEEN PARSE_TIMESTAMP('%H:%M', ue_open_time) AND PARSE_TIMESTAMP('%H:%M', ue_close_time) THEN "Within Range"
    WHEN ABS(TIMESTAMP_DIFF(PARSE_TIMESTAMP('%H:%M', JSON_EXTRACT(gh_business_hours, '$[1]')), PARSE_TIMESTAMP('%H:%M', ue_open_time), MINUTE)) < 5 THEN "Close Range (<5 min)"
    ELSE "Out of Range"
  END AS time_status
FROM merged_hours;
