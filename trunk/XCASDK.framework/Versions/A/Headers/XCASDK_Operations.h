//
//  XCASDK_Operations.h
//  XCA
//
//  Created by xyzmo on 14.10.11.
//  Copyright (c) 2011 xyzmo Software GmbH. All rights reserved.
//

// #define SDK_DEBUG 1

/*!
 @copyright 2011-2013 xyzmo Software GmbH
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kMultiSelectListboxSeparator @"°°°"

/*!
 @abstract The operation types.
 */
typedef enum {
	kXCAOpenDocument,
	kXCACloseDocument,
	kXCAGetAttachment,
	kXCAZoomPage,
	kXCADelete,
	kXCAAddSignature,
	kXCAAddTextAnnotation,
	kXCAShowHelp,
	kXCAFinishDocument,
	kXCASelectWorkstep,
	kXCAFinishWorkstep,
	kXCAUndoWorkstep,
	kXCARejectWorkstep,
	kXCASignedOk,
	kXCASignedCancel,
	kXCASignedRetry,
	kXCAPagingForward,
	kXCAPagingBackward,
	kXCAPagingJump,
	kXCAOpenTasklist,
	kXCAOpenTasklistOnRefresh
} XCAOperation;

/*!
 @abstract The error types.
 */
typedef enum {
	kXCAOpError_NotFound,
	kXCAOpError_Workstep_Already_Finished,
	kXCAOpError_General,
	kXCAOpError_Server_Not_Reachable,
	kXCAOpError_Cancel
} XCAOperationError;

/*!
 @abstract The toolbar button types.
 */
typedef enum {
	kXCAUndoButton,
	kXCAZoomButton,
	kXCATrashButton,
	kXCAAdhocAnnotationButton,
	kXCAAdhocSignButton,
	kXCAAdhocAttachmentButton,
	kXCAHelpButton,
	kXCAFurtherActionButton,
	kXCACloseButton,
	kXCAFinishButton,
	kXCAOpenEditButton,
	kXCARejectButton,
	kXCASignatureBarCancel,
	kXCASignatureBarRetry,
	kXCASignatureBarColor,
	kXCASignatureBarSlide,
	kXCASignatureBarPenSelect,
	kXCASignatureBarOk,
	kXCASyncButton,
	kXCAEditDocumentsButton,
	kXCAEditFoldersButton,
	kXCABackToDocumentsButton,
	kXCAAddFolderButton,
	kXCASupportButton,
	kXCAAutoSteppingButton
} XCAOperationToolbarButton;

/*!
 @abstract The UI button types (except toolbar buttons).
 */
typedef enum {
	kXCAPagePreviewButton
} XCAOperationButton;

/*!
 @abstract The soap request implementation types.
 */
typedef enum {
	kXCASoapRequestDefault,
	kXCASoapRequestAFNetworking
} XCAOperationSoapRequestImplementation;

/*!
 @abstract The logging types.
 */
typedef enum {
	kXCALoggingDebug,
	kXCALoggingNetworkDebug,
	kXCALoggingError,
	kXCALoggingTemporary
} XCAOperationLoggingType;

/*!
 @abstract The debug function types.
 */
typedef enum {
	kXCADebugFunctionPenInfo
} XCADebugFunction;

/*!
 @abstract The backend job types.
 */
typedef enum {
	kXCAWorkstepDownload,
	kXCAUploadPdf,
	kXCASynchronization,
	kXCAFinish,
	kXCAReject,
	kXCAFinalize,
	kXCAUndo,
	kXCASaveDocument,
	kXCASendMail,
	kXCAReportIssue,
	kXCAOpenWith,
	kXCAAddAttachment,
	kXCAAddAttachmentPage,
	kXCARetrieveLicenseDetails,
	kXCAUpdateLicenseActiveState,
	kXCATemplateDownload
} XCABackendJobType;

/*!
 @abstract The backend job status types.
 */
typedef enum {
	kXCAJobStarted,                     // Job started
	kXCAJobWorking,                     // Working on job, user cannot view
	kXCAWorkingButViewable,             // Working on job, user can open this workstep
	kXCAJobWaitingForUser_Credentials,  // gui should prompt user for credentials
	kXCAJobWaitingForUser_Notification, // gui should show some notification
	kXCAJobError,                       // some error occured (see errorcode)
	kXCAJobReady,                       // job is ready and done
	kXCAJobCanBePurged                  // job is finished and can be purged from list
} XCABackendJobStatus;

/*!
 @abstract The tab types.
 */
typedef enum {
	kXCAAttachmentsTab,
	kXCASettingsTab,
	kXCATemplatesTab
} XCATabType;

/*!
 @abstract The workstep states.
 */
typedef enum {
	kXCAWorkstepStateSynced,
	kXCAWorkstepStateUnsynced,
	kXCAWorkstepStateTemplateBasedAndUnmodified,
	kXCAWorkstepStateSyncing,
	kXCAWorkstepStateDownloading,
	kXCAWorkstepStateError
} XCAWorkstepState;

/*!
 @abstract The sync button types.
 */
typedef enum {
	kXCASyncButtonShowSyncStateList,
	kXCASyncButtonSyncAll
} XCASyncButtonFunctionality;

/*!
 @abstract The alert types.
 */
typedef enum {
	kXCAAlertTypeConnectionError,
	kXCAAlertTypeWscError,
	kXCAAlertTypeInternalError,
	kXCAAlertTypeNoConnectionInfo,
	kXCAAlertTypeReloadingDocumentAfterConflictDetectedInfo,
	kXCAAlertTypeBioVerificationUnknownError,
	kXCAAlertTypeCompleteAllTasksBeforeFinishingInfo,
	kXCAAlertTypeNotAllowedByPolicyInfo,
	kXCAAlertTypeUndoInProgressInfo,
	kXCAAlertTypeConfigFileError,
	kXCAAlertTypeAttachmentAddedInfo,
	kXCAAlertTypeUndoOnlyPossibleOnlineInfo,
	kXCAAlertTypeNoMailAccountConfiguredInfo,
	kXCAAlertTypeNoAppsAvailableInfo,
	kXCAAlertTypeExportError,
	kXCAAlertTypeExportSucceededInfo,
	kXCAAlertTypeOpenDocumentFailedInfo,
	kXCAAlertTypeDocumentIsReadonlyInfo,
	kXCAAlertTypeDocumentWillBeClosedInfo,
	kXCAAlertTypeWorkstepIdNilError,
	kXCAAlertTypeWorkstepConfigurationNilError,
	kXCAAlertTypeWorkstepControllerNotSupportedError,
	kXCAAlertTypeWorkstepInformationParseError
} XCAAlertType;

/*!
 @abstract The pdf content format.
 */
typedef enum {
	kXCAPdfContentFormatFlattened,
	kXCAPdfContentFormatOriginal,
	kXCAPdfContentFormatUnknown
} XCAPdfContentFormat;

/*!
 @abstract The definition of a template object.
 */
@interface XCATemplateDefinition : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *workstepId;
@property(nonatomic, strong) NSString *protocol;
@property(nonatomic, strong) NSString *host;
@property(nonatomic) int port;
@property(nonatomic, strong) NSString *path;

@end

/*!
 @abstract The definition of a form field object.
 */
@interface XCAFormFieldDefinition : NSObject

@property(nonatomic, strong) NSString *key;
@property(nonatomic, strong) NSString *value;
@property(nonatomic) BOOL isReadOnly;

@end

/*!
 @abstract The definition of a workstep state object.
 */
@interface XCAWorkstepStateDefinition : NSObject

@property(nonatomic, strong) NSString *workstepId;
@property(nonatomic, strong) NSString *serverWorkstepId;
@property(nonatomic, strong) NSString *label;
@property(nonatomic) XCAWorkstepState state;
@property(nonatomic) NSDate *expirationDate;
@property(nonatomic) BOOL isFinished;
@property(nonatomic) BOOL isRejected;

-(id)initWithWorkstepId:(NSString *)workstepId andServerWorkstepId:(NSString *)serverWorkstepId andState:(XCAWorkstepState)state andLabel:(NSString *)label andExpirationDate:(NSDate *)expirationDate;

@end

/*!
 @abstract The delegate protocol for customizing the behavior of the SIGNificant view.
 */
@protocol XCASDK_OperationsDelegate

@required

@optional

/*!
 @abstract Called when the view controller that was requested by the XCA Manager is ready loaded and initialized.
 
 @param pView The view object
 */
-(BOOL) XCASDK_Operations_ViewDidLoad:(UIView *)pView;

/*!
 @abstract Called when the view controller that was requested by the XCA_Manager is about to be shown.
 
 @param pView The view object
 */
-(BOOL) XCASDK_Operations_ViewWillAppear:(UIView *)pView;

/*!
 @abstract Called when the view controller that was requested by the XCA_Manager is ready showing.
 
 @param pView The view object
 */
-(BOOL) XCASDK_Operations_ViewDidAppear:(UIView *)pView;

/*!
 @abstract Called when a workstep was loaded into offline storage.
 
 @param pUrlToWorkstep The workstep URL
 @param pOfflineStoragePath The offline storage path
 */
-(BOOL) XCASDK_Operations_DidLoadWorkstep:(NSURL *)pUrlToWorkstep toOfflineStorage:(NSString *)pOfflineStoragePath;

/*!
 @abstract Called when a loading operation fails.
 
 @param pErrorDescription The error description
 @param pErrorId The error id
 @return YES if delegate will show the error to the user
 */
-(BOOL) XCASDK_Operations_LoadError:(NSString *)pErrorDescription withId:(XCAOperationError)pErrorId;

/*!
 @abstract Called when a general operation fails.
 
 @param pErrorDescription The error description
 @param pErrorId The error id
 @return YES if delegate will show the error to the user
 */
-(BOOL) XCASDK_Operations_GeneralError:(NSString *)pErrorDescription withId:(XCAOperationError)pErrorId;

/*!
 @abstract Called when a finishing operation fails.
 
 @param pErrorDescription The error description
 @param pErrorId The error id
 @return YES if delegate will show the error to the user
 */
-(BOOL) XCASDK_Operations_FinishError:(NSString *)pErrorDescription withId:(XCAOperationError)pErrorId;

/*!
 @abstract Called when a page preview has been fetched from the server.
 
 @param pPageNr The page number
 @param pPathToLocalCache The path to the local cache directory
 */
-(void) XCASDK_Operations_DidLoadPage:(int)pPageNr withCacheFilename:(NSString *)pPathToLocalCache;

/*!
 @abstract Called after the last page of a document has been loaded.
 */
-(void) XCASDK_Operations_DidLoadLastPage;

/*!
 @abstract Called when a workstep has been finished.
 
 @param pWorkstepId The workstep id
 */
-(void) XCASDK_Operations_DidFinishWorkstep:(NSString *)pWorkstepId;

/*!
 @abstract Called when a workstep has been rejected.
 
 @param pWorkstepId The workstep id
 */
-(void) XCASDK_Operations_DidRejectWorkstep:(NSString *)pWorkstepId;

/*!
 @abstract Called when user invokes an operation.
 
 @param pOperation The operation invoked
 @param pControl The GUI control element
 @return YES if delegate handles this event, NO for standard behavior
 */
-(BOOL) XCASDK_Operations_WillInvokeUserActivatedOperation:(XCAOperation)pOperation withControl:(UIControl *)pControl;

/*!
 @abstract Called when a page is shown.
 
 @param pPageNr The page number
 */
-(void) XCASDK_Operations_DidShowPage:(int)pPageNr;

/*!
 @abstract Specifies if the user credentials should be saved per URL.
 
 @return YES to save the credentials per URL
 */
-(BOOL) XCASDK_Operations_CredentialsShouldSave;

/*!
 @abstract Specifies the credential's user name.
 
 @return The username to be used, or nil to show an input dialog
 */
-(NSString *) XCASDK_Operations_CredentialsGetUsername;

/*!
 @abstract Specifies the credential's password.
 
 @return The password to be used
 */
-(NSString *) XCASDK_Operations_CredentialsGetPassword;

/*!
 @abstract Callback to notify the delegate that the credentials have been re-entered (due to an authorization fail).
 
 @param pUrl The URL used for the request which has failed
 @param pUser The new user name entered
 @param pPassword The new password entered
 */
-(void)XCASDK_Operations_CredentialsReEnteredForUrl:(NSURL *)pUrl withUser:(NSString *)pUser withPassword:(NSString *)pPassword;

/*!
 @abstract Specifies if the SOAP request should be retried.
 
 @param pAction The SOAP request action
 @param pRetryCount The current retry count
 @return YES to retry the request
 */
-(BOOL)XCASDK_Operations_RetrySoapRequestAction:(NSString *)pAction withCurrentRetryCount:(int)pRetryCount;

/*!
 @abstract Specifies if the SOAP write request should be retried.
 
 @param pAction The SOAP request write action
 @param pRetryCount The current retry count
 @return YES to retry the request
 */
-(BOOL)XCASDK_Operations_RetrySoapRequestWriteAction:(NSString *)pAction withCurrentRetryCount:(int)pRetryCount;

/*!
 @abstract Specifies the timeout for a SOAP request in seconds.
 
 @param pAction The SOAP request action
 @param pRetryCount The current retry count
 @return The timeout in seconds
 */
-(float)XCASDK_Operations_GetSoapRequestTimeoutForAction:(NSString *)pAction withCurrentRetryCount:(int)pRetryCount;

/*!
 @abstract Specifies the timeout for a SOAP write request in seconds.
 
 @param pAction The SOAP request write action
 @param pRetryCount The current retry count
 @return The timeout in seconds
 */
-(float)XCASDK_Operations_GetSoapRequestTimeoutForWriteAction:(NSString *)pAction withCurrentRetryCount:(int)pRetryCount;

/*!
 @abstract For Debugging. Specifies if the given SOAP action should succeed.
 
 @param pAction The SOAP request action
 @param pAfterServerWasRequested when this is YES, the request was sent to the server (useful for simulating connection loss where the server got the request but the client got no answer)
 @return YES if the action should succeed or NO if the soap request should fail
 */
-(BOOL)XCASDK_Operations_DebugShouldSoapActionSucceed:(NSString *)pAction afterServerWasRequested:(BOOL)pAfterServerRequest;

/*!
 @abstract Called when any SOAP request error occurs.
 
 @param pError The system error object
 */
-(void)XCASDK_Operations_SoapRequestErrorOccured:(NSError *)pError;

/*!
 @abstract Called before any SOAP request is performed to set/manage cookies needed.
 
 @param pCookieStorage The cookie storage
 @param pUrl The url of the SOAP request
 */
-(void)XCASDK_Operations_SoapRequestCookies:(NSHTTPCookieStorage *)pCookieStorage forUrl:(NSURL *)pUrl;

/*!
 @abstract Called when any SOAP request will be performed to modify the SOAP xml request.
 
 @param pSoapXml The xml of the SOAP request
 @param pSoapAction The SOAP action
 @return A new XML content or null to use the default content
 */
-(NSString *)XCASDK_Operations_WillSoapRequest:(NSString *)pSoapXml withAction:(NSString *)pSoapAction;

/*!
 @abstract Specifies the SOAP request implementation to use. Note: kXCASoapRequestDefault should not be used any more (e.g. not able to identify HTTP status codes correctly.
 
 @return The SOAP implementation to use
 */
-(XCAOperationSoapRequestImplementation)XCASDK_Operations_GetSoapRequestImplementation;

/*!
 @abstract Specifies if the logging of a particular type should be activated.
 
 @param pLoggingType The logging type
 @return YES to activate this logging type
 */
-(BOOL)XCASDK_Operations_ActivateLoggingFor:(XCAOperationLoggingType)pLoggingType;

/*!
 @abstract Specifies if a particular button should be shown in the toolbar.
 
 @param pButton The toolbar button type
 @return YES to add the given toolbar button to the toolbar
 */
-(BOOL) XCASDK_Operations_ShouldShowToolbarButton:(XCAOperationToolbarButton)pButton;

/*!
 @abstract Specifies if a particular button should be shown in the UI.
 
 @param pButton The button type
 @return YES to add the given button to the UI, NO otherwise
 */
- (BOOL)XCASDK_Operations_ShouldShowButton:(XCAOperationButton)pButton;

/*!
 @abstract Specifies if the document only mode should be enabled and all document related gui elements (folder and document management, settings, etc.) should be hidden.
 
 @return YES to enable the document only mode
 */
-(BOOL)XCASDK_Operations_IsDocumentOnlyMode;

/*!
 @abstract Specifies if the respective tab should be shown or hidden.
 
 @param pTabType The type of the tab to be shown or hidden
 @return NO if the respective tab should be hidden
 */
-(BOOL)XCASDK_Operations_ShowTab:(XCATabType)pTabType;

/*!
 @abstract Called to notify of the current backend job status.
 
 @param pWorkstepId The workstep id
 @param pJobType The job type
 @param pJobStatus The job status
 @param pPercentageReady The job status in percentage
 */
-(void) XCASDK_Operations_BackendJobStatusChanged:(NSString *)pWorkstepId withJobType:(XCABackendJobType)pJobType status:(XCABackendJobStatus)pJobStatus percentReady:(float)pPercentReady;

/*!
 @abstract Specifies if a particular pen should be available for signing.
 
 @return NO if the given pen should not be available
 */
-(BOOL)XCASDK_Operations_MayUsePenForSignature:(NSString *)pPenDriverName supportsPressure:(BOOL)pSupportsPressure;

/*!
 @abstract Specifies if a particular debugging function should be enabled.
 
 @return YES to activate the given debugging function
 */
-(BOOL)XCASDK_Operations_DebugActivateFunction:(XCADebugFunction)pDebugFunction;

/*!
 @abstract Specifies if the document should be zoomed to full page after the master view has been toggled.
 
 @return YES to zoom the document to full page
 */
-(BOOL)XCASDK_Operations_FitPageOnScreenAfterToggleMasterView;

/*!
 @abstract Called whenever a workstep document has been created (either ad-hoc or template based).
 
 @param workstepId The workstep id of the created document (note that this might be just a client-side id - when syncing there will be another server-side id created)
 */
-(void)XCASDK_Operations_WorkstepCreated:(NSString *)workstepId;

/*!
 @abstract Called whenever a workstep document has been synchronized.
 
 @param workstepId The client-side workstep id of the document
 @param serverWorkstepId The server-side workstep id of the document
 */
-(void)XCASDK_Operations_WorkstepSynced:(NSString *)workstepId withServerWorkstepId:(NSString *)serverWorkstepId;

/*!
 @abstract Declares if a specific alert should be shown.
 
 @return YES if the alert should be shown
 */
-(BOOL)XCASDK_Operations_ShouldShowAlert:(XCAAlertType)type;

/*!
 @abstract Called to filter / restrict the list of worksteps.
 
 @return The list of workstep IDs to be shown or nil to apply no filter
 */
-(NSArray *)XCASDK_Operations_GetWorkstepsFilter;

/*!
 @abstract Specifies if worksteps of a specific state should be shown in the list.
 
 @return YES if the worksteps of the specific state should be shown
 */
-(BOOL)XCASDK_Operations_ShouldShowWorkstepsOfState:(XCAWorkstepState)state;

/*!
 @abstract Specifies the functionality of the sync button.
 
 @return The desired sync button functionality
 */
-(XCASyncButtonFunctionality)XCASDK_Operations_GetSyncButtonFunctionality;

/*!
 @abstract Called when the PDF document of a workstep has been successfully downloaded.
 
 @param workstepId The client-side id of the workstep
 @param filepath The full file path and file name of the downloaded PDF document
 */
-(void)XCASDK_Operations_WorkstepSavedAsPdf:(NSString *)workstepId toFile:(NSString *)filepath usingFormat:(XCAPdfContentFormat)format;

/*!
 @abstract Specifies if a workstep which do not exist on the server any more should be removed during (unsuccessful) synchronization.
 
 @param workstepId The id of the workstep to be removed
 @return YES to remove the worksteps, NO otherwise
 */
- (BOOL)XCASDK_Operations_ShouldRemoveNonexistingWorkstepDuringSync:(NSString *)workstepId;

/*!
 @abstract Gets the license user id for a given server URL.
 
 @param serverUrl The server url for which the license user id is retrieved
 @return The license user id to be used or nil to use standard behavior
 */
- (NSString *)XCASDK_Operations_LicenseUserIdForServer:(NSString *)serverUrl;

@end

/*!
 @abstract The operations object for registering the operations delegate.
 */
@interface XCASDK_Operations : NSObject
{
	id<XCASDK_OperationsDelegate> delegate;
}

@property(nonatomic, retain) id<XCASDK_OperationsDelegate> delegate;

#pragma mark - General Operations

/*!
 @abstract Opens one or more workstep(s) with a given URL. If the URL contains one workstep, this workstep will be displayed.
 
 @param pUrlToWorkstep The workstep URL
 */
-(void)openWorkstep:(NSURL *)pUrlToWorkstep;

/*!
 @abstract Opens one or more workstep(s) with a given URL and displays it/them if specified.
 
 @param pUrlToWorkstep The workstep URL
 @param pViewAfterLoading Specifies if the workstep should be displayed after loading
 */
-(void)openWorkstep:(NSURL *)pUrlToWorkstep viewAfterLoading:(BOOL)pViewAfterLoading;

/*!
 @abstract Loads a workstep from a customer-specific integration webservice.
 
 @param pPdfFile The path to the pdf file
 @param pServerUrl The integration server URL
 */
-(void)openWorkstepWithPdfFile:(NSString *)pPdfFile andIntegrationServerUrl:(NSURL *)pServerUrl;

/*!
 @abstract Creates an adhoc workstep based on a local PDF document.
 
 @param pFileUrl The URL to the PDF document
 */
-(void)createAdHocWorkstep:(NSURL *)pFileUrl;

/*!
 @abstract Removes the credentials if they are only saved in memory (not on disk).
 */
-(void)clearCredentials;

/*!
 @abstract Shows the master view (folders, documents, tasks etc.).
 */
-(void)showMaster;

/*!
 @abstract Removes expired worksteps from the documents list.
 */
-(void)removeExpiredWorksteps;

/*!
 @abstract Removes all cached offline documents and resets to no (empty) document.
 */
-(BOOL)clearOfflineDocuments;

/*!
 @abstract Closes the currently opened workstep and resets the view. Does nothing if no workstep is visible.
 */
- (void)closeCurrentWorkstep;

/*!
 @abstract Deletes a single workstep document from the disk and removes it from the folder list.
 */
-(void)deleteWorkstep:(NSString *)workstepId;

/*!
 @abstract Processes a XML formatted control file, which can contain template and/or workstep loading instructions.
 
 @param controlXml The SIGNificant control xml
 */
-(void)processSIGNificantControlXml:(NSData *)controlXml;

/*!
 @abstract Shows a hint informing the user about documents which are about to expire in the next five days.
 
 @param minInterval Specifies the minimum time interval (in hours) since the last hint
 */
-(void)showExpiringDocumentsInfoWithMinimumInterval:(int)minInterval;

/*!
 @abstract Sets custom URL params for the communication with the server. This is needed e.g. to bypass authentication tokens etc.
 
 @param urlParams The params (NSString*) which should be added to each call (key-value pairs)
 */
-(void)setCustomQueryParams:(NSDictionary *)urlParams;

/*!
 @abstract Starts synchronizing the workstep with the given id with the server.
 */
-(void)syncWorkstep:(NSString *)workstepId;

/*!
 @abstract Starts synchronizing all worksteps with the server.
 */
-(void)syncAllWorksteps;

/*!
 @abstract Provides a list of all worksteps and their current state (e.g. synced, unsynced, downloading etc.).
 
 @return The list containing XCAWorkstepStateDefinition objects
 */
-(NSArray *)currentWorkstepStates;

/*!
 @abstract Downloads the PDF document of the workstep to the given path using the specified PDF type.
 
 @param workstepId The workstep id of the desired workstep document
 @param filename The filename for saving the document in the application's documents directory
 @param format The PDF content format (flattened / original)
 */
-(void)saveWorkstepAsPdf:(NSString *)workstepId toFile:(NSString *)filename usingFormat:(XCAPdfContentFormat)format;

#pragma mark - Licensing Operations

/*!
 @abstract Brings up a dialog for activating an enterprise license.
 
 @param url The enterprise licensing activation URL
 */
-(void)activateLicense:(NSURL *)url;

#pragma mark - Templating

/*!
 @abstract Loads a template from the server using the given template definition.
 
 @param templateDefinition The definition of the template object
 */
-(void)loadTemplateFromServer:(XCATemplateDefinition *)templateDefinition;

/*!
 @abstract Creates a workstep document based on a (previously loaded) template.
 
 @param templateDefinition The definition of the template object (server parameters are optional)
 @param workstepName The name (label) of the new workstep
 @param ttlMinutes The time-to-live setting in minutes for this new document (0 = live forever, -1 = use the template's TTL)
 @param formFieldDefinitions The form field definitions (XCAFormFieldDefinition) in an dictionary (key = form field id)
 @param attachmentPath The path to the image to be attached as a new page
 @param additionalClientInfo The additional client information meta data (must be XML formatted!)
 
 @return The client-side workstep id of the created workstep
 */
-(NSString *)createTemplateBasedWorkstep:(XCATemplateDefinition *)templateDefinition withName:(NSString *)workstepName andTimeToLive:(int)ttlMinutes andFormFieldDefinitions:(NSDictionary *)formFieldDefinitions andAttachmentPaths:(NSArray *)attachmentPaths andAdditionalClientInfo:(NSString *)additionalClientInfo;

/*!
 @abstract Processes a XML formatted template definition, which can contain template loading or workstep creation instructions.
 
 @param templateDefinition The template definition xml
 */
-(void)processTemplateDefinitionXml:(NSData *)templateDefinition;

/*!
 @abstract Retrieves a list of templates which are currently loaded.
 
 @return The list containing XCATemplateDefinition objects
 */
- (NSArray *)availableTemplates;

@end
