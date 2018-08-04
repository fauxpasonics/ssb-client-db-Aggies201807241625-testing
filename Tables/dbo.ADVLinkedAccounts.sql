CREATE TABLE [dbo].[ADVLinkedAccounts]
(
[PK] [int] NOT NULL,
[ContactID] [int] NULL,
[LinkedAccount] [int] NULL,
[PercentOfPoints] [float] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
