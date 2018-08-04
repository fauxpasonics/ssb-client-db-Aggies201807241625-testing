CREATE TABLE [audit].[MDM_SYSTEM_AUDIT]
(
[AuditDate] [datetime] NULL,
[ClientDB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Table_Schema] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Table_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Failure_Message] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
CREATE CLUSTERED INDEX [IX_MDM_SYSTEM_AUDIT] ON [audit].[MDM_SYSTEM_AUDIT] ([AuditDate], [ClientDB])
GO
