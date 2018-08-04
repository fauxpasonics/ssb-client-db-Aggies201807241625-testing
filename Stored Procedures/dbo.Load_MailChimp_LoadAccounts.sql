SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO













/*============================================================================================================
CREATED BY:		Jeff Barberio
CREATED DATE:	5/1/2017
PY VERSION:		N/A
USED BY:		Mail Chimp Outbound Integration
UPDATES:		-5/5  jbarberio added in an updated column to the loadAccounts table
				-5/25 jbarberio altered proc to use temp tables/index instead of pulling from the 
								[dbo].[vw_MailChimp_LoadAccounts] view
				-5/26 jbarberio added in logic to prevent duplicate emails from attempting to be inserted, added
								in logic to record soft deletes
				-6/9  jbarberio updated to keep maintain full load list to use in unsub view 
NOTES:			This PROC loads the data into dbo.MailChimp_LoadAccounts for the Mail Chimp Outbound Integration
=============================================================================================================*/


CREATE PROC [dbo].[Load_MailChimp_LoadAccounts] AS 

/*====================================================================================================
											PRODUCTION DATA
====================================================================================================*/

CREATE TABLE #Production(
 AccountNumber		nvarchar	(50)
,FirstName			nvarchar	(150)
,LastName			nvarchar	(150)
,Email				nvarchar	(500)
,Status				varchar		(200)
,AccountName		nvarchar	(200)
,DonorGroups		nvarchar	(200)
)

INSERT INTO #Production

SELECT cast(NULLIF(attr.ACCTNUMBER,'')AS VARCHAR(50))									AS AccountNumber
	 , REPLACE(NULLIF(attr.FNAME,''),'''''''''','''')									AS firstname
	 , REPLACE(NULLIF(attr.LNAME,''),'''''''''','''')									AS lastname	
	 , REPLACE(NULLIF(email.email_address,''),'''''''''','''')							AS Email
	 , REPLACE(NULLIF(attr.status,''),'''''''''','''')									AS Status
	 , REPLACE(NULLIF(attr.ACCTNAME,''),'''''''''','''')								AS AccountName
	 , case when d4833c1e14	= 'True' THEN CASE WHEN a6a4874dca = 'True' THEN 'Athletic Ambassadors,Champions Council'
											   ELSE 'Athletic Ambassadors'
										  END
			ELSE CASE WHEN a6a4874dca = 'True' THEN 'Champions Council'
					  ELSE NULL
				 END
	   END AS DonorGroups
FROM [apietl].[MailChimp_ListMembers_Prod_members_1] email (NOLOCK)
	JOIN [apietl].[MailChimp_ListMembers_Prod_members_merge_fields_2] (NOLOCK) attr ON email.ETL__MailChimp_ListMembers_Prod_members_id = attr.ETL__MailChimp_ListMembers_Prod_members_id
	JOIN [apietl].[MailChimp_ListMembers_Prod_members_interests_2] intr on intr.ETL__MailChimp_ListMembers_Prod_members_id = email.ETL__MailChimp_ListMembers_Prod_members_id
WHERE list_id = '80071420fa'

/*====================================================================================================
											ACCOUNTS TO LOAD
====================================================================================================*/

DROP INDEX IX_AccountNumber on dbo.MailChimp_LoadAccounts_Full --(AccountNumber)
DROP INDEX IX_email on dbo.MailChimp_LoadAccounts_Full --(email)

TRUNCATE TABLE dbo.MailChimp_LoadAccounts_Full

INSERT INTO dbo.MailChimp_LoadAccounts_Full(
 AccountNumber		--nvarchar	(50)
,FirstName			--nvarchar	(150)
,LastName			--nvarchar	(150)
,Email				--nvarchar	(500)
,Status				--varchar	(200)
,AccountName		--nvarchar	(200)
,DonorGroups		--nvarchar	(200)
)

SELECT accountnumber	
	  ,firstname	
	  ,lastname	
	  ,email	
	  ,status	
	  ,accountname	
	  ,DonorGroups
	 FROM (
			 SELECT  CAST(adnumber AS VARCHAR(50)) accountnumber 
					,firstname 
					,lastname 
					,CAST(LTRIM(RTRIM(REPLACE(email,NCHAR(0x09),'')))AS VARCHAR(200)) email
					,status 
					,accountname 
					,RANK() OVER(PARTITION BY adnumber ORDER BY LastEdited DESC, SetupDate DESC, NEWID()) PrimaryRank
					,STUFF(( SELECT  ',' + GroupName
								FROM   advqagroup (NOLOCK) g
						 			JOIN ADVQADonorGroupbyYear (NOLOCK) gy ON g.groupid = gy.groupid
								WHERE  MemberYear = YEAR(GETDATE())
						 			AND contactid = a.contactid
						 			AND gy.groupid IN ( 1, 2 )
								ORDER BY groupname
								FOR XML PATH('')), 1, 1, '') DonorGroups
			FROM    advcontact a
			WHERE   email IS NOT NULL 
					AND email  <> ''
		  )x
	WHERE PrimaryRank = 1
    
	UNION ALL

	SELECT accountnumber 
		  ,firstname 
		  ,lastname 
		  ,CAST(LTRIM(RTRIM(REPLACE(email,NCHAR(0x09),'')))AS VARCHAR(200))
		  ,'VTXOnly' status 
		  ,accountname  
		  ,NULL DonorGroups
	FROM (	SELECT c.accountnumber 
				  ,c.firstname 
				  ,c.lastname 
				  ,c.email 
				  ,fd.StringValue accountname 
				  ,RANK() OVER(PARTITION BY c.accountnumber ORDER BY c.ETL_updatedDate DESC
																	,c.ETL_CreatedDate DESC
																	,fd.ETL_updatedDate DESC
																	,fd.ETL_CreatedDate DESC, NEWID()) PrimaryRank
			FROM ods.VTXcustomers (NOLOCK) c
				JOIN ( SELECT   ACCOUNTNUMBER
						FROM     amy.SEATdetail_individual_history (NOLOCK)
						EXCEPT
						SELECT   CAST(adnumber AS VARCHAR)
						FROM     advcontact (NOLOCK) 
						)account ON account.ACCOUNTNUMBER = c.AccountNumber
				LEFT JOIN ods.VTXcustomerFieldData (NOLOCK) fd ON fd.customerid = c.id
																		 AND customerfieldid = 1007
			WHERE c.ETL_IsDeleted = 0
				  AND email IS NOT NULL 
				  AND email  <> ''
		  ) x	
	WHERE PrimaryRank = 1

CREATE NONCLUSTERED INDEX IX_AccountNumber on dbo.MailChimp_LoadAccounts_Full (AccountNumber)
CREATE NONCLUSTERED INDEX IX_email on dbo.MailChimp_LoadAccounts_Full (email)
CREATE NONCLUSTERED INDEX IX_AccountNumber on #production (AccountNumber)


/*====================================================================================================
											NET NEW
====================================================================================================*/

SELECT NULLIF(accountnumber	,'')	accountnumber	
	  ,NULLIF(firstname		,'')	firstname		
	  ,NULLIF(lastname		,'')	lastname		
	  ,NULLIF(email		,'')		email		
	  ,NULLIF(status		,'')	status		
	  ,NULLIF(accountname	,'')	accountname		
	  ,NULLIF(DonorGroups	,'')	DonorGroups	
INTO #NewLoadAccounts
FROM dbo.MailChimp_LoadAccounts_Full

EXCEPT 

SELECT accountnumber
	  ,firstname	
	  ,lastname	
	  ,email		
	  ,status		
	  ,accountname	
	  ,DonorGroups	
FROM #production


/*====================================================================================================
											LOAD RECORDS
====================================================================================================*/

TRUNCATE TABLE dbo.MailChimp_LoadAccounts

INSERT INTO dbo.MailChimp_LoadAccounts

SELECT accountnumber	
			  ,firstname	
			  ,lastname	
			  ,Email	
			  ,CurrentEmail	
			  ,status	
			  ,accountname	
			  ,DonorGroups	
			  ,GETDATE() AS LastUpdated
FROM (  SELECT la.accountnumber	
			 , la.firstname	
			 , la.lastname	
			 , CASE WHEN prod.email <> la.email THEN prod.email ELSE NULL END AS Email
			 , la.email	CurrentEmail
			 , la.status	
			 , la.accountname	
			 , la.DonorGroups
			 , RANK() OVER(PARTITION BY la.email ORDER BY case when prod.AccountNumber IS NULL THEN 1 ELSE 0 END, NEWID()) EmailRank
		FROM #NewLoadAccounts la
			LEFT JOIN #production prod ON prod.AccountNumber = la.accountnumber
	 )la 
WHERE EmailRank = 1

/*====================================================================================================
											RECORD SOFT DELETES
====================================================================================================*/
--records no longer in the source will be soft deleted by setting to "unsubscribe" this table is meant
--as a record to distinguish actual unsubscribes from soft deletes

INSERT INTO dbo.MailChimp_Deletes (AccountNumber, Email)

SELECT DISTINCT prod.AccountNumber, Prod.Email
FROM #production prod
	LEFT JOIN dbo.MailChimp_LoadAccounts_Full la on la.AccountNumber = prod.AccountNumber
	LEFT JOIN dbo.MailChimp_Deletes del on del.AccountNumber = prod.AccountNumber
WHERE la.AccountNumber IS NULL
	  AND del.AccountNumber IS NULL
	  AND prod.AccountNumber IS NOT NULL

	  
drop table #production
drop table #NewLoadAccounts
GO
