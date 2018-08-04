CREATE TABLE [src].[VTXtixsysoutlets]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixoutletid] [int] NULL,
[tixoutletdesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixoutletinitdate] [datetime2] (6) NULL,
[tixoutletlastupdwho] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixoutletlastupdwhen] [datetime2] (6) NULL,
[tixoutletdisplayorder] [int] NULL,
[tixoutletcontrol] [nvarchar] (192) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixoutletestablishmenttype] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixoutletestablishmentkey] [numeric] (10, 0) NULL,
[tixoutlettype] [smallint] NULL,
[tixoutletmerchid] [int] NULL,
[tixoutletmaxticket] [numeric] (10, 0) NULL,
[tixoutletonsaledate] [datetime2] (6) NULL,
[tixoutletoffsaledate] [datetime2] (6) NULL,
[tixoutletsubnetrootip] [numeric] (10, 0) NULL,
[tixoutletsubnetrootmask] [numeric] (10, 0) NULL,
[tixoutletzipcode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixoutletautocloseouttime] [datetime2] (6) NULL,
[client_id] [numeric] (10, 0) NULL
)
GO
