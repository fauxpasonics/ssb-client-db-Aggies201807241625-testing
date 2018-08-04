CREATE TABLE [amy].[fundingmodel]
(
[fundingreportid] [int] NULL,
[Side] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Level] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seating Option] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Total Seats] [int] NULL,
[Annual Contribution] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Total Annual] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[originalcount] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[altcount] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[altprice] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
CREATE NONCLUSTERED INDEX [fundingmodel_ind_id] ON [amy].[fundingmodel] ([fundingreportid])
GO
