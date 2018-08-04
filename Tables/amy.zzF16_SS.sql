CREATE TABLE [amy].[zzF16_SS]
(
[accountnumber] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastname] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[firstname] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventzonedesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventzonetype] [int] NULL,
[Game] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatsection] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatrow] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatseat] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[etl_IsDeleted] [bit] NULL,
[rwdeleted] [bit] NULL,
[secdeleted] [bit] NULL,
[SeatType] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[scandatetime] [datetime] NULL,
[scan_date] [datetime2] NULL
)
GO
