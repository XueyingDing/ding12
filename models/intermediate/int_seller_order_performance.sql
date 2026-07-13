-- one row per order item
-- revenue fact + seller/product/category context
with order_items as (
    select * from {{ ref('stg_order_items') }}
),
orders as (
    select * from {{ ref('stg_orders') }}
),
sellers as (
    select * from {{ ref('stg_sellers') }}
),
products as (
    select * from {{ ref('stg_products') }}
),
category as (
    select * from {{ ref('stg_product_category_name_translation') }}
)

select
    order_items.order_id,
    order_items.order_item_id,
    order_items.seller_id,
    order_items.product_id,

    orders.order_status,
    orders.order_purchased_at,
    cast(orders.order_purchased_at as date) as order_date,

    sellers.seller_city,
    sellers.seller_state,

    products.product_category_name,
    coalesce(category.product_category_name_english, products.product_category_name, 'unknown') as product_category_name_english,

    -- Revenue components at the order-item grain
    order_items.price,
    order_items.freight_value,
    order_items.price + order_items.freight_value as item_total_value
from order_items
left join orders   on order_items.order_id   = orders.order_id
left join sellers  on order_items.seller_id  = sellers.seller_id
left join products on order_items.product_id = products.product_id
left join category on products.product_category_name = category.product_category_name