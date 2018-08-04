CREATE TABLE [ods].[VTXeventcategoryrelation]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventid] [numeric] (10, 0) NULL,
[categoryid] [numeric] (10, 0) NULL,
[createdate] [datetime2] (6) NULL,
[createdby] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [ods].[VTXeventcategoryrelation] ADD CONSTRAINT [PK__VTXevent__7EF6BFCD90C98ABB] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
CREATE NONCLUSTERED INDEX [idx_EventCatRel_IsDel] ON [ods].[VTXeventcategoryrelation] ([ETL_IsDeleted]) INCLUDE ([categoryid], [tixeventid])
GO
CREATE NONCLUSTERED INDEX [idx_EventCatRelation_Cat_IsDel] ON [ods].[VTXeventcategoryrelation] ([ETL_IsDeleted], [categoryid])
GO
CREATE NONCLUSTERED INDEX [idx_EventCatRel_IsDel_Event] ON [ods].[VTXeventcategoryrelation] ([ETL_IsDeleted], [tixeventid]) INCLUDE ([categoryid])
GO
