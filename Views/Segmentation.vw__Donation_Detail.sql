SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Segmentation].[vw__Donation_Detail]

AS
(

SELECT 

SSBID.SSB_CRMSYSTEM_CONTACT_ID
--,header.TransID
--,contact.ADNumber
--,contact.ContactID
--,contact.PatronID
,header.TransYear
,header.TransDate
,header.TransGroup
,header.TransType
,lineItem.TransAmount
--,header.PaymentType
,program.ProgramCode
,program.ProgramName
,program.ProgramGroup
,header.MatchingAcct
,header.MatchingTransID
,lineItem.MatchAmount
,lineItem.MatchingGift
--,header.EnterDateTime
--,header.EnterByUser
--,header.BatchRefNo

FROM ADVContact contact WITH (NOLOCK)
	 JOIN ADVContactTransHeader header WITH (NOLOCK)
		  ON contact.ContactID = header.ContactID
	 JOIN ADVContactTransLineItems lineItem WITH (NOLOCK)
		  ON header.TransID = lineitem.transID
	 JOIN ADVProgram program WITH (NOLOCK)
		  ON lineitem.ProgramID = program.ProgramID
	 LEFT JOIN dbo.dimcustomerssbid SSBID WITH (NOLOCK) 
		  ON SSBID.SSID = CAST(contact.contactID AS NVARCHAR) 
			 AND SSBID.SourceSystem = 'Advantage'
)
GO
