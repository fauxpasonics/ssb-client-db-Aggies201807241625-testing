CREATE TABLE [apietl].[MailChimp_Lists_lists__links_2]
(
[ETL__MailChimp_Lists_lists__links_id] [uniqueidentifier] NOT NULL,
[ETL__MailChimp_Lists_lists_id] [uniqueidentifier] NULL,
[rel] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[href] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[method] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[targetSchema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[schema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_Lists_lists__links_2] ADD CONSTRAINT [PK__MailChim__691722B22543B340] PRIMARY KEY CLUSTERED  ([ETL__MailChimp_Lists_lists__links_id])
GO
