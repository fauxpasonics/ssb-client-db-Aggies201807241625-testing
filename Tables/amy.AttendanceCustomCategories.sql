CREATE TABLE [amy].[AttendanceCustomCategories]
(
[AttendanceCustomCategoriesID] [int] NOT NULL IDENTITY(1, 1),
[tixeventid] [numeric] (10, 0) NULL,
[tixeventlookupid] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sporttype] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ticketyear] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[categorytitle] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[categoryamount] [int] NULL,
[updateuser] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updatedate] [datetime] NULL
)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  TRIGGER [amy].[AUR_AttendanceCustomCategories] ON [amy].[AttendanceCustomCategories]
AFTER UPDATE
AS
Begin
Update T
Set T.UpdateDate = Getdate(), T.UpdateUser = User_name()
from amy.AttendanceCustomCategories T
JOIN INSERTED I
ON I.[AttendanceCustomCategoriesID] = T.[AttendanceCustomCategoriesID]
End
GO
DISABLE TRIGGER [amy].[AUR_AttendanceCustomCategories] ON [amy].[AttendanceCustomCategories]
GO
CREATE NONCLUSTERED INDEX [idx_AttendanceCustomCategories_tixeventid] ON [amy].[AttendanceCustomCategories] ([tixeventid])
GO
