-- Operational delivery reliability trend.
-- Grain: one row per order_month (based on purchase month).
with delivery as (
    select * from {{ ref('int_order_delivery_performance') }}
),
orders as (
    select order_id, order_month from {{ ref('int_orders_enriched') }}
),

delivered as (
    select
        orders.order_month,
        delivery.late_delivery_flag,
        delivery.delivery_delay_days,
        delivery.purchase_to_delivered_days
    from delivery
    inner join orders on delivery.order_id = orders.order_id
    -- Only orders that actually delivered contribute to reliability metrics
    where delivery.order_delivered_customer_at is not null
)

select
    order_month,
    count(*)                                    as delivered_orders,
    sum(late_delivery_flag)                      as late_orders,
    {{ safe_divide('sum(late_delivery_flag)', 'count(*)') }} as late_delivery_rate,
    avg(delivery_delay_days)                      as avg_delivery_delay_days,
    avg(purchase_to_delivered_days)               as avg_purchase_to_delivered_days
from delivered
where order_month is not null
group by 1
order by 1