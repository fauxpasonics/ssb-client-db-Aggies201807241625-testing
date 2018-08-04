CREATE TABLE [amy].[zz_tk_odet_f18_0530]
(
[Customer] [int] NULL,
[Name] [nvarchar] (164) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Customer Type] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item Name] [nvarchar] (163) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item Price Level Name] [nvarchar] (164) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item Price Level] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item Price per Seat] [decimal] (10, 2) NULL,
[Item Value (Ticket)] [decimal] (28, 10) NULL,
[Item Charge Amount (Fee)] [decimal] (10, 2) NULL,
[Item Extension (Ticket + Fees)] [decimal] (10, 2) NULL,
[Item Pay (Ticket)] [decimal] (28, 10) NULL,
[Item Charge Payment (Fee)] [decimal] (10, 2) NULL,
[Item Balance (Ticket)] [decimal] (28, 10) NULL,
[Item Charge Balance (fee)] [decimal] (10, 2) NULL,
[Item Order Qty] [int] NULL,
[ID] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orig Date] [datetime] NULL,
[Last Date] [datetime] NULL,
[Orig Time] [time] NULL,
[Last Time] [time] NULL,
[Order Comments] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item Special Handling] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item Bill Plan Code] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item Disposition] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
