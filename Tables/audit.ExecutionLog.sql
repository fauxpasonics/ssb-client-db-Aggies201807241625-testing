CREATE TABLE [audit].[ExecutionLog]
(
[ExecutionLogID] [int] NOT NULL IDENTITY(1, 1),
[ExecutionID] [bigint] NULL,
[ExecutedBy] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PackageName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientDB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartTime] [datetime] NULL,
[EndTime] [datetime] NULL
)
GO
ALTER TABLE [audit].[ExecutionLog] ADD CONSTRAINT [PK_ExecutionLog_ExecutionLogID] PRIMARY KEY CLUSTERED  ([ExecutionLogID])
GO
