SELECT 'best' AS flag, vin, MAX(fuel_efficiency) AS fuel_efficiency
      ,'56나 3294' AS my_vin, MAX(CASE WHEN vin='56나 3294' THEN fuel_efficiency ELSE 0 END) AS my_fuel
  FROM history_section
UNION
SELECT '3months' AS flag, vin, MAX(avg_fuel) AS fuel_efficiency
      ,'56나 3294' AS my90_vin, MAX(CASE WHEN vin='56나 3294' THEN avg_fuel ELSE 0 END) AS my90_fuel
  FROM ( SELECT vin ,AVG(fuel_efficiency) AS avg_fuel
          FROM history_section
         WHERE yearmonthday <= '2013-02-22'
           AND yearmonthday >= DATE_ADD('2013-02-22', INTERVAL -90 DAY)
         GROUP BY vin) pseudo_table
UNION
SELECT '1week' AS flag, vin, MAX(avg_fuel) AS fuel_efficiency
      ,'56나 3294' AS my90_vin, MAX(CASE WHEN vin='56나 3294' THEN avg_fuel ELSE 0 END) AS my90_fuel
  FROM ( SELECT vin ,AVG(fuel_efficiency) AS avg_fuel
          FROM history_section
         WHERE yearmonthday <= '2013-02-22'
           AND yearmonthday >= DATE_ADD('2013-02-22', INTERVAL -7 DAY)
         GROUP BY vin) pseudo_table
