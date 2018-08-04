CREATE TABLE [src].[VTXpayments]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentid] [numeric] (10, 0) NULL,
[paymentccbatchid] [numeric] (10, 0) NULL,
[paymenttranstype] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentusercckey] [int] NULL,
[paymentamount] [numeric] (19, 4) NULL,
[paymentauthcode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentrefnumber] [nvarchar] (96) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentdate] [datetime2] (6) NULL,
[paymentsetup] [datetime2] (6) NULL,
[paymentsetdown] [datetime2] (6) NULL,
[paymentmerchid] [int] NULL,
[paymentname] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentaddress1] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentaddress2] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentcity] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentst] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentcountry] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentzip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentstatecode] [int] NULL,
[paymentrelatedpaymentid] [numeric] (10, 0) NULL,
[paymentsetdownperforminguser] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymenttransactiondate] [datetime2] (6) NULL,
[paymentuserccvalidcoderesponse] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentcardentryindicator] [smallint] NULL,
[paymentproviderresponsecode] [smallint] NULL,
[paymenthostresponsemessage] [nvarchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymenthostresponsecode] [nvarchar] (90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentavsresultcode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentuserccname] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentuserccexp] [datetime2] (6) NULL,
[paymentusercctype] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentsetupperforminguser] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentstatus] [numeric] (10, 0) NULL,
[paymentresult] [numeric] (10, 0) NULL,
[paymentoutletid] [int] NULL,
[paymentchannel] [smallint] NULL,
[paymentsetupoutletid] [int] NULL,
[customerid] [numeric] (38, 10) NULL,
[ordergroupid] [numeric] (20, 0) NULL,
[client_id] [numeric] (10, 0) NULL,
[paymentusercclastfour] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cctransactiontype] [smallint] NULL,
[provider_response_details] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_token_id] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_first_six] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[application_id] [smallint] NULL,
[paymentprocessorresponsecode] [nvarchar] (90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_hash_info_id] [numeric] (10, 0) NULL
)
GO