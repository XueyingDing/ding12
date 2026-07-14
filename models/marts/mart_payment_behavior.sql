-- Payment mix and installment behavior.
-- Grain: one row per payment_type.
with payments as (
    select * from {{ ref('stg_order_payments') }}
)

select
    payment_type,
    count(distinct order_id)     as orders,
    count(*)                     as payment_records,
    sum(payment_value)           as total_payment_value,
    {{ safe_divide('sum(payment_value)', 'count(*)') }}        as avg_payment_value,
    {{ safe_divide('sum(payment_installments)', 'count(*)') }} as avg_payment_installments
from payments
group by 1
order by total_payment_value desc