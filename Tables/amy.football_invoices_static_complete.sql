CREATE TABLE [amy].[football_invoices_static_complete]
(
[AD_Number] [int] NULL,
[Account_Name] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seating_Area] [nvarchar] (54) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seat_Qty] [int] NULL,
[Kyle_Field_Gift] [decimal] (10, 2) NULL,
[Kyle_Field_Credits] [decimal] (10, 2) NULL,
[Current_Kyle_Field_Due] [decimal] (10, 2) NULL,
[Annual_Seat_Contribution] [decimal] (10, 2) NULL,
[Annual_Credits] [decimal] (10, 2) NULL,
[Current_Annual_Due] [decimal] (10, 2) NULL,
[Total_Current_Due] [decimal] (10, 2) NULL,
[BatchNo] [int] NULL
)
GO
