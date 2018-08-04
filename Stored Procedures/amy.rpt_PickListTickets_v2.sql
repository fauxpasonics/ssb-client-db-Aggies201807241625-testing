SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--EXEC  amy.[rpt_PickListTickets_v2] '3531', '04/01/2016 23:59:59',null
--EXEC  [rpt].[rpt_PickListTickets] '3531'


CREATE  PROCEDURE [amy].[rpt_PickListTickets_v2]  (@EventID NUMERIC, @EntryDatePick DATETIME,@PromptComments INT)  AS  

BEGIN

--IF OBJECT_ID('tempdb..#eventcustomer') IS NOT NULL DROP TABLE #eventcustomer
--IF OBJECT_ID('tempdb..#prioritypoints') IS NOT NULL DROP TABLE #prioritypoints


--DROP table  #EventCustomer
--DROP table  #PriorityPoints
--DECLARE @EventCustomer TABLE(contactID INT, ADNumber INT)
--DECLARE @PriorityPoints TABLE(ADNumber INT, PriorityPoints FLOAT)
--DECLARE @EventID AS NUMERIC = 3531
--DECLARE @EntryDatePick DATE = '11/9/15'
--DECLARE @PromptComments int = 0
--DECLARE @EntryDate DATETIME
--SET @EntryDate = (SELECT MAX(CAST(EntryDate AS DATE)) AS EntryDate FROM dbo.ADVHistoricalPriorityPoints WHERE EntryDate < @EntryDatePick )



--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
/*
CREATE TABLE #EventCustomer (contactID INT, ADNumber INT)

INSERT INTO #EventCustomer(contactID, ADNumber)
SELECT DISTINCT 
       con.ContactID
       ,con.ADNumber
--INTO #eventcustomer
FROM ods.VTXtixeventzoneseats ezs
JOIN ods.VTXordergroups og
       ON  ezs.tixseatordergroupid   = og.ordergroup
JOIN ods.VTXcustomers c
       ON og.customerid = c.id
JOIN ods.ADVContact con
       ON c.accountnumber = con.ADNumber
WHERE tixeventid = @EventID
AND ezs.tixseatordergroupid <> '' 
AND c.accountnumber NOT LIKE '%[A-Z]%'


CREATE UNIQUE INDEX IDX01 ON #EventCustomer(contactID, ADNumber) 
*/


/*CREATE TABLE  #PriorityPoints (ADNumber INT, PriorityPoints FLOAT)
INSERT INTO #PriorityPoints( ADNumber, PriorityPoints )
SELECT 
       --hpp.ContactID, switching to ADNumber
       ec.ADNumber
       --,hpp.curr_yr_cash_pts AS prioritypoints
       ,cash_basis_ppts+linked_ppts-linked_ppts_given_up AS prioritypoints  --2015.10.29 Updated calculation per Amy - DT
--INTO #prioritypoints
FROM ods.ADVHistoricalPriorityPoints hpp
JOIN #EventCustomer ec 
       ON hpp.ContactID = ec.ContactID
WHERE CONVERT (DATE, EntryDate)  =  @EntryDate 
       -- AND curr_yr_cash_pts <> 0 --removed to match Amy's logic
       

CREATE UNIQUE INDEX IDX02 ON #PriorityPoints (ADNumber) 

select top * from rpt.rpt_PickListHistory_Hist  */


SELECT
       c.accountnumber
       ,c.OrderID
       ,c.CustomerName
       ,c.FirstName
       ,c.LastName
       ,ct.CustomerType
       ,hpp.PriorityPoints AS PriorityPoints
       ,hpp.Rank AS Rank
       ,c.EventDesc
       ,c.tixsyspricecodedesc
       ,c.tixsyspricecodecode
       ,c.DeliveryMethod
       ,c.section
       ,c.[row]
       ,c.seats
       ,c.Qty
       ,c.tixsyspriceleveldesc
       ,c.[Description]
       ,y.phone1
       ,y.email   
       , cr.RequestNotes RenewalComments
       --, rank() over (partition by con.contactID order by hpp.entryDate desc) as daterank 
       --,hpp.curr_yr_cash_pts as prioritypoints
FROM rpt.rpt_PickListHistory_Hist c
Left join ods.VTXcustomers y  on c.accountnumber = y.accountnumber
left join -- amy.vtxcustomertypes 
(select C.accountnumber, cfd.stringvalue CustomerType from ods.VTXcustomers C, ods.VTXcustomerfielddata CFD where  c.id = CFD.customerid  and CFD.customerfieldid = '111')
ct on ct.accountnumber = c.accountnumber 
left join -- amy.vtxCustomerRequests 
(select C.accountnumber, cfd.stringvalue RequestNotes  from ods.VTXcustomers C,  ods.VTXcustomerfields cf, ods.VTXcustomerfielddata CFD 
where  c.id = CFD.customerid and  cf.id = CFD.customerfieldid  and cf.name = 'F16 Request Notes' 
)
cr on (c.accountnumber = cr.accountnumber )
LEFT JOIN  --#PriorityPoints 
(SELECT 
       --hpp.ContactID, switching to ADNumber
       ec.ADNumber, hpp.[Rank]
       ,cash_basis_ppts+linked_ppts-linked_ppts_given_up AS prioritypoints  
FROM ods.ADVHistoricalPriorityPoints hpp
JOIN advcontact ec 
       ON hpp.ContactID = ec.ContactID
WHERE  EntryDate =  @EntryDatePick
) hpp  
       ON hpp.ADNumber = cast ( c.accountnumber as int) 
WHERE 
tixeventid = @EventID
AND ((c.[Description] IS NOT NULL or cr.RequestNotes is not null) OR @PromptComments=1)
ORDER BY hpp.prioritypoints DESC
--ORDER BY c.accountnumber


END 

/*
select  c.accountnumber
       ,c.OrderID
       ,c.CustomerName
       ,c.FirstName
       ,c.LastName
        ,ct.CustomerType
       ,hpp.PriorityPoints AS PriorityPoints
       ,hpp.Rank AS Rank
       ,c.EventDesc
       ,c.tixsyspricecodedesc
       ,c.tixsyspricecodecode
       ,c.DeliveryMethod
       ,c.section
       ,c.[row]
       ,c.seats
       ,c.Qty
       ,c.tixsyspriceleveldesc
       ,c.[Description]
       ,y.phone1
       ,y.email   
       , cr.RequestNotes RenewalComments
       FROM rpt.rpt_PickListHistory_Hist c
Left join ods.VTXcustomers y  on c.accountnumber = y.accountnumber
left join amy.vtxcustomertypes ct on  cast ( c.accountnumber as int) = ct.accountnumber
left join amy.vtxCustomerRequests cr on ( cast ( c.accountnumber as int)= cr.accountnumber and cr.RequestType = 'F16 Request Notes')
LEFT JOIN  --#PriorityPoints 
(SELECT 
       ec.ADNumber, hpp.[Rank]
       ,cash_basis_ppts+linked_ppts-linked_ppts_given_up AS prioritypoints  
FROM ods.ADVHistoricalPriorityPoints hpp
JOIN advcontact ec 
       ON hpp.ContactID = ec.ContactID
WHERE  EntryDate =  :EntryDatePick
) hpp  
       ON hpp.ADNumber =  cast ( c.accountnumber as int)
WHERE 
tixeventid = :EventID
AND ((c.[Description] IS NOT NULL or cr.RequestNotes is not null) OR :PromptComments=1)
ORDER BY hpp.prioritypoints DESC
--ORDER BY c.accountnumber
*/
GO
