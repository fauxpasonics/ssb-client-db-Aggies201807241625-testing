CREATE TABLE [amy].[zz_wealth_engine_032016]
(
[adjustedfirstname] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adjustedlastname] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssbaddressprimarystreet] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status_DELETE_COLUMN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Donor_TYPE_DELETE_COLUMN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[firstname_needs_attention] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_needs_attention] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[client_uid] [int] NULL,
[client_uid2] [int] NOT NULL,
[courtesy] [int] NULL,
[first_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_name] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUFFIX] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address2] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address3] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[plus_four] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COUNTY] [int] NULL,
[COUNTRY] [int] NULL,
[BUSINESS_NAME] [int] NULL,
[BUSINESS_TITLE] [int] NULL,
[BUSINESS_PHONE] [int] NULL,
[ADDRESS1_LINE1] [int] NULL,
[ADDRESS1_LINE2] [int] NULL,
[CITY1] [int] NULL,
[REGION1] [int] NULL,
[POSTAL_CODE1] [int] NULL,
[POSTAL_CODE_FOUR1] [int] NULL,
[COUNTRY1] [int] NULL,
[ADDRESS2_LINE1] [int] NULL,
[ADDRESS2_LINE2] [int] NULL,
[CITY2] [int] NULL,
[REGION2] [int] NULL,
[POSTAL_CODE2] [int] NULL,
[PHONE_NUMBER] [int] NULL,
[CLIENT_EMAIL] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLIENT_AGE] [int] NULL,
[CLIENT_BIRTH_DATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GENDER] [int] NULL,
[CLIENT_GRADUATE_DATE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLIENT_GIFT_AMOUNT] [money] NULL,
[CLIENT_TOTAL_NO_GIFTS] [int] NULL,
[CLIENT_LARGEST_GIFT_AMOUNT] [money] NULL,
[CLIENT_LARGEST_GIFT_DATE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLIENT_FIRST_GIFT_AMOUNT] [money] NULL,
[CLIENT_FIRST_GIFT_DATE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLIENT_LAST_GIFT_AMOUNT] [money] NULL,
[CLIENT_LAST_GIFT_DATE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLIENT_TOTAL_YEARS_GIVING] [money] NULL,
[IC_FLAG] [int] NULL,
[SPOUSE_CLIENT_UID] [int] NULL,
[SPOUSE_CLIENT_UID2] [int] NULL,
[SPOUSE_COURTESY] [int] NULL,
[SPOUSE_FIRST_NAME] [int] NULL,
[SPOUSE_MIDDLE_NAME] [int] NULL,
[SPOUSE_LAST_NAME] [int] NULL,
[SPOUSE_SUFFIX] [int] NULL,
[SPOUSE_PHONE] [int] NULL,
[SPOUSE_EMAIL] [int] NULL,
[SPOUSE_AGE] [int] NULL,
[SPOUSE_BIRTH_DATE] [int] NULL,
[SPOUSE_GRADUATE_DATE] [int] NULL,
[SPOUSE_GENDER] [int] NULL,
[SP_BUSINESS_NAME] [int] NULL,
[SP_BUSINESS_TITLE] [int] NULL,
[SP_BUSINESS_PHONE] [int] NULL,
[SP_ADDRESS_LINE1] [int] NULL,
[SP_ADDRESS_LINE2] [int] NULL,
[SP_CITY] [int] NULL,
[SP_REGION] [int] NULL,
[SP_POSTAL_CODE] [int] NULL,
[SP_COUNTRY] [int] NULL,
[CD_FLAG] [int] NULL,
[CLIENT_PLANNED_GIVING_FLAG] [int] NULL,
[CLIENT_ATTRIBUTE1] [int] NULL,
[CLIENT_ATTRIBUTE2] [int] NULL,
[CLIENT_ATTRIBUTE3] [int] NULL,
[CLIENT_ATTRIBUTE4] [int] NULL,
[CLIENT_ATTRIBUTE5] [int] NULL,
[CLIENT_ATTRIBUTE6] [int] NULL,
[CLIENT_ATTRIBUTE7] [int] NULL,
[CLIENT_ATTRIBUTE8] [int] NULL,
[CLIENT_ATTRIBUTE9] [int] NULL,
[CLIENT_ATTRIBUTE10] [int] NULL,
[CLIENT_ATTRIBUTE11] [int] NULL,
[CLIENT_ATTRIBUTE12] [int] NULL,
[CLIENT_ATTRIBUTE13] [int] NULL,
[CLIENT_ATTRIBUTE14] [int] NULL,
[CLIENT_ATTRIBUTE15] [int] NULL
)
GO