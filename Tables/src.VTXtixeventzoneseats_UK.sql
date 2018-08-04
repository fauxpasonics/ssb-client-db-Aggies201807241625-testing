CREATE TABLE [src].[VTXtixeventzoneseats_UK]
(
[tixeventid] [numeric] (10, 0) NULL,
[tixeventzoneid] [smallint] NULL,
[tixseatgroupid] [int] NULL,
[tixseatid] [numeric] (10, 0) NULL
)
GO
CREATE NONCLUSTERED INDEX [IDX_Key] ON [src].[VTXtixeventzoneseats_UK] ([tixseatid], [tixseatgroupid], [tixeventzoneid], [tixeventid])
GO
ALTER INDEX [IDX_Key] ON [src].[VTXtixeventzoneseats_UK] DISABLE
GO
