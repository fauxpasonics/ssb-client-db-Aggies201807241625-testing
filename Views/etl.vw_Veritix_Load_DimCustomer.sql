SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE VIEW [etl].[vw_Veritix_Load_DimCustomer] AS 
(

/************************/
--Created: 2015.10.07
--Last Updated: 
--Version: 1.0
--Author: LK
--Version Notes: Created separate view for Veritix mapping
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
                      'TAMU_V' AS [SourceDB]
                      , 'Veritix' AS [SourceSystem]
                      , 1 AS [SourceSystemPriority]

                      /*Standard Attributes*/
                      , CAST(CAST (cust.id AS INT) AS NVARCHAR(50)) [SSID]
                      , NULL AS [CustomerType]
                      , CAST('Active' AS NVARCHAR(50)) AS [CustomerStatus] --UDF1?
                      , NULL AS [AccountType] 
                      , NULL AS [AccountRep] 
                      , CAST(cust.companyname AS NVARCHAR(50)) AS [CompanyName] 
                      , cust.salutation AS [SalutationName]
                      , NULL AS [DonorMailName]
                      , NULL AS [DonorFormalName]
                      , TRY_CAST(cust.Birthday AS DATE) AS Birthday
					  , NULL AS [Gender] 
                      , NULL AS [MergedRecordFlag]
                      , NULL AS [MergedIntoSSID]

                      /**ENTITIES**/
                      /*Name*/                     
                      , cust.fullname AS FullName
                      , cust.prefix AS [Prefix]
                      , cust.FirstName AS [FirstName]
                      , cust.Middle AS [MiddleName]
                      , cust.LastName AS [LastName]
                      , cust.Suffix AS [Suffix]
                      --, c.name_title as [Title]

                      /*AddressPrimary*/
                      , CAST(ISNULL(ad.address1,'') AS VARCHAR(100)) + ' ' + CAST(ISNULL(ad.address2,'') AS VARCHAR(100)) AS [AddressPrimaryStreet]
                      , ad.City AS [AddressPrimaryCity] 
                      , ad.State AS [AddressPrimaryState] 
                      , ad.Zip      AS [AddressPrimaryZip] 
                      , NULL AS [AddressPrimaryCounty]
                      , ad.Country      AS [AddressPrimaryCountry] 
                      
                      , CAST(ISNULL(ad1.address1,'') AS VARCHAR(100)) + ' ' + CAST(ISNULL(ad1.address2,'') AS VARCHAR(100)) AS [AddressOneStreet]
                      , ad1.City AS [AddressOneCity] 
                      , ad1.State AS [AddressOneState] 
                      , ad1.zip AS [AddressOneZip] 
                      , NULL AS [AddressOneCounty] 
                      , ad1.Country  AS [AddressOneCountry] 

                      , CAST(ISNULL(ad2.address1,'') AS VARCHAR(100)) + ' ' + CAST(ISNULL(ad2.address2,'') AS VARCHAR(100)) AS [AddressTwoStreet]
                      , ad2.City AS [AddressTwoCity] 
                      , ad2.State AS [AddressTwoState] 
                      , ad2.zip AS [AddressTwoZip] 
                      , NULL AS [AddressTwoCounty] 
                      , ad2.Country AS [AddressTwoCountry] 

                      , CAST(ISNULL(ad3.address1,'') AS VARCHAR(100)) + ' ' + CAST(ISNULL(ad3.address2,'') AS VARCHAR(100)) AS [AddressThreeStreet]
                      , ad3.City AS [AddressThreeCity] 
                      , ad3.State AS [AddressThreeState] 
                      , ad3.zip AS [AddressThreeZip] 
                      , NULL AS [AddressThreeCounty] 
                      , ad3.Country AS [AddressThreeCountry] 
                      
                      , CAST(ISNULL(ad4.address1,'') AS VARCHAR(100)) + ' ' + CAST(ISNULL(ad4.address2,'') AS VARCHAR(100)) AS [AddressFourStreet]
                      , ad4.City AS [AddressFourCity] 
                      , ad4.State AS [AddressFourState] 
                      , ad4.zip AS [AddressFourZip] 
                      , NULL AS [AddressFourCounty]
                      , ad4.Country AS [AddressFourCountry] 

                      /*Phone*/
                      , CAST(cust.phone1 AS NVARCHAR(25)) AS [PhonePrimary] --was loaded incorrectly as homephone, updated to primaryphone 8/3/2015
                      , CAST(CASE WHEN cust.phone1type = 1 THEN phone1 WHEN cust.phone2type = 1 THEN phone2 WHEN cust.phone3type = 1 THEN phone3 END AS NVARCHAR(25)) AS [PhoneHome]
                      , CAST(CASE WHEN cust.phone1type = 2 THEN phone1 WHEN cust.phone2type = 2 THEN phone2 WHEN cust.phone3type = 2 THEN phone3 END AS NVARCHAR(25)) AS [PhoneCell]
                      , CAST(CASE WHEN cust.phone1type = 0 THEN phone1 WHEN cust.phone2type = 0 THEN phone2 WHEN cust.phone3type = 0 THEN phone3 END AS NVARCHAR(25)) AS [PhoneBusiness]
                      , CAST(cust.fax AS NVARCHAR(25)) AS [PhoneFax]
                      , CAST(CASE WHEN cust.phone1type IS NULL THEN phone1 WHEN cust.phone2type IS NULL THEN phone2 WHEN cust.phone3type IS NULL THEN phone3 END AS NVARCHAR(25)) AS [PhoneOther]

                      /*Email*/
                      , cust.Email AS [EmailPrimary]
                      , NULL AS [EmailOne]
                      , NULL AS [EmailTwo]

                      /*Extended Attributes*/
                      , NULL AS[ExtAttribute1] --nvarchar(100)
                      , NULL AS[ExtAttribute2] 
                      , NULL AS[ExtAttribute3] 
                      , NULL AS[ExtAttribute4] 
                      , NULL AS[ExtAttribute5] 
                      , NULL AS[ExtAttribute6] 
                      , NULL AS[ExtAttribute7] 
                      , NULL AS[ExtAttribute8] 
                      , NULL AS[ExtAttribute9] 
                      , NULL AS[ExtAttribute10] 

                      , CASE WHEN ISNUMERIC(accountnumber + '.0e0') = 1 AND accountnumber NOT LIKE '%[^0-9.]%' THEN CAST(accountnumber AS DECIMAL(18,6)) END AS [ExtAttribute11] 
                      , NULL AS [ExtAttribute12] 
                      , NULL AS [ExtAttribute13] 
                      , NULL AS [ExtAttribute14] 
                      , NULL AS [ExtAttribute15] 
                      , CAST(cust.optedin AS INT) AS [ExtAttribute16] 
                      , NULL AS [ExtAttribute17] 
                      , NULL AS [ExtAttribute18] 
                      , NULL AS [ExtAttribute19] 
                      , NULL AS [ExtAttribute20]  

                      , NULL AS [ExtAttribute21] --datetime
                      , NULL AS [ExtAttribute22] 
                      , NULL AS[ExtAttribute23] 
                      , NULL AS [ExtAttribute24] 
                      , NULL AS [ExtAttribute25] 
                      , NULL AS [ExtAttribute26] 
                      , NULL AS [ExtAttribute27] 
                      , NULL AS [ExtAttribute28] 
                      , NULL AS [ExtAttribute29] 
                      , NULL AS [ExtAttribute30]  

                    --  , NULL AS [ExtAttribute31] not in dimcustomer
                      , ad.shipto AS [ExtAttribute32] 
                      , ad.description AS [ExtAttribute33] 
                      , NULL AS [ExtAttribute34] 
                      , NULL AS [ExtAttribute35] 

                      /*Source Created and Updated*/
                      , NULL [SSCreatedBy]
                      , NULL [SSUpdatedBy]
                      , cust.initdate AS [SSCreatedDate]
                      , cust.lastupdate [SSUpdatedDate]

                      , NULL [AccountId]
                      , 0 IsBusiness
                      --, customer_matchkey

					  /* Created and Updated*/
					, GETDATE() CreatedDate
					, GETDATE() UpdatedDate
					, 0 IsDeleted
					, NULL DeleteDate
					
				FROM ods.VTXcustomers cust WITH(NOLOCK)
				JOIN ods.VTXcustomeraddresses ad WITH(NOLOCK)
					ON cust.addressid = ad.addressid
				LEFT JOIN 
					(SELECT * FROM
							(
								SELECT 
									ca.customerid,ca.address1,ca.address2,ca.city,ca.STATE,ca.zip,ca.country
									,RANK() OVER (PARTITION BY customerid ORDER BY addressid) AS rownum
								FROM ods.vtxCustomerAddresses ca
								WHERE 1=1
								AND addressid NOT IN (SELECT addressid FROM ods.vtxcustomers cust WHERE ca.customerid = cust.id)
								AND ACTIVE = 1
							) a
							WHERE rownum = 1
						)ad1
				ON cust.id = ad1.customerid
				LEFT JOIN 
					(SELECT * FROM
							(
								SELECT 
									ca.customerid,ca.address1,ca.address2,ca.city,ca.STATE,ca.zip,ca.country
									,RANK() OVER (PARTITION BY customerid ORDER BY addressid) AS rownum
								FROM ods.vtxCustomerAddresses ca
								WHERE 1=1
								AND addressid NOT IN (SELECT addressid FROM ods.vtxcustomers cust WHERE ca.customerid = cust.id)
								AND ACTIVE = 1
							) a
							WHERE rownum = 2
						)ad2
				ON cust.id = ad2.customerid
				LEFT JOIN 
					(SELECT * FROM
							(
								SELECT 
									ca.customerid,ca.address1,ca.address2,ca.city,ca.STATE,ca.zip,ca.country
									,RANK() OVER (PARTITION BY customerid ORDER BY addressid) AS rownum
								FROM ods.vtxCustomerAddresses ca
								WHERE 1=1
								AND addressid NOT IN (SELECT addressid FROM ods.vtxcustomers cust WHERE ca.customerid = cust.id)
								AND ACTIVE = 1
							) a
							WHERE rownum = 3
						)ad3
				ON cust.id = ad3.customerid
				LEFT JOIN 
					(SELECT * FROM
							(
								SELECT 
									ca.customerid,ca.address1,ca.address2,ca.city,ca.STATE,ca.zip,ca.country
									,RANK() OVER (PARTITION BY customerid ORDER BY addressid) AS rownum
								FROM ods.vtxCustomerAddresses ca
								WHERE 1=1
								AND addressid NOT IN (SELECT addressid FROM ods.vtxcustomers cust WHERE ca.customerid = cust.id)
								AND ACTIVE = 1
							) a
							WHERE rownum = 4
						)ad4
				ON cust.id = ad4.customerid
			

       ) a

)
GO
