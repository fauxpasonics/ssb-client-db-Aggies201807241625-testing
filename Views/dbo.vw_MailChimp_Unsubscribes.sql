SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










/*============================================================================================================
CREATED BY:		Jeff Barberio
CREATED DATE:	5/1/2017
PY VERSION:		N/A
USED BY:		Mail Chimp Outbound Integration
UPDATES:		- 5/4 jbarberio updated the final join to compare on accountnumber instead of email (This will
								prevent email changes in the source data from setting records to "unsubscribed")
				- 6/8 jbarberio Updated the view to look at dbo.MailChimp_LoadAccounts_Full to avoid unsubcribing 
								records that haven't been modified sint the last push
NOTES:			This view is used in conjunction with [dbo].[vw_MailChimp_Members] for the Mail Chimp outbound
				integration for Texas AM
=============================================================================================================*/



CREATE VIEW [dbo].[vw_MailChimp_Unsubscribes] AS 

SELECT email_address CurrentEmail
FROM [apietl].[MailChimp_ListMembers_Prod_members_1] email (NOLOCK)
	JOIN [apietl].[MailChimp_ListMembers_Prod_members_merge_fields_2] (NOLOCK) attr ON email.ETL__MailChimp_ListMembers_Prod_members_id = attr.ETL__MailChimp_ListMembers_Prod_members_id
	LEFT JOIN dbo.MailChimp_LoadAccounts_Full la  ON attr.ACCTNUMBER = la.accountnumber
WHERE list_id = '80071420fa'
	  AND la.accountnumber IS NULL 
	  AND NULLIF(attr.ACCTNUMBER,'') IS NOT NULL
GO
