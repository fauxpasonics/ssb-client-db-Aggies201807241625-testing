CREATE TABLE [apietl].[MailChimp_ListMembers__links_1]
(
[MailChimp_ListMembers__links_id] [uniqueidentifier] NOT NULL,
[MailChimp_ListMembers_id] [uniqueidentifier] NULL,
[rel] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[href] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[method] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[targetSchema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[schema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_ListMembers__links_1] ADD CONSTRAINT [PK__MailChim__A75EFBE47B293A6E] PRIMARY KEY CLUSTERED  ([MailChimp_ListMembers__links_id])
GO
