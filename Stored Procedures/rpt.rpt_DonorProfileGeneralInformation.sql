SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [rpt].[rpt_DonorProfileGeneralInformation] (@ADNumber VARCHAR(300)='', @FirstName VARCHAR(300)='', @LastName VARCHAR(300)='')
WITH RECOMPILE
AS

DECLARE @sql VARCHAR (MAX)

--IF (ISNULL(@ADNumber,'') = '')
--BEGIN
--SET @ADNumber = 0
--end

IF (COALESCE(@FirstName,@LastName,@ADNumber,'NONESUPPLIED')='NONESUPPLIED')
BEGIN
SELECT 'nothing' AS NoDataLogi 
END
ELSE BEGIN


--Original Lookup Logic update to use fuzzy logic

SELECT TOP 100
	ROW_NUMBER() OVER (ORDER BY c.ADNumber) RowId
	,c.AccountName
	,c.FirstName
	,c.LastName
	,c.ADNumber 
	,c.PHHome
	,c.PHBusiness
	,c.Mobile 
	,c.Email  
	,c.Status
	,c.UDF2 DonorType
	,cei.PrefClassYear "Alumni"
	,c.Birthday
	-- Spouse Information
	,c.SpouseName
	,cei.SpousePrefClassYear
	,c.SpouseBirthday
	--Donor Address
	,ca.Address1 
	,ca.Address2 
	,ca.Address3 
	,ca.City + ', ' + ca.State + ' ' + ca.zip "CityStateZip"
	,ca.City
	,ca.State
	,ca.Zip
	,ca.Salutation
	,vca.address1 AS tixAddress1
	,vca.address2 AS tixAddress2
	,vca.city + ', ' + vca.State + ' ' + vca.zip AS tixCityStateZip
	,vc.salutation AS tixSalutation
	-- Major Gifts
	,c.StaffAssigned StaffAssigned
	,REPLACE(c.UDF4, '''', '') MajorGiftsNamingOpp
	,c.UDF1 MajorGiftsStatus
	,c.contactid    --Not shown but can be used for other queries
FROM dbo.ADVContact c
LEFT JOIN dbo.ADVQAContactExtendedInfo cei 
	ON cei.contactid = c.contactid
LEFT JOIN dbo.ADVContactAddresses ca 
	ON (c.ContactID = ca.ContactID AND ca.PrimaryAddress = 1)
LEFT JOIN ods.VTXcustomers vc
	ON CAST(c.ADNumber AS VARCHAR(200)) = CAST(vc.accountnumber AS VARCHAR(200))
LEFT JOIN (SELECT * FROM ods.VTXcustomeraddresses WHERE [description] = 'Current') vca
	ON vc.addressid = vca.addressid
--filtering
WHERE ((c.adnumber = @ADNumber OR ISNULL(@ADNumber,'') = '')
AND (c.LastName = @Lastname OR ISNULL(@LastName,'') = '') 
AND (c.FirstName = @FirstName OR ISNULL(@FirstName,'') = ''))

/*
SET @SQL = '
SELECT TOP 100
	ROW_NUMBER() OVER (ORDER BY c.ADNumber) RowId
	,c.AccountName
	,c.FirstName
	,c.LastName
	,c.ADNumber 
	,c.PHHome
	,c.PHBusiness
	,c.Mobile 
	,c.Email  
	,c.Status
	,c.UDF2 DonorType
	,cei.PrefClassYear "Alumni"
	,c.Birthday
	-- Spouse Information
	,c.SpouseName
	,cei.SpousePrefClassYear
	,c.SpouseBirthday
	--Donor Address
	,ca.Address1 
	,ca.Address2 
	,ca.Address3 
	,ca.City + '', '' + ca.State + '' '' + ca.zip CityStateZip
	,ca.City
	,ca.State
	,ca.Zip
	,ca.Salutation
	,vca.address1 AS tixAddress1
	,vca.address2 AS tixAddress2
	,vca.city + '', '' + vca.State + '' '' + vca.zip AS tixCityStateZip
	,vc.salutation AS tixSalutation
	-- Major Gifts
	,c.StaffAssigned StaffAssigned
	,c.UDF4 MajorGiftsNamingOpp
	,c.UDF1 MajorGiftsStatus
	,c.contactid    --Not shown but can be used for other queries
FROM dbo.ADVContact c
LEFT join dbo.ADVQAContactExtendedInfo cei 
	ON cei.contactid = c.contactid
LEFT JOIN dbo.ADVContactAddresses ca 
	ON (c.ContactID = ca.ContactID and ca.PrimaryAddress = 1)
LEFT JOIN ods.VTXcustomers vc
	ON CAST(c.ADNumber AS VARCHAR(200)) = CAST(vc.accountnumber AS VARCHAR(200))
LEFT JOIN (SELECT * FROM ods.VTXcustomeraddresses WHERE [description] = ''Current'') vca
	ON vc.addressid = vca.addressid
----filtering
WHERE ((c.LastName like ''%'+@Lastname+'%'' OR ISNULL('''+@LastName+''','''') = '''') 
AND (c.FirstName like ''%'+@Firstname+'%'' OR ISNULL('''+@FirstName+''','''') = '''')
AND (c.ADNumber like ''%'+@ADNumber+'%'' OR ISNULL('''+@ADNumber+''','''') = ''''))
'
EXEC (@sql)
*/

END
GO
