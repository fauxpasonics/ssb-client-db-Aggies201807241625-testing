SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [etl].[Load_dbo_ADVContact]
(
	@BatchId INT = 0,
	@Options NVARCHAR(MAX) = null
)
AS 

BEGIN
/**************************************Comments***************************************
**************************************************************************************
Mod #:  1
Name:     svcETL
Date:     07/01/2015
Comments: Initial creation
*************************************************************************************/

DECLARE @RunTime DATETIME = GETDATE()

DECLARE @ExecutionId uniqueidentifier = newid();
DECLARE @ProcedureName NVARCHAR(255) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
DECLARE @SrcRowCount INT = ISNULL((SELECT CONVERT(VARCHAR, COUNT(*)) FROM ods.ADVContact),'0');	
DECLARE @SrcDataSize NVARCHAR(255) = '0'

BEGIN TRY 

PRINT 'Execution Id: ' + CONVERT(NVARCHAR(100),@ExecutionId)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'PROCEDURE Processing', 'START', @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src ROW COUNT', @SrcRowCount, @ExecutionId
EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src DataSize', @SrcDataSize, @ExecutionId

SELECT  ContactID, ADNumber, SetupDate, Status, AccountName, FirstName, MiddleInitial, LastName, Company, Salutation, Email, PHHome, PHBusiness, Ext, Fax, Mobile, PHOther1, PHOther1Desc, PHOther2, PHOther2Desc, Birthday, TicketNumber, TicketName, AlumniInfo, SpouseName, SpouseBirthday, SpouseAlumniInfo, ChildrenNames, CashBasisPP, AccrualBasisPP, AdjustedPP, LastEdited, EditedBy, Program, ProgramName, Dear, Zone, BusinessTitle, BankName, BankCity, AccountNo, RoutingNo, LifetimeGiving, UDF1, UDF2, UDF3, UDF4, UDF5, BillingCycle, EStatement, FundraiserID, LinkedAccount, SSN, Fundraiser, TeamID, ActionNotes, StaffAssigned, BillingMonth, PPRank, PledgeLevel, OverrideLevel, ReceiptsLevel, Suffix, CumulativePriority, ImageLink, PinNumber
INTO #SrcData
FROM ods.ADVContact

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Loaded', @ExecutionId

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (ContactID)

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'Src TABLE Setup', 'Temp TABLE Indexes Created', @ExecutionId

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'MERGE Load', 'MERGE Statement Execution', 'START', @ExecutionId

MERGE dbo.ADVContact AS myTarget

USING (
	SELECT * FROM #SrcData
) AS mySource
    
	ON myTarget.ContactID = mySource.ContactID

WHEN MATCHED

THEN UPDATE SET
      myTarget.[ContactID] = mySource.[ContactID]
     ,myTarget.[ADNumber] = mySource.[ADNumber]
     ,myTarget.[SetupDate] = mySource.[SetupDate]
     ,myTarget.[Status] = mySource.[Status]
     ,myTarget.[AccountName] = mySource.[AccountName]
     ,myTarget.[FirstName] = mySource.[FirstName]
     ,myTarget.[MiddleInitial] = mySource.[MiddleInitial]
     ,myTarget.[LastName] = mySource.[LastName]
     ,myTarget.[Company] = mySource.[Company]
     ,myTarget.[Salutation] = mySource.[Salutation]
     ,myTarget.[Email] = mySource.[Email]
     ,myTarget.[PHHome] = mySource.[PHHome]
     ,myTarget.[PHBusiness] = mySource.[PHBusiness]
     ,myTarget.[Ext] = mySource.[Ext]
     ,myTarget.[Fax] = mySource.[Fax]
     ,myTarget.[Mobile] = mySource.[Mobile]
     ,myTarget.[PHOther1] = mySource.[PHOther1]
     ,myTarget.[PHOther1Desc] = mySource.[PHOther1Desc]
     ,myTarget.[PHOther2] = mySource.[PHOther2]
     ,myTarget.[PHOther2Desc] = mySource.[PHOther2Desc]
     ,myTarget.[Birthday] = mySource.[Birthday]
     ,myTarget.[TicketNumber] = mySource.[TicketNumber]
     ,myTarget.[TicketName] = mySource.[TicketName]
     ,myTarget.[AlumniInfo] = mySource.[AlumniInfo]
     ,myTarget.[SpouseName] = mySource.[SpouseName]
     ,myTarget.[SpouseBirthday] = mySource.[SpouseBirthday]
     ,myTarget.[SpouseAlumniInfo] = mySource.[SpouseAlumniInfo]
     ,myTarget.[ChildrenNames] = mySource.[ChildrenNames]
     ,myTarget.[CashBasisPP] = mySource.[CashBasisPP]
     ,myTarget.[AccrualBasisPP] = mySource.[AccrualBasisPP]
     ,myTarget.[AdjustedPP] = mySource.[AdjustedPP]
     ,myTarget.[LastEdited] = mySource.[LastEdited]
     ,myTarget.[EditedBy] = mySource.[EditedBy]
     ,myTarget.[Program] = mySource.[Program]
     ,myTarget.[ProgramName] = mySource.[ProgramName]
     ,myTarget.[Dear] = mySource.[Dear]
     ,myTarget.[Zone] = mySource.[Zone]
     ,myTarget.[BusinessTitle] = mySource.[BusinessTitle]
     ,myTarget.[BankName] = mySource.[BankName]
     ,myTarget.[BankCity] = mySource.[BankCity]
     ,myTarget.[AccountNo] = mySource.[AccountNo]
     ,myTarget.[RoutingNo] = mySource.[RoutingNo]
     ,myTarget.[LifetimeGiving] = mySource.[LifetimeGiving]
     ,myTarget.[UDF1] = mySource.[UDF1]
     ,myTarget.[UDF2] = mySource.[UDF2]
     ,myTarget.[UDF3] = mySource.[UDF3]
     ,myTarget.[UDF4] = mySource.[UDF4]
     ,myTarget.[UDF5] = mySource.[UDF5]
     ,myTarget.[BillingCycle] = mySource.[BillingCycle]
     ,myTarget.[EStatement] = mySource.[EStatement]
     ,myTarget.[FundraiserID] = mySource.[FundraiserID]
     ,myTarget.[LinkedAccount] = mySource.[LinkedAccount]
     ,myTarget.[SSN] = mySource.[SSN]
     ,myTarget.[Fundraiser] = mySource.[Fundraiser]
     ,myTarget.[TeamID] = mySource.[TeamID]
     ,myTarget.[ActionNotes] = mySource.[ActionNotes]
     ,myTarget.[StaffAssigned] = mySource.[StaffAssigned]
     ,myTarget.[BillingMonth] = mySource.[BillingMonth]
     ,myTarget.[PPRank] = mySource.[PPRank]
     ,myTarget.[PledgeLevel] = mySource.[PledgeLevel]
     ,myTarget.[OverrideLevel] = mySource.[OverrideLevel]
     ,myTarget.[ReceiptsLevel] = mySource.[ReceiptsLevel]
     ,myTarget.[Suffix] = mySource.[Suffix]
     ,myTarget.[CumulativePriority] = mySource.[CumulativePriority]
     ,myTarget.[ImageLink] = mySource.[ImageLink]
     ,myTarget.[PinNumber] = mySource.[PinNumber]
     
WHEN NOT MATCHED BY TARGET
THEN INSERT
     ([ContactID]
     ,[ADNumber]
     ,[SetupDate]
     ,[Status]
     ,[AccountName]
     ,[FirstName]
     ,[MiddleInitial]
     ,[LastName]
     ,[Company]
     ,[Salutation]
     ,[Email]
     ,[PHHome]
     ,[PHBusiness]
     ,[Ext]
     ,[Fax]
     ,[Mobile]
     ,[PHOther1]
     ,[PHOther1Desc]
     ,[PHOther2]
     ,[PHOther2Desc]
     ,[Birthday]
     ,[TicketNumber]
     ,[TicketName]
     ,[AlumniInfo]
     ,[SpouseName]
     ,[SpouseBirthday]
     ,[SpouseAlumniInfo]
     ,[ChildrenNames]
     ,[CashBasisPP]
     ,[AccrualBasisPP]
     ,[AdjustedPP]
     ,[LastEdited]
     ,[EditedBy]
     ,[Program]
     ,[ProgramName]
     ,[Dear]
     ,[Zone]
     ,[BusinessTitle]
     ,[BankName]
     ,[BankCity]
     ,[AccountNo]
     ,[RoutingNo]
     ,[LifetimeGiving]
     ,[UDF1]
     ,[UDF2]
     ,[UDF3]
     ,[UDF4]
     ,[UDF5]
     ,[BillingCycle]
     ,[EStatement]
     ,[FundraiserID]
     ,[LinkedAccount]
     ,[SSN]
     ,[Fundraiser]
     ,[TeamID]
     ,[ActionNotes]
     ,[StaffAssigned]
     ,[BillingMonth]
     ,[PPRank]
     ,[PledgeLevel]
     ,[OverrideLevel]
     ,[ReceiptsLevel]
     ,[Suffix]
     ,[CumulativePriority]
     ,[ImageLink]
     ,[PinNumber]
     )
VALUES
     (mySource.[ContactID]
     ,mySource.[ADNumber]
     ,mySource.[SetupDate]
     ,mySource.[Status]
     ,mySource.[AccountName]
     ,mySource.[FirstName]
     ,mySource.[MiddleInitial]
     ,mySource.[LastName]
     ,mySource.[Company]
     ,mySource.[Salutation]
     ,mySource.[Email]
     ,mySource.[PHHome]
     ,mySource.[PHBusiness]
     ,mySource.[Ext]
     ,mySource.[Fax]
     ,mySource.[Mobile]
     ,mySource.[PHOther1]
     ,mySource.[PHOther1Desc]
     ,mySource.[PHOther2]
     ,mySource.[PHOther2Desc]
     ,mySource.[Birthday]
     ,mySource.[TicketNumber]
     ,mySource.[TicketName]
     ,mySource.[AlumniInfo]
     ,mySource.[SpouseName]
     ,mySource.[SpouseBirthday]
     ,mySource.[SpouseAlumniInfo]
     ,mySource.[ChildrenNames]
     ,mySource.[CashBasisPP]
     ,mySource.[AccrualBasisPP]
     ,mySource.[AdjustedPP]
     ,mySource.[LastEdited]
     ,mySource.[EditedBy]
     ,mySource.[Program]
     ,mySource.[ProgramName]
     ,mySource.[Dear]
     ,mySource.[Zone]
     ,mySource.[BusinessTitle]
     ,mySource.[BankName]
     ,mySource.[BankCity]
     ,mySource.[AccountNo]
     ,mySource.[RoutingNo]
     ,mySource.[LifetimeGiving]
     ,mySource.[UDF1]
     ,mySource.[UDF2]
     ,mySource.[UDF3]
     ,mySource.[UDF4]
     ,mySource.[UDF5]
     ,mySource.[BillingCycle]
     ,mySource.[EStatement]
     ,mySource.[FundraiserID]
     ,mySource.[LinkedAccount]
     ,mySource.[SSN]
     ,mySource.[Fundraiser]
     ,mySource.[TeamID]
     ,mySource.[ActionNotes]
     ,mySource.[StaffAssigned]
     ,mySource.[BillingMonth]
     ,mySource.[PPRank]
     ,mySource.[PledgeLevel]
     ,mySource.[OverrideLevel]
     ,mySource.[ReceiptsLevel]
     ,mySource.[Suffix]
     ,mySource.[CumulativePriority]
     ,mySource.[ImageLink]
     ,mySource.[PinNumber]
     )

WHEN NOT MATCHED BY SOURCE

THEN DELETE
;

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Merge Load', 'Merge Statement Execution', 'Complete', @ExecutionId


END TRY 
BEGIN CATCH 

	DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
	DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
	DECLARE @ErrorState INT = ERROR_STATE();
			
	PRINT @ErrorMessage
	EXEC etl.LogEventRecordDB @Batchid, 'Error', @ProcedureName, 'Merge Load', 'Merge Error', @ErrorMessage, @ExecutionId
	EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Merge Load', 'Procedure Processing', 'Complete', @ExecutionId

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)

END CATCH

EXEC etl.LogEventRecordDB @Batchid, 'Info', @ProcedureName, 'Merge Load', 'Procedure Processing', 'Complete', @ExecutionId


END
GO
