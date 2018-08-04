CREATE TABLE [amy].[SuiteAllocations]
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
[alternateduedate] [date] NULL,
[sporttype] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[programcode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create TRIGGER [amy].[AUR_SuiteAllocations] ON [amy].[SuiteAllocations]
AFTER UPDATE
AS
Begin
Update T
Set T.UpdateDate = Getdate(), T.UpdateUser = User_name()
from amy.SuiteAllocations T
JOIN INSERTED I
ON I.SuiteAllocationsID = T.SuiteAllocationsID
End
GO
DISABLE TRIGGER [amy].[AUR_SuiteAllocations] ON [amy].[SuiteAllocations]
GO
ALTER TABLE [amy].[SuiteAllocations] ADD CONSTRAINT [PK__SUITEALLOCATIONS_ID] PRIMARY KEY CLUSTERED  ([SuiteAllocationsId])
GO
CREATE NONCLUSTERED INDEX [idx_suiteallocations_adnumber_suite_programid] ON [amy].[SuiteAllocations] ([adnumber], [Suite], [programid])
GO
