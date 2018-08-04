CREATE TABLE [ods].[PAC_AccountCreditCard]
(
[AccountDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[AccountID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sequence] [int] NOT NULL,
[CreditCardTypeCodeDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[CreditCardTypeCodeType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[CreditCardTypeCodeSubType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[CreditCardTypeCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[CreditCardNumber] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpirationMonth] [int] NULL,
[ExpirationYear] [int] NULL,
[IsPreferred] [bit] NULL,
[LastUsed] [date] NULL,
[NameOnCard] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NickName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sys_CreateIP] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sys_CreateTS] [datetime] NULL,
[sys_CreateUser] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sys_Status] [int] NULL,
[sys_UpdateIP] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sys_UpdateTS] [datetime] NULL,
[sys_UpdateUser] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ods__PAC_AccountCreditCard] ON [ods].[PAC_AccountCreditCard]
GO
