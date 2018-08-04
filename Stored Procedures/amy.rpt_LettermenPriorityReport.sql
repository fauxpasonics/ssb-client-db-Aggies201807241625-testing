SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_LettermenPriorityReport] 
as
select  adnumber, accountname, firstname, lastname, status, adjustedpp, pprank, email from (
select distinct adnumber, accountname, firstname, lastname, status, adjustedpp, pprank  , email from (
select distinct adnumber, accountname, firstname, lastname, status, adjustedpp, pprank  , email
FROM amy.PatronExtendedInfo_vw p  ,
(select distinct acct from  amy.PacTranItem_alt_vw a 
where allocationid in ('LDM','LRG','LSDM','LLM','LCLM','LCSLM' , 'LO', 'LSDC')) pp
where p.patron = pp.acct
 union 
select distinct patron, accountname, firstname, lastname, status, adjustedpp, pprank ,email
FROM  amy.PatronExtendedInfo_vw  c 
where adnumber in (select cast(adnumber as varchar) from amy.donorcategory_vw where categorycode in ('LM','LWA','LW','SLW'))  
) l  ) t order by lastname
/*select  adnumber, accountname, firstname, lastname, status, adjustedpp, pprank, email from (
select distinct adnumber, accountname, firstname, lastname, status, adjustedpp, pprank  , email from (
select distinct adnumber, accountname, firstname, lastname, status, adjustedpp, pprank  , email
FROM advcontact c,
(select distinct contactid from advcontacttransheader h,advcontacttranslineitems l,advProgram p
         WHERE   h.TransID = l.TransID
AND p.ProgramID = l.ProgramID
and (matchinggift = 0 or matchinggift is null)
and programcode in ('LDM','LRG','LSDM','LLM','LCLM','LCSLM' , 'LO', 'LSDC')) pp
where c.contactid = pp.contactid
 union 
select distinct adnumber, accountname, firstname, lastname, status, adjustedpp, pprank ,email
FROM advcontact c 
where contactid in (select contactid from advcontactdonorcategories where categoryid in (122,256,383,335))  
) l  ) t order by lastname*/
GO
