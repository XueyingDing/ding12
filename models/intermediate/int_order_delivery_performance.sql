-- one row per order
-- delivery timing: delay days, late flag, purchase-to-delivered

with orders as (
    select * from {{ref('stg_orders')}}
)

select
    order_id,
    order_status,
    order_purchased_at,
    order_delivered_customer_at,
    order_estimated_delivery_at,
    case when order_delivered_customer_at is not null 
        then date_diff('day',order_purchased_at, order_delivered_customer_at) 
    end as purchase_to_delivered_days,
    date_diff('day',order_purchased_at, order_estimated_delivery_at) as estimated_delivery_days,
    case when order_delivered_customer_at is not null
        then date_diff('day',order_estimated_delivery_at, order_delivered_customer_at)
    end as delivery_delay_days,
    case when order_delivered_customer_at is not null and order_delivered_customer_at > order_estimated_delivery_at then 1
        when order_delivered_customer_at is not null then 0 
    end as late_delivery_flag
from orders