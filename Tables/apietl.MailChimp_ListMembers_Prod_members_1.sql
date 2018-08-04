CREATE TABLE [apietl].[MailChimp_ListMembers_Prod_members_1]
(
[ETL__MailChimp_ListMembers_Prod_members_id] [uniqueidentifier] NOT NULL,
[ETL__MailChimp_ListMembers_Prod_id] [uniqueidentifier] NULL,
[id] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_address] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unique_email_id] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_type] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ip_signup] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp_signup] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ip_opt] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp_opt] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[member_rating] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_changed] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[language] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vip] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_client] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[list_id] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unsubscribe_reason] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_ListMembers_Prod_members_1] ADD CONSTRAINT [PK__MailChim__5ED6A8CD39C4E861] PRIMARY KEY CLUSTERED  ([ETL__MailChimp_ListMembers_Prod_members_id])
GO
