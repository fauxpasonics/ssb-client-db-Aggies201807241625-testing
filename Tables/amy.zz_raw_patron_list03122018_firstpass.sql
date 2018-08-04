CREATE TABLE [amy].[zz_raw_patron_list03122018_firstpass]
(
[acct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adv_acct] [int] NULL,
[vtx_accountnumber] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_accountnumber] [decimal] (18, 6) NULL,
[ssbv_ssid] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_DimCustomerId] [int] NULL,
[ssbv_sourcesystem] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_sourcedb] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_customertype] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_CustomerStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_AccountId] [int] NULL,
[ssbv_AccountType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_CompanyName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_SalutationName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_DonorMailName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_DonorFormalName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_Birthday] [date] NULL,
[ssbv_Gender] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_Prefix] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_firstname] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_MiddleName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_lastname] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_suffix] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_fullname] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_Street] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_Suite] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_City] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_State] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_Zip] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_Email] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_Phone] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_PhoneHome] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_PhoneCell] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vtx_id] [numeric] (38, 10) NULL,
[vtx_lastname] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vtx_firstname] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vtx_middle] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vtx_phone1] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vtx_phone2] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vtx_address1] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vtx_address2] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vtx_city] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vtx_state] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vtx_zip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vtx_email] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vtx_createdate] [datetime2] (6) NULL,
[adv_firstname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adv_lastname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adv_accountname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adv_email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adv_setupdate] [datetime] NULL,
[adv_address1] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adv_address2] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adv_attnname] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adv_address3] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adv_city] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adv_state] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adv_zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_accountnumber] [decimal] (18, 6) NULL,
[ssba_ssid] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_DimCustomerId] [int] NULL,
[ssba_sourcesystem] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_sourcedb] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_customertype] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_CustomerStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_AccountId] [int] NULL,
[ssba_AccountType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_CompanyName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_SalutationName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_DonorMailName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_DonorFormalName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_Birthday] [date] NULL,
[ssba_Gender] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_Prefix] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_firstname] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_MiddleName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_lastname] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_suffix] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_fullname] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_Street] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_Suite] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_City] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_State] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_Zip] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_Email] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_Phone] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_PhoneHome] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_PhoneCell] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_addressclean] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_addressclean] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssba_country] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbv_country] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vtx_country] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adv_country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[initdate] [datetime2] (6) NULL,
[SetupDate] [datetime] NULL,
[custtype] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[maxorderdate] [datetime2] (6) NULL,
[vtx_deleted] [bit] NULL
)
GO