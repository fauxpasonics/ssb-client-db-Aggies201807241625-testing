CREATE TABLE [amy].[suite_issue]
(
[SuiteAllocationsId] [int] NOT NULL IDENTITY(1, 1),
[adnumber] [int] NULL,
[Suite] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[programid] [int] NULL,
[programname] [nvarchar] (61) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transyear] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[renewalyear] [int] NULL,
[donationtype] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amountexpected] [decimal] (10, 2) NULL,
[percentexpected] [decimal] (10, 4) NULL,
[seatareaid] [int] NULL,
[totaldue] [decimal] (10, 2) NULL,
[CreateDate] [datetime] NULL,
[CreateUser] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateDate] [datetime] NULL,
[UpdateUser] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alternateduedate] [date] NULL
)
GO
