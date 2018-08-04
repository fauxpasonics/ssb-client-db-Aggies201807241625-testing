CREATE TABLE [dbo].[ContactMembershipLevels]
(
[ContactID] [int] NOT NULL,
[MembID] [int] NOT NULL,
[OverrideLevel] [int] NULL,
[PledgeLevel] [int] NULL,
[ReceiptLevel] [int] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[ContactMembershipLevels] ADD CONSTRAINT [PK_ContactMembershipLevels_c9d572f9-2aa4-4b8f-ae6f-6e36a41f5e2c] PRIMARY KEY CLUSTERED  ([ContactID], [MembID])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_ContactMembershipLevels_MembID] ON [dbo].[ContactMembershipLevels] ([ContactID], [OverrideLevel], [PledgeLevel], [ReceiptLevel], [MembID])
GO
