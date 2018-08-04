CREATE TABLE [mdm].[DataMask]
(
[PositionNumber] [int] NOT NULL,
[OriginalText] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MaskText] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
