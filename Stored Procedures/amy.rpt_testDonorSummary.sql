SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [amy].[rpt_testDonorSummary] (
@TRANSTYPE varchar(20)  = 'TRANSYEAR',
@TRANSYEAR nvarchar(max) = '2015')
as 

DECLARE @DriveYearXML AS XML
SET @DriveYearXML = cast(('<a>'+replace(@TRANSYEAR,',' ,'</a><a>')
                 +'</a>') AS XML)


SELECT   h1.contactid ,
  sum (CASE WHEN transtype LIKE '%Pledge%' THEN  l.TransAmount +l.MatchAmount ELSE  0 END)  totalpledge,   
  sum (CASE WHEN transtype LIKE '%Receipt%' THEN l.TransAmount +l.MatchAmount ELSE  0 END)  totalreceipt,
  sum (CASE WHEN transtype LIKE '%Credit%' THEN  l.TransAmount+ l.MatchAmount  ELSE  0   END)  totalcredit
  from  advcontacttransheader h1,
        advcontacttranslineitems l,
        advProgram p
where  h1.TransID = l.TransID
AND p.ProgramID = l.ProgramID
AND (@TRANSTYPE = 'TRANSYEAR' and
transyear IN  ( 
   SELECT T.C.value('.', 'NVARCHAR(100)') AS [Name]
   FROM (SELECT  --cast(('<a>'+replace(:TRANSYEAR,',' ,'</a><a>') +'</a>') AS XML) 
    @DriveYearXML  AS [Names]) AS A
    CROSS APPLY Names.nodes('/a') as T(C))  )
group by h1.contactid
GO
