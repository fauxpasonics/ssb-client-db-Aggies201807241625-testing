SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Segmentation].[vw__Donation_Memberships]

AS

(
                SELECT  ssbid.SSB_CRMSYSTEM_CONTACT_ID
                      , c.TransYear AS DM_TransYear
                      , c.MembershipName AS DM_MembershipName
					  , d.LevelName AS DM_MembershipLevel
        FROM    dbo.ADVContact contact WITH (NOLOCK)
                JOIN [dbo].[ADVContactMembershipLevels] b WITH (NOLOCK) ON contact.contactid = b.contactid
                JOIN dbo.ADVMembership c WITH (NOLOCK) ON b.MembID = c.MembID
                JOIN dbo.ADVMembershipLevels d WITH (NOLOCK) ON b.MembID = d.MembID
                                                   AND b.PledgeLevel = d.LevelID
                LEFT JOIN dbo.dimcustomerssbid SSBID WITH ( NOLOCK ) ON SSBID.SSID = CAST(Contact.ContactID AS NVARCHAR) AND SSBID.SourceSystem = 'Advantage'


	

)
GO
