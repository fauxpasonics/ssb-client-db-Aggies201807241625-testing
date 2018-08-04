SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*****	Revision History

DCH 2018-05-01	-	view creation for sync to DW04.

*****/


CREATE VIEW [etl].[vw_dbo_ADVProgram]	WITH SCHEMABINDING
AS 


SELECT ProgramID, ProgramCode, ProgramName, ProgramGroup, PriorityPercent, SpecialEvent, Inactive, GLAccount, MoneyPoints, LifetimeGiving, DonationValue, Percentage
	, AvailableOnline, OnlineDescription, BalanceOnline, CapDriveYear, PayInFullRequired, AllowPaySchedules, DeadlineDate
FROM dbo.ADVProgram (nolock)
GO
