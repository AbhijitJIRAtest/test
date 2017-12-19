CREATE OR REPLACE PACKAGE pkg_potent_inv AS
/*******************************************************************************************************
 Package Name : pkg_potent_inv
 Description  : Package to create Potential Investigator List

 Version_No               Date                 Owner           Remark
 1.0                      12-APR-2016          Cognizant          Initial

********************************************************************************************************/

/******************************************************************************
Object_name - SP_POTENTIAL_INV
Purpose - Procedure to create PI list
*******************************************************************************/
PROCEDURE SP_POTENTIAL_INV(
    P_PILIST            IN typ_potentialInv_list,
	CUR_PILISTOUT       OUT SYS_REFCURSOR,
	P_STUDYID IN NUMBER
);

PROCEDURE PROC_POPULATE_POTENTIALINV (
    TITLE_ARRAY   IN NUM_ARRAY ,
    V_NEW_TITLEID IN NUMBER,
    V_CREATEDBY   IN VARCHAR2,
    V_CREATEDDATE DATE,
    V_STATUS_FLAG OUT NUMBER,
    CUR_PILISTOUT OUT SYS_REFCURSOR

  );

PROCEDURE PROC_POPULATE_POTINVFACMAP (
    V_STATUS_FLAG 			    OUT NUMBER
  );

FUNCTION FN_SEND_PI_TASK(
   P_USERID IN VARCHAR2, 
   P_TITLE IN VARCHAR2
  )RETURN INTEGER;


/******************************************************************************
Object_name - PROC_MERGE_POTENTIALINV
Purpose - Procedure to merge survey list in PI list
*******************************************************************************/
PROCEDURE PROC_MERGE_POTENTIALINV (
    P_SURVEYLIST  IN typ_survey_list,
    V_NEW_TITLEID IN NUMBER,
    V_CREATEDBY   IN VARCHAR2,
    V_CREATEDDATE DATE,
    V_STATUS_FLAG OUT NUMBER
  );
END pkg_potent_inv;
/