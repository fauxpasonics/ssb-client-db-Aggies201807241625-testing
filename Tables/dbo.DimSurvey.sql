CREATE TABLE [dbo].[DimSurvey]
(
[DimSurveyId] [int] NOT NULL,
[SportName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SurveyYear] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSID_SurveyId] [bigint] NULL,
[PriorYearSurvey] [int] NULL
)
GO
