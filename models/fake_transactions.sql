MODEL (
  name gold.sales_transactions,
  kind INCREMENTAL_BY_TIME_RANGE (
    time_column business_date
  ),
  start '2020-01-01',
  grain (sale_id, business_date)
);


SELECT [business_date],
			[channel],
			[currency],
			[customer_id],
			[gross_amount],
			[product_id],
			[quantity],
			[sale_id],
			[sale_ts],
			[unit_price]
FROM [lh_fake_data].[dbo].[sales_transactions]