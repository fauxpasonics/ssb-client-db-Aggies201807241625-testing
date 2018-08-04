CREATE TABLE [dbo].[ADVReps]
(
[RepID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FullName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SecurityLevel] [int] NULL,
[EmailProgram] [int] NULL,
[LogOnProfile] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogOnPassword] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogOnProxy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
