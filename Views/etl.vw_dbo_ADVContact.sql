SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*****	Revision History

DCH 2018-05-01	-	view creation for sync to DW04.

*****/


CREATE VIEW [etl].[vw_dbo_ADVContact]	WITH SCHEMABINDING
AS 


SELECT ContactID, ADNumber, SetupDate, Status, AccountName, FirstName, MiddleInitial, LastName, Company, Salutation, Email, PHHome, PHBusiness, Ext, Fax, Mobile
	, PHOther1, PHOther1Desc, PHOther2, PHOther2Desc, Birthday, TicketNumber, TicketName, AlumniInfo, SpouseName, SpouseBirthday, SpouseAlumniInfo, ChildrenNames
	, CashBasisPP, AccrualBasisPP, AdjustedPP, LastEdited, EditedBy, Program, ProgramName, Dear, Zone, BusinessTitle, BankName, BankCity, AccountNo, RoutingNo
	, LifetimeGiving, UDF1, UDF2, UDF3, UDF4, UDF5, BillingCycle, EStatement, FundraiserID, LinkedAccount, SSN, Fundraiser, TeamID
--	, ActionNotes
	, StaffAssigned, BillingMonth, PPRank, PledgeLevel, OverrideLevel, ReceiptsLevel, Suffix, CumulativePriority, ImageLink, PinNumber
FROM dbo.ADVContact (nolock)
GO
