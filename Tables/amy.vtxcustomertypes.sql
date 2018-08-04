CREATE TABLE [amy].[vtxcustomertypes]
(
[AccountNumber] [int] NULL,
[Last Name] [nvarchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[First Name] [nvarchar] (59) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Company] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CareOf] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address 1] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [nvarchar] (61) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone 1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
CREATE NONCLUSTERED INDEX [vtxcustomertypes_account_ind01] ON [amy].[vtxcustomertypes] ([AccountNumber])
GO
