CREATE TABLE [amy].[capital_percent]
(
[capital_percentid] [int] NOT NULL IDENTITY(1, 1),
[adnumber] [int] NULL,
[accountname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seatregionname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seatregionid] [int] NOT NULL,
[qty] [int] NULL,
[percentdue] [numeric] (10, 2) NULL,
[ticketyear] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__capital_p__Creat__424DBD78] DEFAULT (getdate()),
[CreateUser] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__capital_p__Creat__4341E1B1] DEFAULT (user_name()),
[UpdateDate] [datetime] NULL,
[UpdateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  TRIGGER [amy].[AUR_Capital_Percent] ON [amy].[capital_percent]
AFTER UPDATE
AS
Begin
Update T
Set T.UpdateDate = Getdate(), T.UpdateUser = User_name()
from amy.Capital_Percent T
JOIN INSERTED I
ON I.capital_percentID = T.capital_percentID
End
GO
DISABLE TRIGGER [amy].[AUR_Capital_Percent] ON [amy].[capital_percent]
GO
