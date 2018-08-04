SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [rpt].[rpt_DonorProfilePriorityPointsLinkedAccounts] (@ADNumber int)

AS 

DECLARE @CurrentYear VARCHAR(20)
DECLARE @ContactID INT
SET @CurrentYear = (SELECT MAX(convert(int,CurrentYear)) FROM dbo.ADVCurrentYear)
SET @ContactID = (SELECT ContactID FROM dbo.ADVContact WHERE ADNumber = @ADNumber)

--Linked accounts
select 
	CAST(c.adnumber as varchar)+ '-'+ c.AccountName LinkedAccount
	,percentofpoints  
FROM dbo.ADVcontact c
JOIN dbo.ADVLinkedAccounts la
ON la.ContactID = c.contactid 
WHERE la.LinkedAccount = @ContactID
GO
