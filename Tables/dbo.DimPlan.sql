CREATE TABLE [dbo].[DimPlan]
(
[DimPlanId] [int] NOT NULL,
[DimSeasonId] [int] NULL,
[PlanCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanDesc] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanClass] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanFse] [decimal] (3, 2) NULL,
[PlanType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanEventCnt] [int] NULL,
[PlanStartDate] [date] NULL,
[PlanEndDate] [date] NULL,
[PlanStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[FullSeasonEventCnt] [int] NULL
)
GO
ALTER TABLE [dbo].[DimPlan] ADD CONSTRAINT [PK_DimPlan] PRIMARY KEY CLUSTERED  ([DimPlanId])
GO
