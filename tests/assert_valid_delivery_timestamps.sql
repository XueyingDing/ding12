-- Data quality: when an order was delivered, the delivered timestamp should not
-- be earlier than the purchase timestamp. Returns offending rows; passes at zero.
select
    order_id,
    order_purchased_at,
    order_delivered_customer_at
from {{ ref('stg_orders') }}
where order_delivered_customer_at is not null
  and order_delivered_customer_at < order_purchased_at