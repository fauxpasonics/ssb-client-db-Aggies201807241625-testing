CREATE TABLE [apietl].[mailchimp_resubcribes__links_1]
(
[ETL__mailchimp_resubcribes__links_id] [uniqueidentifier] NOT NULL,
[ETL__mailchimp_resubcribes_id] [uniqueidentifier] NULL,
[rel] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[href] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[method] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[targetSchema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[schema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[mailchimp_resubcribes__links_1] ADD CONSTRAINT [PK__mailchim__96E09BF738CF1002] PRIMARY KEY CLUSTERED  ([ETL__mailchimp_resubcribes__links_id])
GO
