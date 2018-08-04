CREATE TABLE [dbo].[Contact]
(
[ContactID] [int] NOT NULL,
[ADNumber] [int] NULL,
[SetupDate] [datetime] NULL,
[Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleInitial] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Company] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Salutation] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHHome] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHBusiness] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ext] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mobile] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHOther1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHOther1Desc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHOther2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHOther2Desc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Birthday] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TicketNumber] [int] NULL,
[TicketName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AlumniInfo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpouseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpouseBirthday] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpouseAlumniInfo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChildrenNames] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CashBasisPP] [float] NULL,
[AccrualBasisPP] [float] NULL,
[AdjustedPP] [float] NULL,
[LastEdited] [datetime] NULL,
[EditedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Program] [bit] NOT NULL,
[ProgramName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Dear] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BusinessTitle] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BankName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BankCity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RoutingNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LifetimeGiving] [money] NULL,
[UDF1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingCycle] [int] NULL,
[EStatement] [bit] NOT NULL,
[FundraiserID] [int] NULL,
[LinkedAccount] [int] NULL,
[SSN] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fundraiser] [bit] NULL,
[TeamID] [int] NULL,
[ActionNotes] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StaffAssigned] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingMonth] [int] NULL,
[PPRank] [int] NULL,
[PledgeLevel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OverrideLevel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceiptsLevel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CumulativePriority] [money] NULL,
[ImageLink] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PinNumber] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[Contact] ADD CONSTRAINT [PK_Contact_cf48e543-8d1f-4091-b1cd-db1659c0146a] PRIMARY KEY CLUSTERED  ([ContactID])
GO
CREATE NONCLUSTERED INDEX [IX_AccountName] ON [dbo].[Contact] ([AccountName])
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ADNumber] ON [dbo].[Contact] ([ADNumber])
GO
CREATE NONCLUSTERED INDEX [IX_Contact_CashBasisPP] ON [dbo].[Contact] ([CashBasisPP])
GO
CREATE NONCLUSTERED INDEX [IX_Company] ON [dbo].[Contact] ([Company])
GO
CREATE NONCLUSTERED INDEX [IX_LastNameFirstName] ON [dbo].[Contact] ([LastName], [FirstName])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_Contact_Status] ON [dbo].[Contact] ([Status])
GO
CREATE NONCLUSTERED INDEX [IX_TicketNumber] ON [dbo].[Contact] ([TicketNumber])
GO
