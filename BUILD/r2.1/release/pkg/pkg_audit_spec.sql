CREATE OR REPLACE PACKAGE PKG_AUDIT AS

  g_operation_create  tbl_audit.operation%TYPE:='Create';
  g_operation_insert  tbl_audit.operation%TYPE:='Insert';
  g_operation_update  tbl_audit.operation%TYPE:='Update';
  g_operation_delete  tbl_audit.operation%TYPE:='Delete';

  g_lov_program                                    VARCHAR2(50):='PROGRAM';
  g_lov_compound                                VARCHAR2(50):='COMPOUND';
  g_lov_disease                                    VARCHAR2(50):='DISEASE';
  g_lov_indication                                VARCHAR2(50):='INDICATION';
  g_lov_organization                            VARCHAR2(50):='ORGANIZATION';
  g_lov_language                                  VARCHAR2(50):='LANGUAGE';
  g_lov_country_id                                VARCHAR2(50):='COUNTRY_ID';
  g_lov_country_code                           VARCHAR2(50):='COUNTRY_CODE';
  g_lov_state_id                                    VARCHAR2(50):='STATE_ID';
  g_lov_state_code                               VARCHAR2(50):='STATE_CODE';
  g_lov_timezone                                  VARCHAR2(50):='TIMEZONE';
  g_lov_alertnotifitype                         VARCHAR2(50):='ALERTNOTIFITYPE';
  g_lov_doctype                                     VARCHAR2(50):='DOCTYPE';
  g_lov_docpkg                                       VARCHAR2(50):='DOCPKG';
  g_lov_role                                            VARCHAR2(50):='ROLE';
  g_lov_trngrejection                             VARCHAR2(50):='TRNGREJECTION';
  g_lov_task                                            VARCHAR2(50):='TASK';
  g_lov_trngstatus                                  VARCHAR2(50):='TRNGSTATUS';
  g_lov_phase                                         VARCHAR2(50):='PHASE';
  g_lov_notifconfig                                 VARCHAR2(50):='NOTIFCONFIG';
  g_lov_userprofile_userid_trans        VARCHAR2(50):='USERPROFILE_USERID_TRANS';
  g_lov_userprofile_user_flname        VARCHAR2(50):='USERPROFILE_USER_FLNAME';
  g_lov_userprofile_trans_flname       VARCHAR2(50):='USERPROFILE_TRANS_FLNAME';
  g_lov_facility       					VARCHAR2(50):='FACILITY';
  g_lov_facilitydoctype      					VARCHAR2(50):='FACILITY_DOCTYPE';
  g_lov_addlfacility     					VARCHAR2(50):='ADDITIONAL_FACILITY';
  g_lov_facilitydoctitle                     VARCHAR2(100):='FILE_ENTRY';

  g_lov_recipientlist                               VARCHAR2(50):='RECIPIENTLIST';
  g_lov_surveysection                             VARCHAR2(50):='SURVEYSECTION';
  g_lov_surveyquestion                          VARCHAR2(50):='SURVEYQUESTION';
  g_lov_surveyanswer                             VARCHAR2(50):='SURVEYANSWER';
  g_lov_therapeuticarea                        VARCHAR2(50):='THERAPEUTICAREA';
  g_lov_subtherapeuticarea                        VARCHAR2(50):='SUBTHERAPEUTICAREA';
  g_lov_reasonlist                                   VARCHAR2(50):='REASONLIST';
  g_lov_template                                     VARCHAR2(50):='TEMPLATE';
  g_lov_surveymetadatatype                 VARCHAR2(50):='SURVEYMETADATATYPE';
  g_lov_surveylogic                                  VARCHAR2(50):='SURVEYLOGIC';
  g_lov_reasons                                       VARCHAR2(50):='REASONS';
  g_lov_surveyresponselist                    VARCHAR2(50):='SURVEYRESPONSELIST';
  g_lov_surveystatus                                VARCHAR2(50):='SURVEY_STATUS';
  g_lov_study                                             VARCHAR2(50):='STUDY';
  g_lov_survey_id                                      VARCHAR2(200):='SURVEY';
  g_lov_surveytype_id                              VARCHAR2(200):='SURVEY_TYPE';
  g_lov_site                                                VARCHAR2(200):='SITE';
  g_lov_surveyquestion_type                  VARCHAR2(50):='QUESTION_TYPE';
  g_lov_trngtype                                         VARCHAR2(200):='TRAINING_TYPE';
  g_lov_docexchangever                           VARCHAR2(200):='DOCEXCHANGEVER';
  g_lov_reviewer                           VARCHAR2(200):='REVIEWER';
  g_lov_responsemanager                           VARCHAR2(200):='RESPONSEMANAGER';
  g_lov_statuscd                           VARCHAR2(100):='STATUSCD';
  g_lov_potinv                           VARCHAR2(100):='POTENTIALINV';
  g_lov_studysystem                      VARCHAR2(100):='STUDY_SYSTEMS';
  g_lov_surveyusermap                     VARCHAR2(100):='SURVEYUSER';
  g_lov_trngstatus_new	                     VARCHAR2(100):='TRNG_STATUS_ID';
  g_lov_sponsortype							VARCHAR2(100):='TRIAL_TYPE';
  g_lov_irfacuser_flname					VARCHAR2(100):='IRFACILITYUSER';
  g_lov_internetaccess						VARCHAR2(100):='INTERNETACCESS';
  g_lov_compopsys							VARCHAR2(100):='COMPOPERATINGSYS';
  g_lov_docname								VARCHAR2(100) := 'DOCNAME';
  g_lov_tempmeasure							VARCHAR2(100) := 'TEMPMEASURE';
  g_lov_specialty							VARCHAR2(100) := 'SPECIALTY';
  g_lov_satellitesites						VARCHAR2(100) := 'SATELLITESITES';
  g_lov_orgname                 VARCHAR2(100) := 'REVIEWER';
  g_lov_study_trng                   VARCHAR2(100):='TRNG_STUDY_ID';
  g_lov_phaseofint                   VARCHAR2(100):='STUDYPHASE';
  g_lov_pottitle                   VARCHAR2(100):='PILISTTITLE';
  g_lov_labacc						VARCHAR2(100):='LABACC';
  g_lov_orgsysname					VARCHAR2(200) :='ORGSTUDYSYSNAME' ;
  g_lov_access					VARCHAR2(200) :='ORGACCESS' ;
  g_lov_studytheraarea					VARCHAR2(200) :='STUDYTHERAAREA' ;
  g_lov_activeflag              VARCHAR2(30):='ACTIVEFLAG';
  g_lov_surveycd              VARCHAR2(30):='BELONGTO';
  g_lov_irbtype              VARCHAR2(30):='IRBTYPE';
  g_lov_pkgsub              VARCHAR2(30):='PKGSUB';
  g_lov_meetfreq              VARCHAR2(30):='MEETFREQ';
  g_lov_surveytype            varchar2(30):='SURVEYSUBTYPE';
  g_lov_notapplicable         VARCHAR2(30):='NOTAPPLICABLE';
  g_lov_surveyans             VARCHAR2(30):='SURVEYANSID';
  g_lov_recptstatus           VARCHAR2(30):='RECIPIENTSTATUS';
  g_lov_surveycreator         VARCHAR2(30):='CREATEDBY';

  PROCEDURE SP_SET_AUDIT
    (ip_entityrefid   IN tbl_audit.entityrefid%TYPE,
     ip_tablename     IN tbl_audit.tablename%TYPE,
     ip_columnname    IN tbl_audit.columnname%TYPE,
     ip_oldvalue      IN tbl_audit.oldvalue%TYPE,
     ip_newvalue      IN tbl_audit.newvalue%TYPE,
     ip_operation     IN tbl_audit.operation%TYPE,
     ip_reason        IN tbl_audit.reason%TYPE,
     ip_createddt     IN tbl_audit.createddt%TYPE,
     ip_createdby     IN tbl_audit.createdby%TYPE,
     ip_modifieddt    IN tbl_audit.modifieddt%TYPE,
     ip_modifiedby    IN tbl_audit.modifiedby%TYPE,
	   op_auditid       OUT tbl_audit.auditid%TYPE
     );

  PROCEDURE SP_GET_STUDY_AUDIT
    (ip_startdate     IN tbl_studyauditreportmap.createddt%TYPE,
     ip_enddate       IN tbl_studyauditreportmap.createddt%TYPE,
     ip_changedby     IN tbl_studyauditreportmap.createdby%TYPE,
     ip_studyid       IN tbl_studyauditreportmap.studyid%TYPE,
     ip_studysiteid   IN NUM_ARRAY,
     ip_countryid     IN NUM_ARRAY,
     ip_offset        IN NUMBER,
     ip_limit         IN NUMBER,
     ip_ordrby        IN VARCHAR2,
     ip_sortby        IN VARCHAR2,
     op_count         OUT NUMBER,
     op_audit_report  OUT SYS_REFCURSOR
     );

  PROCEDURE SP_SET_STUDYAUDITREPORTMAP
    (ip_auditid           IN tbl_studyauditreportmap.STUDYAUDITID%TYPE,
     ip_studyid           IN tbl_studyauditreportmap.STUDYID%TYPE,
     ip_studysiteid       IN tbl_studyauditreportmap.STUDYSITEID%TYPE,
     ip_createddt         IN tbl_studyauditreportmap.CREATEDDT%TYPE,
     ip_createdby         IN tbl_studyauditreportmap.CREATEDBY%TYPE,
     ip_modifieddt    	  IN tbl_studyauditreportmap.modifieddt%TYPE,
	   ip_modifiedby   	  IN tbl_studyauditreportmap.modifiedby%TYPE

     );


  PROCEDURE SP_SET_SURVEYAUDITREPORTMAP
    (ip_auditid           IN tbl_surveyauditreportmap.SURVEYAUDITID%TYPE,
     ip_surveyid          IN tbl_surveyauditreportmap.SURVEYID%TYPE,
     ip_surveyname			  IN tbl_surveyauditreportmap.SURVEYNAME%TYPE,
     ip_studyid      	    IN tbl_surveyauditreportmap.STUDYID%TYPE,
     ip_surveyrecipient   IN tbl_surveyauditreportmap.SURVEYRECIPIENT%TYPE,
     ip_createddt         IN tbl_surveyauditreportmap.CREATEDDT%TYPE,
     ip_createdby         IN tbl_surveyauditreportmap.CREATEDBY%TYPE,
     ip_modifieddt    	  IN tbl_surveyauditreportmap.modifieddt%TYPE,
     ip_modifiedby   	    IN tbl_surveyauditreportmap.modifiedby%TYPE
     );

 PROCEDURE SP_GET_SURVEY_AUDIT
    (ip_startdate     IN tbl_surveyauditreportmap.modifieddt%TYPE,
     ip_enddate       IN tbl_surveyauditreportmap.modifieddt%TYPE,
     ip_changedby     IN tbl_surveyauditreportmap.modifiedby%TYPE,
     ip_surveyid      IN tbl_surveyauditreportmap.surveyid%TYPE,
     ip_surveytitle   IN tbl_surveyauditreportmap.surveyname%TYPE,
     ip_studyid       IN tbl_surveyauditreportmap.studyid%TYPE,
     ip_offset        IN NUMBER,
     ip_limit         IN NUMBER,
     ip_ordrby        IN VARCHAR2,
     ip_sortby        IN VARCHAR2,
     op_count         OUT NUMBER,
     op_audit_report  OUT SYS_REFCURSOR
     );
     PROCEDURE SP_GET_TRNGCREDITS_AUDIT
    (ip_loggedinuser  IN Number ,
     ip_startdate     IN TBL_TRNGCREDITSAUDITREPORTMAP.modifieddt%TYPE,
     ip_enddate       IN TBL_TRNGCREDITSAUDITREPORTMAP.modifieddt%TYPE,
     ip_changedby     IN TBL_TRNGCREDITSAUDITREPORTMAP.modifiedby%TYPE,
     ip_requestedby   IN TBL_TRNGCREDITSAUDITREPORTMAP.requestedby%TYPE,
     ip_orgid         IN number,
     ip_offset        IN NUMBER,
     ip_limit         IN NUMBER,
     ip_ordrby        IN VARCHAR2,
     ip_sortby        IN VARCHAR2,
     op_count         OUT NUMBER,
     op_audit_report  OUT SYS_REFCURSOR
     );

	 PROCEDURE SP_SET_TRNGCREDITSATREPORTMAP
    (ip_auditid           IN tbl_trngcreditsauditreportmap.trngcreditsauditid%TYPE,
     ip_requestid         IN tbl_trngcreditsauditreportmap.requestid%TYPE,
     ip_requestedby       IN tbl_trngcreditsauditreportmap.requestedby%TYPE,
	   ip_requestedfor      IN tbl_trngcreditsauditreportmap.requestedfor%TYPE,
     ip_createddt         IN tbl_surveyauditreportmap.CREATEDDT%TYPE,
     ip_createdby         IN tbl_trngcreditsauditreportmap.createdby%TYPE,
     ip_modifieddt    	  IN tbl_trngcreditsauditreportmap.modifieddt%TYPE,
	   ip_modifiedby   	    IN tbl_trngcreditsauditreportmap.modifiedby%TYPE
	      );

  PROCEDURE SP_SET_TRNGSTATUSATREPORTMAP
    (ip_auditid          IN TBL_TRNGSTATUSAUDITREPORTMAP.TRNGSTATUSAUDITID%TYPE,
    ip_courseid          IN TBL_TRNGSTATUSAUDITREPORTMAP.COURSEID%TYPE,
    ip_userid         	 IN TBL_TRNGSTATUSAUDITREPORTMAP.USERID%TYPE,
    ip_studyid          IN TBL_TRNGSTATUSAUDITREPORTMAP.STUDYID%TYPE,
    ip_siteid    		   IN TBL_TRNGSTATUSAUDITREPORTMAP.SITEID%TYPE,
    ip_createddt        IN TBL_TRNGSTATUSAUDITREPORTMAP.CREATEDDT%TYPE,
    ip_createdby        IN TBL_TRNGSTATUSAUDITREPORTMAP.CREATEDBY%TYPE,
    ip_modifieddt       IN TBL_TRNGSTATUSAUDITREPORTMAP.MODIFIEDDT%TYPE,
    ip_modifiedby       IN TBL_TRNGSTATUSAUDITREPORTMAP.MODIFIEDBY%TYPE
    );

        PROCEDURE SP_GET_TRNGSTATUSATREPORTMAP
    (ip_startdate     IN TBL_TRNGSTATUSAUDITREPORTMAP.createddt%TYPE,
     ip_enddate       IN TBL_TRNGSTATUSAUDITREPORTMAP.createddt%TYPE,
     ip_changedby     IN TBL_TRNGSTATUSAUDITREPORTMAP.createdby%TYPE,
     ip_userid        IN TBL_TRNGSTATUSAUDITREPORTMAP.Userid%TYPE,
     ip_courseid      IN TBL_TRNGSTATUSAUDITREPORTMAP.Courseid%type,
     ip_offset        IN NUMBER,
     ip_limit         IN NUMBER,
     ip_ordrby        IN VARCHAR2,
     ip_sortby        IN VARCHAR2,
     op_count         OUT NUMBER,
     op_trng_audit_report  OUT SYS_REFCURSOR
     );

   	 PROCEDURE SP_SET_DOCAUDITREPORTMAP
    (ip_auditid           IN TBL_DOCAUDITREPORTMAP.DOCAUDITID%TYPE,
     ip_facilityid        IN TBL_DOCAUDITREPORTMAP.FACILITYID%TYPE,
	   ip_userid     		  IN TBL_DOCAUDITREPORTMAP.USERID%TYPE,
	   ip_isforfacility	  IN TBL_DOCAUDITREPORTMAP.ISFORFACILITY%TYPE,
	   ip_isforuser		  IN TBL_DOCAUDITREPORTMAP.ISFORUSER%TYPE,
     ip_createddt         IN TBL_DOCAUDITREPORTMAP.CREATEDDT%TYPE,
     ip_createdby         IN TBL_DOCAUDITREPORTMAP.createdby%TYPE,
     ip_modifieddt    	  IN TBL_DOCAUDITREPORTMAP.modifieddt%TYPE,
	 ip_modifiedby   	  IN TBL_DOCAUDITREPORTMAP.modifiedby%TYPE,
   ip_documentid      IN TBL_DOCUMENTS.DOCUMENTID%TYPE
	      );

          PROCEDURE SP_GET_FACDEPTDOC_AUDIT
    (ip_startdate     IN TBL_DOCAUDITREPORTMAP.modifieddt%TYPE,
     ip_enddate       IN TBL_DOCAUDITREPORTMAP.modifieddt%TYPE,
     ip_changedby     IN TBL_DOCAUDITREPORTMAP.modifiedby%TYPE,
     ip_facilitydeptid     IN TBL_DOCAUDITREPORTMAP.FACILITYID%TYPE,
     ip_offset        IN NUMBER,
     ip_limit         IN NUMBER,
     ip_ordrby        IN VARCHAR2,
     ip_sortby        IN VARCHAR2,
     op_count         OUT NUMBER,
     op_audit_report  OUT SYS_REFCURSOR
     );

     PROCEDURE SP_GET_USERDOC_AUDIT
    (ip_startdate     IN TBL_DOCAUDITREPORTMAP.modifieddt%TYPE,
     ip_enddate       IN TBL_DOCAUDITREPORTMAP.modifieddt%TYPE,
     ip_changedby     IN TBL_DOCAUDITREPORTMAP.modifiedby%TYPE,
     ip_userid     IN TBL_DOCAUDITREPORTMAP.USERID%TYPE,
     ip_offset        IN NUMBER,
     ip_limit         IN NUMBER,
     ip_ordrby        IN VARCHAR2,
     ip_sortby        IN VARCHAR2,
     op_count         OUT NUMBER,
     op_audit_report  OUT SYS_REFCURSOR
     );



       PROCEDURE SP_USR_SEARCH_PROC(
      I_ORGID          IN NUMBER,
      I_FIRSTNAME      IN VARCHAR2,
      I_LASTNAME       IN VARCHAR2,
      I_TRANSUSERID    IN VARCHAR2,
      I_EMAIL          IN VARCHAR2,
      I_COUNTRYID      IN num_array,
      I_STATECD        IN num_array,
      I_CITY           IN VARCHAR2,
      I_OFFSET         IN NUMBER,
      I_LIMIT          IN NUMBER,
      I_ORDRBY         IN VARCHAR2,
      I_SORTBY         IN VARCHAR2,
      I_COUNT OUT NUMBER,
      USRSRCH OUT SYS_REFCURSOR);



  PROCEDURE SP_SET_USERAUDITREPORTMAP
    (ip_auditid           IN tbl_userauditreportmap.USERAUDITID%TYPE,
     ip_userid            IN tbl_userauditreportmap.USERID%TYPE,
     ip_createddt         IN tbl_userauditreportmap.CREATEDDT%TYPE,
     ip_createdby         IN tbl_userauditreportmap.CREATEDBY%TYPE,
     ip_modifieddt    	  IN tbl_userauditreportmap.modifieddt%TYPE,
	 ip_modifiedby   	  IN tbl_userauditreportmap.modifiedby%TYPE

     );

  PROCEDURE SP_SET_FACAUDITREPORTMAP
    (ip_auditid           IN tbl_facauditreportmap.FACAUDITID%TYPE,
     ip_facilityid          IN tbl_facauditreportmap.FACILITYID%TYPE,
     ip_createddt         IN tbl_facauditreportmap.CREATEDDT%TYPE,
     ip_createdby         IN tbl_facauditreportmap.CREATEDBY%TYPE,
     ip_modifieddt    	  IN tbl_facauditreportmap.modifieddt%TYPE,
	 ip_modifiedby   	  IN tbl_facauditreportmap.modifiedby%TYPE

     );

  PROCEDURE SP_GET_USER_AUDIT
    (ip_startdate     IN tbl_userauditreportmap.createddt%TYPE,
     ip_enddate       IN tbl_userauditreportmap.createddt%TYPE,
     ip_changedby     IN tbl_userauditreportmap.createdby%TYPE,
     ip_userid       IN tbl_userauditreportmap.userid%TYPE,
     ip_offset        IN NUMBER,
     ip_limit         IN NUMBER,
     ip_ordrby        IN VARCHAR2,
     ip_sortby        IN VARCHAR2,
     op_count         OUT NUMBER,
     op_audit_report  OUT SYS_REFCURSOR
     );

  PROCEDURE SP_GET_FACILITY_AUDIT
    (ip_startdate     IN tbl_facauditreportmap.createddt%TYPE,
     ip_enddate       IN tbl_facauditreportmap.createddt%TYPE,
     ip_changedby     IN tbl_facauditreportmap.createdby%TYPE,
     ip_facilityid      IN tbl_facauditreportmap.facilityid%TYPE,
	 ip_informationarea  IN NUMBER,
     ip_offset        IN NUMBER,
     ip_limit         IN NUMBER,
     ip_ordrby        IN VARCHAR2,
     ip_sortby        IN VARCHAR2,
     op_count         OUT NUMBER,
     op_audit_report  OUT SYS_REFCURSOR
     );


  --Function to get LOV Values using IDs
  FUNCTION fn_get_lov_value
  (ip_lovid     IN VARCHAR2,
   ip_lovtype  IN VARCHAR2
  ) RETURN VARCHAR2;

  --Function to get createdby for deleted records
  FUNCTION fn_get_del_createdby
  (ip_tablename     IN VARCHAR2,
   ip_primary_key    IN VARCHAR2
   ) RETURN VARCHAR2;

  --Function to get createddt for deleted records
  FUNCTION fn_get_del_createddt
  (ip_tablename     IN VARCHAR2,
   ip_primary_key    IN VARCHAR2
  ) RETURN DATE;

  --Procedure to delete records from table TBL_DELETEDRECORD created for deleted records
  PROCEDURE sp_del_deletedrecords
  (ip_tablename     IN VARCHAR2,
   ip_primary_key   IN VARCHAR2);

   FUNCTION FN_GET_USER_ORGID
(ip_transcelerateuserid IN TBL_USERPROFILES.TRANSCELERATEUSERID%TYPE)
RETURN NUMBER;

FUNCTION FN_GET_USER_ORGNAME
(ip_transcelerateuserid IN TBL_USERPROFILES.TRANSCELERATEUSERID%TYPE)
RETURN varchar2;

FUNCTION FN_CHECK_USER_ORG
(ip_transcelerateuserid IN TBL_USERPROFILES.TRANSCELERATEUSERID%TYPE,
 ip_loggedinorgid               IN TBL_USERPROFILES.ORGID%TYPE)
RETURN NUMBER;

END pkg_audit;
/