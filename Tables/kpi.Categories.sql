CREATE TABLE [kpi].[Categories]
(
[CATID] [int] NOT NULL,
[ParentID] [int] NULL,
[LowestGranularity] [bit] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Enabled] [bit] NULL
)
GO
ALTER TABLE [kpi].[Categories] ADD CONSTRAINT [PK__Categori__709E29DBF62030A6] PRIMARY KEY CLUSTERED  ([CATID])
GO
