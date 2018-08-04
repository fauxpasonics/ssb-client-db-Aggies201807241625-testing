CREATE TABLE [amy].[zz_tixeventzoneseatsF18Season]
(
[tixeventid] [numeric] (10, 0) NULL,
[tixeventzoneid] [smallint] NULL,
[tixseatgroupid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatdesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatcurrentstatus] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatecommercehdrlink] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatecommercedtllink] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatseasonticket] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatbarcode] [nvarchar] (96) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatdefltavailstatus] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatprintcount] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatnexthistoryptr] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatprimaryspeccode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpricecode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatvaluebeforediscounts] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpriceafterdiscounts] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpaidtodate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpricetoprintonticket] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatsold] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpaid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatrenewable] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatthiseventownersuserid] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatnexteventownersuserid] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatholdexpiration] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatsoldfromoutlet] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatprintbatchid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpackageon] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpackage] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpackageid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatspecialtycode_ctrlreqd] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatspecialtycode_ctrlopt] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatlastupdate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatprintable] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatprinted] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatshipdate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatshipservecharge] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatrenewalexpiredate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatprojectedprice] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseateventtype] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatprintfilename] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpkgpricecode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatmod] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatshippingoption] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseattrackingnumber] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatofferid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatlastscandate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatoffergroupid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatordergroupid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatinfo1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatinfo2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatlocked] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[change_group_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seat_bit_flags] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixhandheldmessage_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatdisplayorder] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paper_converted] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpricelevel] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
CREATE NONCLUSTERED INDEX [aj_IDX_VTXtixeventzoneseats_tixeventid] ON [amy].[zz_tixeventzoneseatsF18Season] ([tixeventid]) INCLUDE ([tixeventzoneid], [tixseatdesc], [tixseatgroupid], [tixseatordergroupid], [tixseatpricecode])
GO
CREATE NONCLUSTERED INDEX [aj_IDX_tixeventid_TixSeatOrderGroupID] ON [amy].[zz_tixeventzoneseatsF18Season] ([tixeventid]) INCLUDE ([tixseatordergroupid])
GO
CREATE NONCLUSTERED INDEX [aj_idx_tixeventidtixeventzoneid] ON [amy].[zz_tixeventzoneseatsF18Season] ([tixeventid], [tixeventzoneid])
GO
CREATE NONCLUSTERED INDEX [aj_idx_tixeventid_tixeventzoneid] ON [amy].[zz_tixeventzoneseatsF18Season] ([tixeventid], [tixeventzoneid]) INCLUDE ([tixseatdesc], [tixseatgroupid], [tixseatid], [tixseatordergroupid], [tixseatpricecode], [tixseatprinted])
GO
CREATE NONCLUSTERED INDEX [aj_IDX_VTXtixeventzoneseats_barcode] ON [amy].[zz_tixeventzoneseatsF18Season] ([tixseatbarcode])
GO
CREATE NONCLUSTERED INDEX [aj_idx_VTXtixeventzoneseats_tixseatid_tixseatgroupid_tixeventid_tixeventzoneid] ON [amy].[zz_tixeventzoneseatsF18Season] ([tixseatid], [tixseatgroupid], [tixeventid], [tixeventzoneid])
GO
CREATE NONCLUSTERED INDEX [aj_IX_tixseatordergroupid] ON [amy].[zz_tixeventzoneseatsF18Season] ([tixseatordergroupid])
GO
CREATE NONCLUSTERED INDEX [aj_idx_tixseatpricecode] ON [amy].[zz_tixeventzoneseatsF18Season] ([tixseatpricecode])
GO
