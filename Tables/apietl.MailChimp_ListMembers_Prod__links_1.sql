CREATE TABLE [apietl].[MailChimp_ListMembers_Prod__links_1]
(
[ETL__MailChimp_ListMembers_Prod__links_id] [uniqueidentifier] NOT NULL,
[ETL__MailChimp_ListMembers_Prod_id] [uniqueidentifier] NULL,
[rel] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[href] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[method] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[targetSchema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[schema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_ListMembers_Prod__links_1] ADD CONSTRAINT [PK__MailChim__DA604509F3C71F29] PRIMARY KEY CLUSTERED  ([ETL__MailChimp_ListMembers_Prod__links_id])
GO
