CREATE TABLE [src].[VTXorder_items]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id] [numeric] (18, 0) NULL,
[order_id] [numeric] (10, 0) NULL,
[sale_date] [datetime2] (6) NULL,
[sale_user] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sale_outlet] [numeric] (10, 0) NULL,
[sale_channel] [numeric] (10, 0) NULL,
[value] [numeric] (19, 4) NULL,
[paid_amount] [numeric] (19, 4) NULL,
[product_id] [numeric] (10, 0) NULL,
[inventory_type] [smallint] NULL,
[primary_product_id] [numeric] (18, 0) NULL,
[number1] [numeric] (10, 0) NULL,
[number2] [numeric] (10, 0) NULL,
[number3] [numeric] (10, 0) NULL,
[number4] [numeric] (10, 0) NULL,
[number5] [numeric] (10, 0) NULL,
[number6] [numeric] (10, 0) NULL,
[number7] [numeric] (10, 0) NULL,
[number8] [numeric] (10, 0) NULL,
[number9] [numeric] (10, 0) NULL,
[number10] [numeric] (10, 0) NULL,
[number11] [numeric] (10, 0) NULL,
[number12] [numeric] (10, 0) NULL,
[number13] [numeric] (10, 0) NULL,
[number14] [numeric] (10, 0) NULL,
[number15] [numeric] (10, 0) NULL,
[string1] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[string2] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[string3] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[string4] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[string5] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[canceled] [smallint] NULL,
[cancel_date] [datetime2] (6) NULL,
[cancel_user] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cancel_outlet] [numeric] (10, 0) NULL,
[cancel_channel] [numeric] (10, 0) NULL,
[offer_restriction_id] [numeric] (18, 0) NULL,
[customer_restriction_id] [numeric] (18, 0) NULL
)
GO
CREATE NONCLUSTERED INDEX [IX_canceled] ON [src].[VTXorder_items] ([canceled])
GO
ALTER INDEX [IX_canceled] ON [src].[VTXorder_items] DISABLE
GO
CREATE NONCLUSTERED INDEX [IX_order_id] ON [src].[VTXorder_items] ([order_id])
GO
ALTER INDEX [IX_order_id] ON [src].[VTXorder_items] DISABLE
GO
CREATE NONCLUSTERED INDEX [IX_product_id] ON [src].[VTXorder_items] ([product_id])
GO
ALTER INDEX [IX_product_id] ON [src].[VTXorder_items] DISABLE
GO
