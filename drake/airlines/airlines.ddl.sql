CREATE TABLE IF NOT EXISTS airlines.airlines(
  year              INT    COMMENT '1987-2008',
  month             INT    COMMENT '1-12',
  dayofmonth        INT    COMMENT '1-31',
  dayofweek         INT    COMMENT '1 (Monday) - 7 (Sunday)',
  deptime           STRING COMMENT 'actual departure time (local, hhmm)',
  crsdeptime        STRING COMMENT 'scheduled departure time (local, hhmm)',
  arrtime           STRING COMMENT 'actual arrival time (local, hhmm)',
  crsarrtime        STRING COMMENT 'scheduled arrival time (local, hhmm)',
  uniquecarrier     STRING COMMENT 'unique carrier code',
  flightnum         STRING COMMENT 'flight number',
  tailnum           STRING COMMENT 'plane tail number',
  actualelapsedtime INT    COMMENT 'in minutes',
  crselapsedtime    INT    COMMENT 'in minutes',
  airtime           INT    COMMENT 'in minutes',
  arrdelay          INT    COMMENT 'arrival delay, in minutes',
  depdelay          INT    COMMENT 'departure delay, in minutes',
  origin            STRING COMMENT 'origin IATA airport code',
  dest              STRING COMMENT 'destination IATA airport code',
  distance          INT    COMMENT 'in miles',
  taxiin            INT    COMMENT 'taxi in time, in minutes',
  taxiout           INT    COMMENT 'taxi out time in minutes',
  cancelled         STRING COMMENT 'was the flight cancelled?',
  cancellationcode  STRING COMMENT 'reason for cancellation (A = carrier, B = weather, C = NAS, D = security)',
  diverted          STRING COMMENT '1 = yes, 0 = no',
  carrierdelay      INT    COMMENT 'in minutes',
  weatherdelay      INT    COMMENT 'in minutes',
  nasdelay          INT    COMMENT 'in minutes',
  securitydelay     INT    COMMENT 'in minutes',
  lateaircraftdelay INT    COMMENT 'in minutes'
) COMMENT 'Air lines data' 
PARTITIONED BY(p_year STRING)
ROW FORMAT DELIMITED
  FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/airlines';
