CREATE TABLE [dbo].[DimSeasonHeader]
(
[DimSeasonHeaderId] [int] NOT NULL,
[DimArenaId] [int] NULL,
[SeasonCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeasonName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeasonDesc] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeasonClass] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeasonYear] [int] NULL,
[PrevSeasonHeaderId] [int] NULL,
[SeasonStartDate] [date] NULL,
[SeasonEndDate] [date] NULL,
[Active] [bit] NULL,
[CreatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [smalldatetime] NOT NULL,
[UpdatedDate] [smalldatetime] NOT NULL,
[IsDeleted] [bit] NOT NULL,
[DeleteDate] [smalldatetime] NULL,
[Config_Org] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Config_AccountingYearName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Config_AccountingYearStartDate] [date] NULL,
[Config_AccountingYearEndDate] [date] NULL
)
GO
ALTER TABLE [dbo].[DimSeasonHeader] ADD CONSTRAINT [PK_DimSeasonHeader] PRIMARY KEY CLUSTERED  ([DimSeasonHeaderId])
GO
