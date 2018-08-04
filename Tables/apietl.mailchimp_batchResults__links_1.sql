CREATE TABLE [apietl].[mailchimp_batchResults__links_1]
(
[ETL__mailchimp_batchResults__links_id] [uniqueidentifier] NOT NULL,
[ETL__mailchimp_batchResults_id] [uniqueidentifier] NULL,
[rel] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[href] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[method] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[targetSchema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[schema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[mailchimp_batchResults__links_1] ADD CONSTRAINT [PK__mailchim__EF7346E426EF77E3] PRIMARY KEY CLUSTERED  ([ETL__mailchimp_batchResults__links_id])
GO
