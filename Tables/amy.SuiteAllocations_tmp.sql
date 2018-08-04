CREATE TABLE [amy].[SuiteAllocations_tmp]
(
[adnumber] [int] NULL,
[Suite] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[programid] [int] NULL,
[programname] [nvarchar] (61) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transyear] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[renewalyear] [int] NULL,
[donationtype] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amountexpected] [decimal] (10, 2) NULL,
[percentexpected] [decimal] (10, 2) NULL,
[seatareaid] [int] NULL,
[totaldue] [decimal] (10, 2) NULL,
[updatedate] [datetime] NULL
)
GO
