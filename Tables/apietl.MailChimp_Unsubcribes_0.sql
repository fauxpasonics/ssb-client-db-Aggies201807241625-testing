CREATE TABLE [apietl].[MailChimp_Unsubcribes_0]
(
[ETL__MailChimp_Unsubcribes_id] [uniqueidentifier] NOT NULL,
[ETL__session_id] [uniqueidentifier] NOT NULL,
[ETL__insert_datetime] [datetime] NOT NULL CONSTRAINT [DF__MailChimp__ETL____5654B625] DEFAULT (getutcdate()),
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
ALTER TABLE [apietl].[MailChimp_Unsubcribes_0] ADD CONSTRAINT [PK__MailChim__2D820D39A48AA09F] PRIMARY KEY CLUSTERED  ([ETL__MailChimp_Unsubcribes_id])
GO
