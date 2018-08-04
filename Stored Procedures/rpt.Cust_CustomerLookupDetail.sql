SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--[rpt].[Cust_CustomerLookupDetail] 332146



CREATE PROC [rpt].[Cust_CustomerLookupDetail] (@DimCustomerID BIGINT)
AS 

IF (@DimCustomerId IS NULL)
BEGIN
SELECT 'nothing' AS NoData
END ELSE
begin


--DECLARE @DimCustomerID BIGINT = 85009
DECLARE @SSB_CONTACT_GUID VARCHAR(50)

SELECT @SSB_CONTACT_GUID = SSB_CRMSYSTEM_CONTACT_ID 
FROM dbo.dimcustomerssbid
WHERE DimCustomerId = @DimCustomerID


SELECT @SSB_CONTACT_GUID AS SourceSystemID,
'SSB Composite Record' AS SourceSystem,
FirstName,
LastName,
MiddleName,
AddressPrimaryStreet,AddressPrimarySuite,AddressPrimaryCity,AddressPrimaryState,AddressPrimaryZip,PhonePrimary, EmailPrimary, @SSB_CONTACT_GUID AS SSBGUID,
0 AS IsPrimary,
1 AS IsComposite,
dc.CustomerType
	  , NULL AS customer_matchkey
		  , NULL AS ContactGUID
    ,dc.SSB_CRMSYSTEM_ACCT_ID
	,dc.CD_Gender AS Gender
	,dc.CompanyName
FROM mdm.compositerecord dc (NOLOCK)
WHERE contactguid = @SSB_CONTACT_GUID 

union

SELECT 
SSID AS SourceSystemID,
SourceSystem,
FirstName,
LastName,
MiddleName,
AddressPrimaryStreet,AddressPrimarySuite,AddressPrimaryCity,AddressPrimaryState,AddressPrimaryZip,PhonePrimary, EmailPrimary, @SSB_CONTACT_GUID AS SSBGUID,
ds.SSB_CRMSYSTEM_PRIMARY_FLAG AS IsPrimary,
0 AS IsComposite,
dc.CustomerType
	  , dc.customer_matchkey
		  , dc.ContactGUID
    ,SSB_CRMSYSTEM_ACCT_ID
	,dc.CD_Gender AS Gender
	,dc.CompanyName
FROM dimcustomer dc 
JOIN (
SELECT DimCustomerId, SSB_CRMSYSTEM_PRIMARY_FLAG, SSB_CRMSYSTEM_ACCT_ID 
FROM dimcustomerssbid  (NOLOCK)
WHERE SSB_CRMSYSTEM_CONTACT_ID = @SSB_CONTACT_GUID
) ds
 ON dc.DimCustomerId = ds.DimCustomerId


 end
/*
DECLARE @SSB_CONTACT_GUID VARCHAR(50)

SELECT @SSB_CONTACT_GUID = SSB_CRMSYSTEM_CONTACT_ID FROM dbo.dimcustomerssbid
WHERE DimCustomerId = @DimCustomerID

SELECT SSID AS SourceSystemID,
SourceSystem,
FirstName,
LastName,
MiddleName,
AddressPrimaryStreet,AddressPrimarySuite,AddressPrimaryCity,AddressPrimaryState,AddressPrimaryZip,PhonePrimary, EmailPrimary, @SSB_CONTACT_GUID AS SSBGUID,
ds.SSB_CRMSYSTEM_PRIMARY_FLAG AS IsPrimary,
dc.CustomerType
 FROM dimcustomer dc JOIN (SELECT DimCustomerId, SSB_CRMSYSTEM_PRIMARY_FLAG FROM dimcustomerssbid WHERE SSB_CRMSYSTEM_CONTACT_ID = @SSB_CONTACT_GUID) ds
 ON dc.DimCustomerId = ds.DimCustomerId
 ORDER BY ds.SSB_CRMSYSTEM_PRIMARY_FLAG DESC
 */
GO
