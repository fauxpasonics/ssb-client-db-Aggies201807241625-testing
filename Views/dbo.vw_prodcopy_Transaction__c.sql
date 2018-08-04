SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_prodcopy_Transaction__c] AS SELECT  Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Amount_Paid__c, Basis__c, Disposition_Code__c, Event_Code__c, Account__c, Item_Code__c, Item_Price__c, Item_Title__c, Location_Preference__c, Order_Date__c, Order_Line_ID__c, Order_Quantity__c, Order_Total__c, Orig_Salecode__c, Orig_Salecode_Name__c, Patron_ID__c, Price_Level__c, Price_Type__c, Promo_Code__c, Promo_Code_Name__c, Mark_Code__c, Season_Code__c, Season_Name__c, Seat_Block__c, Sequence__c, Ticket_Class__c, Full_Transaction_ID__c, Price_Type_Name__c, Discount__c, Salecode_Name__c, Campaign__c, Current_Fiscal_Months_Trans__c, Is_Trans_Current__c, Sort_Month__c, Transaction_Month__c, copyloaddate, ETL_Sync_DeltaHashKey FROM prodcopy.Transaction__c;
GO
