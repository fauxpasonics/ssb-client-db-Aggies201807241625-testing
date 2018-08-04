CREATE TABLE [src].[VTXtixeventzoneseats_CNT]
(
[tixeventid] [numeric] (10, 0) NULL,
[rowcnt] [int] NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF__VTXtixeve__Creat__5FA91635] DEFAULT (getdate())
)
GO
