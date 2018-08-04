CREATE TABLE [audit].[ExecutionRestartPoint]
(
[ClientDB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExecutionID] [bigint] NULL,
[ExecutionTaskID] [uniqueidentifier] NULL,
[FailureDate] [datetime] NULL
)
GO
