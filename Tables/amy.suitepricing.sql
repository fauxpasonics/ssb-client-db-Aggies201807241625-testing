CREATE TABLE [amy].[suitepricing]
(
[SuitePricingID] [int] NOT NULL IDENTITY(1, 1),
[Seatareaid] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SectionNum] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAPTotal] [decimal] (10, 2) NULL,
[Annual] [decimal] (10, 2) NULL,
[NumberofSeats] [int] NULL,
[SRO] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CombinedCAPperseat] [decimal] (10, 2) NULL,
[AnnualPerSeat] [decimal] (10, 2) NULL,
[KFC-FoundersSuiteOptional] [decimal] (10, 2) NULL,
[KFC-FoundersSuiteRequired] [decimal] (10, 2) NULL,
[Notes] [nvarchar] (56) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[startyear] [int] NULL,
[endyear] [int] NULL,
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
create TRIGGER [amy].[AUR_SuitePricing] ON [amy].[suitepricing]
AFTER UPDATE
AS
Begin
Update T
Set T.UpdateDate = Getdate(), T.UpdateUser = User_name()
from amy.SuitePricing T
JOIN INSERTED I
ON I.SuitePricingID = T.SuitePricingID
End
GO
DISABLE TRIGGER [amy].[AUR_SuitePricing] ON [amy].[suitepricing]
GO
ALTER TABLE [amy].[suitepricing] ADD CONSTRAINT [PK__suitepricing_ID] PRIMARY KEY CLUSTERED  ([SuitePricingID])
GO
