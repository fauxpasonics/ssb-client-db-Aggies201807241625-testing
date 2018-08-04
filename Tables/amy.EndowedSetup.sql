CREATE TABLE [amy].[EndowedSetup]
(
[EndowedSetupID] [int] NOT NULL IDENTITY(1, 1),
[ADNumber] [int] NULL,
[ActiveStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeasonQty] [int] NULL,
[RoadGameQty] [int] NULL,
[PriceCode] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EstablishedYear] [int] NULL,
[EndDate] [int] NULL,
[EndDateInitialLength] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Endowment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Terms] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Beneficiaries] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpouseName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL,
[CreateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateDate] [datetime] NULL,
[UpdateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pastadnumber] [int] NULL,
[ActualQtyUsed] [int] NULL,
[EndowedCreditTotal] [decimal] (10, 2) NULL,
[EndowmentNumber] [int] NULL
)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  TRIGGER [amy].[AUR_EndowedSetup] ON [amy].[EndowedSetup]
AFTER UPDATE
AS
Begin
Update T
Set T.UpdateDate = Getdate(), T.UpdateUser = User_name()
from amy.EndowedSetup T
JOIN INSERTED I
ON I.EndowedSetupID = T.EndowedSetupID
End
GO
DISABLE TRIGGER [amy].[AUR_EndowedSetup] ON [amy].[EndowedSetup]
GO
