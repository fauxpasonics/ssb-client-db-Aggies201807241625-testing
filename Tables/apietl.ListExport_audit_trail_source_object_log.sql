CREATE TABLE [apietl].[ListExport_audit_trail_source_object_log]
(
[audit_id] [uniqueidentifier] NOT NULL,
[ListExport_id] [uniqueidentifier] NULL,
[session_id] [uniqueidentifier] NOT NULL,
[insert_datetime] [datetime] NOT NULL CONSTRAINT [DF__ListExpor__inser__49EEDF40] DEFAULT (getutcdate()),
[json_payload] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[raw_response] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[ListExport_audit_trail_source_object_log] ADD CONSTRAINT [PK__ListExpo__5AF33E33C47D1169] PRIMARY KEY CLUSTERED  ([audit_id])
GO
