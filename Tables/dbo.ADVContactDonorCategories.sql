CREATE TABLE [dbo].[ADVContactDonorCategories]
(
[ContactID] [int] NOT NULL,
[CategoryID] [int] NOT NULL,
[Value] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
CREATE NONCLUSTERED INDEX [nci_wi_ADVContactDonorCategories_6F25E0BEDDE783044AE4A4BBAE72529B] ON [dbo].[ADVContactDonorCategories] ([CategoryID], [ContactID])
GO
