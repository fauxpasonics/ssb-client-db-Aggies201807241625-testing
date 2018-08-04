CREATE TABLE [amy].[zz_tixeventzoneseats_f18pk]
(
[tixeventid] [int] NULL,
[tixeventzoneid] [int] NULL,
[tixseatgroupid] [int] NULL,
[tixseatid] [int] NULL,
[tixseatdesc] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatcurrentstatus] [int] NULL,
[tixseatecommercehdrlink] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatecommercedtllink] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatseasonticket] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatbarcode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatdefltavailstatus] [int] NULL,
[tixseatprintcount] [int] NULL,
[tixseatnexthistoryptr] [int] NULL,
[tixseatprimaryspeccode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpricecode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatvaluebeforediscounts] [decimal] (28, 10) NULL,
[tixseatpriceafterdiscounts] [decimal] (28, 10) NULL,
[tixseatpaidtodate] [decimal] (28, 10) NULL,
[tixseatpricetoprintonticket] [decimal] (28, 10) NULL,
[tixseatsold] [int] NULL,
[tixseatpaid] [int] NULL,
[tixseatrenewable] [int] NULL,
[tixseatthiseventownersuserid] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatnexteventownersuserid] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatholdexpiration] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatsoldfromoutlet] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatprintbatchid] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpackageon] [int] NULL,
[tixseatpackage] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpackageid] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatspecialtycode_ctrlreqd] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatspecialtycode_ctrlopt] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatlastupdate] [datetime] NULL,
[tixseatprintable] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatprinted] [int] NULL,
[tixseatshipdate] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatshipservecharge] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatrenewalexpiredate] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatprojectedprice] [decimal] (28, 10) NULL,
[tixseateventtype] [int] NULL,
[tixseatprintfilename] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpkgpricecode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatmod] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatshippingoption] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseattrackingnumber] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatofferid] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatlastscandate] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatoffergroupid] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatordergroupid] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatinfo1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatinfo2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatlocked] [int] NULL,
[change_group_id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seat_bit_flags] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixhandheldmessage_id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatdisplayorder] [int] NULL,
[paper_converted] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpricelevel] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
