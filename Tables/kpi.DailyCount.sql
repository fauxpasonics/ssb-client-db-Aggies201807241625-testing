CREATE TABLE [kpi].[DailyCount]
(
[KPIDC_ID] [int] NOT NULL IDENTITY(1, 1),
[ClientID] [int] NULL,
[CATID] [int] NULL,
[KPIID] [int] NULL,
[DateID] [date] NULL,
[KPIValue] [float] NULL
)
GO
ALTER TABLE [kpi].[DailyCount] ADD CONSTRAINT [PK__DailyCou__9AF5538C6373615E] PRIMARY KEY CLUSTERED  ([KPIDC_ID])
GO
