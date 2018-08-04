CREATE TABLE [ods].[VTXtixeventzoneseat_bkp]
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
[tixseatgroupid] [int] NULL,
[tixseatid] [numeric] (10, 0) NULL,
[tixseatdesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatcurrentstatus] [numeric] (10, 0) NULL,
[tixseatecommercehdrlink] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatecommercedtllink] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatseasonticket] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatbarcode] [nvarchar] (96) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatdefltavailstatus] [numeric] (10, 0) NULL,
[tixseatprintcount] [numeric] (10, 0) NULL,
[tixseatnexthistoryptr] [smallint] NULL,
[tixseatprimaryspeccode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpricecode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatvaluebeforediscounts] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpriceafterdiscounts] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpaidtodate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpricetoprintonticket] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatsold] [smallint] NULL,
[tixseatpaid] [smallint] NULL,
[tixseatrenewable] [smallint] NULL,
[tixseatthiseventownersuserid] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatnexteventownersuserid] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatholdexpiration] [datetime2] (6) NULL,
[tixseatsoldfromoutlet] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatprintbatchid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpackageon] [smallint] NULL,
[tixseatpackage] [int] NULL,
[tixseatpackageid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatspecialtycode_ctrlreqd] [smallint] NULL,
[tixseatspecialtycode_ctrlopt] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatlastupdate] [datetime2] (6) NULL,
[tixseatprintable] [smallint] NULL,
[tixseatprinted] [smallint] NULL,
[tixseatshipdate] [datetime2] (6) NULL,
[tixseatshipservecharge] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatrenewalexpiredate] [datetime2] (6) NULL,
[tixseatprojectedprice] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseateventtype] [smallint] NULL,
[tixseatprintfilename] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpkgpricecode] [smallint] NULL,
[tixseatmod] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatshippingoption] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseattrackingnumber] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatofferid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatlastscandate] [datetime2] (6) NULL,
[tixseatoffergroupid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatordergroupid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatinfo1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatinfo2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatlocked] [smallint] NULL,
[change_group_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seat_bit_flags] [int] NULL,
[tixhandheldmessage_id] [int] NULL,
[tixseatdisplayorder] [numeric] (10, 0) NULL,
[paper_converted] [smallint] NULL
)
GO
ALTER TABLE [ods].[VTXtixeventzoneseat_bkp] ADD CONSTRAINT [PK__VTXtixev__7EF6BFCD5307852E] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO