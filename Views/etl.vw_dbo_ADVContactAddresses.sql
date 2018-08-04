SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*****	Revision History

DCH 2018-05-01	-	view creation for sync to DW04.

*****/


CREATE VIEW [etl].[vw_dbo_ADVContactAddresses]	WITH SCHEMABINDING
AS 


SELECT PK, ContactID, Code, AttnName, Company, Address1, Address2, Address3, City, State, Zip, County, Country, StartDate, EndDate, Region, PrimaryAddress, Salutation, TicketAddress
FROM dbo.ADVContactAddresses (nolock)
GO
