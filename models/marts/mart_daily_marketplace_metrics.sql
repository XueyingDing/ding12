with orders as (
    select * from {{ ref('int_orders_enriched') }}
),

items as (
    select * from {{ ref('int_seller_order_performance') }}
),

orders_daily as (
    select
        order_date,
        count(*)                             as gross_orders,
        sum(completed_order_flag)            as completed_orders,
        sum(canceled_order_flag)             as canceled_orders,
        count(distinct customer_unique_id)   as active_customers
    from orders
    where order_date is not null
    group by 1
),

revenue_daily as (
    select
        order_date,
        sum(price + freight_value) as total_gmv,
        sum(freight_value)         as total_freight
    from items
    where order_date is not null
    group by 1
)

select
    orders_daily.order_date,
    orders_daily.gross_orders,
    orders_daily.completed_orders,
    orders_daily.canceled_orders,
    {{ safe_divide('orders_daily.completed_orders', 'orders_daily.gross_orders') }} as completion_rate,
    {{ safe_divide('orders_daily.canceled_orders', 'orders_daily.gross_orders') }} as cancellation_rate,
    coalesce(revenue_daily.total_gmv, 0)     as total_gmv,
    coalesce(revenue_daily.total_freight, 0) as total_freight,
    {{ safe_divide('revenue_daily.total_gmv', 'orders_daily.gross_orders') }} as avg_order_value,
    orders_daily.active_customers
from orders_daily
left join revenue_daily
    on orders_daily.order_date = revenue_daily.order_date
order by orders_daily.order_date