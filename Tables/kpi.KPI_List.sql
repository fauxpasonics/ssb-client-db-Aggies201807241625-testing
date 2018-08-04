CREATE TABLE [kpi].[KPI_List]
(
[KPIID] [int] NOT NULL,
[Enabled] [int] NULL,
[ClientSpecific] [int] NULL CONSTRAINT [DF_KPI_List_ClientSpecific] DEFAULT ((1)),
[ClientId] [int] NULL,
[CATID] [int] NULL,
[KPIDisplayName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[KPIDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KPICount_Query] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[KPIDetail_Query] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_KPI_List_CreatedDate] DEFAULT (getdate()),
[LastModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModifiedDate] [datetime] NULL CONSTRAINT [DF_KPI_List_LastModifiedDate] DEFAULT (getdate())
)
GO
ALTER TABLE [kpi].[KPI_List] ADD CONSTRAINT [PK__KPI_List__72E6928183676037] PRIMARY KEY CLUSTERED  ([KPIID])
GO
