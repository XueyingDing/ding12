-- Seller scorecard: value contribution vs. customer-experience risk.
-- Grain: one row per seller_id.
with items as (

    select * from {{ ref('int_seller_order_performance') }}

),

delivery as (

    select * from {{ ref('int_order_delivery_performance') }}

),

reviews as (

    select * from {{ ref('int_review_experience') }}

),

-- Numeric performance aggregated at the item grain
seller_items as (

    select
        seller_id,
        count(distinct order_id)                                    as seller_orders,
        count(distinct case when order_status = 'delivered' then order_id end) as completed_orders,
        sum(price + freight_value)                                  as seller_gmv,
        avg(price)                                                  as avg_item_price,
        sum(freight_value)                                          as total_freight,
        avg(freight_value)                                          as avg_freight,
        count(distinct product_id)                                  as distinct_products_sold
    from items
    group by 1

),

-- Distinct seller/order pairs so order-level metrics aren't double counted
seller_orders as (

    select distinct seller_id, order_id
    from items

),

seller_delivery as (

    select
        seller_orders.seller_id,
        avg(cast(delivery.late_delivery_flag as double)) as late_delivery_rate
    from seller_orders
    inner join delivery on seller_orders.order_id = delivery.order_id
    where delivery.late_delivery_flag is not null
    group by 1

),

-- Average the per-order review scores up to the seller
order_reviews as (

    select order_id, avg(cast(review_score as double)) as order_review_score
    from reviews
    group by 1

),

seller_reviews as (

    select
        seller_orders.seller_id,
        avg(order_reviews.order_review_score) as avg_review_score
    from seller_orders
    inner join order_reviews on seller_orders.order_id = order_reviews.order_id
    group by 1

)

select
    seller_items.seller_id,
    seller_items.seller_orders,
    seller_items.completed_orders,
    seller_items.seller_gmv,
    seller_items.avg_item_price,
    seller_items.total_freight,
    seller_items.avg_freight,
    seller_items.distinct_products_sold,
    seller_reviews.avg_review_score,
    seller_delivery.late_delivery_rate
from seller_items
left join seller_reviews  on seller_items.seller_id = seller_reviews.seller_id
left join seller_delivery on seller_items.seller_id = seller_delivery.seller_id
order by seller_items.seller_gmv desc