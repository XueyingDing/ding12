with orders as (
    select * from {{ref('stg_orders')}}
),

order_items as (
    select * from {{ref('stg_order_items')}}
),

products as (
    select * from {{ref('stg_products')}}
),

category as (
    select * from {{ref('stg_product_category_name_translation')}}
)

select
    a.order_id,
    a.order_item_id,
    a.product_id,
    b.order_status, 
    cast(b.order_purchased_at as date) as order_date,
    c.product_category_name,
    coalesce(d.product_category_name_english, c.product_category_name, 'unknown') as product_category_name_english,
    a.price, a.freight_value
from order_items a 
left join orders b on a.order_id = b.order_id
left join products c on a.product_id = c.product_id
left join category d on c.product_category_name = d.product_category_name