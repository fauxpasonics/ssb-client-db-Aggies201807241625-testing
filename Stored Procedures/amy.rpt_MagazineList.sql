SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec rpt_MagazineList

CREATE PROCEDURE [amy].[rpt_MagazineList]
as

declare @CurrentYearDT  int

SET @CurrentYearDT = year (getdate()) ;

 SELECT adnumber AccountNumber, accountname, FIRSTNAME , LastName,
               adj_address1 Address1,
               adj_address2 Address2,
               City,
               State,
               Zip,
              Status 
          FROM amy.patronextendedinfo_vw p
           --      where patron in (select patron  from  amy.donorcategory_vw where categorycode = 'MAG'
          --                         EXCEPT
          --                           select patron    from  amy.donorcategory_vw  where categorycode = 'MAGOPTOUT')
        --       and status in ('Active','Lifetime') and Status <> 'Deceased'
        where patron in (
select patron from (
select patron from (
SELECT  distinct c.patron, --, c.adnumber "Account Number", c.accountname "Full Name",
              -- ca.Address1, ca.Address2,ca.City,ca.State, ca.Zip,ca.Salutation,
               ytd_all.YTD_Total, 
               Status
          FROM amy.PatronExtendedInfo_vw  c
              --JOIN ad12thman..contactaddresses ca
              --    ON c.ContactID = ca.ContactID AND ca.PrimaryAddress = 1
               JOIN
               (SELECT h.acct,
                       al.MembID,
                       al.driveyear,
                       sUM (  isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0) + isnull(CreditAmt,0) )  AS YTD_Total  
                  FROM  amy.PacTranItem_alt_vw h
                   INNER JOIN (select alll.AllocationID ,  alll.MembershipID membid , alll.DriveYear from 
                          ods.PAC_MembershipContributingAllocation alll WHERE  alll.MembershipID ='TMF-ALL' AND alll.DriveYear =@CurrentYearDT 
                           ) al
                          ON    h.AllocationID  = al.AllocationID      
                             AND al.DriveYear =@CurrentYearDT 
                        where  (  h.driveyear = @CurrentYearDT  or 
                        receiveddate >= dateadd(DD,-370, getdate())   )
                       -- (   h.driveyear in (--cast(year(getdate())-1 as char),
                       --      year(getdate()))                                      
                        --         OR (    h.driveyear = 0 AND receiveddate >= '01/01/'+ cast(year(getdate()) as char)))
                GROUP BY h.acct, al.MembID, al.driveyear) 
                 YTD_ALL
                  ON c.patron= YTD_ALL.acct       and ytd_all.YTD_Total >= 150      
      -- AS t
 --WHERE This_Week_CAP_Receipt + This_Week_Annual_Receipt > 0
 ) eee where Status not in ( 'Deceased', 'No Benefits')
 union select patron from amy.PatronExtendedInfo_vw  where status = 'Lifetime'
 --union select contactid, 350  from ad12thman..DonationSummary ds3 where transyear = cast(year(getdate()) as char) and ds3.ProgramID in(106) and ds3.CashReceipts > 0 and ds3.CashReceipts > 0
) y
 except 
select accountid from ods.PAC_DonorCategory where donorcategoryid = 'MAGOPTOUT'
)
GO
