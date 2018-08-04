CREATE TABLE [dbo].[FactSecSurveyAggies]
(
[DimQuestionId] [int] NOT NULL,
[DimSurveyId] [int] NOT NULL,
[DimSchoolId] [int] NULL,
[DimTicketSpanId] [int] NOT NULL,
[Points] [bigint] NULL,
[Responses] [int] NULL,
[LoadDate] [datetime] NOT NULL,
[DimTicketTypeId] [int] NOT NULL,
[DimMobileProviderId] [int] NOT NULL,
[Email] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RespondentId] [bigint] NOT NULL,
[RespondentCount] [int] NULL
)
GO
