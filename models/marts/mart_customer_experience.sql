-- order_month
-- Customer Experience
with reviews as (

    select * from {{ ref('int_review_experience') }}

)

select
    order_month,
    count(*)                                              as review_count,
    avg(cast(review_score as double))                      as avg_review_score,
    sum(low_review_flag)                                   as low_review_count,
    {{ safe_divide('sum(low_review_flag)', 'count(*)') }}  as low_review_rate,
    {{ safe_divide('sum(late_delivery_flag)', 'count(late_delivery_flag)') }} as late_delivery_rate,
    avg(delivery_delay_days)                               as avg_delivery_delay_days
from reviews
where order_month is not null
group by 1
order by 1