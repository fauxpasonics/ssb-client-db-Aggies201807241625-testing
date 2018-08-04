CREATE TABLE [dbo].[DimQuestion]
(
[DimQuestionId] [int] NOT NULL,
[QuestionType] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuestionHeader] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuestionSubHeader] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportType] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncludeInReport] [bit] NULL,
[QuestionLayout] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportQuestionSubHeader] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DimQuestionParentId] [int] NULL
)
GO
