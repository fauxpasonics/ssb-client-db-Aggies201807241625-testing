CREATE TABLE [dbo].[DimItem]
(
[DimItemId] [int] NOT NULL,
[DimSeasonId] [int] NOT NULL,
[ItemCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemDesc] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemClass] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSCreatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSUpdatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSCreatedDate] [smalldatetime] NULL,
[SSUpdatedDate] [smalldatetime] NULL,
[SSID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSID_event_id] [int] NULL,
[SourceSystem] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeltaHashKey] [binary] (32) NULL,
[CreatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [smalldatetime] NOT NULL,
[UpdatedDate] [smalldatetime] NOT NULL,
[IsDeleted] [bit] NOT NULL,
[DeleteDate] [smalldatetime] NULL,
[Config_IsFactSalesEligible] [bit] NULL,
[Config_IsClosed] [bit] NULL,
[DimSeasonHeaderId] [int] NULL
)
GO
ALTER TABLE [dbo].[DimItem] ADD CONSTRAINT [PK_DimItem] PRIMARY KEY CLUSTERED  ([DimItemId])
GO
