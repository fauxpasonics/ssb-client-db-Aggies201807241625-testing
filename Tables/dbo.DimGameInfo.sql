CREATE TABLE [dbo].[DimGameInfo]
(
[DimGameInfoId] [int] NOT NULL,
[Outcome] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PistonsScore] [int] NULL,
[OpponentScore] [int] NULL,
[RecordToDateWin] [int] NULL,
[RecordToDateLoss] [int] NULL,
[OpponentRecordToDateWin] [int] NULL,
[OpponentRecordToDateLoss] [int] NULL,
[Qtr1StartTime] [smalldatetime] NULL,
[Qtr1EndTime] [smalldatetime] NULL,
[Qtr2StartTime] [smalldatetime] NULL,
[Qtr2EndTime] [smalldatetime] NULL,
[Qtr3StartTime] [smalldatetime] NULL,
[Qtr3EndTime] [smalldatetime] NULL,
[Qtr4StartTime] [smalldatetime] NULL,
[Qtr4EndTime] [smalldatetime] NULL,
[OvertimePeriods] [int] NULL,
[CreatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [smalldatetime] NOT NULL,
[UpdatedDate] [smalldatetime] NOT NULL,
[IsDeleted] [bit] NOT NULL,
[DeleteDate] [smalldatetime] NULL,
[SSID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceSystem] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [dbo].[DimGameInfo] ADD CONSTRAINT [PK_DimGameInfo] PRIMARY KEY CLUSTERED  ([DimGameInfoId])
GO
