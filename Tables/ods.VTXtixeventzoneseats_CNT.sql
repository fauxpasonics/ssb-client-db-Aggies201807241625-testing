CREATE TABLE [ods].[VTXtixeventzoneseats_CNT]
(
[tixeventid] [numeric] (10, 0) NOT NULL,
[ODS_rowcnt] [int] NOT NULL,
[SRC_rowcnt] [int] NOT NULL,
[RowNum] [int] NOT NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF__VTXtixeve__Creat__5AE46118] DEFAULT (getdate())
)
GO
