CREATE TABLE [prodcopystg].[User]
(
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Username] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Name] [nvarchar] (121) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyName] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Division] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Department] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Street] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Latitude] [float] NULL,
[Longitude] [float] NULL,
[GeocodeAccuracy] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailPreferencesAutoBcc] [bit] NULL,
[EmailPreferencesAutoBccStayInTouch] [bit] NULL,
[EmailPreferencesStayInTouchReminder] [bit] NULL,
[SenderEmail] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SenderName] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Signature] [nvarchar] (1333) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StayInTouchSubject] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StayInTouchSignature] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StayInTouchNote] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobilePhone] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Alias] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CommunityNickname] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BadgeText] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NULL,
[TimeZoneSidKey] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserRoleId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocaleSidKey] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceivesInfoEmails] [bit] NULL,
[ReceivesAdminInfoEmails] [bit] NULL,
[EmailEncodingKey] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserType] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LanguageLocaleKey] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmployeeNumber] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DelegatedApproverId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ManagerId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastLoginDate] [datetime] NULL,
[LastPasswordChangeDate] [datetime] NULL,
[CreatedDate] [datetime] NULL,
[CreatedById] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModifiedDate] [datetime] NULL,
[LastModifiedById] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SystemModstamp] [datetime] NULL,
[OfflineTrialExpirationDate] [datetime] NULL,
[OfflinePdaTrialExpirationDate] [datetime] NULL,
[UserPermissionsMarketingUser] [bit] NULL,
[UserPermissionsOfflineUser] [bit] NULL,
[UserPermissionsAvantgoUser] [bit] NULL,
[UserPermissionsCallCenterAutoLogin] [bit] NULL,
[UserPermissionsMobileUser] [bit] NULL,
[UserPermissionsSFContentUser] [bit] NULL,
[UserPermissionsInteractionUser] [bit] NULL,
[UserPermissionsSupportUser] [bit] NULL,
[ForecastEnabled] [bit] NULL,
[UserPreferencesActivityRemindersPopup] [bit] NULL,
[UserPreferencesEventRemindersCheckboxDefault] [bit] NULL,
[UserPreferencesTaskRemindersCheckboxDefault] [bit] NULL,
[UserPreferencesReminderSoundOff] [bit] NULL,
[UserPreferencesDisableAllFeedsEmail] [bit] NULL,
[UserPreferencesDisableFollowersEmail] [bit] NULL,
[UserPreferencesDisableProfilePostEmail] [bit] NULL,
[UserPreferencesDisableChangeCommentEmail] [bit] NULL,
[UserPreferencesDisableLaterCommentEmail] [bit] NULL,
[UserPreferencesDisProfPostCommentEmail] [bit] NULL,
[UserPreferencesApexPagesDeveloperMode] [bit] NULL,
[UserPreferencesHideCSNGetChatterMobileTask] [bit] NULL,
[UserPreferencesDisableMentionsPostEmail] [bit] NULL,
[UserPreferencesDisMentionsCommentEmail] [bit] NULL,
[UserPreferencesHideCSNDesktopTask] [bit] NULL,
[UserPreferencesHideChatterOnboardingSplash] [bit] NULL,
[UserPreferencesHideSecondChatterOnboardingSplash] [bit] NULL,
[UserPreferencesDisCommentAfterLikeEmail] [bit] NULL,
[UserPreferencesDisableLikeEmail] [bit] NULL,
[UserPreferencesSortFeedByComment] [bit] NULL,
[UserPreferencesDisableMessageEmail] [bit] NULL,
[UserPreferencesDisableBookmarkEmail] [bit] NULL,
[UserPreferencesDisableSharePostEmail] [bit] NULL,
[UserPreferencesEnableAutoSubForFeeds] [bit] NULL,
[UserPreferencesDisableFileShareNotificationsForApi] [bit] NULL,
[UserPreferencesShowTitleToExternalUsers] [bit] NULL,
[UserPreferencesShowManagerToExternalUsers] [bit] NULL,
[UserPreferencesShowEmailToExternalUsers] [bit] NULL,
[UserPreferencesShowWorkPhoneToExternalUsers] [bit] NULL,
[UserPreferencesShowMobilePhoneToExternalUsers] [bit] NULL,
[UserPreferencesShowFaxToExternalUsers] [bit] NULL,
[UserPreferencesShowStreetAddressToExternalUsers] [bit] NULL,
[UserPreferencesShowCityToExternalUsers] [bit] NULL,
[UserPreferencesShowStateToExternalUsers] [bit] NULL,
[UserPreferencesShowPostalCodeToExternalUsers] [bit] NULL,
[UserPreferencesShowCountryToExternalUsers] [bit] NULL,
[UserPreferencesShowProfilePicToGuestUsers] [bit] NULL,
[UserPreferencesShowTitleToGuestUsers] [bit] NULL,
[UserPreferencesShowCityToGuestUsers] [bit] NULL,
[UserPreferencesShowStateToGuestUsers] [bit] NULL,
[UserPreferencesShowPostalCodeToGuestUsers] [bit] NULL,
[UserPreferencesShowCountryToGuestUsers] [bit] NULL,
[UserPreferencesHideS1BrowserUI] [bit] NULL,
[UserPreferencesDisableEndorsementEmail] [bit] NULL,
[UserPreferencesPathAssistantCollapsed] [bit] NULL,
[UserPreferencesCacheDiagnostics] [bit] NULL,
[UserPreferencesShowEmailToGuestUsers] [bit] NULL,
[UserPreferencesShowManagerToGuestUsers] [bit] NULL,
[UserPreferencesShowWorkPhoneToGuestUsers] [bit] NULL,
[UserPreferencesShowMobilePhoneToGuestUsers] [bit] NULL,
[UserPreferencesShowFaxToGuestUsers] [bit] NULL,
[UserPreferencesShowStreetAddressToGuestUsers] [bit] NULL,
[UserPreferencesLightningExperiencePreferred] [bit] NULL,
[ContactId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CallCenterId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Extension] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FederationIdentifier] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AboutMe] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FullPhotoUrl] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SmallPhotoUrl] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DigestFrequency] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultGroupNotificationFrequency] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastViewedDate] [datetime] NULL,
[LastReferencedDate] [datetime] NULL,
[Mark_Code__c] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Full_User_ID__c] [nvarchar] (1300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleName] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserPermissionsKnowledgeUser] [bit] NULL,
[UserPreferencesPreviewLightning] [bit] NULL,
[UserPreferencesHideEndUserOnboardingAssistantModal] [bit] NULL,
[UserPreferencesHideLightningMigrationModal] [bit] NULL,
[UserPreferencesHideSfxWelcomeMat] [bit] NULL,
[UserPreferencesHideBiggerPhotoCallout] [bit] NULL,
[UserPreferencesGlobalNavBarWTShown] [bit] NULL,
[UserPreferencesGlobalNavGridMenuWTShown] [bit] NULL,
[UserPreferencesCreateLEXAppsWTShown] [bit] NULL,
[UserPreferencesFavoritesWTShown] [bit] NULL,
[UserPreferencesRecordHomeSectionCollapseWTShown] [bit] NULL,
[UserPreferencesRecordHomeReservedWTShown] [bit] NULL,
[UserPreferencesFavoritesShowTopFavorites] [bit] NULL,
[IsExtIndicatorVisible] [bit] NULL,
[MediumPhotoUrl] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BannerPhotoUrl] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SmallBannerPhotoUrl] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediumBannerPhotoUrl] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsProfilePhotoActive] [bit] NULL,
[copyloaddate] [datetime] NULL CONSTRAINT [DF__User__copyloadda__5CCCA98A] DEFAULT (getdate())
)
GO
ALTER TABLE [prodcopystg].[User] ADD CONSTRAINT [PK__User__3214EC07E7659ECF] PRIMARY KEY CLUSTERED  ([Id])
GO