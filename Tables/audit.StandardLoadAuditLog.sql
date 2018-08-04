CREATE TABLE [audit].[StandardLoadAuditLog]
(
[StandardLoadAuditLogID] [int] NOT NULL IDENTITY(1, 1),
[LoadDate] [datetime] NULL,
[LoadView] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadGuid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordCount] [int] NULL
)
GO
ALTER TABLE [audit].[StandardLoadAuditLog] ADD CONSTRAINT [PK__Standard__91742232C6FAEB1D] PRIMARY KEY CLUSTERED  ([StandardLoadAuditLogID])
GO
