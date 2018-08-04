CREATE TABLE [apietl].[MailChimp_Lists__links_1]
(
[ETL__MailChimp_Lists__links_id] [uniqueidentifier] NOT NULL,
[ETL__MailChimp_Lists_id] [uniqueidentifier] NULL,
[rel] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[href] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[method] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[targetSchema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[schema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_Lists__links_1] ADD CONSTRAINT [PK__MailChim__6DA015A9F1C23FE9] PRIMARY KEY CLUSTERED  ([ETL__MailChimp_Lists__links_id])
GO
