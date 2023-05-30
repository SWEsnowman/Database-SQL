

--Query 1

with t1 as (
select avg(quant) quant, month, prod
from sales
group by month, prod
order by prod, month
), before as (
select prev.quant prev_quant, prev.month prev_month, curr.quant curr_quant, curr.month, curr.prod 
from t1 curr left join t1 prev
on curr.month-1 = prev.month and curr.prod = prev.prod
), after as (
select next.quant next_quant, next.month next_month, curr.quant curr_quant, curr.month, curr.prod 
from t1 curr left join t1 next
on curr.month+1 = next.month and curr.prod = next.prod

), prevnext as (
select before.prod, t1.month, before.prev_quant, before.curr_quant, after.next_quant 
from before, t1, after
where before.month = t1.month and t1.month = after.month and before.prod = t1.prod and t1.prod = after.prod
)
select s.prod, s.month, count(s.quant) as between_averages
from sales s, prevnext pn
where s.prod = pn.prod
and s.month = pn.month
and (s.quant between pn.prev_quant and pn.next_quant)
or (s.quant between pn.next_quant and pn.prev_quant)
group by s.prod, s.month

--Query 2

with extend_sales as (
select *, ceiling(month/3.0) quarter
from sales
), base as (
select cust, prod, quarter, avg(quant) average
from extend_sales
group by cust, prod, quarter
), before as (
select curr.cust, curr.prod, curr.quarter curr_quarter, prev.quarter prev_quarter, curr.average curr_avg, prev.average prev_avg
from base curr left join base prev
on curr.quarter -1 = prev.quarter and curr.cust = prev.cust and curr.prod = prev.prod
order by curr.cust, curr.prod, curr.quarter
), after as (
select curr.cust, curr.prod, curr.quarter curr_quarter, next.quarter next_quarter, curr.average curr_avg, next.average next_avg
from base curr left join base next
on curr.quarter +1 = next.quarter and curr.cust = next.cust and curr.prod = next.prod
order by curr.cust, curr.prod, curr.quarter
)
select before.cust, before.prod, before.curr_quarter, before.prev_avg, before.curr_avg, after.next_avg
from before natural join after 

--Query 3

with t1 as (
select cust, prod, state, avg(quant) prod_avg
from sales
group by cust, prod, state
), rest_of_prod as (
select t1.cust, t1.prod, t1.state, t1.prod_avg, avg(s.quant) rest_of_prod_avg
from t1, sales s
where t1.cust = s.cust and t1.state = s.state and t1.prod != s.prod
group by t1.cust, t1.prod, t1.state, t1.prod_avg
), rest_of_cust as (
select t1.cust, t1.prod, t1.state, t1.prod_avg, avg(s.quant) rest_of_cust_avg
from t1, sales s 
where t1.prod = s.prod and t1.state = s.state and t1.cust != s.cust
group by t1.cust, t1.prod, t1.state, t1.prod_avg
)
select cust, prod, state, prod_avg, rest_of_cust_avg, rest_of_prod_avg
from rest_of_prod natural join rest_of_cust

--Query 4

with t1 as (
select prod, quant
from sales
group by prod, quant
), t2 as (
select s.prod, s.quant, count(s.quant) pos
from t1 s, t1 t
where s.prod = t.prod and s.quant >= t.quant
group by s.prod, s.quant
order by s.prod, s.quant
), median as (
select prod, ceiling(count(quant)/2) median_pos
from t2
group by prod
), posit as (
select t2.prod, min(t2.pos) med_pos
from t2 natural join median
where pos >= median.median_pos
group by t2.prod
order by t2.prod
)
select t2.prod, t2.quant median_quant
from t2, posit
where t2.prod = posit.prod and t2.pos = posit.med_pos



