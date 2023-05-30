
--QUESTION 1

with t1 as (
select cust, min(quant) as min_Q,max(quant) as max_Q, avg(quant) as avg_Q
	from sales
	group by cust
), t2 as(
select t1.cust,t1.min_Q,s.prod as MIN_PROD, s.date as min_date, s.state as min_ST,t1.max_Q, t1.avg_Q
	from t1, sales as s
	where t1.cust = s.cust and t1.min_Q = s.quant
)
select t2.cust, t2.min_Q, t2.MIN_PROD, t2.min_date, t2.min_st,t2.max_Q,s.prod as max_prod,s.date as max_date, s.state as max_ST, t2.avg_Q
from t2, sales as s
where t2.cust = s.cust and t2.max_Q = s.quant


--QUESTION 2

with t1 as 
(select month, day, sum(quant) as sums
 from sales
 group by month, day
),
t2 as 
(select month, max(sums) as maxprofit, min(sums) as minprofit
 from t1
 group by month
), t3 as (
select t1.month, t2.maxprofit as MOST_PROFIT_TOTAL_Q, t2.minprofit as LEAST_PROFIT_TOTAL_Q
from t1,t2
where t1.month = t2.month and t1.sums = t2.maxprofit
order by t1.month
), t4 as(
select t1.month,t3.most_profit_total_q,t1.day as most_profit_day, t3.least_profit_total_q
from t3,t1
where t1.sums = t3.most_profit_total_q
)
select t1.month, t4.most_profit_day, t4.most_profit_total_q, t1.day as least_profit_day, t4.least_profit_total_q
from t4,t1
where t1.sums = t4.least_profit_total_q
order by t1.month


--QUESTION 3

with t1 as 
(select prod, month, sum(quant) as sums
 from sales
 group by prod, month
), t2 as (
select prod, max(sums) as maxprofit, min(sums) as minprofit
 from t1
 group by prod
), t3 as(
select t2.prod, t1.month as most_fav_month, t2.minprofit
from t2,t1
where t2.maxprofit = t1.sums
)
select t3.prod, t3.most_fav_month, t1.month as least_fav_month
from t1,t3
where t3.minprofit = t1.sums


--QUESTION 4

with t1 as 
(
select cust as customer, prod as product, avg(quant) as Q1_AVG
	from sales
	where month in (1,2,3)
	group by cust, prod
), t2 as (
select cust as customer, prod as product, avg(quant) as Q2_AVG
	from sales
	where month in (4,5,6)
	group by cust, prod
), t3 as (
select cust as customer, prod as product, avg(quant) as Q3_AVG
	from sales
	where month in (7,8,9)
	group by cust, prod
), t4 as (
select cust as customer, prod as product, avg(quant) as Q4_AVG
	from sales
	where month in (10,11,12)
	group by cust, prod
),
t5 as
(
select cust as customer, prod as product, avg(quant) as average, sum(quant) as total,count(quant)
from sales
group by cust, prod)
select *
from t1 natural join t2 natural join t3 natural join t4 natural join t5


--QUESTION 5

with t1 as (
select prod, cust, state, max(quant) as maxes
from sales
group by prod, cust,state
order by prod, cust, state
), t2 as (
select t1.cust, t1.prod, maxes as CT_MAX, sales.date as ct_date
from t1, sales
where t1.state = 'CT' and t1.maxes = sales.quant and t1.prod = sales.prod and t1.cust = sales.cust
order by maxes
), t3 as(
select t1.cust, t1.prod, maxes as NY_MAX, sales.date as ny_date
from t1, sales
where t1.state = 'NY' and t1.maxes = sales.quant and t1.prod = sales.prod and t1.cust = sales.cust
order by maxes
), t4 as (
select t1.cust, t1.prod, maxes as NJ_MAX, sales.date as nj_date
from t1, sales
where t1.state = 'NJ' and t1.maxes = sales.quant and t1.prod = sales.prod and t1.cust = sales.cust
order by maxes
)
select distinct t1.cust,t1.prod, t2.ct_max, t2.ct_date, t3.ny_max, t3.ny_date, t4.nj_max, t4.nj_date
from t1 natural join t2 natural join t3 natural join t4
where (t3.ny_max > t2.ct_max) or (t3.ny_max > t4.nj_max)
