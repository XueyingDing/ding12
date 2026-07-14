-- Data quality: order-item prices should never be negative.
-- Returns offending rows; the test passes when zero rows are returned.
-- (freight_value can legitimately be 0, so we only guard against negatives.)
select
    order_id,
    order_item_id,
    price,
    freight_value
from {{ ref('stg_order_items') }}
where price < 0
   or freight_value < 0