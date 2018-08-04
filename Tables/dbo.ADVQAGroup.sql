CREATE TABLE [dbo].[ADVQAGroup]
(
[GroupID] [int] NOT NULL,
[GroupName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AutoAddYear] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramID] [int] NULL,
[DonorCategoryID] [int] NULL,
[CreateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [date] NULL,
[UpdateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateDate] [date] NULL,
[LifetimeIndicator] [bit] NULL,
[LoadDetailfromSummary] [bit] NULL
)
GO
