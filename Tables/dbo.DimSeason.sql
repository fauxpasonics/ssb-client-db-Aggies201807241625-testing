CREATE TABLE [dbo].[DimSeason]
(
[DimSeasonId] [int] NOT NULL,
[DimArenaId] [int] NULL,
[SeasonCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeasonName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeasonDesc] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeasonClass] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeasonYear] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrevSeasonId] [int] NULL,
[SeasonStartDate] [date] NULL,
[SeasonEndDate] [date] NULL,
[ManifestId] [int] NULL,
[Active] [bit] NULL,
[SSCreatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSUpdatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSCreatedDate] [smalldatetime] NULL,
[SSUpdatedDate] [smalldatetime] NULL,
[SSID] [int] NULL,
[SSID_season_id] [int] NULL,
[SourceSystem] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeltaHashKey] [binary] (32) NULL,
[CreatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [smalldatetime] NOT NULL,
[UpdatedDate] [smalldatetime] NOT NULL,
[IsDeleted] [bit] NULL,
[DeleteDate] [smalldatetime] NULL,
[Config_IsFactSalesEligible] [bit] NULL,
[Config_IsMultiYearSeason] [bit] NULL,
[Config_SeasonOrg] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Config_DefaultDimSeasonHeaderId] [int] NULL,
[Config_SeasonEventCntFSE] [int] NULL
)
GO
ALTER TABLE [dbo].[DimSeason] ADD CONSTRAINT [PK_DimSeason] PRIMARY KEY CLUSTERED  ([DimSeasonId])
GO
