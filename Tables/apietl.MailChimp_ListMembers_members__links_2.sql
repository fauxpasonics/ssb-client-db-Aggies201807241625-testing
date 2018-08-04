CREATE TABLE [apietl].[MailChimp_ListMembers_members__links_2]
(
[MailChimp_ListMembers_members__links_id] [uniqueidentifier] NOT NULL,
[MailChimp_ListMembers_members_id] [uniqueidentifier] NULL,
[rel] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[href] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[method] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[targetSchema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[schema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_ListMembers_members__links_2] ADD CONSTRAINT [PK__MailChim__655880C521B3213F] PRIMARY KEY CLUSTERED  ([MailChimp_ListMembers_members__links_id])
GO
