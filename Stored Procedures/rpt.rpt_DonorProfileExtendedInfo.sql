SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [rpt].[rpt_DonorProfileExtendedInfo] (@ADNumber INT)

AS 

DECLARE @CurrentYear VARCHAR(20)
DECLARE @ContactID INT
SET @CurrentYear = (SELECT MAX(convert(int,CurrentYear)) FROM dbo.ADVCurrentYear)
SET @ContactID = (SELECT ContactID FROM dbo.ADVContact WHERE ADNumber = @ADNumber)

SELECT  
	REPLACE(FirstName,'&','&amp;') AS FirstName
	,REPLACE(LastName,'&','&amp;') AS LastName
	,MiddleInitial
	,SetupDate
	,AlumniInfo
	,StaffAssigned
	,udf5 MailingName
	,ProgramName
	,address2.Address1 AS ad2Address1
	,address2.Address2 AS ad2Address2
	,address2.Address3 AS ad2Address3
	,address2.CityStateZip AS ad2CityStateZip
	,address2.Salutation AS ad2Salutation
	,address3.Address1 AS ad2Address1
	,address3.Address2 AS ad2Address2
	,address3.Address3 AS ad2Address3
	,address3.CityStateZip AS ad2CityStateZip
	,address3.Salutation AS ad2Salutation
FROM dbo.ADVcontact con
LEFT JOIN (
		SELECT * FROM
		(
			SELECT 
				ca.contactid
				,ca.Address1
				,ca.Address2 
				,ca.Address3 
				,ca.City + ', ' + State + ' ' + ca.zip CityStateZip
				,ca.Salutation 
				,RANK() OVER (PARTITION BY ContactID ORDER BY PK) AS rownum
			FROM dbo.ADVContactAddresses ca
			WHERE 1=1
			AND contactid = @ContactID
			AND primaryaddress = 0
		) a
		WHERE rownum = 1
) address2
ON con.contactid = address2.contactid
LEFT JOIN (
		SELECT * FROM
		(
			SELECT 
				ca.contactid
				,ca.Address1
				,ca.Address2 
				,ca.Address3 
				,ca.City + ', ' + State + ' ' + ca.zip CityStateZip
				,ca.Salutation 
				,RANK() OVER (PARTITION BY ContactID ORDER BY PK) AS rownum
			FROM dbo.ADVContactAddresses ca
			WHERE 1=1
			AND contactid = @ContactID
			AND primaryaddress = 0
		) a
		WHERE rownum = 2
) address3
ON con.contactid = address3.contactid
WHERE ADNumber = @ADNumber
GO
