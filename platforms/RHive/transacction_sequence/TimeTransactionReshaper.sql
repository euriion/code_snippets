DROP TABLE IF EXISTS card_transaction;

CREATE TABLE IF NOT EXISTS card_transaction (
  customer STRING,
  shop     STRING,
  auth_dt  STRING,
  cardno   STRING,
  class    STRING
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ",";

LOAD DATA LOCAL INPATH './card_transaction.body.csv' OVERWRITE INTO TABLE card_transaction;

DROP TABLE IF EXISTS card_transaction_output;

CREATE TABLE IF NOT EXISTS card_transaction_output (
  customer      STRING,
  shop          STRING,
  start_auth_dt STRING,
  start_cardno  STRING,
  start_class   STRING,
  end_auth_dt   STRING,
  end_cardno    STRING,
  end_class     STRING
);

DELETE FILE /home/ndap/codes/RHive/transacction_sequence/TimeTransactionReshaper.py;
ADD FILE /home/ndap/codes/RHive/transacction_sequence/TimeTransactionReshaper.py;

FROM (
  FROM card_transaction
    MAP card_transaction.customer
      , card_transaction.shop
      , card_transaction.auth_dt
      , card_transaction.cardno
      , card_transaction.class
    USING '/bin/cat'
    AS customer, shop, auth_dt, cardno, class
    CLUSTER BY customer, shop
) map_output
-- INSERT OVERWRITE TABLE card_transaction_reshaped
REDUCE map_output.customer
     , map_output.shop
     , map_output.auth_dt
     , map_output.cardno
     , map_output.class
USING '/usr/bin/python ./TimeTransactionReshaper.py'
   AS customer
  , shop    
  , start_auth_dt 
  , start_cardno  
  , start_class   
  , end_auth_dt   
  , end_cardno    
  , end_class     
;
