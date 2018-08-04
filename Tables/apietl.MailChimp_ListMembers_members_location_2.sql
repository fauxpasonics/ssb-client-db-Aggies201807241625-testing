CREATE TABLE [apietl].[MailChimp_ListMembers_members_location_2]
(
[MailChimp_ListMembers_members_location_id] [uniqueidentifier] NOT NULL,
[MailChimp_ListMembers_members_id] [uniqueidentifier] NULL,
[latitude] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[longitude] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gmtoff] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dstoff] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country_code] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timezone] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_ListMembers_members_location_2] ADD CONSTRAINT [PK__MailChim__0CE9A7CB144B0132] PRIMARY KEY CLUSTERED  ([MailChimp_ListMembers_members_location_id])
GO
