CREATE TABLE [ods].[VTXorder_products]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
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
ALTER TABLE [ods].[VTXorder_products] ADD CONSTRAINT [PK__VTXorder__7EF6BFCD3679912C] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
