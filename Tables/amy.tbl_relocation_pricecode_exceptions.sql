CREATE TABLE [amy].[tbl_relocation_pricecode_exceptions]
(
[relocation_pricecode_exceptions_id] [int] NOT NULL IDENTITY(1, 1),
[pricecode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sport] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_date] [datetime] NULL
)
GO
