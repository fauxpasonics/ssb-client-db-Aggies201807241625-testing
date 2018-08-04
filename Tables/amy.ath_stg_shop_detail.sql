CREATE TABLE [amy].[ath_stg_shop_detail]
(
[order_date] [datetime] NULL,
[order_number] [int] NULL,
[amount] [decimal] (28, 10) NULL,
[transaction_id] [bigint] NULL,
[order_status] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unique_bill_name] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_name] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_company] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_address] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_city] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_state] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_zip] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_country] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unique_ship_name] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_name] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_company] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_address] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_city] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_state] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_zip] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_country] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_ship_phone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery_desc] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
