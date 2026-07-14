-- grain: product_category_name_english
-- Category economics and satisfaction.
-- Grain: one row per product_category_name_english.
with items as (

    select * from {{ ref('int_category_performance') }}

),

reviews as (

    select * from {{ ref('int_review_experience') }}

),

category_items as (

    select
        product_category_name_english,
        count(distinct order_id)     as orders,
        count(*)                     as items_sold,
        sum(price + freight_value)   as category_gmv,
        avg(price)                   as avg_item_price,
        avg(freight_value)           as avg_freight
    from items
    group by 1

),

-- One review score per order, then linked to each category the order touched
order_reviews as (

    select order_id, avg(cast(review_score as double)) as order_review_score
    from reviews
    group by 1

),

category_orders as (

    select distinct product_category_name_english, order_id
    from items

),

category_reviews as (

    select
        category_orders.product_category_name_english,
        avg(order_reviews.order_review_score) as avg_review_score
    from category_orders
    inner join order_reviews on category_orders.order_id = order_reviews.order_id
    group by 1

)

select
    category_items.product_category_name_english,
    category_items.orders,
    category_items.items_sold,
    category_items.category_gmv,
    category_items.avg_item_price,
    category_items.avg_freight,
    category_reviews.avg_review_score
from category_items
left join category_reviews
    on category_items.product_category_name_english = category_reviews.product_category_name_english
order by category_items.category_gmv desc