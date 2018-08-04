SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







/*============================================================================================================
CREATED BY:		Jeff Barberio
CREATED DATE:	5/1/2017
PY VERSION:		N/A
USED BY:		Mail Chimp Outbound Integration
UPDATES:		-5/5 updated the process to filter out deleted accounts and to rank accounts on update/create to 
				 prevent duplicate account numbers coming through. Also, I added in string manipulation to trim
				 spaces on the load accounts and correct an error affecting emails with apostrophes in the "apietl"
				 tables
		
NOTES:			This view is used in conjunction with [dbo].[vw_MailChimp_Unsubscribes] for the Mail Chimp outbound
				integration for Texas AM
=============================================================================================================*/


CREATE VIEW [dbo].[vw_MailChimp_LoadAccounts] AS 


/*======================================================================================================================
													CTE Declaration
======================================================================================================================*/

--Pull account number / current email address to use for updates

WITH CTE_Prod (AccountNumber, Email)
AS (
	SELECT NULLIF(attr.ACCTNUMBER,'') AccountNumber
		 , REPLACE(email.email_address,'''''''''','''') Email
	FROM [apietl].[MailChimp_ListMembers_Prod_members_1] email (NOLOCK)
		JOIN [apietl].[MailChimp_ListMembers_Prod_members_merge_fields_2] (NOLOCK) attr ON email.ETL__MailChimp_ListMembers_Prod_members_id = attr.ETL__MailChimp_ListMembers_Prod_members_id
	WHERE list_id = '80071420fa'
	)
	
--Load Accounts

,CTE_LoadAccounts (accountnumber	,firstname	,lastname	,email	,[status]	,accountname	,DonorGroups)
AS ( 
	 SELECT accountnumber	
		   ,firstname	
		   ,lastname	
		   ,email	
		   ,status	
		   ,accountname	
		   ,DonorGroups
	 FROM (
			 SELECT  CAST(adnumber AS VARCHAR) accountnumber 
					,firstname 
					,lastname 
					,LTRIM(RTRIM(REPLACE(email,NCHAR(0x09),''))) email
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
		  ,LTRIM(RTRIM(REPLACE(email,NCHAR(0x09),'')))
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

	)

/*======================================================================================================================
														OUTPUT
======================================================================================================================*/

SELECT la.accountnumber	
	 , la.firstname	
	 , la.lastname	
	 , CASE WHEN prod.email <> la.email THEN prod.email ELSE NULL END AS OldEmail
	 , la.email	CurrentEmail
	 , la.status	
	 , la.accountname	
	 , la.DonorGroups
FROM CTE_LoadAccounts la
	LEFT JOIN CTE_Prod prod ON prod.AccountNumber = la.accountnumber
GO
