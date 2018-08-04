CREATE TABLE [apietl].[MailChimp_ListMembers_members_stats_2]
(
[MailChimp_ListMembers_members_stats_id] [uniqueidentifier] NOT NULL,
[MailChimp_ListMembers_members_id] [uniqueidentifier] NULL,
[avg_open_rate] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[avg_click_rate] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_ListMembers_members_stats_2] ADD CONSTRAINT [PK__MailChim__DB8C58738788F53C] PRIMARY KEY CLUSTERED  ([MailChimp_ListMembers_members_stats_id])
GO
