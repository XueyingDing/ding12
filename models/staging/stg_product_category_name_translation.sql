with source as (
    select * from {{ref('product_category_name_translation')}}
)

select
    lower(trim(product_category_name))         as product_category_name,
    lower(trim(product_category_name_english)) as product_category_name_english
from source