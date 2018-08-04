CREATE TABLE [apietl].[MailChimp_PutRequest_audit_trail_source_object_log]
(
[ETL__audit_id] [uniqueidentifier] NOT NULL,
[ETL__MailChimp_PutRequest_id] [uniqueidentifier] NULL,
[ETL__session_id] [uniqueidentifier] NOT NULL,
[ETL__insert_datetime] [datetime] NOT NULL CONSTRAINT [DF__MailChimp__ETL____5378497A] DEFAULT (getutcdate()),
[json_payload] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[raw_response] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_PutRequest_audit_trail_source_object_log] ADD CONSTRAINT [PK__MailChim__DB9573BC196EACE9] PRIMARY KEY CLUSTERED  ([ETL__audit_id])
GO
