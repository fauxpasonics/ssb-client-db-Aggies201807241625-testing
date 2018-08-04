SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [rpt].[rpt_DonorProfileBalanceDue] (@ADNumber VARCHAR(200))

AS

DECLARE @CurrentYear VARCHAR(20)
SET @CurrentYear = (SELECT MAX(convert(int,CurrentYear)) FROM dbo.ADVCurrentYear)

SELECT adv.*, vtx.TicketingDue
FROM
(
	SELECT
		con.ADNumber
		,SUM(case when transyear = @CurrentYear then  ds.CashPledges+matchpledges+gikpledges-cashreceipts-matchreceipts-gikreceipts else 0 end) AS AnnualBalanceDue
		,SUM(case when transyear = 'CAP' then ds.CashPledges+matchpledges-cashreceipts-matchreceipts else 0 end) AS CAPBalanceDue
	FROM dbo.ADVDonationSummary ds
	JOIN dbo.ADVContact con
		ON ds.ContactID = con.ContactID
	WHERE CAST(con.ADNumber AS VARCHAR(200)) = @ADNumber
	  AND (TransYear = @CurrentYear OR (TransYear = 'CAP'))
	GROUP BY con.ADNumber
) adv
LEFT JOIN
(
	SELECT
		c.accountnumber
		,SUM(ordergrouppaymentbalance) as TicketingDue
	FROM ods.VTXcustomers c
	LEFT JOIN ods.VTXordergroups og
		ON og.customerid = c.id
	WHERE 1=1 
		AND CAST(c.accountnumber as VARCHAR(200)) = @ADNumber
		AND ordergroupstatus <> 5
		AND DATEPART(yyyy,og.ordergroupdate) = @CurrentYear
	GROUP BY c.accountnumber
) vtx
ON CAST(adv.ADNumber AS VARCHAR(200)) = CAST(vtx.accountnumber AS VARCHAR(200))
GO
