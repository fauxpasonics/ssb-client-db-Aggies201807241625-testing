CREATE TABLE [mdm].[release_sql_log]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[release_version] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clientdb] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[release_step] [int] NULL,
[category] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sql_text] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[succeeded] [bit] NULL CONSTRAINT [DF__release_s__succe__524F1B17] DEFAULT ((0)),
[insertdate] [datetime] NULL CONSTRAINT [DF__release_s__inser__53433F50] DEFAULT (getdate()),
[lastupdated] [datetime] NULL,
[error_msg] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
