-- one row per order
-- orders + customer geography + date grains + lifecycle flags
with orders as (
    select * from {{ ref('stg_orders') }}
),
customers as (
    select * from {{ ref('stg_customers') }}
)

select
    orders.order_id,
    orders.customer_id,
    customers.customer_unique_id,
    customers.customer_city,
    customers.customer_state,    
    orders.order_status,
    orders.order_purchased_at,
    orders.order_approved_at,
    orders.order_delivered_customer_at,
    orders.order_estimated_delivery_at,
    -- Reporting date grains derived from purchase timestamp
    cast(orders.order_purchased_at as date) as order_date,
    date_trunc('month',orders.order_purchased_at)::date as order_month,
    date_trunc('day',orders.order_purchased_at)::date as order_week,
    -- lifecycle flags
    case when orders.order_status = 'delivered' then 1 else 0 end as completed_order_flag,
    case when orders.order_status = 'canceled'  then 1 else 0 end as canceled_order_flag
from orders
left join customers on orders.customer_id = customers.customer_id
