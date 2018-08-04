CREATE TABLE [kpi].[CLIENTS]
(
[ClientID] [int] NOT NULL,
[Client_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServerName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TI_DBName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CI_DBName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Proc_DBName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active] [bit] NULL CONSTRAINT [DF__CLIENTS__Active__02084FDA] DEFAULT ((0)),
[LastChangeDate] [datetime] NULL CONSTRAINT [DF__CLIENTS__LastCha__02FC7413] DEFAULT (getdate())
)
GO
ALTER TABLE [kpi].[CLIENTS] ADD CONSTRAINT [PK_CLIENTS] PRIMARY KEY CLUSTERED  ([ClientID])
GO
