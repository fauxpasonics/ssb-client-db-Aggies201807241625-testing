CREATE TABLE [apietl].[MailChimp_ListMembers_Prod_members_stats_2]
(
[ETL__MailChimp_ListMembers_Prod_members_stats_id] [uniqueidentifier] NOT NULL,
[ETL__MailChimp_ListMembers_Prod_members_id] [uniqueidentifier] NULL,
[avg_open_rate] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[avg_click_rate] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_ListMembers_Prod_members_stats_2] ADD CONSTRAINT [PK__MailChim__FD15D7C2799ED045] PRIMARY KEY CLUSTERED  ([ETL__MailChimp_ListMembers_Prod_members_stats_id])
GO
