CREATE TABLE [apietl].[MailChimp_ListMembers_Prod_audit_trail_source_object_log]
(
[ETL__audit_id] [uniqueidentifier] NOT NULL,
[ETL__MailChimp_ListMembers_Prod_id] [uniqueidentifier] NULL,
[ETL__session_id] [uniqueidentifier] NOT NULL,
[ETL__insert_datetime] [datetime] NOT NULL CONSTRAINT [DF__MailChimp__ETL____4FA7B896] DEFAULT (getutcdate()),
[json_payload] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[raw_response] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_ListMembers_Prod_audit_trail_source_object_log] ADD CONSTRAINT [PK__MailChim__DB9573BCB5CCF71C] PRIMARY KEY CLUSTERED  ([ETL__audit_id])
GO
