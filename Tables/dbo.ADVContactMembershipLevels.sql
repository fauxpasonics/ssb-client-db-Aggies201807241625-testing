CREATE TABLE [dbo].[ADVContactMembershipLevels]
(
[ContactID] [int] NOT NULL,
[MembID] [int] NOT NULL,
[OverrideLevel] [int] NULL,
[PledgeLevel] [int] NULL,
[ReceiptLevel] [int] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
CREATE NONCLUSTERED INDEX [nci_wi_ADVContactMembershipLevels_10FB817BC6CE4CE3A91EEF3C770FB25D] ON [dbo].[ADVContactMembershipLevels] ([ContactID]) INCLUDE ([MembID], [ReceiptLevel])
GO
