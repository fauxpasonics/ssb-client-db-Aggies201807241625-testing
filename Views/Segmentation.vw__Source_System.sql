SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW  [Segmentation].[vw__Source_System] AS (

SELECT  ssbid.SSB_CRMSYSTEM_CONTACT_ID
		, dimcustomer.SourceSystem CustomerSourceSystem
		, dimcustomer.SSID AS CustomerSourceSystemID
		, dimcustomer.customer_matchkey AS Customer_MatchKey
		, ssbid.SSB_CRMSYSTEM_PRIMARY_FLAG

FROM    dbo.DimCustomer dimcustomer WITH ( NOLOCK )
        JOIN dbo.dimcustomerssbid ssbid WITH ( NOLOCK ) ON ssbid.DimCustomerId = dimcustomer.DimCustomerId


)
GO
