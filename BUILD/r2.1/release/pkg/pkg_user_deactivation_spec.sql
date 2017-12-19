create or replace PACKAGE  pkg_user_deactivation AS
/*******************************************************************************************************
 Package Name : pkg_user_deactivation
 Description  : Package to execute updates for users having deactivation request in tbl_userdeactivationlog.

 Version_No               Date                 Owner           Remark
 1.0                      11-Nov-2014          Cognizant          Initial

********************************************************************************************************/

/******************************************************************************
Object_name - sp_user_deactivation
Purpose - Procedure to updates for users having deactivation request in tbl_userdeactivationlog
*******************************************************************************/
PROCEDURE   sp_user_deactivation (p_status_code   OUT NUMBER , CUR_PLAT_SPON_DEACT OUT SYS_REFCURSOR)  ;


END pkg_user_deactivation;
/