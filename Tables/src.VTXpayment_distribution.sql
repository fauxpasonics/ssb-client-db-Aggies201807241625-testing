CREATE TABLE [src].[VTXpayment_distribution]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id] [numeric] (18, 0) NULL,
[payment_id] [numeric] (18, 0) NULL,
[order_item_id] [numeric] (18, 0) NULL,
[product_id] [numeric] (18, 0) NULL,
[settlement_code_id] [numeric] (18, 0) NULL,
[dist_date] [datetime2] (6) NULL,
[user_id] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[outlet_id] [numeric] (10, 0) NULL,
[channel_id] [numeric] (10, 0) NULL,
[amount] [numeric] (19, 4) NULL,
[fully_paid_qty] [numeric] (10, 0) NULL,
[fully_paid_amount] [numeric] (19, 4) NULL
)
GO
