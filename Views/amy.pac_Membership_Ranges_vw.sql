SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [amy].[pac_Membership_Ranges_vw] as
select  m.membershipid membid, M.DriveYear, ml.membershiplevelid levelid,  mll.name levelname , ML.MinimumAmt/100 minamount, isnull (min (ml2.MinimumAmt/100 - .0001), 1000000000)        maxamount
           from ods.PAC_Membership M
          join ods.PAC_MembershipLevel  ML on M.MembershipID = ML.MembershipID and M.DriveYear = ML.DriveYear
          LEFT JOIN ods.PAC_MembershipLevel  ml2   ON     ML.MembershipID= ml2.MembershipID
                             AND ml2.MinimumAmt > ml.MinimumAmt
                             and ml2.membershipid =  m.membershipid
          join ods.PAC_MembershipLevelLanguage MLL 
          on ML.MembershipID = MLL.MembershipID and ML.DriveYear = MLL.DriveYear and ML.MembershipLevelID = MLL.MembershipLevelID and languagecode = 'en_US'
          where m.organizationid = 'TAM' -- and m.MembershipiD = @MEMBCODE and m.driveyear =  @CurrentYearDT 
   GROUP BY m.membershipid, M.DriveYear, ml.membershiplevelid ,  mll.name ,  ML.MinimumAmt
GO
