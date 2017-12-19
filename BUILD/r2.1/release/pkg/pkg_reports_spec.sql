CREATE OR REPLACE PACKAGE "PKG_REPORTS"
AS
  PROCEDURE SP_USER_STUDIES_REPORT(
      P_USERID            IN NUMBER,
    P_STUDYID           IN NUMBER,
    P_STUDYSHORTDESC    IN VARCHAR2,
    P_COMPOUNDID        IN NUMBER,
    P_PROGID            IN NUMBER,
    P_THERAPEUTICAREAID IN NUMBER,
    P_COUNTRYID         IN NUMBER,
    P_INDICATIONID      IN NUMBER,
    P_OFFSET            IN NUMBER,
    P_LIMIT             IN NUMBER,
    P_ORDRBY            IN VARCHAR2,
    P_SORTBY            IN VARCHAR2,
    P_USER_STUDIES OUT SYS_REFCURSOR,
    P_COUNT OUT NUMBER);
PROCEDURE PROC_STUDYSITEFACDETAILS (
    V_ORGID IN NUMBER,
     V_TRANSCELERATEID IN VARCHAR2,
    P_OFFSET          IN NUMBER,
    P_LIMIT           IN NUMBER,
    P_ORDRBY          IN VARCHAR2,
    P_SORTBY          IN VARCHAR2,
    P_STUDYSITEFACDETAILS OUT SYS_REFCURSOR,
    P_COUNT OUT NUMBER
    );

 PROCEDURE PROC_USERREGISTRATIONREP(
      V_TRANSCELERATEID IN VARCHAR2,
      V_ROLEID          IN NUMBER,
      V_STATUS          IN VARCHAR2,
      V_ACTSTARTDATE    IN DATE,
      V_ACTENDDATE      IN DATE,
      P_OFFSET          IN NUMBER,
      P_LIMIT           IN NUMBER,
      P_ORDRBY          IN VARCHAR2,
      P_SORTBY          IN VARCHAR2,
      P_USERREGISTRATION OUT SYS_REFCURSOR,
      P_COUNT OUT NUMBER );

  --/******************************************************************************
  --Object_name - SITE_USR_ASOC_FAC_PROC
  --Purpose - Procedure to fetch site userlist associated to facilites as per search criteria
  --*******************************************************************************/
   PROCEDURE SITE_USR_ASOC_FAC_PROC(
    I_STUDYIDS       IN NUM_ARRAY,
    I_CNTRYID        IN NUM_ARRAY,
    I_LOGINID        IN NUMBER,
    I_FIRSTNAME      IN VARCHAR2,
    I_LASTNAME       IN VARCHAR2,
    I_FACILITY_DEPT_NAME   IN VARCHAR2,
    I_EXCLUDE        IN VARCHAR2,
    I_OFFSET         IN NUMBER,
    I_LIMIT          IN NUMBER,
    I_ORDRBY         IN VARCHAR2,
    I_SORTBY         IN VARCHAR2,
    SITEUSRASSOCFACREP OUT SYS_REFCURSOR,
    O_COUNT OUT NUMBER );

  PROCEDURE PROC_STUDYCLOSE_REPORT(
    p_USERID  IN NUMBER,
    p_STUDYID IN NUMBER,
	p_SITEID IN NUMBER,
	p_COUNTRYCD  IN VARCHAR2,
    p_OFFSET  IN NUMBER,
    p_LIMIT   IN NUMBER,
    p_ORDRBY  IN VARCHAR2,
    p_SORTBY  IN VARCHAR2,
    p_STUDYCLOSEREC OUT SYS_REFCURSOR,
    P_COUNT OUT NUMBER );

	--/******************************************************************************
  --Object_name - STUDY_USR_ACCS_PROC
  --Purpose - Procedure to fetch user access report as per search criteria
  --*******************************************************************************/
 PROCEDURE SP_SiteUser_Registration(
      I_FIRSTNAME      IN VARCHAR2,
      I_LASTNAME       IN VARCHAR2,
      I_TRANSUSERID    IN VARCHAR2,
      I_EMAIL          IN VARCHAR2,
    --  I_ACTSTATUS      IN VARCHAR2,
      I_INVITE_START_DATE    IN DATE,
      I_INVITE_END_DATE      IN DATE,
      I_REG_START_DATE       IN DATE,
      I_REG_END_DATE         IN DATE,
      I_DEACTIVE_START_DATE  IN DATE,
      I_DEACTIVE_END_DATE    IN DATE,
      I_FACILITY_NAME        IN VARCHAR2,
      I_DEPT_NAME            IN VARCHAR2,
    --  I_ACTFROM_DATE   IN DATE,
    --  I_ACTTO_DATE     IN DATE,
    --  I_STUDYIDS       IN NUM_ARRAY,
    --  I_SITEIDS        IN NUM_ARRAY,
      I_ROLEID         IN NUMBER,
      I_STATEID        IN NUM_ARRAY,
      I_LOGGEDINUSERID IN NUMBER,
     -- I_USERID         IN NUMBER,
      I_COUNTRYID      IN NUM_ARRAY,
    --  I_ORGID          IN NUMBER,
    --  I_DEGSITECNTCT   IN VARCHAR2,
    --  I_INVFROM_DATE   IN DATE,
    --  I_INVTO_DATE     IN DATE,
      I_OFFSET         IN NUMBER,
      I_LIMIT          IN NUMBER,
      I_ORDRBY         IN VARCHAR2,
      I_SORTBY         IN VARCHAR2,
      I_COUNT OUT NUMBER,
      USERACCESSREP OUT SYS_REFCURSOR);

  -- /******************************************************************************
 -- Object_name - PROC_PLATFORMDIMENSION_REPORT
 -- Purpose - Procedure to fetch overall platform diemnsion report as per search criteria
 -- *******************************************************************************/
  PROCEDURE PROC_PLATFORMDIMENSION_REPORT(
      p_USERID IN NUMBER,
      p_ORGID  IN NUMBER,
      P_STUDYCNT OUT NUMBER,
      P_ASSOUSRCNT OUT NUMBER,
      P_NOTASSOUSRCNT OUT NUMBER,
      P_NOTACCEPTDTCCNT OUT NUMBER);

 -- /******************************************************************************
 -- Object_name - PROC_PFSPONSORSTUDIES_REPORT
 -- Purpose - Procedure to fetch overall platform diemnsion sponsor studies report as per search criteria
 -- *******************************************************************************/
  PROCEDURE PROC_PFSPONSORSTUDIES_REPORT(
      p_USERID IN NUMBER,
      p_ORGID  IN NUMBER,
      P_OFFSET IN NUMBER,
      P_LIMIT  IN NUMBER,
      P_ORDRBY IN VARCHAR2,
      P_SORTBY IN VARCHAR2,
      P_COUNT OUT NUMBER,
      p_PFSPONSORSTUDIESREC OUT SYS_REFCURSOR);

 -- /******************************************************************************
 -- Object_name - PROC_PFSPONSORUSERS_REPORT
 -- Purpose - Procedure to fetch overall platform diemnsion sponsor (linked or not linked)users report as per search criteria
 -- *******************************************************************************/
  PROCEDURE PROC_PFSPONSORUSERS_REPORT(
      p_USERID    IN NUMBER,
      p_ORGID     IN NUMBER,
      p_ISLINKED   IN VARCHAR2,
      p_FIRSTNAME IN VARCHAR2,
      p_LASTNAME  IN VARCHAR2,
      p_EMAIL     IN VARCHAR2,
      P_OFFSET    IN NUMBER,
      P_LIMIT     IN NUMBER,
      P_ORDRBY    IN VARCHAR2,
      P_SORTBY    IN VARCHAR2,
      P_COUNT OUT NUMBER,
      p_PFSPONSORUSERSREC OUT SYS_REFCURSOR);
--/******************************************************************************
 -- Object_name - SP_TASK_LIST_REPORT
 -- Purpose - Procedure to fetch user task report as per search criteria
 -- *******************************************************************************/
    PROCEDURE SP_TASK_LIST_REPORT(
    P_LOGINUSER         IN VARCHAR2,
    P_STUDYID           IN NUM_ARRAY,
    P_TRANSCELERATEID   IN VARCHAR2,
    P_FIRSTNAME         IN VARCHAR2,
    P_LASTNAME          IN VARCHAR2,
    P_STUDYSITEID       IN NUM_ARRAY,
    P_COUNTRYCODE       IN VARCHAR2,
    P_TASKTYPE          IN VARCHAR2,
    P_TASKSTATUS        IN VARCHAR2,
    P_FROMDATE          IN DATE,
    P_USERID            IN NUMBER,
    P_OFFSET            IN NUMBER,
    P_LIMIT             IN NUMBER,
    P_ORDRBY            IN VARCHAR2,
    P_SORTBY            IN VARCHAR2,
    P_TASK_LIST OUT SYS_REFCURSOR,
    P_COUNT OUT NUMBER);
 -- /******************************************************************************
 -- Object_name - POT_INV_REG_SURVEY_STATUS
 -- Purpose - Procedure to fetch potential users status and survey status report as per search criteria
 -- *******************************************************************************/
	PROCEDURE POT_INV_REG_SURVEY_STATUS(
         I_LOGGEDINUSERID    IN NUMBER,
      I_FIRSTNAME         IN VARCHAR2,
      I_LASTNAME          IN VARCHAR2,
      I_COUNTRYID         IN NUM_ARRAY,
      I_DEPARTMENTNAME    IN VARCHAR2,
      I_SURVEYID          IN NUM_ARRAY,
      I_FACILITYNAME      IN VARCHAR2,
      I_STUDYIDS          IN NUM_ARRAY,
      I_OFFSET            IN NUMBER,
      I_LIMIT             IN NUMBER,
      I_ORDRBY            IN VARCHAR2,
      I_SORTBY            IN VARCHAR2,
      I_COUNT OUT NUMBER,
      POTINVREGSURVEYSTATUS OUT SYS_REFCURSOR);


	--/******************************************************************************
    --Object_name - PROC_USERSNOTACCPTTCNP_REPORT
    --Purpose - Procedure to fetch overall platform dimension sponsor users who did not accepte TERMS and CONDITION and POLICY report as per search criteria
    --*******************************************************************************/
	PROCEDURE PROC_USERSNOTACCPTTCNP_REPORT(
      p_USERID    IN NUMBER,
      p_ORGID     IN NUMBER,
      p_FIRSTNAME IN VARCHAR2,
      p_LASTNAME  IN VARCHAR2,
      p_EMAIL     IN VARCHAR2,
      P_OFFSET    IN NUMBER,
      P_LIMIT     IN NUMBER,
      P_ORDRBY    IN VARCHAR2,
      P_SORTBY    IN VARCHAR2,
      P_COUNT OUT NUMBER,
      p_USERSNOTACCPTTCNPREC OUT SYS_REFCURSOR);

	PROCEDURE PROC_USER_INV_REGI_REPORT(
      V_USERID  IN TBL_USERPROFILES.USERID%TYPE,
      V_FROMDT  IN DATE,
      V_TODT    IN DATE,
      V_MIN     IN NUMBER,
      V_MAX     IN NUMBER,
      V_ORDERBY IN VARCHAR2,
      V_SORTBY  IN VARCHAR2,
      V_POTINV_REG_RES OUT SYS_REFCURSOR,
      O_COUNT OUT NUMBER );
--/******************************************************************************
--Object_name - PROC_STUDY_ALRTS_NTFS
--Purpose - Procedure to fetch alerts and notifications count
--*******************************************************************************/
PROCEDURE PROC_STUDY_ALRTS_NTFS(
      V_ROLEID     IN NUMBER,
      V_SPONOSORID IN NUMBER,
      V_STUDYID    IN VARCHAR2,
      V_FROMDT     IN DATE,
      V_TODT       IN DATE,
      V_LEVEL      IN VARCHAR2,
      I_OFFSET     IN NUMBER,
      I_LIMIT      IN NUMBER,
      V_ORDERBY    IN VARCHAR2,
      V_SORTBY     IN VARCHAR2,
      V_STUDY_ALRTS_NTFS OUT SYS_REFCURSOR,
      O_COUNT OUT NUMBER);
--/******************************************************************************
--Object_name - PROC_SITEUSRROLSUMRY_REPORT
--Purpose - Procedure to fetch study site user role summary
--*******************************************************************************/
PROCEDURE PROC_SITEUSRROLSUMRY_REPORT(
    p_userid          IN NUMBER,
    p_studyids         IN NUM_ARRAY,
    p_siteids          IN NUM_ARRAY,
    p_countryid       IN VARCHAR2,
    p_firstname       IN VARCHAR2,
    p_lastname        IN VARCHAR2,
    p_institutionname IN VARCHAR2,
    p_fromdate        IN DATE,
    p_todate          IN DATE,
    p_offset          IN NUMBER,
    p_limit           IN NUMBER,
    p_orderby         IN VARCHAR2,
    p_sortby          IN VARCHAR2,
    p_siteusrrolsumry OUT SYS_REFCURSOR,
    p_count OUT NUMBER);


PROCEDURE PROC_STUDY_ALRTS_NTFS_SUB(
    V_SPONOSORID IN TBL_ORGANIZATION.ORGID%TYPE,
    I_STUDYID   IN VARCHAR2,
    I_TRANSUSERID IN VARCHAR2,
    I_ISSPONSOR IN VARCHAR2,
    I_ISALERT IN VARCHAR2,
    V_FROMDT     IN DATE,
    V_TODT       IN DATE,
    P_OFFSET     IN NUMBER,
    P_LIMIT      IN NUMBER,
    P_ORDERBY    IN VARCHAR2,
    P_SORTBY     IN VARCHAR2,
    STUDY_ALRTS_NTFS_SUB OUT SYS_REFCURSOR,
    P_COUNT OUT NUMBER);

	PROCEDURE PROC_SPONSOR_USR_ACCESS_REPORT(
    I_LOGGEDINUSERID IN NUMBER,
    I_FIRSTNAME      IN VARCHAR2,
    I_LASTNAME       IN VARCHAR2,
    I_TRANSUSERID    IN VARCHAR2,
    I_STUDYIDS       IN NUM_ARRAY,
    I_ROLEID         IN NUM_ARRAY,
    I_EMAIL          IN VARCHAR2,
    I_ACTSTATUS      IN VARCHAR2,
    I_COUNTRYID      IN NUM_ARRAY,
    I_ONBRDFROM_DATE   IN DATE,
    I_ONBRDTO_DATE     IN DATE,
    I_OFFSET         IN NUMBER,
    I_LIMIT          IN NUMBER,
    I_ORDRBY         IN VARCHAR2,
    I_SORTBY         IN VARCHAR2,
    I_COUNT OUT NUMBER,
    SPONSORUSERACCESSREP OUT SYS_REFCURSOR);

    -- /******************************************************************************
 -- Object_name - SURVEY_RECIPIENT_REG_STATUS
 -- Purpose - Procedure to fetch survey status report as per search criteria
 -- *******************************************************************************/
  PROCEDURE SURVEY_RECIPIENT_REG_STATUS(
      I_LOGGEDINUSERID    IN NUMBER,
      I_FIRSTNAME         IN VARCHAR2,
      I_LASTNAME          IN VARCHAR2,
      I_EMAIL             IN VARCHAR2,
      I_COUNTRYID         IN NUM_ARRAY,
      I_STATEID           IN NUM_ARRAY,
      I_SURVEYID          IN NUM_ARRAY,
      I_FACILITYNAME      IN VARCHAR2,
      I_STUDYIDS          IN NUM_ARRAY,
      I_OFFSET            IN NUMBER,
      I_LIMIT             IN NUMBER,
      I_ORDRBY            IN VARCHAR2,
      I_SORTBY            IN VARCHAR2,
      I_COUNT OUT NUMBER,
      SURVEYREGSTATUS OUT SYS_REFCURSOR);

     PROCEDURE SP_TRAINING_CREDIT(
      I_LOGGEDINUSERID    IN VARCHAR2,
      I_USERID    IN NUMBER,
      I_SPONSORID    IN NUMBER,
      I_STUDYID    IN NUM_ARRAY,
      I_COUNTRYID    IN NUMBER,
      I_STATUS    IN VARCHAR2,
      I_STUDYSITEID    IN NUM_ARRAY,
      P_FROMDATE          IN DATE,
      P_TODATE          IN DATE,
      I_TRAININGTYPE    IN NUMBER,
      I_ROLE    IN NUMBER,
      I_OFFSET            IN NUMBER,
      I_LIMIT             IN NUMBER,
      I_ORDRBY            IN VARCHAR2,
      I_SORTBY            IN VARCHAR2,
      I_COUNT OUT NUMBER,
      TRAININGCREDIT OUT SYS_REFCURSOR);

-- /******************************************************************************
-- Object_name - USER_ESIGNATURE_REPORT
-- Purpose - Procedure to fetch User E-Signature report data
-- *******************************************************************************/
  PROCEDURE SP_USER_ESIGNATURE_REPORT(
    P_USERID                  IN NUMBER,
    P_TRANSID                 IN VARCHAR2,
    P_DOCTYPECD               IN VARCHAR2,
    P_CREATEDDATEFROM         IN DATE,
    P_CREATEDDATETO           IN DATE,
    P_STUDYID                 IN NUMBER,
    P_OFFSET                  IN NUMBER,
    P_LIMIT                   IN NUMBER,
    P_ORDRBY                  IN VARCHAR2,
    P_SORTBY                  IN VARCHAR2,
    P_USERESIGNATUREDETAILS   OUT SYS_REFCURSOR,
    P_COUNT OUT NUMBER
  );

 procedure sp_user_training_status_sync(v_source IN Varchar2);

 
 PROCEDURE SP_TRAINING_STATUS_REPORT(
    P_LOGGEDINUSERID IN NUMBER,
    P_ROLEID         IN NUMBER,
    P_CONTENTTYPEID  IN NUMBER,
    P_CONTENTTYPE    IN VARCHAR2,
    P_COUNTRYID      IN number,
    P_TRAININGSTATUS IN VARCHAR2,
    P_TRANSCELERATEUSERID         IN varchar2,
    P_ISINTEGRATION_ACTIVE        In VARCHAR2,
    P_STARTDATE      IN DATE,
    P_ENDDATE        IN DATE,
    P_ORGID          IN NUMBER,
    P_COMPOUNDID     IN NUMBER,
    P_PROGRAMID      IN NUMBER,
    P_STUDYID        IN NUM_ARRAY,
    P_SITEID         IN NUM_ARRAY,
    P_COURSETITLE    IN VARCHAR2,
    P_TRNGPROVIDER   IN VARCHAR2,
    P_REQUIREMENT    IN VARCHAR2,
    P_OFFSET         IN NUMBER,
    P_LIMIT          IN NUMBER,
    P_ORDRBY         IN VARCHAR2,
    P_SORTBY         IN VARCHAR2,
    P_TRAINING_STATUS OUT SYS_REFCURSOR,
    P_COUNT OUT NUMBER);


  PROCEDURE SP_SPONSERSURVEYOVERVIEW_XPRT(
  P_SPONSORID             IN NUMBER,
  P_SURVEYID              IN NUMBER,
  P_MULTISELECTSTUDYID    IN NUM_ARRAY,
  P_CREATEDBY             IN VARCHAR2,
  P_LANGUAGEID            IN NUMBER,
  P_THEREAPUTICAREAID     IN NUMBER,
  P_COUNTRYID             IN NUMBER,
  P_STARTDATE             IN DATE,
  P_ENDDATE               IN DATE,
  P_STATUSID              IN NUMBER,
  P_ISSTUDYMANAGER        IN NUMBER,
  P_ISMONITOR             IN NUMBER,
  P_GETASSOCIATEDSTUDYIDS IN NUM_ARRAY,
  P_OFFSET                IN NUMBER,
  P_LIMIT                 IN NUMBER,
  P_ORDER                 IN VARCHAR2,
  P_SORTBY                IN VARCHAR2,
  P_FINAL_REPORT          OUT SYS_REFCURSOR,
  P_COUNT                 OUT NUMBER);
  
procedure sp_fac_dept_report( IP_COUNTRYID      IN num_array,
      IP_LOGGEDIN_USER  IN NUMBER,
      IP_STATEID        IN NUMBER,
      IP_FACNAME        IN VARCHAR2,
      IP_FACID          IN NUMBER,
      IP_THERAAREA      IN num_array,
      IP_SUBTHERAAREA   IN num_array,
      IP_DEPTTYPID      IN NUMBER,
      IP_OFFSET         IN NUMBER,
      IP_LIMIT          IN NUMBER,
      IP_ORDRBY         IN VARCHAR2,
      IP_SORTBY         IN VARCHAR2,
      IP_COUNT          OUT NUMBER,
      IP_REPORT_DATA OUT SYS_REFCURSOR);
      
procedure sp_study_site_stf_report(
      IP_STUDYID        IN num_array,
      IP_SITEID         IN num_array,
      IP_COUNTRYID      IN NUM_ARRAY,
      IP_LOGGEDIN_USER  IN NUMBER,
      IP_FIRSTNAME      IN VARCHAR2,
      IP_LASTNAME       IN VARCHAR2,
      IP_SYSTEMID       IN NUM_ARRAY,
      IP_ACCESS_START_DATE_FROM DATE,
      IP_ACCESS_START_DATE_TO   DATE,
      IP_ACCESS_END_DATE_FROM   DATE,
      IP_ACCESS_END_DATE_TO     DATE,
      IP_OFFSET         IN NUMBER,
      IP_LIMIT          IN NUMBER,
      IP_ORDRBY         IN VARCHAR2,
      IP_SORTBY         IN VARCHAR2,
      IP_COUNT          OUT NUMBER,
      IP_REPORT_DATA OUT SYS_REFCURSOR);  

 procedure sp_email_failure_log(
      IP_LOGGEDIN_USER  IN NUMBER,
      IP_EMAIL                    IN VARCHAR2,
      IP_TRANS_USERID             IN VARCHAR2,
      IP_LASTNAME                 IN VARCHAR2,
      IP_STUDY_ID                 IN NUM_ARRAY,
      IP_STUDY_SITE_ID            IN NUM_ARRAY,
      IP_EMAILSUBJECT             IN VARCHAR2,
      IP_EMAIL_FAIL_LOG_STARTDATE IN DATE,
      IP_EMAIL_FAIL_LOG_ENDDATE   IN DATE,
      IP_NOTIFIC_TYPE             IN NUM_ARRAY,
      IP_OFFSET                   IN NUMBER,
      IP_LIMIT                    IN NUMBER,
      IP_ORDRBY                   IN VARCHAR2,
      IP_SORTBY                   IN VARCHAR2,
      OP_COUNT                    OUT NUMBER,
      OP_REPORT_DATA              OUT SYS_REFCURSOR);

procedure sp_email_safetynotfail(
      IP_LOGGEDIN_USER  IN NUMBER,
      IP_STUDY_ID                 IN NUM_ARRAY,
      IP_STUDY_SITE_ID            IN NUM_ARRAY,
      IP_DIST_STARTDATE           IN DATE,
      IP_DIST_ENDDATE             IN DATE,
      IP_COMPOUND                 IN NUM_ARRAY,
	  IP_COUNTRYID                IN NUM_ARRAY,
      IP_OFFSET                   IN NUMBER,
      IP_LIMIT                    IN NUMBER,
      IP_ORDRBY                   IN VARCHAR2,
      IP_SORTBY                   IN VARCHAR2,
      OP_COUNT                    OUT NUMBER,
      OP_REPORT_DATA              OUT SYS_REFCURSOR);

	  PROCEDURE SP_STUDYFAC_REPORT(
      I_LOGGEDINUSERID    IN NUMBER,
	  I_COMPOUNDIDS		  IN NUM_ARRAY,
      I_STUDYIDS          IN NUM_ARRAY,
      I_SITEIDS           IN NUM_ARRAY,
	  I_THERAPEUTICAREAIDS IN NUM_ARRAY,
      I_STUDYSITESTATUS   IN VARCHAR2,
      I_OFFSET            IN NUMBER,
      I_LIMIT             IN NUMBER,
      I_ORDRBY            IN VARCHAR2,
      I_SORTBY            IN VARCHAR2,
      I_COUNT OUT NUMBER,
      STUDYFAC OUT SYS_REFCURSOR);
	  
	  PROCEDURE SP_Survey_Template_Details(
      IP_LOGGEDIN_USER   IN NUMBER,
      IP_TYPE            IN NUMBER,
      IP_RECIPIENT       IN NUMBER,
      IP_SURVEYID        IN NUM_ARRAY,
      IP_SURVEYTITLE     IN NUM_ARRAY,
      IP_TEMPLATEID      IN NUM_ARRAY,
      IP_TEMPLATETITLE   IN NUM_ARRAY,
      IP_SURVEYTYPE      IN NUM_ARRAY,
      IP_SURVEYSTATUS    IN NUM_ARRAY,
      IP_THERAPEUTICAREA IN NUM_ARRAY,
      IP_COMPOUND        IN NUM_ARRAY,
      IP_PROGRAM         IN NUM_ARRAY,
      IP_STUDYID         IN NUM_ARRAY,
      IP_INDICATION      IN NUM_ARRAY,
      IP_STUDYPHASE      IN NUM_ARRAY,
      IP_SURVEYCREATOR   IN NUM_ARRAY,
      IP_SURVEYFROMDATE  IN DATE,
      IP_SURVEYTODATE    IN DATE,
      IP_COUNTRYID       IN NUM_ARRAY,
      IP_LANGUAGEID      IN NUM_ARRAY,
      IP_OFFSET          IN NUMBER,
      IP_LIMIT           IN NUMBER,
      IP_ORDRBY          IN VARCHAR2,
      IP_SORTBY          IN VARCHAR2,
      OP_COUNT OUT NUMBER,
      OP_REPORT_DATA OUT SYS_REFCURSOR);
	  
	  PROCEDURE SP_SS_STAFF_SYSTEM_ACCESS (
	I_LOGGEDINUSERID    IN NUMBER,
	I_STUDYIDS          IN NUM_ARRAY,
	I_SITEIDS           IN NUM_ARRAY,
	I_COUNTRYIDS        IN NUM_ARRAY,
	I_ROLEIDS           IN NUM_ARRAY,
  I_LASTNAME          IN VARCHAR2,
  I_FIRSTNAME         IN VARCHAR2,
  I_OFFSET            IN NUMBER,
	I_LIMIT             IN NUMBER,
	I_ORDRBY            IN VARCHAR2,
	I_SORTBY            IN VARCHAR2,
	I_COUNT OUT NUMBER,
	STUDYSITESTAFF OUT SYS_REFCURSOR);
	  
  
  PROCEDURE SP_SS_STAFF_DETAILS (
	I_LOGGEDINUSERID    IN NUMBER,
	I_STUDYIDS          IN NUM_ARRAY,
	I_SITEIDS           IN NUM_ARRAY,
	I_COUNTRYIDS        IN NUM_ARRAY,
	I_LASTNAME          IN VARCHAR2,
  I_FIRSTNAME         IN VARCHAR2,
  I_FACILITYNAME      IN VARCHAR2,
  I_DEPARTMENTNAME    IN VARCHAR2,
  I_FROMDATE          IN DATE,
  I_TODATE            IN DATE,
  I_OFFSET            IN NUMBER,
	I_LIMIT             IN NUMBER,
	I_ORDRBY            IN VARCHAR2,
	I_SORTBY            IN VARCHAR2,
	I_COUNT OUT NUMBER,
	STUDYSITESTAFFDETAILS OUT SYS_REFCURSOR) ;
 
FUNCTION FN_BLOB_TO_CHAR(IP_BLOB BLOB)
         RETURN VARCHAR2;	  
END pkg_reports;
/