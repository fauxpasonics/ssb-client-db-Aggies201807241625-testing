SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

		


CREATE VIEW [Segmentation].[vw__Donation_Summary]

AS

(
                SELECT  ssbid.SSB_CRMSYSTEM_CONTACT_ID
                      , contact.CashBasisPP AS DS_Cash_PriorityPoints
					  , contact.AccrualBasisPP AS DS_Accrual_PriorityPoints
					  , contact.AdjustedPP AS DS_Adjusted_PriorityPoints
					  , contact.PPRank AS DS_PriorityPointRank
					  , contact.LifetimeGiving AS DS_LifetimeGiving
					  , contact.StaffAssigned AS DS_StaffAssigned
        FROM    dbo.ADVContact contact WITH (NOLOCK)
                LEFT JOIN dbo.dimcustomerssbid SSBID WITH ( NOLOCK ) ON SSBID.SSID = CAST(Contact.ContactID AS NVARCHAR) AND SSBID.SourceSystem = 'Advantage'


	

)
GO
