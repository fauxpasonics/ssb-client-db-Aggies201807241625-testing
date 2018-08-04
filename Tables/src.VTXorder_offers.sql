CREATE TABLE [src].[VTXorder_offers]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_id] [numeric] (20, 0) NULL,
[offer_id] [numeric] (20, 0) NULL
)
GO
CREATE NONCLUSTERED INDEX [IX_offer_ID] ON [src].[VTXorder_offers] ([offer_id])
GO
ALTER INDEX [IX_offer_ID] ON [src].[VTXorder_offers] DISABLE
GO
