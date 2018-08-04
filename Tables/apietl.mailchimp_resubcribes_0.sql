CREATE TABLE [apietl].[mailchimp_resubcribes_0]
(
[ETL__mailchimp_resubcribes_id] [uniqueidentifier] NOT NULL,
[ETL__session_id] [uniqueidentifier] NOT NULL,
[ETL__insert_datetime] [datetime] NOT NULL CONSTRAINT [DF__mailchimp__ETL____546C6DB3] DEFAULT (getutcdate()),
[ETL__multi_query_value_for_audit] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[total_operations] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[finished_operations] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[errored_operations] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[submitted_at] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[completed_at] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[response_body_url] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[mailchimp_resubcribes_0] ADD CONSTRAINT [PK__mailchim__9D233E24FD15E6E0] PRIMARY KEY CLUSTERED  ([ETL__mailchimp_resubcribes_id])
GO
