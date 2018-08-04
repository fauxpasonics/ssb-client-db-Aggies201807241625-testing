CREATE TABLE [dbo].[LinkedAccounts]
(
[PK] [int] NOT NULL,
[ContactID] [int] NULL,
[LinkedAccount] [int] NULL,
[PercentOfPoints] [float] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[LinkedAccounts] ADD CONSTRAINT [PK_LinkedAccounts_3fa55f9b-7681-44a2-83c5-090c9371ec02] PRIMARY KEY CLUSTERED  ([PK])
GO
