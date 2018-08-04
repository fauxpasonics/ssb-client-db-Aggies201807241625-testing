SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [rpt].[rpt_DonorProfilePriorityPointsHistory] (@ADNumber int)

AS 

DECLARE @CurrentYear VARCHAR(20)
DECLARE @ContactID INT
SET @CurrentYear = (SELECT CurrentYear FROM dbo.ADVCurrentYear)
SET @ContactID = (SELECT ContactID FROM dbo.ADVContact WHERE ADNumber = @ADNumber)

select TOP 10 
	entrydate
	, cash_basis_ppts+linked_ppts-linked_ppts_given_up points
	,rank
from dbo.ADVHistoricalPriorityPoints pp
JOIN dbo.ADVContact con
	ON pp.ContactID = con.ContactID
WHERE adnumber = @ADNumber  
order by entrydate desc
GO
