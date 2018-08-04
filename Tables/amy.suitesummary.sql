CREATE TABLE [amy].[suitesummary]
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
[UpdateUser] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create TRIGGER [amy].[AUR_SuiteSummary] ON [amy].[suitesummary]
AFTER UPDATE
AS
Begin
Update T
Set T.UpdateDate = Getdate(), T.UpdateUser = User_name()
from amy.SuiteSummary T
JOIN INSERTED I
ON I.SuiteSummaryID = T.SuiteSummaryID
End
GO
DISABLE TRIGGER [amy].[AUR_SuiteSummary] ON [amy].[suitesummary]
GO
ALTER TABLE [amy].[suitesummary] ADD CONSTRAINT [PK__SuiteSummaryID_ID] PRIMARY KEY CLUSTERED  ([SuiteSummaryID])
GO
