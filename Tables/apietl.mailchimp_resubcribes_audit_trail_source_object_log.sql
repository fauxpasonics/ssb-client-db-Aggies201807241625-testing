CREATE TABLE [apietl].[mailchimp_resubcribes_audit_trail_source_object_log]
(
[ETL__audit_id] [uniqueidentifier] NOT NULL,
[ETL__mailchimp_resubcribes_id] [uniqueidentifier] NULL,
[ETL__session_id] [uniqueidentifier] NOT NULL,
[ETL__insert_datetime] [datetime] NOT NULL CONSTRAINT [DF__mailchimp__ETL____556091EC] DEFAULT (getutcdate()),
[json_payload] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[raw_response] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[mailchimp_resubcribes_audit_trail_source_object_log] ADD CONSTRAINT [PK__mailchim__DB9573BC3E7A1873] PRIMARY KEY CLUSTERED  ([ETL__audit_id])
GO
