CREATE TABLE [mdm].[ClientRefreshConfig]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ClientName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefreshFrequency] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefreshDay] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefreshStartDate] [date] NULL,
[RefreshEndDate] [date] NULL,
[Active] [bit] NULL CONSTRAINT [DF_ClientRefreshConfig_Active] DEFAULT ((1)),
[LastRefreshDate] [datetime] NULL,
[InsertDate] [datetime] NULL CONSTRAINT [DF_ClientRefreshConfig_InsertDate] DEFAULT (getdate()),
[UpdateDate] [datetime] NULL,
[ActivateDate] [datetime] NULL CONSTRAINT [DF_ClientConfigRefresh_ActivateDate] DEFAULT (getdate()),
[DeactivateDate] [datetime] NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ClientRefreshConfig_CreatedBy] DEFAULT (suser_sname()),
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE TRIGGER [mdm].[trg_ClientRefreshConfig_Update_Insert]    
ON [mdm].[ClientRefreshConfig] 
AFTER UPDATE, INSERT    
AS     
BEGIN    
	SET NOCOUNT ON     
    
	DECLARE @action CHAR(1), @currentDatetime DATETIME = CURRENT_TIMESTAMP    
 
	IF EXISTS (SELECT a.ClientName, a.RefreshFrequency, a.Active, COUNT(0) AS cnt 
	FROM mdm.ClientRefreshConfig a 
	INNER JOIN Inserted b ON a.ClientName = b.ClientName 
		AND a.RefreshFrequency = b.RefreshFrequency 
	GROUP BY a.ClientName, a.RefreshFrequency, a.Active 
	HAVING COUNT(0) > 1) 
	BEGIN 
		RAISERROR('Only 1 Daily/Weekly schedule per client is permitted.', 16, 1) 
		ROLLBACK 
	END 
  
	IF ISNULL((SELECT COUNT(0) 
	FROM mdm.ClientRefreshConfig a 
	INNER JOIN Inserted b ON a.ID = b.ID 
	WHERE b.RefreshFrequency = 'Weekly' 
	AND ISNULL(b.RefreshDay,'') NOT IN ('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')),0) > 0 
	BEGIN 
		RAISERROR('Invalid value supplied for RefreshDay. Valid values are Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, or Sunday.', 16, 1) 
		ROLLBACK 
	END 
 
    --    
    -- Check if this is an INSERT, UPDATE or DELETE Action.    
    --     
    SET @action = 'I'; -- Set Action to Insert by default.    
    IF EXISTS(SELECT * FROM Deleted)    
    BEGIN    
        SET @action =     
            CASE    
                WHEN EXISTS(SELECT * FROM Inserted) THEN 'U' -- Set Action to Updated.    
                ELSE 'D' -- Set Action to Deleted.           
            END    
    END    
    ELSE IF NOT EXISTS(SELECT * FROM Inserted)     
		RETURN; -- Nothing updated or inserted.    
    
	IF @action = 'I'    
	BEGIN    
		UPDATE mdm.ClientRefreshConfig    
		SET RefreshDay = CASE WHEN i.RefreshFrequency = 'Daily' THEN NULL ELSE i.RefreshDay END 
			, ActivateDate = CASE WHEN i.Active = 1 THEN i.InsertDate ELSE NULL END 
			, CreatedBy = SYSTEM_USER 
			, UpdateDate = NULL 
			, UpdatedBy = NULL 
		--SELECT *     
		FROM mdm.ClientRefreshConfig a    
		INNER JOIN Inserted i ON a.ID = i.ID    
	END    
	ELSE IF @action = 'U'-- AND NOT UPDATE(InsertDate)   
	BEGIN    
		IF UPDATE(Active)    
			UPDATE mdm.ClientRefreshConfig    
			SET ActivateDate = CASE WHEN i.Active = 1 THEN @currentDatetime ELSE i.ActivateDate END    
				, DeactivateDate = CASE WHEN i.Active = 0 THEN @currentDatetime ELSE i.DeactivateDate END    
				, UpdateDate = @currentDatetime    
				, UpdatedBy = SYSTEM_USER 
			FROM mdm.ClientRefreshConfig a    
			INNER JOIN Inserted i ON a.ID = i.ID    
			INNER JOIN Deleted d ON i.ID = d.ID    
			WHERE 1=1    
			AND i.Active != d.Active    
    
		IF (UPDATE(ClientName)    
			OR UPDATE(RefreshFrequency)     
			OR UPDATE(RefreshDay)     
			OR UPDATE(RefreshStartDate)     
			OR UPDATE(RefreshEndDate))    
		BEGIN    
			UPDATE mdm.ClientRefreshConfig    
			SET RefreshDay = CASE WHEN i.RefreshFrequency = 'Daily' THEN NULL ELSE i.RefreshDay END 
				, UpdateDate = @currentDatetime    
				, UpdatedBy = SYSTEM_USER 
			FROM mdm.ClientRefreshConfig a    
			INNER JOIN Inserted i ON a.ID = i.ID    
			INNER JOIN Deleted d ON i.ID = d.ID    
			WHERE 1=1    
			AND (ISNULL(i.ClientName,'') != ISNULL(d.ClientName,'')    
				OR ISNULL(i.RefreshFrequency,'') != ISNULL(d.RefreshFrequency,'')    
				OR ISNULL(i.RefreshDay,'') != ISNULL(d.RefreshDay,'')    
				OR ISNULL(CAST(i.RefreshStartDate AS VARCHAR(50)),'') != ISNULL(CAST(d.RefreshStartDate AS VARCHAR(50)),'')    
				OR ISNULL(CAST(i.RefreshEndDate AS VARCHAR(50)),'') != ISNULL(CAST(d.RefreshEndDate AS VARCHAR(50)),'')     
			)    
		END    
	END    
 
END
GO
DISABLE TRIGGER [mdm].[trg_ClientRefreshConfig_Update_Insert] ON [mdm].[ClientRefreshConfig]
GO
