CREATE TABLE [apietl].[MailChimp_Unsubcribes__links_1]
(
[ETL__MailChimp_Unsubcribes__links_id] [uniqueidentifier] NOT NULL,
[ETL__MailChimp_Unsubcribes_id] [uniqueidentifier] NULL,
[rel] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[href] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[method] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[targetSchema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[schema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_Unsubcribes__links_1] ADD CONSTRAINT [PK__MailChim__765E5CA1BA13972A] PRIMARY KEY CLUSTERED  ([ETL__MailChimp_Unsubcribes__links_id])
GO
