CREATE TABLE [amy].[suitepricing_tmp]
(
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
[endyear] [int] NULL
)
GO
