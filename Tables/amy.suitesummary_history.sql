CREATE TABLE [amy].[suitesummary_history]
(
[SuiteSummaryID] [int] NOT NULL IDENTITY(1, 1),
[suitesection] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[accountnumber] [int] NULL,
[TotalTickets] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAP_Percent] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAP_Percent_Description] [nvarchar] (77) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suiteparking] [nvarchar] (102) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAPExpected] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AnnualExpected] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL,
[CreateUser] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateDate] [datetime] NULL,
[UpdateUser] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ticketyear] [int] NOT NULL
)
GO
