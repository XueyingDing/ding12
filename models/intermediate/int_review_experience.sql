-- one row per review record
-- reviews + delivery, for CX analysis

with reviews as (
    select * from {{ ref('stg_order_reviews') }}
),
orders as (
    select * from {{ ref('int_orders_enriched') }}
),
delivery as (
    select * from {{ ref('int_order_delivery_performance') }}
)

select
    reviews.review_id,
    reviews.order_id,
    reviews.review_score,
    reviews.review_created_at,
    orders.order_month,
    orders.order_status,
    orders.customer_state,
    delivery.late_delivery_flag,
    delivery.delivery_delay_days,
    -- Low review = score of 1 or 2 (documented in docs/business_assumptions.md)
    case when reviews.review_score <= 2 then 1 else 0 end as low_review_flag
from reviews
left join orders on reviews.order_id = orders.order_id
left join delivery on reviews.order_id = delivery.order_id