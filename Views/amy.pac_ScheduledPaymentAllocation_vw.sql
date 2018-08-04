SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [amy].[pac_ScheduledPaymentAllocation_vw]
              as 
                            select u.OrganizationID, u.AccountID, u.PaymentScheduleID, u.ScheduledPaymentID, u.[Sequence], u.AllocationID, u.RolledPaymentScheduleID, u.DriveYear,
                            u.ApplyAmount/100 ApplyAmount, u.PaidOffAmount/100 PaidOffAmount, u.sys_CreateIP, u.sys_CreateTS, u.sys_CreateUser, u.sys_Status, u.sys_UpdateIP, u.sys_UpdateTS,
                            u.sys_UpdateUser, u.ETL_Sync_DeltaHashKey 
                            from   ods.pac_ScheduledPaymentAllocation u where allocationid  in ( 'FSC','FSTEC') and applyamount > 0
GO
