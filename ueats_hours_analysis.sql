-- Retrieve all fields from Ubereats hours data
SELECT *
FROM `project_alt.dataset_alt.ue_hours_data`
LIMIT 5;

-- Extract start and end times from the hours section
WITH extracted_hours AS (
  SELECT
      JSON_EXTRACT(hours_data, "$.hoursInfo.closeTime") AS close_hour, 
      JSON_EXTRACT(hours_data, "$.hoursInfo.openTime") AS open_hour
  FROM 
      `project_alt.dataset_alt.ue_hours_data`,
      UNNEST(JSON_QUERY_ARRAY(response_field, '$.info.menus.menuItems')) AS hours_data
)

SELECT 
    open_hour, 
    close_hour
FROM extracted_hours;
