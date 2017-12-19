create or replace PACKAGE  pkg_study_site AS
/*******************************************************************************************************
 Package Name : pkg_study_site
 Description  : Package to return list of sites for a users
 
 Version_No               Date                 Owner           Remark
 1.0                      26-May-2016          Cognizant          Initial
 
********************************************************************************************************/

/******************************************************************************
Object_name - SP_STUDY_SITE
Purpose - Procedure to return paginated values for study site
*******************************************************************************/
PROCEDURE SP_STUDY_SITE(
    P_USERID            IN NUMBER,
    P_INCLUDEINACTIVE   IN VARCHAR2,
    P_STUDYID           IN INTEGER,
	P_COUNTRYIDS        IN NUM_ARRAY,
	P_SITEIDS           IN NUM_ARRAY,
    P_OFFSET            IN NUMBER,
    P_LIMIT             IN NUMBER,
    P_ORDRBY            IN VARCHAR2,
    P_SORTBY            IN VARCHAR2,
    CUR_STUDYSITELIST   OUT SYS_REFCURSOR,
    P_COUNT OUT NUMBER
);


PROCEDURE SP_FETCH_ALL_LABS_FOR_SITE (
		I_STUDYID    	IN NUMBER,
		I_SITEID    	IN NUMBER,
		I_OFFSET        IN NUMBER,
		I_LIMIT         IN NUMBER,
		I_ORDRBY        IN VARCHAR2,
		I_SORTBY        IN VARCHAR2,
		I_COUNT 		OUT NUMBER,
		SITELABS		OUT SYS_REFCURSOR
	);
	
END pkg_study_site;
/