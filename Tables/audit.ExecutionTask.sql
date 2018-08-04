CREATE TABLE [audit].[ExecutionTask]
(
[ExecutionTaskID] [uniqueidentifier] NOT NULL,
[PackageName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Restartability] [bit] NULL,
[InsertDate] [datetime] NULL CONSTRAINT [DF_ExecutionTask_InsertDate] DEFAULT (getdate()),
[UpdateDate] [datetime] NULL CONSTRAINT [DF_ExecutionTask_UpdateDate] DEFAULT (getdate())
)
GO
ALTER TABLE [audit].[ExecutionTask] ADD CONSTRAINT [PK_ExecutionTask_ExecutionTaskID] PRIMARY KEY CLUSTERED  ([ExecutionTaskID])
GO
ALTER TABLE [audit].[ExecutionTask] ADD CONSTRAINT [UC_ExecutionTask_ExecutionTaskID_PackageName_TaskName] UNIQUE NONCLUSTERED  ([ExecutionTaskID], [PackageName], [TaskName])
GO
