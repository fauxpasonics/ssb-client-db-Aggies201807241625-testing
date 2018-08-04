CREATE TABLE [amy].[zz_tixeventzoneseatbarcodes]
(
[tixseatbarcodeid] [int] NULL,
[tixeventid] [int] NULL,
[tixeventzoneid] [int] NULL,
[tixseatgroupid] [int] NULL,
[tixseatid] [int] NULL,
[barcode] [bigint] NULL,
[scandatetime] [datetime] NULL,
[scanlocation] [nvarchar] (52) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clustercode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gatenumber] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[validationresponse] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[initdate] [datetime] NULL
)
GO
CREATE NONCLUSTERED INDEX [zz_tixeventzoneseatbarcodes_ind1] ON [amy].[zz_tixeventzoneseatbarcodes] ([tixeventid], [tixseatgroupid], [tixseatid], [tixeventzoneid])
GO
