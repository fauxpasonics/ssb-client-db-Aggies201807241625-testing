CREATE TABLE [amy].[zz_seattrelocate_changes]
(
[AD Number] [int] NULL,
[Account Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seat Region] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Veritix Ticket Total] [int] NULL,
[CAP per Seat, Rate Sheet] [money] NULL,
[CAP Expected] [money] NULL,
[CAP Actual Pledge] [money] NULL,
[CAP Credits] [money] NULL,
[CAP Pledge Differences] [money] NULL,
[CAP Cash Receipts] [money] NULL,
[CAP Matching Pledge] [money] NULL,
[CAP Scheduled Payments] [money] NULL,
[Cap 20%] [int] NULL,
[Cap 40%] [int] NULL,
[Cap 60%] [int] NULL,
[Cap 80%] [int] NULL,
[Cap 100%] [int] NULL,
[CAP OTHER %] [int] NULL,
[CAP Due to Date] [int] NULL,
[Past Due CAP] [money] NULL,
[Annual per Seat, Rate Sheet] [money] NULL,
[Annual Expected] [money] NULL,
[Annual Actual Pledge] [money] NULL,
[Annual Credits] [money] NULL,
[Annual Pledge Differences] [money] NULL,
[Annual Cash Receipts] [money] NULL,
[Annual Matching Pledges] [money] NULL,
[Annual Scheduled Payments] [money] NULL,
[Current Year Annual Past Due] [money] NULL,
[Ticket Order % Paid] [numeric] (19, 4) NULL,
[Ticket Order % Schd] [numeric] (19, 4) NULL,
[Ticket Order % Past Due] [numeric] (21, 4) NULL,
[CAP Due] [int] NOT NULL,
[Annual Due] [int] NOT NULL,
[Tickets Due] [int] NOT NULL,
[Items Due] [money] NULL,
[ADA] [int] NULL,
[E] [int] NULL,
[EC] [int] NULL,
[ZC E] [int] NULL,
[Lettermen] [int] NULL,
[FacultyAD] [int] NULL,
[Faculty] [int] NULL,
[DC] [int] NULL,
[Comp] [int] NULL,
[UO] [int] NULL,
[UO-R] [int] NULL,
[Single Season] [int] NULL,
[Ticket Count] [int] NULL,
[Region Id] [int] NULL,
[Renewal Start Date] [datetime] NULL,
[LinealTransfer] [int] NULL,
[Veritix Order Number] [numeric] (10, 0) NULL,
[appointmenttime] [datetime] NULL,
[Seat Last Updated] [datetime] NULL,
[DiffReceiptArea] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiffReceipt] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO