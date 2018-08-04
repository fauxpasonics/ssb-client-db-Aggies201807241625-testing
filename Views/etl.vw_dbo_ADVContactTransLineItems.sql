SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*****	Revision History

DCH 2018-05-01	-	view creation for sync to DW04.

*****/


CREATE VIEW [etl].[vw_dbo_ADVContactTransLineItems]	WITH SCHEMABINDING
AS 


SELECT PK, TransID, ProgramID, MatchProgramID, TransAmount, MatchAmount, MatchingGift, Renew, Renewed
--	, Comments
FROM dbo.ADVContactTransLineItems (nolock)
GO
