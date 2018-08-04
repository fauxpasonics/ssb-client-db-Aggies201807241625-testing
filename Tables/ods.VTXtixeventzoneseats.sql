CREATE TABLE [ods].[VTXtixeventzoneseats]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[paper_converted] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [ods].[VTXtixeventzoneseats] ADD CONSTRAINT [PK__VTXtixev__7EF6BFCD243D0D46] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
CREATE NONCLUSTERED INDEX [idx_TixEventZoneSeats_IsDel] ON [ods].[VTXtixeventzoneseats] ([ETL_IsDeleted], [tixeventid]) INCLUDE ([tixeventzoneid], [tixseatgroupid], [tixseatpricecode], [tixseatsold])
GO
CREATE NONCLUSTERED INDEX [IDX_VTXtixeventzoneseats_tixeventid] ON [ods].[VTXtixeventzoneseats] ([tixeventid]) INCLUDE ([tixeventzoneid], [tixseatdesc], [tixseatgroupid], [tixseatordergroupid], [tixseatpricecode])
GO
ALTER INDEX [IDX_VTXtixeventzoneseats_tixeventid] ON [ods].[VTXtixeventzoneseats] DISABLE
GO
CREATE NONCLUSTERED INDEX [IDX_tixeventid_TixSeatOrderGroupID] ON [ods].[VTXtixeventzoneseats] ([tixeventid]) INCLUDE ([tixseatordergroupid])
GO
CREATE NONCLUSTERED INDEX [idx_tixeventidtixeventzoneid] ON [ods].[VTXtixeventzoneseats] ([tixeventid], [tixeventzoneid])
GO
CREATE NONCLUSTERED INDEX [idx_tixeventid_tixeventzoneid] ON [ods].[VTXtixeventzoneseats] ([tixeventid], [tixeventzoneid]) INCLUDE ([tixseatdesc], [tixseatgroupid], [tixseatid], [tixseatordergroupid], [tixseatpricecode], [tixseatprinted])
GO
CREATE NONCLUSTERED INDEX [IDX_VTXtixeventzoneseats_barcode] ON [ods].[VTXtixeventzoneseats] ([tixseatbarcode])
GO
CREATE NONCLUSTERED INDEX [idx_VTXtixeventzoneseats_tixseatid_tixseatgroupid_tixeventid_tixeventzoneid] ON [ods].[VTXtixeventzoneseats] ([tixseatid], [tixseatgroupid], [tixeventid], [tixeventzoneid])
GO
ALTER INDEX [idx_VTXtixeventzoneseats_tixseatid_tixseatgroupid_tixeventid_tixeventzoneid] ON [ods].[VTXtixeventzoneseats] DISABLE
GO
CREATE NONCLUSTERED INDEX [IX_tixseatordergroupid] ON [ods].[VTXtixeventzoneseats] ([tixseatordergroupid])
GO
ALTER INDEX [IX_tixseatordergroupid] ON [ods].[VTXtixeventzoneseats] DISABLE
GO
CREATE NONCLUSTERED INDEX [idx_tixseatpricecode] ON [ods].[VTXtixeventzoneseats] ([tixseatpricecode])
GO
