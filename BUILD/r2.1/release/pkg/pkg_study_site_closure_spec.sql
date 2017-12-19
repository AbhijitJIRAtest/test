create or replace
PACKAGE  pkg_study_site_closure AS
/*******************************************************************************************************
 Package Name : pkg_study_site_closure
 Description  : Package is perform list of activities related to site or study.
 
 Version_No               Date                 Owner           Remark
 1.0                      11-Nov-2014          Cognizant          Initial
 
********************************************************************************************************/

/******************************************************************************
Object_name - PROC_STUDY_CLOSURE_ACTIVITY
Purpose - Procedure  to perform study closure related activities 
*******************************************************************************/
PROCEDURE   PROC_STUDY_CLOSURE_ACTIVITY (V_NEW_CNT OUT NUMBER)  ;

/******************************************************************************
Object_name - PROC_SITE_CLOSURE_ACTIVITY
Purpose - Procedure  to perform site closure related activities.
*******************************************************************************/

PROCEDURE PROC_SITE_CLOSURE_ACTIVITY (V_NEW_CNT OUT NUMBER) ;

/******************************************************************************
Object_name - PROC_IMMEDIATE_STUDY_CLOSE
Purpose - Procedure  to perform immediate study close.
*******************************************************************************/

PROCEDURE PROC_IMMEDIATE_STUDY_CLOSE (
	p_sponsorid         IN NUMBER,
    p_studyid           IN NUMBER,
	p_closedate			IN DATE,
	v_status OUT VARCHAR2
);

/******************************************************************************
Object_name - PROC_SITE_CLOSE
Purpose - Procedure  to perform immediate study site close.
*******************************************************************************/

PROCEDURE PROC_SITE_CLOSE (
	p_sponsorid         IN NUMBER,
	p_studyid           IN NUMBER,
    p_siteid           	IN NUM_ARRAY,
	p_closedate			IN DATE,
	v_status OUT VARCHAR2
);

/******************************************************************************
Object_name - PROC_STUDYSITE_ACTUALCLOSE
Purpose - Call from scheduler, procedure to perform actual study or study site close 
*******************************************************************************/
PROCEDURE PROC_STUDYSITE_ACTUALCLOSE(v_status OUT VARCHAR2);
 
END pkg_study_site_closure;
/