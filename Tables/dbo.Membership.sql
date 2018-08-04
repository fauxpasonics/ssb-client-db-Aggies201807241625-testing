CREATE TABLE [dbo].[Membership]
(
[MembID] [int] NOT NULL,
[MembershipName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TransYear] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[Membership] ADD CONSTRAINT [PK_Memberships_b8706e49-bfc6-4994-b55f-bee5475be11e] PRIMARY KEY CLUSTERED  ([MembID])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_Membership_MembershipName] ON [dbo].[Membership] ([MembershipName], [TransYear])
GO
