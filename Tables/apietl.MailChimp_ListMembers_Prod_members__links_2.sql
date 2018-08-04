CREATE TABLE [apietl].[MailChimp_ListMembers_Prod_members__links_2]
(
[ETL__MailChimp_ListMembers_Prod_members__links_id] [uniqueidentifier] NOT NULL,
[ETL__MailChimp_ListMembers_Prod_members_id] [uniqueidentifier] NULL,
[rel] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[href] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[method] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[targetSchema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[schema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_ListMembers_Prod_members__links_2] ADD CONSTRAINT [PK__MailChim__98CB6A631BAE7B10] PRIMARY KEY CLUSTERED  ([ETL__MailChimp_ListMembers_Prod_members__links_id])
GO
