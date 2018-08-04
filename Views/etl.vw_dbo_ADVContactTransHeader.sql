SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*****	Revision History

DCH 2018-05-01	-	view creation for sync to DW04.

*****/


CREATE VIEW [etl].[vw_dbo_ADVContactTransHeader]	WITH SCHEMABINDING
AS 


SELECT TransID, ContactID, TransYear, TransDate, TransGroup, TransType, MatchingAcct, MatchingTransID, PaymentType, CheckNo, CardType, CardNo, ExpireDate
	, CardHolderName, CardHolderAddress, CardHolderZip, AuthCode, AuthTransID
--	, notes
	, renew, EnterDateTime, EnterByUser, BatchRefNo, ReceiptID
FROM dbo.ADVContactTransHeader (nolock)
GO
