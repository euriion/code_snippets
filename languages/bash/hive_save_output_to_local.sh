#!/bin/bash
SQL="INSERT OVERWRITE LOCAL DIRECTORY '/tmp/hive/output' 
SELECT c.cust_no, hma_merge(c.parsed_field) 
FROM customer c;"
hive -e '$SQL'