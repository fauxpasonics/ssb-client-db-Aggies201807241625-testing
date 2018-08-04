CREATE TABLE [ods].[VTXorder_offers]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_id] [numeric] (20, 0) NULL,
[offer_id] [numeric] (20, 0) NULL
)
GO
ALTER TABLE [ods].[VTXorder_offers] ADD CONSTRAINT [PK__VTXorder__7EF6BFCD7A3B5E43] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
CREATE NONCLUSTERED INDEX [IX_offer_ID] ON [ods].[VTXorder_offers] ([offer_id])
GO
