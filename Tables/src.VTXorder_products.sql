CREATE TABLE [src].[VTXorder_products]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_id] [numeric] (20, 0) NULL,
[product_id] [numeric] (20, 0) NULL,
[status] [int] NULL,
[quantity] [numeric] (20, 0) NULL,
[value] [numeric] (20, 4) NULL,
[payments_cleared] [numeric] (20, 4) NULL,
[payments_scheduled] [numeric] (20, 4) NULL,
[payment_balance] [numeric] (20, 4) NULL
)
GO
CREATE NONCLUSTERED INDEX [IX_order_id] ON [src].[VTXorder_products] ([order_id])
GO
ALTER INDEX [IX_order_id] ON [src].[VTXorder_products] DISABLE
GO
