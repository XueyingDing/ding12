with source as (
    select * from {{ref('olist_orders_dataset')}}
)

select
    order_id,
    customer_id,
    lower(trim(order_status)) as order_status,
    cast(order_purchase_timestamp as timestamp) as order_purchase_at,
    cast(order_approved_at as timestamp) as order_purchase_at,
    cast(order_delivered_carrier_date as timestamp) as order_delivered_carrier_dt,
    cast(order_delivered_customer_date as timestamp) as order_delivered_customer_dt,
    cast(order_estimated_delivery_date as timestamp) as order_estimated_delivery_dt
from source