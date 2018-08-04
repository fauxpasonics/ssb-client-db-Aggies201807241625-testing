CREATE TABLE [apietl].[MailChimp_ListMembers_audit_trail_source_object_log]
(
[audit_id] [uniqueidentifier] NOT NULL,
[MailChimp_ListMembers_id] [uniqueidentifier] NULL,
[session_id] [uniqueidentifier] NOT NULL,
[insert_datetime] [datetime] NOT NULL CONSTRAINT [DF__MailChimp__inser__4DBF7024] DEFAULT (getutcdate()),
[json_payload] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[raw_response] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_ListMembers_audit_trail_source_object_log] ADD CONSTRAINT [PK__MailChim__5AF33E3354F4C7F6] PRIMARY KEY CLUSTERED  ([audit_id])
GO
