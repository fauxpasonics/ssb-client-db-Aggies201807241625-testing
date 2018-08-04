SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE VIEW [etl].[vw_Advantage_Load_DimCustomer_backup] AS 
(

/************************/
--Created: 2015.08.27
--Last Updated: 2015.10.07
--Version: 0.2
--Author: DT, LK
--Version Notes: Removed Veritix mapping, created separate view for it
/***********************/


/*****Hash Rules for Reference******
WHEN 'int' THEN 'ISNULL(RTRIM(CONVERT(varchar(10),' + COLUMN_NAME + ')),''DBNULL_INT'')'
WHEN 'bigint' THEN 'ISNULL(RTRIM(CONVERT(varchar(10),' + COLUMN_NAME + ')),''DBNULL_BIGINT'')'
WHEN 'datetime' THEN 'ISNULL(RTRIM(CONVERT(varchar(25),' + COLUMN_NAME + ')),''DBNULL_DATETIME'')'  
WHEN 'datetime2' THEN 'ISNULL(RTRIM(CONVERT(varchar(25),' + COLUMN_NAME + ')),''DBNULL_DATETIME'')'
WHEN 'date' THEN 'ISNULL(RTRIM(CONVERT(varchar(10),' + COLUMN_NAME + ',112)),''DBNULL_DATE'')' 
WHEN 'bit' THEN 'ISNULL(RTRIM(CONVERT(varchar(10),' + COLUMN_NAME + ')),''DBNULL_BIT'')'  
WHEN 'decimal' THEN 'ISNULL(RTRIM(CONVERT(varchar(25),'+ COLUMN_NAME + ')),''DBNULL_NUMBER'')' 
WHEN 'numeric' THEN 'ISNULL(RTRIM(CONVERT(varchar(25),'+ COLUMN_NAME + ')),''DBNULL_NUMBER'')' 
ELSE 'ISNULL(RTRIM(' + COLUMN_NAME + '),''DBNULL_TEXT'')'
*****/
--drop view ods.vw_TM_LoadDimCustomer


       SELECT *
       /*Name*/
       , HASHBYTES('sha2_256',
                                                  --ISNULL(RTRIM(FullName),'DBNULL_TEXT') 
                                                   ISNULL(RTRIM(Prefix),'DBNULL_TEXT') 
                                                  + ISNULL(RTRIM(FirstName),'DBNULL_TEXT')
                                                  + ISNULL(RTRIM(MiddleName),'DBNULL_TEXT')  
                                                  + ISNULL(RTRIM(LastName),'DBNULL_TEXT') 
                                                  + ISNULL(RTRIM(Suffix),'DBNULL_TEXT')
                                                  --+ ISNULL(RTRIM(CompanyName),'DBNULL_TEXT')
                                                  ) AS [NameDirtyHash]
       , NULL AS [NameIsCleanStatus]
       , NULL AS [NameMasterId]

       /*Address*/
       /*Address*/
       , HASHBYTES('sha2_256', ISNULL(RTRIM(AddressPrimaryStreet),'DBNULL_TEXT') 
                                                  + ISNULL(RTRIM(AddressPrimaryCity),'DBNULL_TEXT')
                                                  + ISNULL(RTRIM(AddressPrimaryState),'DBNULL_TEXT')  
                                                  + ISNULL(RTRIM(AddressPrimaryZip),'DBNULL_TEXT') 
                                                  ---+ ISNULL(RTRIM(AddressPrimaryCounty),'DBNULL_TEXT')
                                                  ---+ ISNULL(RTRIM(AddressPrimaryCountry),'DBNULL_TEXT')
                                                  ) AS [AddressPrimaryDirtyHash]
       , NULL AS [AddressPrimaryIsCleanStatus]
       , NULL AS [AddressPrimaryMasterId]
       , HASHBYTES('sha2_256', ISNULL(RTRIM(AddressOneStreet),'DBNULL_TEXT') 
                                                  + ISNULL(RTRIM(AddressOneCity),'DBNULL_TEXT')
                                                  + ISNULL(RTRIM(AddressOneState),'DBNULL_TEXT')  
                                                  + ISNULL(RTRIM(AddressOneZip),'DBNULL_TEXT') 
                                                  ---+ ISNULL(RTRIM(AddressOneCounty),'DBNULL_TEXT')
                                                  ---+ ISNULL(RTRIM(AddressOneCountry),'DBNULL_TEXT')
                                                  ) AS [AddressOneDirtyHash]
       , NULL AS [AddressOneIsCleanStatus]
       , NULL AS [AddressOneMasterId]
       , HASHBYTES('sha2_256', ISNULL(RTRIM(AddressTwoStreet),'DBNULL_TEXT') 
                                                  + ISNULL(RTRIM(AddressTwoCity),'DBNULL_TEXT')
                                                  + ISNULL(RTRIM(AddressTwoState),'DBNULL_TEXT')  
                                                  + ISNULL(RTRIM(AddressTwoZip),'DBNULL_TEXT')
                                                  ---+ ISNULL(RTRIM(AddressTwoCounty),'DBNULL_TEXT') 
                                                  ---+ ISNULL(RTRIM(AddressTwoCountry),'DBNULL_TEXT')
                                                  ) AS [AddressTwoDirtyHash]
       , NULL AS [AddressTwoIsCleanStatus]
       , NULL AS [AddressTwoMasterId]
       , HASHBYTES('sha2_256', ISNULL(RTRIM(AddressThreeStreet),'DBNULL_TEXT') 
                                                  + ISNULL(RTRIM(AddressThreeCity),'DBNULL_TEXT')
                                                  + ISNULL(RTRIM(AddressThreeState),'DBNULL_TEXT')  
                                                  + ISNULL(RTRIM(AddressThreeZip),'DBNULL_TEXT') 
                                                  ---+ ISNULL(RTRIM(AddressThreeCounty),'DBNULL_TEXT')
                                                  ---+ ISNULL(RTRIM(AddressThreeCountry),'DBNULL_TEXT')
                                                  ) AS [AddressThreeDirtyHash]
       , NULL AS [AddressThreeIsCleanStatus]
       , NULL AS [AddressThreeMasterId]
       , HASHBYTES('sha2_256', ISNULL(RTRIM(AddressFourStreet),'DBNULL_TEXT') 
                                                  + ISNULL(RTRIM(AddressFourCity),'DBNULL_TEXT')
                                                  + ISNULL(RTRIM(AddressFourState),'DBNULL_TEXT')  
                                                  + ISNULL(RTRIM(AddressFourZip),'DBNULL_TEXT')
                                                  ---+ ISNULL(RTRIM(AddressFourCounty),'DBNULL_TEXT') 
                                                  ---+ ISNULL(RTRIM(AddressFourCountry),'DBNULL_TEXT')
                                                  ) AS [AddressFourDirtyHash]
       , NULL AS [AddressFourIsCleanStatus]
       , NULL AS [AddressFourMasterId]

       /*Contact*/
       , NULL AS [ContactDirtyHash]
       , NULL AS [ContactGuid]

       /*Phone*/
       , HASHBYTES('sha2_256',       ISNULL(RTRIM(PhonePrimary),'DBNULL_TEXT')) AS [PhonePrimaryDirtyHash]
       , NULL AS [PhonePrimaryIsCleanStatus]
       , NULL AS [PhonePrimaryMasterId]
       , HASHBYTES('sha2_256',       ISNULL(RTRIM(PhoneHome),'DBNULL_TEXT')) AS [PhoneHomeDirtyHash]
       , NULL AS [PhoneHomeIsCleanStatus]
       , NULL AS [PhoneHomeMasterId]
       , HASHBYTES('sha2_256',       ISNULL(RTRIM(PhoneCell),'DBNULL_TEXT')) AS [PhoneCellDirtyHash]
       , NULL AS [PhoneCellIsCleanStatus]
       , NULL AS [PhoneCellMasterId]
       , HASHBYTES('sha2_256',       ISNULL(RTRIM(PhoneBusiness),'DBNULL_TEXT')) AS [PhoneBusinessDirtyHash]
       , NULL AS [PhoneBusinessIsCleanStatus]
       , NULL AS [PhoneBusinessMasterId]
       , HASHBYTES('sha2_256',       ISNULL(RTRIM(PhoneFax),'DBNULL_TEXT')) AS [PhoneFaxDirtyHash]
       , NULL AS [PhoneFaxIsCleanStatus]
       , NULL AS [PhoneFaxMasterId]
       , HASHBYTES('sha2_256',       ISNULL(RTRIM(PhoneFax),'DBNULL_TEXT')) AS [PhoneOtherDirtyHash]
       , NULL AS [PhoneOtherIsCleanStatus]
       , NULL AS [PhoneOtherMasterId]

       /*Email*/
       , HASHBYTES('sha2_256',       ISNULL(RTRIM(EmailPrimary),'DBNULL_TEXT')) AS [EmailPrimaryDirtyHash]
       , NULL AS [EmailPrimaryIsCleanStatus]
       , NULL AS [EmailPrimaryMasterId]
       , HASHBYTES('sha2_256',       ISNULL(RTRIM(EmailOne),'DBNULL_TEXT')) AS [EmailOneDirtyHash]
       , NULL AS [EmailOneIsCleanStatus]
       , NULL AS [EmailOneMasterId]
       , HASHBYTES('sha2_256',       ISNULL(RTRIM(EmailTwo),'DBNULL_TEXT')) AS [EmailTwoDirtyHash]
       , NULL AS [EmailTwoIsCleanStatus]
       , NULL AS [EmailTwoMasterId]
	   

       FROM (
--base set

  SELECT
                      'TAMU_A' AS [SourceDB]
                      , 'Advantage' AS [SourceSystem]
                      , 1 AS [SourceSystemPriority]

                      /*Standard Attributes*/
                      , CAST(con.ContactID AS NVARCHAR) [SSID]
                      , CAST(UDF2 AS NVARCHAR(50)) AS [CustomerType]
                      , CAST(Status AS NVARCHAR(50)) AS [CustomerStatus] --UDF1?
                      , NULL AS [AccountType] 
                      , CAST(StaffAssigned AS NVARCHAR(50)) AS [AccountRep] 
                      , CAST(con.Company AS NVARCHAR(50)) AS [CompanyName] 
                      , ad1.Salutation AS [SalutationName]
                      , UDF5 AS [DonorMailName]
                      , UDF5 AS [DonorFormalName]
                      , TRY_CAST(Birthday AS DATE) AS Birthday
					  , NULL AS [Gender] 
                      , NULL AS [MergedRecordFlag]
                      , NULL AS [MergedIntoSSID]

                      /**ENTITIES**/
                      /*Name*/                     
                      , NULL AS FullName
                      , NULL AS [Prefix]
                      , FirstName AS [FirstName]
                      , MiddleInitial AS [MiddleName]
                      , LastName AS [LastName]
                      , Suffix AS [Suffix]
                      --, c.name_title as [Title]

                      /*AddressPrimary*/
                      , ISNULL(ad1.address1,'') + ' ' + ISNULL(ad1.address2,'') + ' ' + ISNULL(ad1.address3, '') AS [AddressPrimaryStreet]
                      , ad1.City AS [AddressPrimaryCity] 
                      , ad1.State AS [AddressPrimaryState] 
                      , ad1.Zip      AS [AddressPrimaryZip] 
                      , ad1.County AS [AddressPrimaryCounty]
                      , ad1.Country      AS [AddressPrimaryCountry] 
                      
                      , ISNULL(ad2.address1,'') + ' ' + ISNULL(ad2.address2,'') + ' ' + ISNULL(ad2.address3,'') AS [AddressOneStreet]
                      , ad2.City AS [AddressOneCity] 
                      , ad2.State AS [AddressOneState] 
                      , ad2.Zip AS [AddressOneZip] 
                      , ad2.County AS [AddressOneCounty] 
                      , ad2.Country  AS [AddressOneCountry] 

                      , ISNULL(ad3.address1,'') + ' ' + ISNULL(ad3.address2,'') + ' ' + ISNULL(ad3.address3,'') AS [AddressTwoStreet]
                      , ad3.City AS [AddressTwoCity] 
                      , ad3.State AS [AddressTwoState] 
                      , ad3.Zip AS [AddressTwoZip] 
                      , ad3.County AS [AddressTwoCounty] 
                      , ad3.Country AS [AddressTwoCountry] 

                      , NULL AS [AddressThreeStreet]
                      , NULL AS [AddressThreeCity] 
                      , NULL AS [AddressThreeState] 
                      , NULL AS [AddressThreeZip] 
                      , NULL AS [AddressThreeCounty] 
                      , NULL AS [AddressThreeCountry] 
                      
                      , NULL AS [AddressFourStreet]
                      , NULL AS [AddressFourCity] 
                      , NULL AS [AddressFourState] 
                      , NULL AS [AddressFourZip] 
                      , NULL AS [AddressFourCounty]
                      , NULL AS [AddressFourCountry] 

                      /*Phone*/
                      , CAST(PHHome AS NVARCHAR(25)) AS [PhonePrimary] --was loaded incorrectly as homephone, updated to primaryphone 8/3/2015
                      , CAST(PHHome AS NVARCHAR(25)) AS [PhoneHome]
                      , CAST(Mobile AS NVARCHAR(25)) AS [PhoneCell]
                      , CAST(PHBusiness AS NVARCHAR(25)) AS [PhoneBusiness]
                      , CAST(Fax AS NVARCHAR(25)) AS [PhoneFax]
                      , CAST(con.PHOther1 AS NVARCHAR(25)) AS [PhoneOther]

                      /*Email*/
                      , Email AS [EmailPrimary]
                      , cei.AdvanceEmail AS [EmailOne]
                      , NULL AS [EmailTwo]

                      /*Extended Attributes*/
                      , con.SpouseName AS [ExtAttribute1] --nvarchar(100)
                      , con.AlumniInfo AS [ExtAttribute2] 
                      , con.SpouseAlumniInfo AS [ExtAttribute3] 
                      , con.ProgramName AS [ExtAttribute4] 
                      , con.UDF3 AS [ExtAttribute5] 
                      , con.UDF4 AS [ExtAttribute6] 
                      , ad2.Salutation AS [ExtAttribute7] 
                      , ad3.Salutation AS [ExtAttribute8] 
                      , cei.AdvanceID AS [ExtAttribute9] 
                      , cei.AdvancePrefName AS[ExtAttribute10] 

                      , NULL AS [ExtAttribute11] --decimal
                      , NULL AS [ExtAttribute12] 
                      , NULL AS [ExtAttribute13] 
                      , NULL AS [ExtAttribute14] 
                      , NULL AS [ExtAttribute15] 
                      , NULL AS [ExtAttribute16] 
                      , NULL AS [ExtAttribute17] 
                      , NULL AS [ExtAttribute18] 
                      , NULL AS [ExtAttribute19] 
                      , NULL AS [ExtAttribute20]  

                      , NULL AS [ExtAttribute21] --datetime
                      , NULL AS [ExtAttribute22] 
                      , NULL AS [ExtAttribute23] 
                      , NULL AS [ExtAttribute24] 
                      , NULL AS [ExtAttribute25] 
                      , NULL AS [ExtAttribute26] 
                      , NULL AS [ExtAttribute27] 
                      , NULL AS [ExtAttribute28] 
                      , NULL AS [ExtAttribute29] 
                      , NULL AS [ExtAttribute30]  

                     -- , NULL AS [ExtAttribute31] doesn't exist in dimcust
                      , cei.AdvanceSpouseName AS [ExtAttribute32] --nvarchar(max)
                      , NULL AS [ExtAttribute33] 
                      , NULL AS [ExtAttribute34] 
                      , NULL AS [ExtAttribute35] 

                      /*Source Created and Updated*/
                      , NULL [SSCreatedBy]
                      , con.EditedBy [SSUpdatedBy]
                      , TRY_CAST(con.SetupDate AS DATE) AS [SSCreatedDate]
                      , TRY_CAST(con.LastEdited AS DATE) AS [SSUpdatedDate]

                      , con.ADNumber [AccountId]
                      , 0 AS IsBusiness
                      --, customer_matchkey

					  , GETDATE() CreatedDate
					  , GETDATE() UpdatedDate
					  , 0 IsDeleted
			          , NULL DeleteDate

			  FROM dbo.ADVContact con WITH (NOLOCK)               
			  LEFT JOIN dbo.ADVContactAddresses ad1 WITH(NOLOCK)
				ON ad1.ContactID = con.ContactID
			  LEFT JOIN dbo.ADVQAContactExtendedInfo cei WITH(NOLOCK)
				ON cei.contactid = ad1.ContactID
			  LEFT JOIN (
							SELECT * FROM
							(
								SELECT 
									ca.contactid
									,ca.Address1
									,ca.Address2 
									,ca.Address3 
									,ca.City 
									,ca.State
									,ca.zip
									,ca.county
									,ca.country
									,ca.Salutation 
									,RANK() OVER (PARTITION BY ContactID ORDER BY PK) AS rownum
								FROM dbo.ADVContactAddresses ca
								WHERE 1=1
								AND primaryaddress = 0
							) a
							WHERE rownum = 1
					) ad2
					ON con.contactid = ad2.contactid
					LEFT JOIN (
							SELECT * FROM
							(
								SELECT 
									ca.contactid
									,ca.Address1
									,ca.Address2 
									,ca.Address3 
									,ca.City 
									,ca.State
									,ca.zip
									,ca.county
									,ca.country
									,ca.Salutation 
									,RANK() OVER (PARTITION BY ContactID ORDER BY PK) AS rownum
								FROM dbo.ADVContactAddresses ca
								WHERE 1=1
								AND primaryaddress = 0
							) a
							WHERE rownum = 2
					) ad3
					ON con.contactid = ad3.contactid
              WHERE 1=1
			  AND ad1.PrimaryAddress = 1
			--  AND ad1.pk = (select max(ad4.PK) from dbo.ADVContactAddresses ad4 where ad4.ContactID = con.ContactID)
	
       ) a

)
GO
