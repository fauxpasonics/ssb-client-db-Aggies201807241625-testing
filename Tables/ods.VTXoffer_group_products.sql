CREATE TABLE [ods].[VTXoffer_group_products]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[group_id] [numeric] (20, 0) NULL,
[product_id] [numeric] (20, 0) NULL,
[disp_order] [numeric] (20, 0) NULL,
[optional] [smallint] NULL
)
GO
ALTER TABLE [ods].[VTXoffer_group_products] ADD CONSTRAINT [PK__VTXoffer__7EF6BFCD9BF482DB] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
