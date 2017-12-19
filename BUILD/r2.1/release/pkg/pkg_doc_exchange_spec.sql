CREATE OR REPLACE PACKAGE PKG_DOC_EXCHANGE
AS
  /*******************************************************************************************************
  Package Name : pkg_doc_exchange
  Description  : Function to fetch document exchange values as per search criteria.
  Version_No               Date                 Owner           Remark
  1.0                      11-Nov-2014          Cognizant          Initial
  ********************************************************************************************************/
  /******************************************************************************
  Object_name - CHECK_PENDING_USER_COUNT
  Purpose - Procedure to retrieve count of user pending to view the document
  *******************************************************************************/
  PROCEDURE CHECK_PENDING_USER_COUNT(
      DOC_EXCHANGE_ID IN NUMBER,
      USER_CNT OUT NUMBER);
  /******************************************************************************
  Object_name - FN_GET_ADMIN_DOCEXCHNG
  Purpose - Function to fetch document exchange values as per search criteria
  *******************************************************************************/
  PROCEDURE FN_GET_ADMIN_DOCEXCHNG(
      I_LOGGEDINUSERID  IN NUMBER,
      I_CREATEDFROMDATE IN DATE,
      I_CREATEDTODATE   IN DATE,
      I_METADATAMODDT   IN DATE,
      I_METADATAMODTODT IN DATE,
      I_PIIDS           IN NUM_ARRAY,
      I_ROLEIDS         IN NUM_ARRAY,
      I_SITEIDS         IN NUM_ARRAY,
      I_STUDYIDS        IN NUM_ARRAY,
      I_USERIDS         IN NUM_ARRAY,
      I_COMPOUNDID      IN NUMBER,
      I_PROGRAMID       IN NUMBER,
      I_PACKAGEID       IN NUMBER,
      I_COUNTRYID       IN NUMBER,
      I_DOCUMENTTYPE    IN NUMBER,
      I_LANGUAGEID      IN NUMBER,
      I_METADATAMODBY   IN NUMBER,
      I_UPLOADEDBY      IN NUMBER,
      I_FILEFORMAT      IN VARCHAR_ARRAY,
      I_DOCSTATUS       IN VARCHAR2,
      I_DOCUPLOADLEVEL  IN VARCHAR2,
      I_ISVIEWEDBYME    IN VARCHAR2,
      I_ORGFILENAME     IN VARCHAR2,
      I_REFMODELSUBSEC  IN VARCHAR2,
      I_REFMODELZONE    IN VARCHAR2,
      I_TITLE           IN VARCHAR2,
      I_UPLOADEDBYROLE  IN VARCHAR2,
      I_PERSNLIDS       IN NUM_ARRAY,
      I_PERSNLNMS       IN VARCHAR2,
      I_OFFSET          IN NUMBER,
      I_LIMIT           IN NUMBER,
      I_ORDRBY          IN VARCHAR2,
      I_SORTBY          IN VARCHAR2,
      O_COUNT OUT NUMBER,
      REF_CUS_DOC_RESULTS OUT SYS_REFCURSOR);
  /******************************************************************************
  Object_name - GET_SITE_USER_STATUS
  Purpose - Procedure to retrieve status of document user/site specific
  *******************************************************************************/
  FUNCTION GET_SITE_USER_STATUS(
      DOCEXCHANGEVERID    IN NUMBER,
      ASSIGNEDTO          IN NUMBER,
      OPSITEID            IN NUMBER,
      OPUSERID            IN NUMBER,
      DOCSTATUS           IN VARCHAR2,
      ISUPLOADEDBYSPONSOR IN VARCHAR2,
      I_USERID NUMBER)
    RETURN VARCHAR2;
  /******************************************************************************
  Object_name - GET_USER_DOC_ACC_STATUS
  Purpose - Retrieve accessed status of document user/site specific
  *******************************************************************************/
  FUNCTION GET_USER_DOC_ACC_STATUS(
      DOCEXCHANGEVERID    IN NUMBER,
      ASSIGNEDTO          IN NUMBER,
      OPSITEID            IN NUMBER,
      OPUSERID            IN NUMBER,
      DOCSTATUS           IN VARCHAR2,
      ISUPLOADEDBYSPONSOR IN VARCHAR2)
    RETURN VARCHAR2;
  /******************************************************************************
  Object_name - CHECK_ACCS_OF_DOC
  Purpose - Procedure to check whether user has access of document or not. If user has access it will return true else false.
  *******************************************************************************/
  PROCEDURE CHECK_ACCS_OF_DOC(
      I_USERID        IN NUMBER,
      I_DOCEXCHANGEID IN NUMBER,
      O_RETRN_MSG OUT VARCHAR2);
  PROCEDURE FN_GET_SPO_DOCEXCHNG(
      I_LOGGEDINUSERID  IN NUMBER,
      I_CREATEDFROMDATE IN DATE,
      I_CREATEDTODATE   IN DATE,
      I_METADATAMODDT   IN DATE,
      I_METADATAMODTODT IN DATE,
      I_PIIDS           IN NUM_ARRAY,
      I_ROLEIDS         IN NUM_ARRAY,
      I_SITEIDS         IN NUM_ARRAY,
      I_STUDYIDS        IN NUM_ARRAY,
      I_USERIDS         IN NUM_ARRAY,
      I_COMPOUNDID      IN NUMBER,
      I_PROGRAMID       IN NUMBER,
      I_PACKAGEID       IN NUMBER,
      I_COUNTRYID       IN NUMBER,
      I_DOCUMENTTYPE    IN NUMBER,
      I_LANGUAGEID      IN NUMBER,
      I_METADATAMODBY   IN NUMBER,
      I_UPLOADEDBY      IN NUMBER,
      I_FILEFORMAT      IN VARCHAR_ARRAY,
      I_DOCSTATUS       IN VARCHAR2,
      I_DOCUPLOADLEVEL  IN VARCHAR2,
      I_ISVIEWEDBYME    IN VARCHAR2,
      I_ORGFILENAME     IN VARCHAR2,
      I_REFMODELSUBSEC  IN VARCHAR2,
      I_REFMODELZONE    IN VARCHAR2,
      I_TITLE           IN VARCHAR2,
      I_UPLOADEDBYROLE  IN VARCHAR2,
      I_PERSNLIDS       IN NUM_ARRAY,
      I_PERSNLNMS       IN VARCHAR2,
      I_OFFSET          IN NUMBER,
      I_LIMIT           IN NUMBER,
      I_ORDRBY          IN VARCHAR2,
      I_SORTBY          IN VARCHAR2,
      O_COUNT OUT NUMBER,
      REF_CUS_DOC_RESULTS OUT SYS_REFCURSOR);
  PROCEDURE FN_GET_SI_DOCEXCHNG(
      I_LOGGEDINUSERID  IN NUMBER,
      I_CREATEDFROMDATE IN DATE,
      I_CREATEDTODATE   IN DATE,
      I_METADATAMODDT   IN DATE,
      I_METADATAMODTODT IN DATE,
      I_PIIDS           IN NUM_ARRAY,
      I_ROLEIDS         IN NUM_ARRAY,
      I_SITEIDS         IN NUM_ARRAY,
      I_STUDYIDS        IN NUM_ARRAY,
      I_USERIDS         IN NUM_ARRAY,
      I_COMPOUNDID      IN NUMBER,
      I_PROGRAMID       IN NUMBER,
      I_PACKAGEID       IN NUMBER,
      I_COUNTRYID       IN NUMBER,
      I_DOCUMENTTYPE    IN NUMBER,
      I_LANGUAGEID      IN NUMBER,
      I_METADATAMODBY   IN NUMBER,
      I_UPLOADEDBY      IN NUMBER,
      I_FILEFORMAT      IN VARCHAR_ARRAY,
      I_DOCSTATUS       IN VARCHAR2,
      I_DOCUPLOADLEVEL  IN VARCHAR2,
      I_ISVIEWEDBYME    IN VARCHAR2,
      I_ORGFILENAME     IN VARCHAR2,
      I_REFMODELSUBSEC  IN VARCHAR2,
      I_REFMODELZONE    IN VARCHAR2,
      I_TITLE           IN VARCHAR2,
      I_UPLOADEDBYROLE  IN VARCHAR2,
      I_PERSNLIDS       IN NUM_ARRAY,
      I_PERSNLNMS       IN VARCHAR2,
      I_OFFSET          IN NUMBER,
      I_LIMIT           IN NUMBER,
      I_ORDRBY          IN VARCHAR2,
      I_SORTBY          IN VARCHAR2,
      O_COUNT OUT NUMBER,
      REF_CUS_DOC_RESULTS OUT SYS_REFCURSOR);
  /******************************************************************************
  Object_name - SEARCH_PERSONNEL
  Purpose - Function to fetch personnels for assigning document exchange
  *******************************************************************************/
  PROCEDURE SEARCH_PERSONNEL(
      I_LOGGEDINUSERID IN NUMBER,
      I_FIRSTNAME      IN VARCHAR2,
      I_LASTNAME       IN VARCHAR2,
      I_EMAIL          IN VARCHAR2,
      I_USERIDS        IN NUM_ARRAY,
      I_TRANSID        IN VARCHAR2,
      I_COUNTRYID      IN NUMBER,
      I_STUDYIDS       IN NUM_ARRAY,
      I_SITEIDS        IN NUM_ARRAY,
      I_ISSPONSOR      IN VARCHAR2,
      I_OFFSET         IN NUMBER,
      I_LIMIT          IN NUMBER,
      I_ORDRBY         IN VARCHAR2,
      I_SORTBY         IN VARCHAR2,
      O_COUNT OUT NUMBER,
      REF_CUS_PERSNL_RESULTS OUT SYS_REFCURSOR);
  /******************************************************************************
  Object_name - GET_USERS_FOR_DOCEX
  Purpose - Function to fetch users who has access on document exchange
  *******************************************************************************/
  PROCEDURE GET_USERS_FOR_DOCEX(
      I_DOCEXID IN NUMBER,
      I_USERID  IN NUMBER,
      I_SITEID  IN NUMBER,
      REF_CUS_USERS OUT SYS_REFCURSOR);
  /******************************************************************************
  Object_name - SEARCH_USERS
  Purpose - Function to fetch user for document exchange
  *******************************************************************************/
  PROCEDURE SEARCH_USERS(
      I_LOGGEDINTRNSID IN VARCHAR2,
      I_FIRSTNAME      IN VARCHAR2,
      I_LASTNAME       IN VARCHAR2,
      I_STUDYNAME      IN VARCHAR2,
      I_ROLE           IN VARCHAR2,
      I_COUNTRY        IN VARCHAR2,
      I_CITY           IN VARCHAR2,
      I_STATE          IN VARCHAR2,
      I_EMAIL          IN VARCHAR2,
      I_ISFRSNDMSG     IN VARCHAR2,
      I_STUDYIDS       IN NUM_ARRAY,
      I_SITEIDS        IN NUM_ARRAY,
      I_OFFSET         IN NUMBER,
      I_LIMIT          IN NUMBER,
      I_ORDRBY         IN VARCHAR2,
      I_SORTBY         IN VARCHAR2,
      O_COUNT OUT NUMBER,
      REF_CUS_USERS_RESULTS OUT SYS_REFCURSOR);
  /******************************************************************************
  Object_name - SEARCH_USER_FR_SND_MSG
  Purpose - Function to search users for sending message.
  *******************************************************************************/
  PROCEDURE SEARCH_USER_FR_SND_MSG(
      I_LOGGEDINUSERID IN NUMBER,
      I_FIRSTNAME      IN VARCHAR2,
      I_LASTNAME       IN VARCHAR2,
      I_EMAIL          IN VARCHAR2,
      I_USERIDS        IN NUM_ARRAY,
      I_TRANSID        IN VARCHAR2,
      I_COUNTRYID      IN NUMBER,
      I_STUDYIDS       IN NUM_ARRAY,
      I_SITEIDS        IN NUM_ARRAY,
      I_ISSPONSOR      IN VARCHAR2,
      I_STUDYNAME      IN VARCHAR2,
      I_OFFSET         IN NUMBER,
      I_LIMIT          IN NUMBER,
      I_ORDRBY         IN VARCHAR2,
      I_SORTBY         IN VARCHAR2,
      O_COUNT OUT NUMBER,
      REF_CUS_PERSNL_RESULTS OUT SYS_REFCURSOR);
   PROCEDURE PR_STUDYID_FOR_USER(
      I_LOGGEDINUSERID  IN NUMBER,
      REF_STUDYID_RESULTS OUT SYS_REFCURSOR);
END PKG_DOC_EXCHANGE;
/