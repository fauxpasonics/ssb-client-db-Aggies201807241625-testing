CREATE TABLE [dbo].[ADVContactPointsSummary]
(
[PK] [int] NOT NULL,
[ContactID] [int] NOT NULL,
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Points] [float] NULL,
[Linked] [bit] NOT NULL,
[Value] [money] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
CREATE NONCLUSTERED INDEX [nci_wi_ADVContactPointsSummary_650FBA9E0AF8FB2848D66850659029C0] ON [dbo].[ADVContactPointsSummary] ([ContactID]) INCLUDE ([Description], [Points])
GO
