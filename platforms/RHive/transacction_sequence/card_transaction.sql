create table card_transaction_cnt as
select customer, shop, count(*) as cnt
from card_transaction
group by customer, shop


