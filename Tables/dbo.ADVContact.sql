CREATE TABLE [dbo].[ADVContact]
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
ALTER TABLE [dbo].[ADVContact] ADD CONSTRAINT [PK_Contact_5a6ad71b-8c07-4f63-94ff-cfe4d6bd0369] PRIMARY KEY CLUSTERED  ([ContactID])
GO
CREATE NONCLUSTERED INDEX [IX_AccountName] ON [dbo].[ADVContact] ([AccountName])
GO
CREATE NONCLUSTERED INDEX [IX_ADNumber] ON [dbo].[ADVContact] ([ADNumber])
GO
CREATE NONCLUSTERED INDEX [IX_Contact_CashBasisPP] ON [dbo].[ADVContact] ([CashBasisPP])
GO
CREATE NONCLUSTERED INDEX [IX_Company] ON [dbo].[ADVContact] ([Company])
GO
CREATE NONCLUSTERED INDEX [nci_wi_ADVContact_0CBC651AE9D203C0173030384546C637] ON [dbo].[ADVContact] ([Email]) INCLUDE ([AccountName], [ADNumber], [FirstName], [LastName], [Status])
GO
CREATE NONCLUSTERED INDEX [IX_LastNameFirstName] ON [dbo].[ADVContact] ([LastName], [FirstName])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_Contact_Status] ON [dbo].[ADVContact] ([Status])
GO
CREATE NONCLUSTERED INDEX [IX_TicketNumber] ON [dbo].[ADVContact] ([TicketNumber])
GO
GRANT SELECT ON  [dbo].[ADVContact] TO [db_ReadAmySchema]
GO
