SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_MatchingExceptions] as
     select h.transyear, c.adnumber, c.accountname, c1.adnumber, c1.adnumber  receiptaccount, c1.accountname  receiptaccountname,  cm.adnumber  matchaccount, cm.accountname  matchaccountname,  
     p.programname,  li.matchinggift,
     sum(case when h.transtype = 'Cash Pledge' then li.matchamount else 0 end )  cashpledge,
        sum(case when h.transtype = 'Cash Receipt' then li.matchamount else 0 end )  cashreceipt --,
   --  li.*
     FROM 
     advcontact c
   join 
     advContactTransHeader h on          c.contactid = h.contactid                 
    join advContactTransLineItems li on        h.transid = li.transid
    join advprogram p on li.programid = p.programid
    left join  advcontact c1 on c1.contactid = receiptid
    left join    advContactTransHeader mh on       mh.transid = h.MatchingTransID    
    left join advContactTransLineItems mli on      mli.transid =  h.MatchingTransID   
      left join  advcontact cm on cm.contactid = mh.contactid
    where  li.MatchAmount <> 0 
    and h.matchingacct = 340004  --and h.matchingtransid is null
   -- and  (h.contactid = 340004  or h.receiptid = 340004)
   -- and h.contactid <> h.receiptid
   and (h.transyear = format(getdate(),'yyyy') or format(h.transdate, 'yyyy') = format(getdate(),'yyyy'))
  group by  h.transyear, c.adnumber, c.accountname, c1.adnumber, c1.adnumber, c1.accountname  ,  p.programname, li.matchinggift, cm.adnumber , cm.accountname
GO
