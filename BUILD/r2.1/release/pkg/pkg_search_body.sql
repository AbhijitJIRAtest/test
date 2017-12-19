create or replace PACKAGE BODY PKG_SEARCH AS

PROCEDURE SP_SEARCH_COMMON_DOCUMENT
(
ip_loggedin_userid        IN TBL_USERPROFILES.userid%TYPE,
ip_search_type            IN VARCHAR2,
ip_documenttypeid         IN TBL_DOCTYPEMASTER.doctypeid%TYPE,
ip_filename               IN TBL_DOCUMENTS.title%TYPE,
ip_description            IN TBL_DOCUMENTS.description%TYPE,
ip_user_first_name        IN TBL_USERPROFILES.firstname%TYPE,
ip_user_last_name         IN TBL_USERPROFILES.lastname%TYPE,
ip_email                  IN TBL_CONTACT.email%TYPE,
ip_roleid                 IN TBL_ROLES.roleid%TYPE,       
ip_user_countryid         IN TBL_COUNTRIES.countryid%TYPE,
ip_user_stateid           IN TBL_STATES.stateid%TYPE,
ip_user_city              IN TBL_CONTACT.city%TYPE,
ip_facility_name          IN TBL_FACILITIES.facilityname%TYPE,
ip_department_name        IN TBL_FACILITIES.departmentname%TYPE,
ip_department_type_id     IN TBL_FACILITIES.departmenttypeid%TYPE,
ip_facdept_countryid      IN TBL_COUNTRIES.countryid%TYPE,
ip_facdept_stateid        IN TBL_STATES.stateid%TYPE,
ip_facdept_city           IN TBL_CONTACT.city%TYPE,
ip_gen_upload_from_date   IN TBL_DOCUMENTS.createddt%TYPE,
ip_gen_upload_to_date     IN TBL_DOCUMENTS.createddt%TYPE,
ip_offset                 IN NUMBER,
ip_limit                  IN NUMBER,
ip_ordrby                 IN VARCHAR2,
ip_sortby                 IN VARCHAR2,
op_count                  OUT NUMBER,
op_common_document        OUT SYS_REFCURSOR
)
IS
v_row_start               PLS_INTEGER;
v_row_end                 PLS_INTEGER;
v_issponsor               TBL_USERPROFILES.issponsor%TYPE;
v_orderby_clause          VARCHAR2(32767);
v_fac_orderby_clause      VARCHAR2(32767);
v_sortby                  VARCHAR2(32767);
v_page_select_clause      VARCHAR2(32767);
v_page_where_clause       VARCHAR2(32767);
v_select_cnt_clause       VARCHAR2(32767);
v_usrdoc_select_clause    VARCHAR2(32767);
v_usrdoc_from_clause      VARCHAR2(32767);
v_usrdoc_where_clause     VARCHAR2(32767);
v_usrdoc_final_query      VARCHAR2(32767);
v_trgdoc_select_clause    VARCHAR2(32767);
v_trgdoc_from_clause      VARCHAR2(32767);
v_trgdoc_where_clause     VARCHAR2(32767);
v_trgdoc_final_query      VARCHAR2(32767);
v_facdoc_select_clause    VARCHAR2(32767);
v_facdoc_from_clause      VARCHAR2(32767);
v_facdoc_where_clause     VARCHAR2(32767);
v_facdoc_final_query      VARCHAR2(32767);
v_final_cnt_query         VARCHAR2(32767);
v_final_query             VARCHAR2(32767);
v_usertype                TBL_ROLES.usertype%TYPE := 'Site';
v_rolelevel               TBL_ROLES.rolelevel%TYPE := 'Platform and StudySite';
v_escape_clause           VARCHAR2(25):= ' ESCAPE ''\'' ';
v_from_date               VARCHAR2(32767);
v_to_date                 VARCHAR2(32767);

BEGIN

    v_row_start := NVL(ip_offset,1);
    v_row_end := v_row_start + ip_limit;
    
    IF ip_sortby IS NOT NULL THEN
       IF ip_sortby = 'FILENAME' THEN
           v_sortby := ' UPPER(filename)';
       ELSIF ip_sortby = 'DOCTYPE' THEN
           v_sortby := ' UPPER(documenttype)';
       ELSIF ip_sortby = 'DESCRIPTION' THEN
           v_sortby := ' UPPER(document_description)';
       ELSIF ip_sortby = 'UPLOADEDON' THEN
           v_sortby := ' uploaded_generated_on ';
       ELSIF ip_sortby = 'UFNAME' THEN
           v_sortby := ' UPPER(user_first_name)';
       ELSIF ip_sortby = 'ULNAME' THEN
           v_sortby := ' UPPER(user_last_name)';
       ELSIF ip_sortby = 'FACNM' THEN
           v_sortby := ' UPPER(facilityname)';
       ELSIF ip_sortby = 'DEPNM' THEN
           v_sortby := ' UPPER(departmentname)'; 
       ELSIF ip_sortby = 'DEPTYPE' THEN
           v_sortby := ' UPPER(departmenttypename)';
       END IF;
    ELSE
       --Default Sorting
       v_sortby := ' uploaded_generated_on ';
    END IF;
  
    -- r_num = 1 Added to fetch Distinct records for User/Course/Attempt
    v_orderby_clause :=  ' ) temp WHERE (r_num = 1 OR r_num IS NULL) ORDER BY ' || v_sortby;
    v_fac_orderby_clause :=  ' ) temp ORDER BY ' || v_sortby;
    
    IF ip_ordrby IS NOT NULL THEN
       v_orderby_clause := v_orderby_clause || ' ' || ip_ordrby;
       v_fac_orderby_clause := v_fac_orderby_clause || ' ' || ip_ordrby;
    ELSE 
       v_orderby_clause := v_orderby_clause;
       v_fac_orderby_clause := v_fac_orderby_clause;
    END IF;
    
    IF ip_loggedin_userid IS NOT NULL THEN
       SELECT up.issponsor INTO v_issponsor FROM TBL_USERPROFILES up WHERE up.userid = ip_loggedin_userid;
    END IF;
    
    v_page_select_clause := ' SELECT * FROM(
                              SELECT  report_data.*,ROWNUM rnum FROM(SELECT * FROM( ';

    v_page_where_clause := ' ) report_data
                             WHERE ROWNUM < '|| v_row_end || ' )
                             WHERE rnum >= ' || v_row_start;

    v_select_cnt_clause := ' SELECT COUNT(1) ';
    
    IF UPPER(ip_search_type) = 'USER' THEN
        --User Documents
        v_usrdoc_select_clause := ' SELECT td.documentid documentid,
                                           td.url fileentryid,
                                           td.title filename,
                                           CASE 
                                               WHEN td.doctypecd = 1 THEN
                                                    ''Abbreviated Curriculum Vitae''
                                               WHEN td.doctypecd = 2 THEN
                                                    ''Medical License''
                                               WHEN td.doctypecd = 3 THEN
                                                    ''Profile Attachments''
                                           END documenttype,
                                           td.doctypecd documenttypeid,
                                           td.description document_description,
                                           td.createddt uploaded_generated_on,
                                           pkg_encrypt.fn_decrypt(tup.firstname) user_first_name,
                                           pkg_encrypt.fn_decrypt(tup.lastname) user_last_name,
                                           NULL facilityname,
                                           NULL departmentname,
                                           NULL departmenttypename,
                                           ''User'' search_type,
                                           NULL r_num';
                                          
        v_usrdoc_from_clause := ' FROM TBL_DOCUMENTS td, 
                                       TBL_USERPROFILES tup,
                                       TBL_CONTACT tc,
                                       TBL_COUNTRIES tcn,
                                       TBL_STATES tst ';                                      
        
        v_usrdoc_where_clause := ' WHERE td.docuserid = tup.userid
                                   AND tup.contactid = tc.contactid
                                   AND tc.countrycd = tcn.countrycd
                                   AND td.islatest = ''Y''
                                   AND td.isdeleted = ''N''
                                   AND tc.state = tst.statecd(+) ';
    
        --Training Documents
        v_trgdoc_select_clause := ' SELECT tuts.id documentid,
                                           CASE 
                                               WHEN tuts.source = ''SIP'' THEN
                                                    tuts.source || ''@#@'' || tuts.requestid || ''@#@''  || tuts.url 
                                               WHEN tuts.source = ''LMS'' THEN
                                                    tuts.source || ''@#@'' || tuts.course_id || ''@#@'' || tuts.emppk || ''@#@''  || tuts.url || ''@#@''  || tuts. attempt_id
                                           END fileentryid,
                                           tuts.course_title filename,
                                           ''Training Completion Certificate'' documenttype,
                                           TO_CHAR(tuts.training_type_id) documenttypeid,
                                           NULL document_description,
                                           tuts.createddt uploaded_generated_on,
                                           pkg_encrypt.fn_decrypt(tup.firstname) user_first_name,
                                           pkg_encrypt.fn_decrypt(tup.lastname) user_last_name,
                                           NULL facilityname,
                                           NULL departmentname,
                                           NULL departmenttypename,
                                           ''Training'' search_type,
                                           ROW_NUMBER() OVER(PARTITION BY tuts.user_id,tuts.course_title,tuts.attempt_id ORDER BY tuts.createddt DESC) r_num '; -- Added to fetch Distinct records for User/Course/Attempt
                                          
        v_trgdoc_from_clause := ' FROM TBL_USER_TRAINING_STATUS tuts, 
                                       TBL_TRAININGTYPE tt,
                                       TBL_USERPROFILES tup,
                                       TBL_CONTACT tc,
                                       TBL_COUNTRIES tcn,
                                       TBL_STATES tst ';                                      
        
        v_trgdoc_where_clause := ' WHERE tuts.user_id = tup.userid
                                   AND tuts.training_type_id = tt.trainingtypeid
                                   AND (UPPER(tuts.course_status) = UPPER(''COMPLETED'') OR
                                        UPPER(tuts.course_status) = UPPER(''CREDIT APPROVED''))
                                   AND UPPER(tuts.category) NOT IN (''NON-MRT'',''NON-MUTUALLY RECOGNIZED TRAINING'')
                                   AND tup.contactid = tc.contactid
                                   AND tc.countrycd = tcn.countrycd
                                   AND tc.state = tst.statecd(+) ';
        
        IF ip_loggedin_userid IS NOT NULL THEN
           IF v_issponsor = 'Y' THEN
              v_usrdoc_where_clause :=  v_usrdoc_where_clause || ' AND td.docuserid IN (SELECT ups.userid FROM TBL_USERPROFILES ups WHERE ups.isactive = ''Y'' AND ups.issponsor = ''N'')';
              v_trgdoc_where_clause :=  v_trgdoc_where_clause || ' AND tuts.user_id IN (SELECT ups.userid FROM TBL_USERPROFILES ups WHERE ups.isactive = ''Y'' AND ups.issponsor = ''N'')';
           ELSE
              v_usrdoc_where_clause :=  v_usrdoc_where_clause || ' AND td.docuserid = ' || ip_loggedin_userid;
              v_trgdoc_where_clause :=  v_trgdoc_where_clause || ' AND tuts.user_id = ' || ip_loggedin_userid;
           END IF;
        END IF;
        
        IF ip_documenttypeid IS NOT NULL THEN
           IF ip_documenttypeid IN (1,2,3) THEN
              v_usrdoc_where_clause :=  v_usrdoc_where_clause || ' AND td.doctypecd = ' || ip_documenttypeid;
           ELSIF ip_documenttypeid = -1 THEN
              v_trgdoc_where_clause :=  v_trgdoc_where_clause || ' AND tuts.training_type_id IS NOT NULL ';
           END IF;
        END IF;
        
        IF ip_filename IS NOT NULL THEN
           v_usrdoc_where_clause := v_usrdoc_where_clause || ' AND UPPER(td.title) LIKE ' || CHR(39) || '%' || UPPER(FN_REPLACE_WILDSPLCHAR(ip_filename)) || '%' || CHR(39) || v_escape_clause;
           v_trgdoc_where_clause := v_trgdoc_where_clause || ' AND UPPER(tuts.course_title) LIKE ' || CHR(39) || '%' || UPPER(FN_REPLACE_WILDSPLCHAR(ip_filename)) || '%' || CHR(39) || v_escape_clause;
        END IF;
        
        IF ip_description IS NOT NULL THEN
           v_usrdoc_where_clause := v_usrdoc_where_clause || ' AND UPPER(td.description) LIKE ' || CHR(39) || '%' || UPPER(FN_REPLACE_WILDSPLCHAR(ip_description)) || '%' || CHR(39) || v_escape_clause;
           v_trgdoc_where_clause := v_trgdoc_where_clause || ' AND UPPER(tuts.course_title) LIKE ' || CHR(39) || '%' || UPPER(FN_REPLACE_WILDSPLCHAR(ip_description)) || '%' || CHR(39) || v_escape_clause;
        END IF;
        
        IF ip_user_first_name IS NOT NULL THEN
           v_usrdoc_where_clause := v_usrdoc_where_clause || ' AND UPPER(pkg_encrypt.fn_decrypt(tup.firstname)) LIKE ' || CHR(39) || '%' || UPPER(FN_REPLACE_WILDSPLCHAR(ip_user_first_name)) || '%' || CHR(39) || v_escape_clause;
           v_trgdoc_where_clause := v_trgdoc_where_clause || ' AND UPPER(pkg_encrypt.fn_decrypt(tup.firstname)) LIKE ' || CHR(39) || '%' || UPPER(FN_REPLACE_WILDSPLCHAR(ip_user_first_name)) || '%' || CHR(39) || v_escape_clause;
        END IF;
        
        IF ip_user_last_name IS NOT NULL THEN
           v_usrdoc_where_clause := v_usrdoc_where_clause || ' AND UPPER(pkg_encrypt.fn_decrypt(tup.lastname)) LIKE ' || CHR(39) || '%' || UPPER(FN_REPLACE_WILDSPLCHAR(ip_user_last_name)) || '%' || CHR(39) || v_escape_clause;
           v_trgdoc_where_clause := v_trgdoc_where_clause || ' AND UPPER(pkg_encrypt.fn_decrypt(tup.lastname)) LIKE ' || CHR(39) || '%' || UPPER(FN_REPLACE_WILDSPLCHAR(ip_user_last_name)) || '%' || CHR(39) || v_escape_clause;
        END IF;
        
        IF ip_email IS NOT NULL THEN
           v_usrdoc_where_clause := v_usrdoc_where_clause || ' AND UPPER(pkg_encrypt.fn_decrypt(tc.email)) LIKE ' || CHR(39) || '%' || UPPER(FN_REPLACE_WILDSPLCHAR(ip_email)) || '%' || CHR(39) || v_escape_clause;
           v_trgdoc_where_clause := v_trgdoc_where_clause || ' AND UPPER(pkg_encrypt.fn_decrypt(tc.email)) LIKE ' || CHR(39) || '%' || UPPER(FN_REPLACE_WILDSPLCHAR(ip_email)) || '%' || CHR(39) || v_escape_clause;
        END IF;
        
        IF ip_roleid IS NOT NULL THEN
           IF ip_roleid = 10 THEN --Investigator
              v_usrdoc_where_clause :=  v_usrdoc_where_clause || ' AND tup.roleid = ' || ip_roleid;
              v_trgdoc_where_clause := v_trgdoc_where_clause || ' AND tup.roleid = ' || ip_roleid;
           ELSIF ip_roleid = 47 THEN --Clinical Research User    
              v_usrdoc_where_clause :=  v_usrdoc_where_clause || ' AND tup.roleid IN (SELECT tr.roleid FROM TBL_ROLES tr WHERE (tr.roleid = 47 OR (tr.usertype = ' || CHR(39) || v_usertype || CHR(39) || ' AND tr.rolelevel = ' || CHR(39) || v_rolelevel || CHR(39) || ' ))) ';
              v_trgdoc_where_clause := v_trgdoc_where_clause || ' AND tup.roleid IN (SELECT tr.roleid FROM TBL_ROLES tr WHERE (tr.roleid = 47 OR (tr.usertype = ' || CHR(39) || v_usertype || CHR(39) || ' AND tr.rolelevel = ' || CHR(39) || v_rolelevel || CHR(39) || ' ))) ';
           END IF;
        END IF;
        
        IF ip_user_countryid IS NOT NULL THEN
           v_usrdoc_where_clause :=  v_usrdoc_where_clause || ' AND tcn.countryid = ' || ip_user_countryid;
           v_trgdoc_where_clause :=  v_trgdoc_where_clause || ' AND tcn.countryid = ' || ip_user_countryid;
        END IF;
        
        IF ip_user_stateid IS NOT NULL THEN
           v_usrdoc_where_clause :=  v_usrdoc_where_clause || ' AND tst.stateid = ' || ip_user_stateid;
           v_trgdoc_where_clause :=  v_trgdoc_where_clause || ' AND tst.stateid = ' || ip_user_stateid;
        END IF;
        
        IF ip_user_city IS NOT NULL THEN
           v_usrdoc_where_clause := v_usrdoc_where_clause || ' AND UPPER(tc.city) LIKE ' || CHR(39) || '%' || UPPER(FN_REPLACE_WILDSPLCHAR(ip_user_city)) || '%' || CHR(39) || v_escape_clause;
           v_trgdoc_where_clause := v_trgdoc_where_clause || ' AND UPPER(tc.city) LIKE ' || CHR(39) || '%' || UPPER(FN_REPLACE_WILDSPLCHAR(ip_user_city)) || '%' || CHR(39) || v_escape_clause;
        END IF;
        

        IF ip_gen_upload_from_date    IS NOT NULL THEN
          v_from_date   := TO_CHAR(ip_gen_upload_from_date, 'yyyy-MM-dd hh24:mi:ss');
          v_usrdoc_where_clause := v_usrdoc_where_clause || ' AND TO_DATE(TO_CHAR(td.createddt, ''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') >= TO_DATE(''' || v_from_date || ''', ''yyyy-MM-dd hh24:mi:ss'')';
          v_trgdoc_where_clause := v_trgdoc_where_clause || ' AND TO_DATE(TO_CHAR(tuts.createddt, ''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') >= TO_DATE(''' || v_from_date || ''', ''yyyy-MM-dd hh24:mi:ss'')';
        END IF;

        
        IF ip_gen_upload_to_date    IS NOT NULL THEN
          v_to_date   := TO_CHAR(ip_gen_upload_to_date, 'yyyy-MM-dd hh24:mi:ss');
          v_usrdoc_where_clause := v_usrdoc_where_clause || ' AND TO_DATE(TO_CHAR(td.createddt, ''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') <= TO_DATE(''' || v_to_date || ''', ''yyyy-MM-dd hh24:mi:ss'')';
          v_trgdoc_where_clause := v_trgdoc_where_clause || ' AND TO_DATE(TO_CHAR(tuts.createddt, ''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') <= TO_DATE(''' || v_to_date || ''', ''yyyy-MM-dd hh24:mi:ss'')';
        END IF;

        IF ip_documenttypeid IS NOT NULL THEN
           IF ip_documenttypeid = -1 THEN
              -- r_num = 1 Added to fetch Distinct records for User/Course/Attempt
              v_final_cnt_query := v_select_cnt_clause || 
              ' FROM (SELECT ROW_NUMBER() OVER(PARTITION BY tuts.user_id,tuts.course_title,tuts.attempt_id ORDER BY tuts.createddt DESC) r_num ' || v_trgdoc_from_clause || v_trgdoc_where_clause || ' ) WHERE r_num = 1 ';
           ELSE
              v_final_cnt_query := v_select_cnt_clause || ' FROM (SELECT ROWNUM ' || v_usrdoc_from_clause || v_usrdoc_where_clause || ' ) ';
           END IF;
        ELSE
           v_final_cnt_query := v_select_cnt_clause || 
           ' FROM (SELECT ROWNUM ' || v_usrdoc_from_clause || v_usrdoc_where_clause || ' UNION ALL ' ||
           ' SELECT * FROM (SELECT ROW_NUMBER() OVER(PARTITION BY tuts.user_id,tuts.course_title,tuts.attempt_id ORDER BY tuts.createddt DESC) r_num ' || v_trgdoc_from_clause || v_trgdoc_where_clause || ' ) WHERE r_num = 1 ) ';  
        END IF;
        
        --DBMS_OUTPUT.PUT_LINE(v_final_cnt_query);
        EXECUTE IMMEDIATE v_final_cnt_query INTO op_count;
        
        v_usrdoc_final_query := v_usrdoc_select_clause || v_usrdoc_from_clause || v_usrdoc_where_clause;
        --DBMS_OUTPUT.PUT_LINE(v_usrdoc_final_query);                                
        v_trgdoc_final_query := v_trgdoc_select_clause || v_trgdoc_from_clause || v_trgdoc_where_clause;  
        --DBMS_OUTPUT.PUT_LINE(v_trgdoc_final_query);
        
        IF ip_documenttypeid IS NOT NULL THEN
           IF ip_documenttypeid = -1 THEN
              v_final_query := v_page_select_clause || v_trgdoc_final_query || v_orderby_clause || v_page_where_clause;
           ELSE
              v_final_query := v_page_select_clause || v_usrdoc_final_query || v_orderby_clause || v_page_where_clause;
           END IF;
        ELSE
           v_final_query := v_page_select_clause || v_usrdoc_final_query || ' UNION ALL ' || v_trgdoc_final_query || v_orderby_clause || v_page_where_clause;
        END IF;
        
        --DBMS_OUTPUT.PUT_LINE(v_final_query);
        
        OPEN op_common_document FOR v_final_query;
    
    ELSIF UPPER(ip_search_type) = 'FACILITY' THEN
    
          --Facility/Department Documents
          v_facdoc_select_clause := ' SELECT tfdm.facilitydocmetadataid documentid,
                                             df.fileentryid,
                                             df.title filename,
                                             tfdtm.doctype documenttype,
                                             tfdm.documenttypeid,
                                             tfdm.documentdescription document_description,
                                             tfdm.createddt uploaded_generated_on,
                                             NULL user_first_name,
                                             NULL user_last_name,
                                             tf.facilityname,
                                             tf.departmentname,
                                             tdt.departmenttypename,
                                             ''Facility'' search_type ';
          
          IF v_issponsor = 'Y' THEN                                 
              v_facdoc_from_clause := ' FROM TBL_FACILITIES tf,
                                             TBL_FACILITYDOCMETADATA tfdm, 
                                             TBL_FACILITYDOCTYPEMASTER tfdtm, 
                                             TBL_DEPARTMENTTYPE tdt,
                                             DLFILEENTRY df,
                                             TBL_CONTACT tc,
                                             TBL_COUNTRIES tcn,
                                             TBL_STATES tst ';                                      
              
              v_facdoc_where_clause := ' WHERE tf.facilityid = tfdm.facilityid
                                         AND tfdm.documenttypeid = tfdtm.facilitydoctypemasterid
                                         AND tf.departmenttypeid = tdt.departmenttypeid(+)
                                         AND tfdm.fileentryid = df.fileentryid
                                         AND tf.contactid = tc.contactid
                                         AND tc.countrycd = tcn.countrycd
                                         AND tc.state = tst.statecd(+) ';
          ELSE
              v_facdoc_from_clause := ' FROM TBL_FACILITIES tf,
                                             TBL_IRFACILITYUSERMAP tfum, 
                                             TBL_FACILITYDOCMETADATA tfdm, 
                                             TBL_FACILITYDOCTYPEMASTER tfdtm, 
                                             TBL_DEPARTMENTTYPE tdt,
                                             DLFILEENTRY df,
                                             TBL_CONTACT tc,
                                             TBL_COUNTRIES tcn,
                                             TBL_STATES tst ';                                      
              
              v_facdoc_where_clause := ' WHERE tf.facilityid = tfum.facilityid
                                         AND tf.facilityid = tfdm.facilityid
                                         AND tfdm.documenttypeid = tfdtm.facilitydoctypemasterid
                                         AND tf.departmenttypeid = tdt.departmenttypeid(+)
                                         AND tfdm.fileentryid = df.fileentryid
                                         AND tf.contactid = tc.contactid
                                         AND tc.countrycd = tcn.countrycd
                                         AND tc.state = tst.statecd(+) ';
          END IF;
          
          IF ip_loggedin_userid IS NOT NULL THEN
             IF v_issponsor = 'Y' THEN
                NULL;
                --v_facdoc_where_clause :=  v_facdoc_where_clause || ' AND tfum.userid IN (SELECT ups.userid FROM TBL_USERPROFILES ups WHERE ups.isactive = ''Y'' AND ups.issponsor = ''N'')';
             ELSE
                v_facdoc_where_clause :=  v_facdoc_where_clause || ' AND tfum.userid = ' || ip_loggedin_userid;
             END IF;
          END IF;
          
          IF ip_documenttypeid IS NOT NULL THEN
             v_facdoc_where_clause :=  v_facdoc_where_clause || ' AND tfdm.documenttypeid = ' || ip_documenttypeid;
          END IF;
          
          IF ip_filename IS NOT NULL THEN
             v_facdoc_where_clause := v_facdoc_where_clause || ' AND UPPER(df.title) LIKE ' || CHR(39) || '%' || UPPER(FN_REPLACE_WILDSPLCHAR(ip_filename)) || '%' || CHR(39) || v_escape_clause;
          END IF;
          
          IF ip_description IS NOT NULL THEN
             v_facdoc_where_clause := v_facdoc_where_clause || ' AND UPPER(tfdm.documentdescription) LIKE ' || CHR(39) || '%' || UPPER(FN_REPLACE_WILDSPLCHAR(ip_description)) || '%' || CHR(39) || v_escape_clause;
          END IF;
          
          IF ip_facility_name IS NOT NULL THEN
             v_facdoc_where_clause := v_facdoc_where_clause || ' AND UPPER(tf.facilityname) LIKE ' || CHR(39) || '%' || UPPER(FN_REPLACE_WILDSPLCHAR(ip_facility_name)) || '%' || CHR(39) || v_escape_clause;
          END IF;
          
          IF ip_department_name IS NOT NULL THEN
             v_facdoc_where_clause := v_facdoc_where_clause || ' AND UPPER(tf.departmentname) LIKE ' || CHR(39) || '%' || UPPER(FN_REPLACE_WILDSPLCHAR(ip_department_name)) || '%' || CHR(39) || v_escape_clause;
          END IF;
          
          IF ip_department_type_id IS NOT NULL THEN
             v_facdoc_where_clause := v_facdoc_where_clause || ' AND tf.departmenttypeid = ' || ip_department_type_id;
          END IF;
        
          IF ip_facdept_countryid IS NOT NULL THEN
             v_facdoc_where_clause :=  v_facdoc_where_clause || ' AND tcn.countryid = ' || ip_facdept_countryid;
          END IF;
          
          IF ip_facdept_stateid IS NOT NULL THEN
             v_facdoc_where_clause :=  v_facdoc_where_clause || ' AND tst.stateid = ' || ip_facdept_stateid;
          END IF;
          
          IF ip_facdept_city IS NOT NULL THEN
             v_facdoc_where_clause := v_facdoc_where_clause || ' AND UPPER(tc.city) LIKE ' || CHR(39) || '%' || UPPER(FN_REPLACE_WILDSPLCHAR(ip_facdept_city)) || '%' || CHR(39) || v_escape_clause;
          END IF;      
      
          IF ip_gen_upload_from_date    IS NOT NULL THEN
            v_from_date   := TO_CHAR(ip_gen_upload_from_date, 'yyyy-MM-dd hh24:mi:ss');
            v_facdoc_where_clause := v_facdoc_where_clause || ' AND TO_DATE(TO_CHAR(tfdm.createddt, ''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') >= TO_DATE(''' || v_from_date || ''', ''yyyy-MM-dd hh24:mi:ss'')';
          END IF;

          IF ip_gen_upload_to_date    IS NOT NULL THEN
            v_to_date   := TO_CHAR(ip_gen_upload_to_date, 'yyyy-MM-dd hh24:mi:ss');
            v_facdoc_where_clause := v_facdoc_where_clause || ' AND TO_DATE(TO_CHAR(tfdm.createddt, ''yyyy-MM-dd hh24:mi:ss''), ''yyyy-MM-dd hh24:mi:ss'') <= TO_DATE(''' || v_to_date || ''', ''yyyy-MM-dd hh24:mi:ss'')';
          END IF;

          
          v_final_cnt_query := v_select_cnt_clause || v_facdoc_from_clause || v_facdoc_where_clause;
          EXECUTE IMMEDIATE v_final_cnt_query INTO op_count;
          --DBMS_OUTPUT.PUT_LINE(v_final_cnt_query);
          
          v_facdoc_final_query := v_page_select_clause || v_facdoc_select_clause || v_facdoc_from_clause || v_facdoc_where_clause ||
                                  v_fac_orderby_clause || v_page_where_clause;
          --DBMS_OUTPUT.PUT_LINE(v_facdoc_final_query);
          
          OPEN op_common_document FOR v_facdoc_final_query;
    
    END IF;
        
END SP_SEARCH_COMMON_DOCUMENT;

  PROCEDURE SP_SPNSR_FAC_SEARCH(
      IP_LOGGEDINUSER   IN NUMBER,
      IP_COUNTRYCD      IN VARCHAR2,
      IP_STATECD        IN VARCHAR2,
      IP_CITY           IN VARCHAR2,
	  IP_FACNAME			IN VARCHAR2,
    IP_DEPTYPEID			IN NUM_ARRAY,
	  IP_THERAAREA		IN NUM_ARRAY,
	  IP_SUBTHERAREA		IN NUM_ARRAY,
    IP_FACPHID       IN NUM_ARRAY,
    IP_ISINDUSTRY    IN VARCHAR2,
    IP_ISINVESTIGATORINITIATED    IN VARCHAR2,
    IP_ISACADEMIC   IN VARCHAR2,
    IP_ISGOVERNMENT    IN VARCHAR2,
    IP_ISOTHERSPONSORTYPES    IN VARCHAR2,
      IP_ISPEDIATRIC    IN VARCHAR2, 
      IP_ISADULT    IN VARCHAR2, 
      IP_ISGERIATRIC    IN VARCHAR2,
      IP_ISHISPANIC     IN VARCHAR2,
      IP_ISAMERICAN     IN VARCHAR2,
      IP_ISASIAN        IN VARCHAR2,
      IP_ISBLACK        IN VARCHAR2,
      IP_ISNATIVE       IN VARCHAR2,
      IP_ISCAUCASIAN    IN VARCHAR2,
      ISWRITTENSOP IN VARCHAR2,
      IP_ISMINORASSENTPEDIATRIC IN VARCHAR2,
      IP_ISOTHERVULNERABLE IN VARCHAR2,
      IP_ISSHORTFORM    IN VARCHAR2,
      IP_AVGDAYS        IN NUM_ARRAY,
      IP_HASLOCAL       IN VARCHAR2,
      IP_HASCENTRALASLOCAL IN VARCHAR2,
      IP_HASSPONSORCENTRAL IN VARCHAR2,
      IP_CENTRIFUGE     IN VARCHAR2,
      IP_REFCENTRIFUGESAMPLES  IN VARCHAR2,
      IP_ISMEDICALEMERGENCIES  IN VARCHAR2,
      IP_OPENWEEKEND    IN VARCHAR2,
      IP_ADMITRESEARCHSUBJECTS  IN VARCHAR2,
      IP_STUDYMATERIAL  IN VARCHAR2,
      IP_PKPDCAPABILITY  IN VARCHAR2,
      IP_ISPGXSAMPLEALLOWED  IN VARCHAR2,
      IP_ISENGKNOWLEDGE  IN VARCHAR2,
      IP_ISTRANSSUPPORT  IN VARCHAR2,
      IP_DEDICATEDCOMPUTER  IN VARCHAR2, 
      IP_CT               IN VARCHAR2,
      IP_DXA              IN VARCHAR2,
      IP_ECG              IN VARCHAR2,
      IP_FLRO             IN VARCHAR2,
      IP_MRI              IN VARCHAR2,
      IP_MRA              IN VARCHAR2,
      IP_MRS              IN VARCHAR2,
      IP_MAMMO            IN VARCHAR2,
      IP_NMED             IN VARCHAR2,
      IP_PET              IN VARCHAR2,
      IP_XRAY             IN VARCHAR2,
      IP_ISRADIOLABLDIPCAPABLE IN VARCHAR2,
      IP_ISINFUSIONCAPABLE IN VARCHAR2,
      IP_ISREGLICPRESENT IN VARCHAR2,
      IP_ISDESTRYIPCPBLCTRLDSUBS IN VARCHAR2,
      IP_ISIPSTORAGESECURED IN VARCHAR2,
      IP_ISDESTROYIPCAPABLE IN VARCHAR2,
      IP_SECURERECORDSTORAGE IN VARCHAR2,
      IP_ONSITEARCHIVING IN VARCHAR2,
      IP_OFFSET         IN NUMBER,
      IP_LIMIT          IN NUMBER,
      IP_ORDRBY         IN VARCHAR2,
      IP_SORTBY         IN VARCHAR2,
      IP_COUNT OUT NUMBER,
      FACSRCH OUT SYS_REFCURSOR)
  AS
    V_DEP_LIST              VARCHAR2(9999);
    V_THERA_LIST            VARCHAR2(9999);
    V_SUBTHERA_LIST         VARCHAR2(9999);
    V_PHASE_LIST            VARCHAR2(9999);
    V_AVGDAYS_LIST          VARCHAR2(9999);
	V_IP_FACNAME            VARCHAR2(9999);
    V_STC_SQL_PART1          VARCHAR2(32767);
    V_STC_SQL_PART2          VARCHAR2(32767);
    V_QUERY_FINAL            VARCHAR2(32767);
    V_DYNMC_SQL_FROM_PART VARCHAR2(32767);
    V_DYNMC_SQL_CLAUSE_PART VARCHAR2(32767);
    V_PAG_END_ROW           NUMBER;
    V_COUNT_QUERY         VARCHAR2(9999);
    V_ORGID               NUMBER(38);
    V_TEMP_SORTBY            VARCHAR2(9999);
    V_TEMP_ORDRBY              VARCHAR2(9999);
 
  BEGIN
    V_TEMP_ORDRBY := '';

 
  IF IP_SORTBY    = 'FACILITYID' THEN
    V_TEMP_SORTBY := 'UPPER(TRIM(FACILITYID))';
  ELSIF IP_SORTBY = 'STATE' THEN
   V_TEMP_SORTBY := 'UPPER(TRIM(STATE))';
  ELSIF IP_SORTBY = 'CITY' THEN
    V_TEMP_SORTBY := 'UPPER(TRIM(CITY))';
  ELSE
    V_TEMP_SORTBY := 'FACILITYNAME';
  END IF;

    V_STC_SQL_PART1 :=
    'select DISTINCT FAC.FACILITYID,
	FAC.FACILITYNAME,
	pkg_encrypt.fn_decrypt(CON.ADDRESS1) ADDRESS1,
	pkg_encrypt.fn_decrypt(CON.ADDRESS2) ADDRESS2,
	pkg_encrypt.fn_decrypt(CON.ADDRESS3) ADDRESS3,
	CON.CITY,
	ST.STATENAME STATE,
	CN.COUNTRYNAME COUNTRY
	FROM TBL_FACILITIES FAC
	LEFT JOIN TBL_CONTACT CON
	ON FAC.CONTACTID = CON.CONTACTID
	LEFT JOIN TBL_COUNTRIES CN
	ON CON.COUNTRYCD = CN.COUNTRYCD
  LEFT JOIN TBL_STATES ST
	ON CON.STATE = ST.STATECD 
  ';

V_DYNMC_SQL_FROM_PART :='';
V_DYNMC_SQL_CLAUSE_PART := ' WHERE FAC.ISACTIVE = ''Y''  AND FAC.Isdepartment=''N''';

--Country as input Mandatory field
    IF IP_COUNTRYCD              IS NOT NULL THEN
      V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND CN.COUNTRYCD = ''' || IP_COUNTRYCD ||''' ';
    END IF;
    
--State as input
    IF IP_STATECD IS NOT NULL THEN
    V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND LOWER(ST.STATECD) LIKE LOWER(''%' || IP_STATECD || '%'')';
    END IF;
    
--City as input    
    IF IP_CITY IS NOT NULL THEN
    V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND LOWER(CON.CITY) LIKE LOWER(''%' || IP_CITY || '%'')';
    END IF;
    
--Facilityname as input   
         IF IP_FACNAME              IS NOT NULL THEN
         V_IP_FACNAME := TRIM(Replace(IP_FACNAME,'''','''''')) ;
         V_IP_FACNAME := TRIM(Replace(V_IP_FACNAME,'\','\\')) ;
        V_IP_FACNAME := TRIM(Replace(V_IP_FACNAME,'%','\%')) ;
        V_IP_FACNAME := TRIM(Replace(V_IP_FACNAME,'_','\_')) ;
    V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND LOWER(FAC.FACILITYNAME) LIKE LOWER(''%' || V_IP_FACNAME || '%'') ESCAPE ''\''';
   END IF;

--Department type as input    
        IF IP_DEPTYPEID IS NOT NULL AND IP_DEPTYPEID.COUNT > 0 THEN
          FOR i IN IP_DEPTYPEID.FIRST..IP_DEPTYPEID.LAST LOOP
              IF V_DEP_LIST IS NOT NULL THEN
                 V_DEP_LIST := V_DEP_LIST || ',' || IP_DEPTYPEID(i);
              ELSE
                 V_DEP_LIST := IP_DEPTYPEID(i);
              END IF;
          END LOOP;
            V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FAC.FACILITYID IN(SELECT f.Facilityfordept FROM TBL_FACILITIES f WHERE f.departmenttypeid IN (' || V_DEP_LIST || '))';
    END IF;


--Therapeutic Area as input    
            IF IP_THERAAREA IS NOT NULL AND IP_THERAAREA.COUNT > 0 THEN
          FOR i IN IP_THERAAREA.FIRST..IP_THERAAREA.LAST LOOP
              IF V_THERA_LIST IS NOT NULL THEN
                 V_THERA_LIST := V_THERA_LIST || ',' || IP_THERAAREA(i);
              ELSE
                 V_THERA_LIST := IP_THERAAREA(i);
              END IF;
          END LOOP;
     V_DYNMC_SQL_FROM_PART := V_DYNMC_SQL_FROM_PART || '   LEFT JOIN TBL_THERAPETICAREAFACILITYMAP TMAP
                                        ON FAC.FACILITYID = TMAP.FACILITYID ' ;   
            V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || '  AND TMAP.THERAPEUTICAREAID  IN(' || V_THERA_LIST || ')';
    END IF;


--Sub-Therapeutic Area as input   
             IF IP_SUBTHERAREA IS NOT NULL AND IP_SUBTHERAREA.COUNT > 0 THEN
          FOR i IN IP_SUBTHERAREA.FIRST..IP_SUBTHERAREA.LAST LOOP
              IF V_SUBTHERA_LIST IS NOT NULL THEN
                 V_SUBTHERA_LIST := V_SUBTHERA_LIST || ',' || IP_SUBTHERAREA(i);
              ELSE
                 V_SUBTHERA_LIST := IP_SUBTHERAREA(i);
              END IF;
          END LOOP;
            V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || '  AND TMAP.SUBTHERAPEUTICAREAID  IN(' || V_SUBTHERA_LIST || ')';
    END IF;


--Phase Capabilities as input    
            IF IP_FACPHID IS NOT NULL AND IP_FACPHID.COUNT > 0 THEN
          FOR i IN IP_FACPHID.FIRST..IP_FACPHID.LAST LOOP
              IF V_PHASE_LIST IS NOT NULL THEN
                 V_PHASE_LIST := V_PHASE_LIST || ',' || IP_FACPHID(i);
              ELSE
                 V_PHASE_LIST := IP_FACPHID(i);
              END IF;
          END LOOP;
     V_DYNMC_SQL_FROM_PART := V_DYNMC_SQL_FROM_PART || '       LEFT JOIN TBL_FACILITYPHASES PH
                                       ON FAC.FACILITYID=PH.FACILITYID ' ; 
            V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || '  AND PH.PHASEID  IN(' || V_PHASE_LIST || ')';
    END IF;
    

--Sponsor type as input     
    IF IP_ISINDUSTRY = 'Y' OR  IP_ISINVESTIGATORINITIATED = 'Y' OR IP_ISACADEMIC = 'Y' OR  IP_ISGOVERNMENT = 'Y' OR IP_ISOTHERSPONSORTYPES = 'Y' THEN
      dbms_output.put_line ('stype');
      V_DYNMC_SQL_FROM_PART := V_DYNMC_SQL_FROM_PART || '         LEFT JOIN TBL_FACILITYSPONSORTYPES FACSP
                                         ON FAC.FACILITYID = FACSP.FACILITYID ' ;

          IF IP_ISINDUSTRY = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACSP.ISINDUSTRY = ''Y'' '  ;
          END IF ;
          IF IP_ISINVESTIGATORINITIATED = 'Y' THEN
                dbms_output.put_line ('ISINVESTIGATORINITIATED');
          V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACSP.ISINVESTIGATORINITIATED = ''Y'' '  ;
          END IF ;
          IF IP_ISACADEMIC = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACSP.ISACADEMIC = ''Y'' '  ;
          END IF ;   
          IF IP_ISGOVERNMENT = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACSP.ISGOVERNMENT = ''Y'' '  ;
          END IF ;
          IF IP_ISOTHERSPONSORTYPES = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACSP.ISOTHERSPONSORTYPES = ''Y'' '  ;
          END IF ;             
    END IF;
 

--Access to Patient Population - Facility Demography 
     IF IP_ISPEDIATRIC = 'Y' OR  IP_ISADULT = 'Y' OR IP_ISGERIATRIC = 'Y' THEN
        V_DYNMC_SQL_FROM_PART := V_DYNMC_SQL_FROM_PART || '         LEFT JOIN TBL_FACILITYDEMOGRAPHY FACDEMO
                                         ON FAC.FACILITYID = FACDEMO.FACILITYID ' ;
                                         
        IF IP_ISPEDIATRIC = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACDEMO.ISPEDIATRIC = ''Y'' '  ;
          END IF ;
          IF IP_ISADULT = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACDEMO.ISADULT = ''Y'' '  ;
          END IF ;
          IF IP_ISGERIATRIC = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACDEMO.ISGERIATRIC = ''Y'' '  ;
          END IF ;                                          
     END IF;



--Access to Patient Population - Ethinicity Percentage      
          IF IP_ISHISPANIC = 'Y' OR  IP_ISAMERICAN = 'Y' OR IP_ISASIAN = 'Y' OR  IP_ISBLACK = 'Y' OR IP_ISNATIVE = 'Y' OR IP_ISCAUCASIAN = 'Y' THEN
    
      V_DYNMC_SQL_FROM_PART := V_DYNMC_SQL_FROM_PART || '         LEFT JOIN TBL_ETHNICITYPERCENTAGE FACPERC
                                         ON FAC.FACILITYID = FACPERC.FACILITYID ' ;
         V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACPERC.PERCENTAGEOFPOPULATION = 1   AND FACPERC.ETHNICITYNAME IN ( ';
                                           
        IF IP_ISHISPANIC = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' ''Hispanic or Latino''  ,'  ;
          ELSE 
          V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' '''' , ' ;
          END IF ;
        IF IP_ISAMERICAN = 'Y' THEN
                dbms_output.put_line ('ISAMERICAN');
          V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' ''American Indian or Alaska Native''  ,'  ;
          ELSE 
          V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' '''' , ' ;
          END IF ;      
          IF IP_ISASIAN = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' ''Asian''  ,'  ;
          ELSE 
          V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' '''' , ' ;
          END IF ;
          IF IP_ISBLACK = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' ''Black or African American''  ,'  ;
          ELSE 
          V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' '''' , ' ;
          END IF ; 
          IF IP_ISNATIVE = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' ''Native Hawaiian or Other Pacific Islander''  ,'  ;
          ELSE 
          V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' '''' , ' ;
          END IF ;
        IF IP_ISCAUCASIAN = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' ''Caucasian'' '  ;
          ELSE 
          V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' '''' ' ;
          END IF ; 
          V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' ) ' ;
     END IF;
  
     
--SOP/Policy/Procedure      
          IF ISWRITTENSOP = 'Y' OR  IP_ISMINORASSENTPEDIATRIC = 'Y' OR IP_ISOTHERVULNERABLE = 'Y' OR IP_ISSHORTFORM = 'Y' THEN
        V_DYNMC_SQL_FROM_PART := V_DYNMC_SQL_FROM_PART || '         LEFT JOIN TBL_CONANDTRGDETLS FACCONDETLS
                                         ON FAC.FACILITYID = FACCONDETLS.FACILITYID ' ;
                                         
        IF ISWRITTENSOP = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACCONDETLS.ISWRITTENSOP = ''Y'' '  ;
          END IF ;
          IF IP_ISMINORASSENTPEDIATRIC = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACCONDETLS.ISMINORASSENTPEDIATRIC = ''Y'' '  ;
          END IF ;
          IF IP_ISOTHERVULNERABLE = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACCONDETLS.ISOTHERVULNERABLE = ''Y'' '  ;
          END IF ;
          IF IP_ISSHORTFORM = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACCONDETLS.ISSHORTFORM = ''Y'' '  ;
          END IF ;
                                         
          END IF;


--Average days FPFV
            IF IP_AVGDAYS IS NOT NULL AND IP_AVGDAYS.COUNT > 0 THEN
          FOR i IN IP_AVGDAYS.FIRST..IP_AVGDAYS.LAST LOOP
              IF V_AVGDAYS_LIST IS NOT NULL THEN
                 V_AVGDAYS_LIST := V_AVGDAYS_LIST || ',' || IP_AVGDAYS(i);
              ELSE
                 V_AVGDAYS_LIST := IP_AVGDAYS(i);
              END IF;
          END LOOP;
     V_DYNMC_SQL_FROM_PART := V_DYNMC_SQL_FROM_PART ||  '         LEFT JOIN TBL_IRBGENERAL IRBGEN
                                         ON FAC.FACILITYID = IRBGEN.FACILITYID ' ;   
            V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || '  AND IRBGEN.AVGSTARTTIME  IN(' || V_AVGDAYS_LIST || ')';
    END IF;


--IRB/ERB/ETHICS COMMITTEE    
            IF IP_HASLOCAL = 'Y' OR  IP_HASCENTRALASLOCAL = 'Y' OR IP_HASSPONSORCENTRAL = 'Y' THEN
     V_DYNMC_SQL_FROM_PART := V_DYNMC_SQL_FROM_PART ||  '         LEFT JOIN TBL_IRBGENERAL IRBGENHAS
                                         ON FAC.FACILITYID = IRBGENHAS.FACILITYID ' ;                                        
         IF IP_HASLOCAL = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND IRBGENHAS.HASLOCAL = ''Y'' '  ;
          END IF ;
          IF IP_HASCENTRALASLOCAL = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND IRBGENHAS.HASCENTRALASLOCAL = ''Y'' '  ;
          END IF ;
          IF IP_HASSPONSORCENTRAL = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND IRBGENHAS.HASSPONSORCENTRAL = ''Y'' '  ;
          END IF ;                                          
     END IF;
     
-- Facility Equipment and Capabilities Part 1    
               IF IP_CENTRIFUGE = 'Y' OR  IP_REFCENTRIFUGESAMPLES = 'Y' OR IP_ISMEDICALEMERGENCIES = 'Y' OR IP_OPENWEEKEND = 'Y' OR IP_ADMITRESEARCHSUBJECTS = 'Y' OR  IP_STUDYMATERIAL = 'Y' OR IP_PKPDCAPABILITY = 'Y' OR IP_ISPGXSAMPLEALLOWED = 'Y' OR  IP_ISENGKNOWLEDGE = 'Y' OR IP_ISTRANSSUPPORT = 'Y' OR IP_DEDICATEDCOMPUTER = 'Y' THEN
        V_DYNMC_SQL_FROM_PART := V_DYNMC_SQL_FROM_PART || '         LEFT JOIN TBL_EQUIPMENT FACEQUIP
                                         ON FAC.FACILITYID = FACEQUIP.FACILITYID ' ;
                                         
        IF IP_CENTRIFUGE = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACEQUIP.CENTRIFUGE = ''Y'' '  ;
          END IF ;
          IF IP_REFCENTRIFUGESAMPLES = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACEQUIP.REFCENTRIFUGESAMPLES = ''Y'' '  ;
          END IF ;
          IF IP_ISMEDICALEMERGENCIES = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACEQUIP.ISMEDICALEMERGENCIES = ''Y'' '  ;
          END IF ;
          IF IP_OPENWEEKEND = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACEQUIP.OPENWEEKEND = ''Y'' '  ;
          END IF ;
        IF IP_ADMITRESEARCHSUBJECTS = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACEQUIP.ADMITRESEARCHSUBJECTS = ''Y'' '  ;
          END IF ;
          IF IP_STUDYMATERIAL = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACEQUIP.STUDYMATERIAL = ''Y'' '  ;
          END IF ;
          IF IP_PKPDCAPABILITY = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACEQUIP.PKPDCAPABILITY = ''Y'' '  ;
          END IF ;
          IF IP_ISPGXSAMPLEALLOWED = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACEQUIP.ISPGXSAMPLEALLOWED = ''Y'' '  ;
          END IF ;
          IF IP_ISENGKNOWLEDGE = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACEQUIP.ISENGKNOWLEDGE = ''Y'' '  ;
          END IF ;
          IF IP_ISTRANSSUPPORT = 'Y' THEN
               V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACEQUIP.ISTRANSSUPPORT = ''Y'' '  ;
          END IF ;
          IF IP_DEDICATEDCOMPUTER = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACEQUIP.DEDICATEDCOMPUTER = ''Y'' '  ;
          END IF ;
                                                                                  
          END IF;

-- Facility Equipment and Capabilities Part 2
        IF IP_CT = 'Y' OR  IP_DXA = 'Y' OR IP_ECG = 'Y' OR IP_FLRO = 'Y' OR IP_MRI = 'Y' OR  IP_MRA = 'Y' OR IP_MRS = 'Y' OR IP_MAMMO = 'Y' OR  IP_NMED = 'Y' OR IP_PET = 'Y' OR IP_XRAY = 'Y' THEN
        V_DYNMC_SQL_FROM_PART := V_DYNMC_SQL_FROM_PART || '         LEFT JOIN TBL_DIGITALDIAGNOSTIC FACDIAG
                                         ON FAC.FACILITYID = FACDIAG.FACILITYID ' ;
                                         
        IF IP_CT = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACDIAG.CT = ''Y'' '  ;
          END IF ;
          IF IP_DXA = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACDIAG.DXA = ''Y'' '  ;
          END IF ;
          IF IP_ECG = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACDIAG.ECG = ''Y'' '  ;
          END IF ;
          IF IP_FLRO = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACDIAG.FLRO = ''Y'' '  ;
          END IF ;
        IF IP_MRI = 'Y' THEN
               V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACDIAG.MRI = ''Y'' '  ;
          END IF ;
          IF IP_MRA = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACDIAG.MRA = ''Y'' '  ;
          END IF ;
          IF IP_MRS = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACDIAG.MRS = ''Y'' '  ;
          END IF ;
          IF IP_MAMMO = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACDIAG.MAMMO = ''Y'' '  ;
          END IF ;
          IF IP_NMED = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACDIAG.NMED = ''Y'' '  ;
          END IF ;
          IF IP_PET = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACDIAG.PET = ''Y'' '  ;
          END IF ;
          IF IP_XRAY = 'Y' THEN
               V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACDIAG.XRAY = ''Y'' '  ;
          END IF ;
                                                                                  
          END IF;

--Investigational product/controlled substances          
        IF IP_ISRADIOLABLDIPCAPABLE = 'Y' OR  IP_ISINFUSIONCAPABLE = 'Y' OR IP_ISREGLICPRESENT = 'Y' OR IP_ISDESTRYIPCPBLCTRLDSUBS = 'Y' OR IP_ISIPSTORAGESECURED = 'Y' OR IP_ISDESTROYIPCAPABLE = 'Y' THEN
        V_DYNMC_SQL_FROM_PART := V_DYNMC_SQL_FROM_PART || '         LEFT JOIN TBL_FACIPDETAILS FACIP
                                         ON FAC.FACILITYID = FACIP.FACILITYID ' ;
                                         
        IF IP_ISRADIOLABLDIPCAPABLE = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACIP.ISRADIOLABLDIPCAPABLE = ''Y'' '  ;
          END IF ;
          IF IP_ISINFUSIONCAPABLE = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACIP.ISINFUSIONCAPABLE = ''Y'' '  ;
          END IF ;
          IF IP_ISREGLICPRESENT = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACIP.ISREGULATORYLICENCEPRESENT = ''Y'' '  ;
          END IF ;
          IF IP_ISDESTRYIPCPBLCTRLDSUBS = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACIP.ISDESTROYIPCAPABLECONTRLDSUBS = ''Y'' '  ;
          END IF ;
          IF IP_ISIPSTORAGESECURED = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACIP.ISIPSTORAGESECURED = ''Y'' '  ;
          END IF ;
          IF IP_ISDESTROYIPCAPABLE = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACIP.ISDESTROYIPCAPABLE = ''Y'' '  ;
          END IF ;   
          
          END IF;
          
          
--On-site capabilities
        IF IP_SECURERECORDSTORAGE = 'Y' OR  IP_ONSITEARCHIVING = 'Y' THEN
                 V_DYNMC_SQL_FROM_PART := V_DYNMC_SQL_FROM_PART || '         LEFT JOIN TBL_SOURCEDOCUMENTATION FACSRC
                                         ON FAC.FACILITYID = FACSRC.FACILITYID ' ;                              
         IF IP_SECURERECORDSTORAGE = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACSRC.SECURERECORDSTORAGE = ''Y'' '  ;
          END IF ;
          IF IP_ONSITEARCHIVING = 'Y' THEN
                V_DYNMC_SQL_CLAUSE_PART := V_DYNMC_SQL_CLAUSE_PART || ' AND FACSRC.ONSITEARCHIVING = ''Y'' '  ;
          END IF ;
                                        
     END IF;
     
    V_TEMP_ORDRBY := ' ORDER BY ' || V_TEMP_SORTBY || ' ' || IP_ORDRBY;
    
    V_QUERY_FINAL := V_STC_SQL_PART1 || V_DYNMC_SQL_FROM_PART || V_DYNMC_SQL_CLAUSE_PART || V_TEMP_ORDRBY;

    V_COUNT_QUERY := 'select count(1) from (' || V_QUERY_FINAL || ')';

--    DBMS_OUTPUT.put_line(V_COUNT_QUERY);

    EXECUTE IMMEDIATE V_COUNT_QUERY INTO IP_COUNT;
    V_PAG_END_ROW           := IP_OFFSET + IP_LIMIT;

    V_STC_SQL_PART2          := 'SELECT * FROM (SELECT ROWNUM RNUM , TEMP.* FROM (' || V_QUERY_FINAL  || ' ) TEMP  WHERE ROWNUM < ' || TO_CHAR(V_PAG_END_ROW) || ' ) WHERE RNUM >='|| TO_CHAR(IP_OFFSET)|| ' ' || V_TEMP_ORDRBY;

 OPEN FACSRCH FOR V_STC_SQL_PART2 ;

END SP_SPNSR_FAC_SEARCH;


---------------------------------------------------------------------------------------------------------------------------------

PROCEDURE SP_SPNSR_PULLCV_USR_SEARCH(
      IP_ORGID          IN TBL_ORGANIZATION.ORGID%TYPE,
      IP_FIRSTNAME      IN TBL_USERPROFILES.FIRSTNAME%TYPE,
      IP_LASTNAME       IN TBL_USERPROFILES.LASTNAME%TYPE,
      IP_EMAIL          IN TBL_CONTACT.EMAIL%TYPE,
      IP_COUNTRYCD      IN TBL_CONTACT.COUNTRYCD%TYPE,
      IP_STATECD        IN TBL_CONTACT.STATE%TYPE,
      IP_CITY           IN TBL_CONTACT.CITY%TYPE,
      IP_ROLENAME       IN TBL_ROLES.ROLENAME%TYPE,
      IP_ACTSTARTDATE   IN DATE,
      IP_ACTENDDATE     IN DATE,
      IP_STUDYIDS       IN NUM_ARRAY,
      IP_PROGRAMIDS     IN NUM_ARRAY,
      IP_SPECIALTYIDS   IN NUM_ARRAY,
      IP_STUDYTYPEIDS   IN NUM_ARRAY,
      IP_PHASEIDS       IN NUM_ARRAY,
      IP_THERAPETICID   IN NUMBER,
      IP_SUBTHERAIDS    IN NUM_ARRAY,
      IP_NOOFCOMPLSTUDY IN NUMBER,
      IP_NOOFONGNTUDY   IN NUMBER,
      IP_INST_PROF      IN TBL_PROFEXPERIENCESIP.INSTITUTION%TYPE,
      IP_INST_EDU       IN TBL_USEREDUCATIONSIP.INSTITUTION%TYPE,
      IP_GCPTRAINING    IN VARCHAR2,
      IP_CV_GENERATED   IN VARCHAR2,
      IP_FACILITY_NAME  IN TBL_FACILITIES.FACILITYNAME%TYPE,
      IP_DEPT_TYPE      IN NUM_ARRAY, 
      IP_CVSTARTDATE    IN DATE,
      IP_CVENDDATE      IN DATE,
      IP_OFFSET         IN NUMBER,
      IP_LIMIT          IN NUMBER,
      IP_ORDRBY         IN VARCHAR2,
      IP_SORTBY         IN VARCHAR2,
      
      OP_COUNT OUT NUMBER,
      OP_USRSRCH OUT SYS_REFCURSOR)
      
  AS
    V_DYNMC_WHERE_CLAUSE    VARCHAR2(32767);
    V_GCPTRAINING_CLAUSE    VARCHAR2(32767):='';
    V_Y                     VARCHAR2(1):='Y';
    V_N                     VARCHAR2(1):='N';
    V_YES                   VARCHAR2(3) :='Yes';
    V_NO                    VARCHAR2(3):='No';
    V_ORDER                 VARCHAR2(32767);
    V_SITE                  VARCHAR2(10):='Site';
  V_INVESTIGATOR          VARCHAR2(20):='Investigator';
  V_USERPROFILEDELEGATE   VARCHAR2(50):='User Profile Delegate';
  V_PLATFORM              VARCHAR2(50):='Platform';
    V_PLATFORMSITE          VARCHAR2(50):='Platform and StudySite';
    V_STUDY_ID_LIST         VARCHAR2(32767);
    V_STUDYTYPES_ID_LIST    VARCHAR2(32767);
    V_PHASE_ID_LIST         VARCHAR2(32767);
    V_SUBTHER_ID_LIST       VARCHAR2(32767);
    V_PROGRAM_ID_LIST       VARCHAR2(32767);
    V_SPECIALTY_ID_LIST     VARCHAR2(32767);
    V_DEPTTYPE_ID_LIST      VARCHAR2(32767);
    V_SQL_QUERY             VARCHAR2(32767);
    V_SELECT_CAUSE1         VARCHAR2(32767);
    V_SELECT_CLAUSE2       VARCHAR2(32767);
    V_SELECT_FIRSTCV        VARCHAR2(32767);
    V_SELECT_LASTCV         VARCHAR2(32767);
    V_WHERE_ISCVGENERATED   VARCHAR2(32767):='';
    V_COUNT_QUERY           VARCHAR2(32767);
    V_FINAL_QUERY           VARCHAR2(32767);
    V_COUNT_QUERY_START     VARCHAR2(32767);
    V_QUERY_START           VARCHAR2(32767);
    V_QUERY_END             VARCHAR2(32767);
    V_ENDINDEX              NUMBER;
    V_STARTINDEX            NUMBER;
    V_FAC_JOIN              VARCHAR2(32767);
    V_PROFEXP_JOIN          VARCHAR2(32767);
    V_RESEARCHEXPTRIAL_JOIN VARCHAR2(32767);
    V_RESEARCHEXPPHASE_JOIN VARCHAR2(32767);
    V_CURRNTTHERUSER_JOIN   VARCHAR2(32767);
    V_TOTALTHERUSER_JOIN    VARCHAR2(32767);
    V_USEREDUTHERA_JOIN     VARCHAR2(32767);
    V_USERROLEMAP_STUDY_JOIN VARCHAR2(32767);
  

  BEGIN
    V_STARTINDEX := IP_OFFSET;
    V_ENDINDEX := IP_LIMIT + IP_OFFSET-1;  
  
    V_COUNT_QUERY_START := 'SELECT count(1) FROM ( ';
    V_QUERY_START := 'SELECT * FROM (SELECT ROWNUM RNUM , TEMP.* FROM ( ';

    IF IP_GCPTRAINING = 'Y' THEN
      V_GCPTRAINING_CLAUSE :=' JOIN TBL_TRNGCREDITS TRNGCRED ON up.userid=TRNGCRED.USERID ';
    END IF;

   V_SELECT_CAUSE1 := 'select 
                      DISTINCT
                        (SELECT MAX(DOC1.CREATEDDT)
                        FROM TBL_DOCUMENTS DOC1
                        WHERE up.USERID   = DOC1.DOCUSERID
                        AND DOC1.DOCTYPECD=1
                        AND DOC1.ISDELETED = '''|| V_N ||'''
                        ) LASTGENERATEDCVDATE,
                           CASE WHEN (SELECT COUNT(1)
                        FROM TBL_DOCUMENTTRACKER DOCTRACKER
                        WHERE DOCTRACKER.DOWNLOADDATETIME IS NOT NULL
                        AND DOCTRACKER.ISDELETED           = '''|| V_N ||'''
                        AND DOCTRACKER.SPONSORCOMPANYNAME in (select orgname from tbl_organization where orgid='''|| IP_ORGID ||''')
                        AND DOCTRACKER.DOCUMENTID         IN
                          (SELECT DOC2.DOCUMENTID
                          FROM TBL_DOCUMENTS DOC2
                          WHERE up.USERID   = DOC2.DOCUSERID
                          AND DOC2.ISDELETED = '''|| V_N ||'''
                          )
                        ) >0 THEN '''|| V_YES ||''' ELSE '''|| V_NO ||''' END CVPULLEDHISTORY,
                      up.TRANSCELERATEUSERID,up.USERID,rol.rolename, PKG_ENCRYPT.fn_decrypt(up.FIRSTNAME) as firstname, PKG_ENCRYPT.fn_decrypt(up.LASTNAME)as lastname, PKG_ENCRYPT.fn_decrypt(up.MIDDLENAME)as Middlename,
                      PKG_ENCRYPT.fn_decrypt(con.EMAIL) as email,contr.COUNTRYCD,contr.countryname,STATE.STATECD,STATE.STATENAME
                      from tbl_userprofiles up
                      join tbl_contact con on up.CONTACTID=con.CONTACTID
                      join tbl_countries contr on con.COUNTRYCD=contr.COUNTRYCD
                      JOIN TBL_STATES STATE ON STATE.STATECD=con.STATE ';

  V_SELECT_CLAUSE2 :=' '||V_GCPTRAINING_CLAUSE||'
                    join tbl_roles rol on up.ROLEID=rol.ROLEID 
                    LEFT JOIN TBL_DOCUMENTS DOC3
                    ON up.USERID       = DOC3.DOCUSERID and DOC3.DOCTYPECD IN ('||1||')
                    where up.ISACTIVE='''|| V_Y ||''' and up.ISSPONSOR='''|| V_N ||'''
                    '; 

  IF IP_CV_GENERATED = 'Y' THEN
    V_WHERE_ISCVGENERATED :='  where LASTGENERATEDCVDATE IS NOT NULL ';
  END IF;
  
    IF IP_CV_GENERATED = 'N' THEN
    V_WHERE_ISCVGENERATED :='  where LASTGENERATEDCVDATE IS NULL ';
  END IF;


  V_SELECT_FIRSTCV :='select LASTGENERATEDCVDATE,CVPULLEDHISTORY,TRANSCELERATEUSERID,USERID,rolename,firstname, lastname,middlename, email ,COUNTRYCD,countryname,STATECD,STATENAME FROM  (';
  V_SELECT_LASTCV :=' ) dual';




  V_DYNMC_WHERE_CLAUSE   := '';
  IF IP_FIRSTNAME           IS NOT NULL THEN 
    V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND LOWER(PKG_ENCRYPT.fn_decrypt(up.FIRSTNAME)) LIKE LOWER(''%' || (TRIM(Replace(IP_FIRSTNAME,'''',''''''))) || '%'')';
  END IF;
  IF IP_LASTNAME            IS NOT NULL THEN 
    V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND LOWER(PKG_ENCRYPT.fn_decrypt(up.LASTNAME)) LIKE LOWER(''%' || (TRIM(Replace(IP_LASTNAME,'''',''''''))) || '%'')';
  END IF;
  IF IP_EMAIL            IS NOT NULL THEN 
    V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND PKG_ENCRYPT.fn_decrypt(con.EMAIL)='''|| IP_EMAIL ||'''';
  END IF;
  IF IP_ROLENAME            IS NOT NULL THEN 
    IF IP_ROLENAME=V_INVESTIGATOR THEN
    V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND LOWER(rol.ROLENAME) =  LOWER(''' || IP_ROLENAME || ''')';
    ELSE
    V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND rol.USERTYPE='''|| V_SITE ||''' AND rol.ROLELEVEL IN ('''|| V_PLATFORMSITE|| ''','''||V_PLATFORM||''') AND rol.ROLENAME NOT IN ('''|| V_INVESTIGATOR|| ''','''||V_USERPROFILEDELEGATE||''')';
    END IF;
  END IF;
  IF IP_ACTSTARTDATE      IS NOT NULL THEN
    V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND up.ACTIVATIONSTARTDT >= ' || CHR(39) || TRUNC(IP_ACTSTARTDATE) || CHR(39);
  END IF;
  IF IP_ACTENDDATE        IS NOT NULL THEN
    V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND up.ACTIVATIONSTARTDT <= ' || CHR(39) || TRUNC(IP_ACTENDDATE) || CHR(39);
  END IF;
  
  IF IP_COUNTRYCD            IS NOT NULL THEN 
    V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND LOWER(con.COUNTRYCD) LIKE LOWER(''%' || IP_COUNTRYCD || '%'')';
  END IF;
  IF IP_STATECD            IS NOT NULL THEN 
    V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND LOWER(con.STATE) LIKE LOWER(''%' || IP_STATECD || '%'')';
  END IF;
  IF IP_CITY            IS NOT NULL THEN 
    V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND LOWER(con.CITY) LIKE LOWER(''%' || IP_CITY || '%'')';
  END IF;
  
    IF IP_STUDYIDS IS NOT NULL AND IP_STUDYIDS.COUNT > 0 THEN
          FOR i IN IP_STUDYIDS.FIRST..IP_STUDYIDS.LAST LOOP
              IF V_STUDY_ID_LIST IS NOT NULL THEN
                 V_STUDY_ID_LIST := V_STUDY_ID_LIST || ',' || IP_STUDYIDS(i);
              ELSE
                 V_STUDY_ID_LIST := IP_STUDYIDS(i);
              END IF;
          END LOOP;
      V_USERROLEMAP_STUDY_JOIN := ' LEFT JOIN TBL_USERROLEMAP URM on up.userid=URM.userid ';    
      V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND URM.STUDYID  IN(' || V_STUDY_ID_LIST || ')';
    END IF;
    
   IF IP_PROGRAMIDS IS NOT NULL AND IP_PROGRAMIDS.COUNT > 0 THEN
          FOR i IN IP_PROGRAMIDS.FIRST..IP_PROGRAMIDS.LAST LOOP
              IF V_PROGRAM_ID_LIST IS NOT NULL THEN
                 V_PROGRAM_ID_LIST := V_PROGRAM_ID_LIST || ',' || IP_PROGRAMIDS(i);
              ELSE
                 V_PROGRAM_ID_LIST := IP_PROGRAMIDS(i);
              END IF;
          END LOOP;
        V_USERROLEMAP_STUDY_JOIN := ' LEFT JOIN TBL_USERROLEMAP URM on up.userid=URM.userid LEFT JOIN TBL_STUDY STUDY ON URM.STUDYID=STUDY.STUDYID';
        V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND STUDY.PROGID  IN(' || V_PROGRAM_ID_LIST || ')';
    END IF;
  
    IF IP_INST_PROF            IS NOT NULL THEN 
      V_PROFEXP_JOIN :=' LEFT JOIN TBL_PROFEXPERIENCESIP PROFEXP ON PROFEXP.USERID=up.userid ';
      V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND LOWER(PROFEXP.INSTITUTION) LIKE LOWER(''%' || (TRIM(Replace(IP_INST_PROF,'''',''''''))) || '%'')';
    END IF;
    
   IF IP_INST_EDU            IS NOT NULL THEN 
      V_USEREDUTHERA_JOIN := ' LEFT JOIN TBL_USEREDUCATIONSIP UEDUSIP ON UEDUSIP.USERID=up.userid
                               LEFT JOIN TBL_SPECIALTY SPEC ON SPEC.SPECIALTYID=UEDUSIP.SPECIALTYID';
      V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND LOWER(UEDUSIP.INSTITUTION) LIKE LOWER(''%' || (TRIM(Replace(IP_INST_EDU,'''',''''''))) || '%'')';
    END IF;
    
     IF IP_SPECIALTYIDS IS NOT NULL AND IP_SPECIALTYIDS.COUNT > 0 THEN
          FOR i IN IP_SPECIALTYIDS.FIRST..IP_SPECIALTYIDS.LAST LOOP
              IF V_SPECIALTY_ID_LIST IS NOT NULL THEN
                 V_SPECIALTY_ID_LIST := V_SPECIALTY_ID_LIST || ',' || IP_SPECIALTYIDS(i);
              ELSE
                 V_SPECIALTY_ID_LIST := IP_SPECIALTYIDS(i);
              END IF;
          END LOOP;
                  V_USEREDUTHERA_JOIN := ' LEFT JOIN TBL_USEREDUCATIONSIP UEDUSIP ON UEDUSIP.USERID=up.userid
                               LEFT JOIN TBL_SPECIALTY SPEC ON SPEC.SPECIALTYID=UEDUSIP.SPECIALTYID ';
      V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND SPEC.SPECIALTYID  IN(' || V_SPECIALTY_ID_LIST || ')';
    END IF;

    
    IF IP_STUDYTYPEIDS IS NOT NULL AND IP_STUDYTYPEIDS.COUNT > 0 THEN
          FOR i IN IP_STUDYTYPEIDS.FIRST..IP_STUDYTYPEIDS.LAST LOOP
              IF V_STUDYTYPES_ID_LIST IS NOT NULL THEN
                 V_STUDYTYPES_ID_LIST := V_STUDYTYPES_ID_LIST || ',' || IP_STUDYTYPEIDS(i);
              ELSE
                 V_STUDYTYPES_ID_LIST := IP_STUDYTYPEIDS(i);
              END IF;
          END LOOP;
    V_RESEARCHEXPTRIAL_JOIN :=' LEFT JOIN TBL_RESEARCHEXPTRIALTYPESIP STUDTYPE ON STUDTYPE.USERID=up.userid ';
      V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND STUDTYPE.SPONSORTYPEID  IN(' || V_STUDYTYPES_ID_LIST || ')';
    END IF;
    
    IF IP_PHASEIDS IS NOT NULL AND IP_PHASEIDS.COUNT > 0 THEN
          FOR i IN IP_PHASEIDS.FIRST..IP_PHASEIDS.LAST LOOP
              IF V_PHASE_ID_LIST IS NOT NULL THEN
                 V_PHASE_ID_LIST := V_PHASE_ID_LIST || ',' || IP_PHASEIDS(i);
              ELSE
                 V_PHASE_ID_LIST := IP_PHASEIDS(i);
              END IF;
          END LOOP;
    V_RESEARCHEXPPHASE_JOIN :=' LEFT JOIN TBL_RESRCHAREAOFINTCLTRPHSIP RESEARCHPHASE ON RESEARCHPHASE.USERID=up.userid';
    V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND RESEARCHPHASE.PHASEID  IN(' || V_PHASE_ID_LIST || ')';
    END IF;
    
   IF IP_SUBTHERAIDS IS NOT NULL AND IP_SUBTHERAIDS.COUNT > 0 THEN
          FOR i IN IP_SUBTHERAIDS.FIRST..IP_SUBTHERAIDS.LAST LOOP
              IF V_SUBTHER_ID_LIST IS NOT NULL THEN
                 V_SUBTHER_ID_LIST := V_SUBTHER_ID_LIST || ',' || IP_SUBTHERAIDS(i);
              ELSE
                 V_SUBTHER_ID_LIST := IP_SUBTHERAIDS(i);
              END IF;
          END LOOP;
    END IF;
    
    
    IF IP_NOOFCOMPLSTUDY IS NOT NULL OR IP_NOOFONGNTUDY IS NOT NULL THEN
        
        IF IP_THERAPETICID IS NOT NULL AND IP_THERAPETICID !=0 THEN
           V_TOTALTHERUSER_JOIN :=' LEFT JOIN TBL_TOTALCLINICALRESRCHEXPSIP TOTARESE ON TOTARESE.USERID=up.userid';
           V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND TOTARESE.THERAPEUTICAREAID = '||IP_THERAPETICID;
        END IF;
        
        IF IP_NOOFCOMPLSTUDY IS NOT NULL AND IP_NOOFCOMPLSTUDY !=0 THEN
           V_TOTALTHERUSER_JOIN :=' LEFT JOIN TBL_TOTALCLINICALRESRCHEXPSIP TOTARESE ON TOTARESE.USERID=up.userid';
           V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND TOTARESE.NUMCOMPLETEDTRIALS >= '||IP_NOOFCOMPLSTUDY;
        END IF;
        
        IF IP_NOOFONGNTUDY IS NOT NULL AND IP_NOOFONGNTUDY !=0 THEN
           V_TOTALTHERUSER_JOIN :=' LEFT JOIN TBL_TOTALCLINICALRESRCHEXPSIP TOTARESE ON TOTARESE.USERID=up.userid';
           V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND TOTARESE.NUMONGOINGTRIALS >= '||IP_NOOFONGNTUDY;
        END IF;
        
        IF V_SUBTHER_ID_LIST        IS NOT NULL THEN
           V_TOTALTHERUSER_JOIN :=' LEFT JOIN TBL_TOTALCLINICALRESRCHEXPSIP TOTARESE ON TOTARESE.USERID=up.userid';
           V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND TOTARESE.SUBTHERAPEUTICAREAID  IN(' || V_SUBTHER_ID_LIST || ')';
        END IF;
        
    ELSE 
        IF IP_THERAPETICID IS NOT NULL AND IP_THERAPETICID !=0 THEN
           V_CURRNTTHERUSER_JOIN :=' LEFT JOIN TBL_CURRENTTHERAUSERMAPSIP CURTHERA ON CURTHERA.USERID=up.userid';
           V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND CURTHERA.THERAPEUTICAREAID = '||IP_THERAPETICID;
        END IF;
    
        IF V_SUBTHER_ID_LIST IS NOT NULL THEN
           V_CURRNTTHERUSER_JOIN :=' LEFT JOIN TBL_CURRENTTHERAUSERMAPSIP CURTHERA ON CURTHERA.USERID=up.userid';
           V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND CURTHERA.SUBTHERAPEUTICAREAID IN(' || V_SUBTHER_ID_LIST || ')';
        END IF;
        
    END IF;
    
    IF IP_FACILITY_NAME            IS NOT NULL THEN 
       V_FAC_JOIN := ' LEFT JOIN TBL_IRFACILITYUSERMAP IFUMP ON IFUMP.USERID=up.userid
                       LEFT JOIN TBL_FACILITIES FAC ON FAC.FACILITYID=IFUMP.FACILITYID';
       V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND LOWER(FAC.FACILITYNAME) LIKE LOWER(''%' || (TRIM(Replace(IP_FACILITY_NAME,'''',''''''))) || '%'')';
    END IF;
   
    IF IP_DEPT_TYPE IS NOT NULL AND IP_DEPT_TYPE.COUNT > 0 THEN
          FOR i IN IP_DEPT_TYPE.FIRST..IP_DEPT_TYPE.LAST LOOP
              IF V_DEPTTYPE_ID_LIST IS NOT NULL THEN
                 V_DEPTTYPE_ID_LIST := V_DEPTTYPE_ID_LIST || ',' || IP_DEPT_TYPE(i);
              ELSE
                 V_DEPTTYPE_ID_LIST := IP_DEPT_TYPE(i);
              END IF;
          END LOOP;
    V_FAC_JOIN := ' LEFT JOIN TBL_IRFACILITYUSERMAP IFUMP ON IFUMP.USERID=up.userid
                       LEFT JOIN TBL_FACILITIES FAC ON FAC.FACILITYID=IFUMP.FACILITYID';
      V_DYNMC_WHERE_CLAUSE := V_DYNMC_WHERE_CLAUSE || ' AND FAC.DEPARTMENTTYPEID  IN(' || V_DEPTTYPE_ID_LIST || ')';
    END IF;
    
  V_SQL_QUERY :=  V_SELECT_CAUSE1 || V_USERROLEMAP_STUDY_JOIN || V_PROFEXP_JOIN || V_RESEARCHEXPTRIAL_JOIN || V_RESEARCHEXPPHASE_JOIN || V_CURRNTTHERUSER_JOIN ||
                  V_TOTALTHERUSER_JOIN || V_USEREDUTHERA_JOIN || V_FAC_JOIN || V_SELECT_CLAUSE2;
  V_FINAL_QUERY := V_SQL_QUERY || V_DYNMC_WHERE_CLAUSE; 
   
    IF IP_CV_GENERATED  IS NOT NULL OR IP_CVSTARTDATE IS NOT NULL OR IP_CVENDDATE IS NOT NULL THEN 
       V_FINAL_QUERY :=V_SELECT_FIRSTCV ||  V_SQL_QUERY || V_DYNMC_WHERE_CLAUSE || V_SELECT_LASTCV;
       V_FINAL_QUERY :=V_FINAL_QUERY || V_WHERE_ISCVGENERATED;
       IF IP_CVSTARTDATE      IS NOT NULL AND IP_CV_GENERATED = 'Y' THEN
          V_FINAL_QUERY := V_FINAL_QUERY || ' AND LASTGENERATEDCVDATE >= ' || CHR(39) || TRUNC(IP_CVSTARTDATE) || CHR(39);
       ELSIF  IP_CVSTARTDATE      IS NOT NULL  THEN
          V_FINAL_QUERY := V_FINAL_QUERY || ' WHERE LASTGENERATEDCVDATE >= ' || CHR(39) || TRUNC(IP_CVSTARTDATE) || CHR(39);
       END IF; 
       IF IP_CVENDDATE      IS NOT NULL AND (IP_CVSTARTDATE IS NOT NULL OR IP_CV_GENERATED = 'Y') THEN
          V_FINAL_QUERY := V_FINAL_QUERY || ' AND LASTGENERATEDCVDATE <= ' || CHR(39) || TRUNC(IP_CVENDDATE) || CHR(39);
       ELSIF  IP_CVENDDATE      IS NOT NULL  THEN
           V_FINAL_QUERY := V_FINAL_QUERY || ' WHERE LASTGENERATEDCVDATE <= ' || CHR(39) || TRUNC(IP_CVENDDATE) || CHR(39);
       END IF;
     END IF;


 IF IP_SORTBY = 'LASTNAME' THEN
    V_ORDER := 'UPPER(TRIM(LASTNAME))';
  ELSIF IP_SORTBY = 'FIRSTNAME' THEN
    V_ORDER     := 'UPPER(TRIM(FIRSTNAME))';
  ELSIF IP_SORTBY = 'COUNTRYNAME' THEN
    V_ORDER     := 'UPPER(TRIM(COUNTRYNAME))';
  ELSIF IP_SORTBY = 'STATENAME' THEN
    V_ORDER     := 'UPPER(TRIM(STATENAME))';
  ELSIF IP_SORTBY = 'LASTGENERATEDCVDATE' THEN
    V_ORDER     := 'LASTGENERATEDCVDATE';
  ELSIF IP_SORTBY = 'CVPULLEDHISTORY' THEN
    V_ORDER     := 'UPPER(TRIM(CVPULLEDHISTORY))';
  ELSE
    V_ORDER := 'LASTGENERATEDCVDATE';
  END IF;
  
  IF V_ORDER = 'LASTGENERATEDCVDATE' AND IP_ORDRBY='ASC' THEN
        V_FINAL_QUERY := V_FINAL_QUERY || ' ORDER BY (CASE WHEN LASTGENERATEDCVDATE IS NULL THEN 1 ELSE 0 END) ASC, 
                     LASTGENERATEDCVDATE ASC';
  ELSIF V_ORDER = 'LASTGENERATEDCVDATE' AND IP_ORDRBY='DESC' THEN
      V_FINAL_QUERY := V_FINAL_QUERY || ' ORDER BY (CASE WHEN LASTGENERATEDCVDATE IS NULL THEN 0 ELSE 1 END) DESC, 
                     LASTGENERATEDCVDATE DESC';
  ELSIF IP_SORTBY IS NOT NULL THEN
    V_FINAL_QUERY   := V_FINAL_QUERY || ' ORDER BY ' || TO_CHAR(V_ORDER);
  ELSE
    V_FINAL_QUERY := V_FINAL_QUERY || ' ORDER BY ' || TO_CHAR(V_ORDER);
  END IF;

  IF IP_ORDRBY IS NOT NULL AND V_ORDER != 'LASTGENERATEDCVDATE' THEN
    V_FINAL_QUERY := V_FINAL_QUERY || ' ' || IP_ORDRBY;
  ELSIF V_ORDER != 'LASTGENERATEDCVDATE' THEN
     V_FINAL_QUERY := V_FINAL_QUERY || ' DESC ';
  END IF;


  V_QUERY_END := ') TEMP WHERE ROWNUM <= ' || TO_CHAR(V_ENDINDEX) ||' ) WHERE RNUM >= '|| TO_CHAR(V_STARTINDEX);
  V_COUNT_QUERY       := 'SELECT COUNT(*) FROM (' || V_FINAL_QUERY || ')';
  V_FINAL_QUERY :=V_QUERY_START ||  V_FINAL_QUERY || V_QUERY_END;


 DBMS_OUTPUT.PUT_LINE(V_FINAL_QUERY);
 EXECUTE IMMEDIATE V_COUNT_QUERY INTO OP_COUNT;
  OPEN OP_USRSRCH FOR V_FINAL_QUERY ;
 DBMS_OUTPUT.PUT_LINE(OP_COUNT);
 
  END SP_SPNSR_PULLCV_USR_SEARCH;
procedure sp_src_usr_studysite(IP_LOGGEDINUSERID IN NUMBER,
                                                   IP_FIRSTNAME      IN VARCHAR2,
                                                   IP_LASTNAME       IN VARCHAR2,
                                                   IP_EMAIL          IN VARCHAR2,
                                                   IP_PHONE          IN NUMBER,
                                                   IP_STATEID        IN NUMBER,
                                                   IP_COUNTRY        IN NUMBER,
                                                   IP_CITY           IN VARCHAR2,
                                                   IP_POSTALCD       IN VARCHAR2,
                                                   IP_STUDYID        IN NUMBER,
                                                   IP_SITEID         IN NUMBER,
                                                   IP_STUDYSIDEROLE  IN NUM_ARRAY,
                                                   IP_TRANSCELERATEID IN VARCHAR2,
                                                   IP_OFFSET         IN NUMBER,
                                                   IP_LIMIT          IN NUMBER,
                                                   IP_ORDRBY         IN VARCHAR2,
                                                   IP_SORTBY         IN VARCHAR2,
                                                   OP_COUNT          OUT NUMBER,
                                                   OP_CURSOR         OUT SYS_REFCURSOR) AS

  V_USERNAME      number;
  V_STUDY_COUNT   NUMBER;
  V_SELECT_CLAUSE VARCHAR2(32767);
  V_AND_CLAUSE    VARCHAR2(32767);
  V_FINAL_SQL     VARCHAR2(32767);
  V_SQL           VARCHAR2(32767);
  V_FINAL_COUNT   VARCHAR2(32767);
  V_PAG_END_ROW   NUMBER;
  V_SQL_PAGINATION_PART VARCHAR2(32767);
  V_STUDYSITEROLE_STR   VARCHAR2(32767);
  V_ORDER               VARCHAR2(32767);
  V_SORT                VARCHAR2(32767);
  V_ISSPONSOR           VARCHAR2(1);
  V_ORGID               VARCHAR2(100);

  TYPE TYP_STUDY IS TABLE OF NUMBER;
  V_STUDY_STR TYP_STUDY;

  V_STUDY VARCHAR2(32767);

  TYPE TYP_SITE IS TABLE OF NUMBER;
  V_SITE_STR TYP_SITE;

  V_SITE  VARCHAR2(32767);
  v_count number;

BEGIN

V_SELECT_CLAUSE := 'select distinct tu.userid,
                tcuser.contactid,
                pkg_encrypt.fn_decrypt(tcuser.email) email,
                pkg_encrypt.fn_decrypt(tcuser.phone1) phone,
                pkg_encrypt.fn_decrypt(tu.firstname) Firstname,
                pkg_encrypt.fn_decrypt(tu.lastname) lastname,
                tu.transcelerateuserid||''@securepass.exostartest.com'' transcelerateuserid,
                tur.studyid,
                tsd.STUDYNAME,
                tur.siteid,
                ts.sitename,
                pkg_encrypt.fn_decrypt(tconsitefac.address1) address,
                tconsitefac.CITY city,
                tconsitefac.STATE state,
                tsta.STATEID STATEID,
                tsta.STATENAME STATENAME,
                pkg_encrypt.fn_decrypt(tconsitefac.POSTALCODE) postalcode,
                tconsitefac.COUNTRYCD countrycd,
                tcoun.COUNTRYNAME countryname,
                tcoun.COUNTRYID COUNTRYID
  FROM tbl_userprofiles tu,
       tbl_userrolemap  tur,
       tbl_contact      tcuser,
       tbl_study        tsd,
       tbl_site         ts,
       tbl_facilities   tsfac,
       tbl_contact      tconsitefac,
       tbl_states       tsta,
       TBL_COUNTRIES    tcoun
   where tu.userid = tur.userid
   and tu.contactid=tcuser.contactid
   and tur.studyid = tsd.studyid
   and tur.siteid = ts.siteid
   and tsfac.facilityid=ts.PRINCIPALFACILITYID
   and tconsitefac.contactid = tsfac.CONTACTID
   and tcoun.COUNTRYCD = tconsitefac.COUNTRYCD
   and tsta.statecd = tconsitefac.state
   and (tur.effectiveenddate is null or tur.effectiveenddate > sysdate)
   AND tu.issponsor=''N'''
   ;

 IF IP_SORTBY = 'TRANSCELERATEUSERID' THEN
    V_ORDER := 'UPPER(TRIM(TRANSCELERATEUSERID))';
  ELSIF IP_SORTBY = 'LASTNAME' THEN
    V_ORDER     := 'UPPER(TRIM(LASTNAME))';
  ELSIF IP_SORTBY = 'FIRSTNAME' THEN
    V_ORDER     := 'UPPER(TRIM(FIRSTNAME))';
  ELSIF IP_SORTBY = 'EMAIL' THEN
    V_ORDER     := 'UPPER(TRIM(EMAIL))';
  ELSIF IP_SORTBY = 'SITENAME' THEN
    V_ORDER     := 'UPPER(SITENAME)';
  ELSIF IP_SORTBY = 'ADDRESS' THEN
    V_ORDER     := 'UPPER(TRIM(ADDRESS))';
   ELSIF IP_SORTBY = 'CITY' THEN
    V_ORDER     := 'UPPER(TRIM(CITY))';
  ELSIF IP_SORTBY = 'STATENAME' THEN
    V_ORDER     := 'UPPER(STATENAME)';
  ELSIF IP_SORTBY = 'COUNTRYNAME' THEN
    V_ORDER     := 'UPPER(TRIM(COUNTRYNAME))';
  ELSIF IP_SORTBY = 'PHONE' THEN
    V_ORDER     := 'UPPER(TRIM(PHONE))';
  ELSE
    V_ORDER := 'TRANSCELERATEUSERID';
  END IF;


if  IP_LOGGEDINUSERID is not null then
  select distinct a.studyid bulk collect
    into V_STUDY_STR
    from tbl_userrolemap a
   where a.userid = IP_LOGGEDINUSERID
     and a.studyid is not null;


  -- and a.studyid is not null; ;

  if V_STUDY_STR.count is not null then

    for I in 1 .. V_STUDY_STR.COUNT loop
      EXIT WHEN V_STUDY_STR(I) is null;
      IF I = 1 THEN
        V_STUDY := V_STUDY_STR(I);
      ELSE
        V_STUDY := V_STUDY || ',' || V_STUDY_STR(I);
      END IF;

    END LOOP;
    --  V_AND_CLAUSE := ' AND tur.studyid IN ( ' || V_STUDY || ')';

  END IF;

  select count(distinct a.siteid)
    into v_count
    from tbl_userrolemap a
   where a.userid = IP_LOGGEDINUSERID
     and to_char(a.studyid) in (V_STUDY);

  if V_STUDY is not null and v_count > 0 then
    select distinct a.siteid bulk collect
      into V_SITE_STR
      from tbl_userrolemap a
     where a.userid = IP_LOGGEDINUSERID
       and a.studyid in (V_STUDY)
       and a.siteid is not null;

    if V_SITE_STR.count is not null then

      for I in 1 .. V_SITE_STR.COUNT loop
        EXIT WHEN V_SITE_STR(I) is null;
        IF I = 1 THEN
          V_SITE := V_SITE_STR(I);
        ELSE
          V_SITE := V_SITE || ',' || V_SITE_STR(I);
        END IF;

      END LOOP;
      V_AND_CLAUSE := ' AND ts.siteid IN ( ' || V_SITE || ')';
    end if;
    end if;
      end if;
   /* if IP_LOGGEDINUSERID is null then
      V_AND_CLAUSE :=V_AND_CLAUSE||' and 1=1 ';
      end if;*/


    if IP_FIRSTNAME is not null then
     V_AND_CLAUSE := V_AND_CLAUSE|| ' AND LOWER(pkg_encrypt.fn_decrypt(tu.firstname))  LIKE LOWER(''%' || TO_CHAR(IP_FIRSTNAME) || '%'' )';
     end if;


    if IP_LASTNAME is not null then
     V_AND_CLAUSE :=V_AND_CLAUSE|| ' AND LOWER(pkg_encrypt.fn_decrypt(tu.lastname))  LIKE LOWER(''%' || TO_CHAR(IP_LASTNAME) || '%'' )';
     end if;

    if IP_EMAIL is not null then
       V_AND_CLAUSE :=V_AND_CLAUSE|| ' AND LOWER(pkg_encrypt.fn_decrypt(tcuser.email)) LIKE LOWER(''%' || TO_CHAR(IP_EMAIL) || '%'' )';
     end if;

     if IP_STATEID is not null then
         V_AND_CLAUSE :=V_AND_CLAUSE|| ' AND tsta.STATEID = ''' ||IP_STATEID||'''';
     end if;

     if IP_COUNTRY is not null then
        V_AND_CLAUSE :=V_AND_CLAUSE|| ' AND tcoun.COUNTRYID = ''' ||IP_COUNTRY||'''';
    end if;

    IF IP_CITY IS NOT NULL THEN
      V_AND_CLAUSE :=V_AND_CLAUSE|| ' AND tconsitefac.CITY ='''||UPPER(IP_CITY)||'''';
      END IF;

        IF IP_POSTALCD IS NOT NULL THEN
      V_AND_CLAUSE :=V_AND_CLAUSE|| ' AND pkg_encrypt.fn_decrypt(tconsitefac.postalcode) ='''||IP_POSTALCD||'''';
      END IF;

        IF IP_STUDYID IS NOT NULL THEN
      V_AND_CLAUSE :=V_AND_CLAUSE|| ' AND tsd.STUDYID ='''||IP_STUDYID||'''';
      END IF;

       IF IP_SITEID IS NOT NULL THEN
      V_AND_CLAUSE :=V_AND_CLAUSE|| ' AND ts.SITEID ='''||IP_SITEID||'''';
      END IF;

      IF IP_PHONE IS NOT NULL THEN
      V_AND_CLAUSE :=V_AND_CLAUSE|| ' AND lower(pkg_encrypt.fn_decrypt(tcuser.phone1))  LIKE LOWER(''%' || TO_CHAR(IP_PHONE) || '%'' )';

      END IF;

        IF IP_TRANSCELERATEID IS NOT NULL THEN
      V_AND_CLAUSE :=V_AND_CLAUSE|| ' AND lower(TRANSCELERATEUSERID) like lower( ''%'|| IP_TRANSCELERATEID||'%'')';

      END IF;

      IF IP_STUDYSIDEROLE IS NOT NULL AND IP_STUDYSIDEROLE.COUNT>0 THEN --V_STUDYSITEROLE_STR
        FOR I IN 1 .. IP_STUDYSIDEROLE.COUNT LOOP
          IF I=1 THEN
            V_STUDYSITEROLE_STR:=IP_STUDYSIDEROLE(I) ;
            ELSE
            V_STUDYSITEROLE_STR:=V_STUDYSITEROLE_STR||','||IP_STUDYSIDEROLE(I);
            END IF;
            END LOOP;
        END IF;
        IF  V_STUDYSITEROLE_STR IS NOT NULL  THEN
        V_AND_CLAUSE :=V_AND_CLAUSE|| ' AND tur.ROLEID IN ('||V_STUDYSITEROLE_STR||')';
        END IF;

      SELECT ISSPONSOR INTO V_ISSPONSOR FROM TBL_USERPROFILES WHERE USERID=IP_LOGGEDINUSERID;


      IF IP_LOGGEDINUSERID IS NOT NULL AND V_ISSPONSOR='Y' AND V_AND_CLAUSE IS NULL /*AND V_AND_CLAUSE IS NOT NULL */THEN

      SELECT  ORGID INTO V_ORGID FROM TBL_USERPROFILES WHERE USERID=IP_LOGGEDINUSERID;

V_AND_CLAUSE :=' and TSD.STUDYID in ( select a.Studyid from tbl_userrolemap a where a.studyid in (select a.studyid from tbl_study a where a.orgid in (select a.orgid from tbl_userprofiles a where a.userid='||IP_LOGGEDINUSERID||')))';
    END IF;


      IF IP_LOGGEDINUSERID IS NOT NULL AND V_ISSPONSOR='Y' AND V_AND_CLAUSE IS NOT NULL /*AND V_AND_CLAUSE IS NOT NULL */THEN

      SELECT  ORGID INTO V_ORGID FROM TBL_USERPROFILES WHERE USERID=IP_LOGGEDINUSERID;

V_AND_CLAUSE :=V_AND_CLAUSE|| ' and TSD.STUDYID in ( select a.Studyid from tbl_userrolemap a where a.studyid in (select a.studyid from tbl_study a where a.orgid in (select a.orgid from tbl_userprofiles a where a.userid='||IP_LOGGEDINUSERID||')))';
    END IF;
     --V_TEMP_ORDRBY := ' ORDER BY ' || V_TEMP_SORTBY || ' ' || IP_ORDRBY;

   -- V_QUERY_FINAL := V_STC_SQL_PART1 || V_DYNMC_SQL_FROM_PART || V_DYNMC_SQL_CLAUSE_PART || V_TEMP_ORDRBY;


    V_FINAL_SQL := V_SELECT_CLAUSE || V_AND_CLAUSE||'ORDER BY '||V_ORDER||IP_ORDRBY;



   V_FINAL_COUNT :=' select count(1) from ('||V_FINAL_SQL||')';

   -- dbms_output.put_line(V_FINAL_COUNT);

   execute immediate V_FINAL_COUNT into OP_COUNT ;

    V_PAG_END_ROW         :=IP_LIMIT+IP_OFFSET-1 ;
    if IP_LIMIT =0 then
     V_PAG_END_ROW        :=OP_COUNT;
     end if;

   V_SQL_PAGINATION_PART :=  'select b.*,rownum rnn from (select a.*,rownum rn from ( ' ||V_FINAL_SQL||' ) a ) b ';

   V_SQL_PAGINATION_PART :='select * from ('||V_SQL_PAGINATION_PART||' where rn>='||TO_CHAR(IP_OFFSET)||') where rn<='||V_PAG_END_ROW;
  dbms_output.put_line(V_SQL_PAGINATION_PART);

    --EXECUTE IMMEDIATE  V_FINAL_SQL;
    OPEN OP_CURSOR FOR V_SQL_PAGINATION_PART;

end sp_src_usr_studysite;

PROCEDURE SP_PI_SEARCH(IP_FIRSTNAME   IN VARCHAR2,
IP_LASTNAME                 IN VARCHAR2,
IP_EMAIL                    IN VARCHAR2,
IP_ROLENAME                 IN VARCHAR_ARRAY,
IP_COUNTRYID                IN NUM_ARRAY,
IP_STATE                    IN VARCHAR2, --STATECD
IP_CITY                     IN VARCHAR2,
IP_USERID                   IN NUMBER,
IP_INS_BY_PROF              IN VARCHAR2,
IP_INS_BY_EDU               IN VARCHAR2,
IP_THERAPEAUTICAREAID       IN NUM_ARRAY,
IP_TRAINING_TYPE_ID         IN NUMBER ,
IP_SPONSORTYPEID            IN NUM_ARRAY,
IP_PHASEID                  IN NUM_ARRAY,
IP_SUBTHERAPEUTICAREAID     IN NUM_ARRAY,
IP_NUMCOMPLETEDTRIALS       IN NUMBER,
IP_NUMONGOINGTRIALS         IN NUMBER,
IP_FACILITYNAME             IN VARCHAR2,
IP_DEPARTMENTTYPEID         IN VARCHAR2,
IP_THERAPEUTICAREANAME      IN NUMBER,
IP_SUBTHERAPEUTICAREANAME   IN NUMBER,
IP_PHASENAME                IN VARCHAR2,
IP_ISPEDIATRIC              IN VARCHAR2,
IP_ISGERIATRIC              IN VARCHAR2,
IP_ISADULT                  IN VARCHAR2,
IP_ETHNICITYTITLE           IN VARCHAR_ARRAY,
IP_HASLOCAL                 IN VARCHAR2,
IP_HASCENTRALASLOCAL        IN VARCHAR2,
IP_HASSPONSORCENTRAL        IN VARCHAR2,
IP_AVGSTARTTIME             IN NUM_ARRAY,
IP_ISRADIOLABLDIPCAPABLE    IN VARCHAR2,
IP_ISINFUSIONCAPABLE        IN VARCHAR2,
IP_ISREGULATORYLICENCEPRESENT IN VARCHAR2,
IP_ISGLOVEBOXVENTED           IN VARCHAR2,
IP_ISLAMINARFLOWHOOD          IN VARCHAR2,
IP_ISGLOVEBOXVENTOUT          IN VARCHAR2,
IP_CENTRIFUGE                 IN VARCHAR2,
IP_REFCENTRIFUGESAMPLES       IN VARCHAR2,
IP_ISMEDICALEMERGENCIES       IN VARCHAR2,
IP_ISREFRIGERATOR2TO8         IN VARCHAR2,
IP_ISFREEZER20TO30            IN VARCHAR2,
IP_ISFREEZER70TO80            IN VARCHAR2,
IP_ISFREEZER135               IN VARCHAR2,
IP_CT                         IN VARCHAR2,
IP_DXA                        IN VARCHAR2,
IP_ECG                        IN VARCHAR2,
IP_FLRO                       IN VARCHAR2,
IP_MRA                        IN VARCHAR2,
IP_MRI                        IN VARCHAR2,
IP_MRS                        IN VARCHAR2,
IP_MAMMO                      IN VARCHAR2,
IP_NMED                       IN VARCHAR2,
IP_PET                        IN VARCHAR2,
IP_XRAY                       IN VARCHAR2,
IP_ISMINORASSENTPEDIATRIC     IN VARCHAR2,
IP_ISOTHERVULNERABLE          IN VARCHAR2,
IP_SECURERECORDSTORAGE        IN VARCHAR2,
IP_ONSITEARCHIVING            IN VARCHAR2,
IP_ISIPSTORAGESECURED         IN VARCHAR2,
IP_OPENWEEKEND                IN VARCHAR2,
IP_ADMITRESEARCHSUBJECTS      IN VARCHAR2,
IP_STUDYMATERIAL              IN VARCHAR2,
IP_PKPDCAPABILITY             IN VARCHAR2,
IP_ISPGXSAMPLEALLOWED         IN VARCHAR2,
IP_ISENGKNOWLEDGE             IN VARCHAR2,
IP_ISTRANSSUPPORT             IN VARCHAR2,
IP_DEDICATEDCOMPUTER          IN VARCHAR2,
IP_ISINDUSTRY                 IN VARCHAR2,
IP_ISINVESTIGATORINITIATED    IN VARCHAR2,
IP_ISACADEMIC                 IN VARCHAR2,
IP_ISGOVERNMENT               IN VARCHAR2,
IP_ISOTHERSPONSORTYPES        IN VARCHAR2,
IP_ISFORUSER_FACILITY         IN VARCHAR2,
IP_RESEARCHTHERAPEUTICID      IN NUMBER,
IP_FACILITYCOUNTRYID          IN NUMBER,
IP_FACILITYSTATE              IN VARCHAR2,
IP_FACILITYCITY               IN VARCHAR2,
IP_ISEXEPREPARATION           IN VARCHAR2,
IP_ISFLOWHOOD                 IN VARCHAR2,
IP_ISINFORMCONSENT            IN VARCHAR2,
IP_ISSHORTFORM                IN VARCHAR2,
IP_ISDESTROYIPCAPABLE         IN VARCHAR2,
IP_ISDSTRYIPCPBLECONTRLDSUBS  IN VARCHAR2,
IP_getIsGcpTrainingCompleted  IN VARCHAR2,
IP_OFFSET                     IN NUMBER,
IP_LIMIT                      IN NUMBER,
IP_ORDRBY                     IN VARCHAR2,
IP_SORTBY                     IN VARCHAR2,
OP_COUNT                      OUT NUMBER,
OP_PI_RESULT                  OUT SYS_REFCURSOR)

IS
V_ROW_START               NUMBER;
V_ROW_END                 NUMBER;
V_ORDERBY_CLAUSE          VARCHAR2(32767);
V_SORTBY                  VARCHAR2(32767);
V_PAGE_SELECT_CLAUSE      VARCHAR2(32767);
V_PAGE_FROM_CLAUSE        VARCHAR2(32767);
V_PAGE_WHERE_CLAUSE       VARCHAR2(32767);
V_SELECT_CNT_CLAUSE       VARCHAR2(32767);
V_FINAL_CNT_QUERY         VARCHAR2(32767);
V_FINAL_QUERY             VARCHAR2(32767);
V_IP_ISFORUSER_FACILITY   VARCHAR2(100);
V_STR_THERAPEAUTICAREAID  VARCHAR2(32767);
V_STR_SPONSORTYPEID       VARCHAR2(32767);
V_STR_PHASEID             VARCHAR2(32767);
V_STR_SUBTHERAPEUTICAREAID VARCHAR2(32767);
V_STR_ROLENAME             VARCHAR2(32767);
V_STR_ETHNICITYTITLE       VARCHAR2(32767);
V_STR_AVGSTARTTIME         VARCHAR2(32767);
V_PAGE_AND_CLAUSE          VARCHAR2(32767);
V_STR_COUNTRYID            VARCHAR2(32767);
V_TEMP_ORDRBY              VARCHAR2(32767);
V_PAG_END_ROW              VARCHAR2(32767);
V_COUNT_QUERY              VARCHAR2(32767);
V_ORDER                    VARCHAR2(32767);
V_getIsGcpTrainingCompleted VARCHAR2(32767);


BEGIN


V_PAGE_SELECT_CLAUSE :=' SELECT/*+ PARALLEL(TTC, 8) PARALLEL(TFAC1, 8) PARALLEL(TPHASE1, 8) PARALLEL(TUTS, 16) */ DISTINCT case when PKG_ENCRYPT.FN_DECRYPT(TU.MIDDLENAME) is null then (PKG_ENCRYPT.FN_DECRYPT(TU.FIRSTNAME)||'',''||PKG_ENCRYPT.FN_DECRYPT(TU.LASTNAME)) else
                (PKG_ENCRYPT.FN_DECRYPT(TU.FIRSTNAME)||'',''||PKG_ENCRYPT.FN_DECRYPT(TU.LASTNAME)||'',''||PKG_ENCRYPT.FN_DECRYPT(TU.MIDDLENAME)) end  PINAME,
                PKG_ENCRYPT.FN_DECRYPT(TU.FIRSTNAME) FIRSTNAME,
                PKG_ENCRYPT.FN_DECRYPT(TU.LASTNAME) LASTNAME,
                (select  pkg_encrypt.fn_decrypt(tcon1.city) from tbl_contact tcon1 where tcon1.contactid=tu.contactid) PICITY,
                (select  pkg_encrypt.fn_decrypt(tcon1.address1) from tbl_contact tcon1 where tcon1.contactid=tu.contactid) PI_ADDRESS1,
                (select  pkg_encrypt.fn_decrypt(tcon1.address2) from tbl_contact tcon1 where tcon1.contactid=tu.contactid) PI_ADDRESS2,
                (select  pkg_encrypt.fn_decrypt(tcon1.address3) from tbl_contact tcon1 where tcon1.contactid=tu.contactid) PI_ADDRESS3,
                (select  st.statename from tbl_contact tcon1,tbl_states st where tcon1.contactid=tu.contactid and st.statecd=tcon1.state) PI_STATE,
                (select  pkg_encrypt.fn_decrypt(tcon1.postalcode) from tbl_contact tcon1 where tcon1.contactid=tu.contactid) PI_ZIPCODE,
                (select  tcon1.institution from tbl_contact tcon1 where tcon1.contactid=tu.contactid) PI_institution,
                PKG_ENCRYPT.FN_DECRYPT(TUSERCON.PHONE1) PHONE,
                PKG_ENCRYPT.FN_DECRYPT(TU.MIDDLENAME) MIDDLENAME,
                TFACIL.FACILITYNAME,
                TFACIL.FACILITYFORDEPT,
                case when TFACIL.Isdepartment=''Y'' then TFACIL.Departmentname else NULL end DEPARTMENTNAME,
               (select td.departmenttypename from tbl_departmenttype td where td.departmenttypeid=TFACIL.DEPARTMENTTYPEID) DEPARTMENTTYPE,
               (select PKG_ENCRYPT.FN_DECRYPT(tc.address1)
                 from  tbl_contact tc
                 where TFACIL.contactid = tc.contactid
                 ) address ,
                 (select PKG_ENCRYPT.FN_DECRYPT(tc.address2)
                 from  tbl_contact tc
                 where TFACIL.contactid = tc.contactid
                 ) address2 ,
                 (select PKG_ENCRYPT.FN_DECRYPT(tc.address3)
                 from  tbl_contact tc
                 where TFACIL.contactid = tc.contactid
                 ) address3 ,
                 (select PKG_ENCRYPT.FN_DECRYPT(tc.postalcode)
                 from  tbl_contact tc
                 where TFACIL.contactid = tc.contactid
                 ) facility_postalcode ,
                 (select tc.city
                 from  tbl_contact tc
                 where TFACIL.contactid = tc.contactid
                 ) city ,
                (select tc.state
                 from  tbl_contact tc
                 where TFACIL.contactid = tc.contactid
                 ) FACILITYSTATE ,
                 (select ts.statename from tbl_states ts where ts.statecd in ((select tc.state
                 from  tbl_contact tc
                 where TFACIL.contactid = tc.contactid
                 )) and ts.countryid = (select countryid from tbl_countries where countrycd = (select tc.countrycd
                 from  tbl_contact tc
                 where TFACIL.contactid = tc.contactid) )) STATENAME,
                (select tcoun.countryname from tbl_countries tcoun where tcoun.countrycd in (select tc.countrycd
                 from  tbl_contact tc
                 where TFACIL.contactid = tc.contactid
                 ) )FACILITYCOUNTRY,
                (select  pkg_encrypt.fn_decrypt(tcon1.email) from tbl_contact tcon1 where tcon1.contactid=tu.contactid)  EMAIL,
                tu.transcelerateuserid  SIP_USERID,
                TFACIL.Facilityid,
                TU.Userid ,
                 (select tcoun.COUNTRYCD from tbl_countries tcoun where tcoun.countrycd in (select tc.countrycd
                 from  tbl_contact tc
                 where TFACIL.contactid = tc.contactid
                 ) )FACILITYCOUNTRYCODE,
                (select  cont.countryname from tbl_contact tcon1,tbl_countries cont where tcon1.contactid=tu.contactid and cont.countrycd=tcon1.countrycd ) PI_COUNTRY ';

V_PAGE_FROM_CLAUSE:=' FROM  TBL_FACILITIES                      TFACIL,
      TBL_IRFACILITYUSERMAP               TFACUSMP,
      TBL_CONTACT                         TFACCON,
      TBL_CONTACT                         TUSERCON,
      TBL_USERPROFILES                    TU,
    --  TBL_THERAPEUTICAREA                 THERA,
      TBL_THERAPETICAREAFACILITYMAP       TPHS,
     -- TBL_SUBTHERAPEUTICAREA              SUBTHERA,
      Tbl_Phaseofint                      TPHASE1,
      TBL_PHASE                           TPHASE,
      TBL_ROLES                           TR,
      TBL_FACILITYPHASES                  TFAC1,
      TBL_FACILITYDEMOGRAPHY              TACI,
      TBL_ETHNICITYPERCENTAGE             TFTET,
      TBL_ETHNICITY                       TET,
      TBL_IRBGENERAL                      TIR,
      TBL_FACIPDETAILS                    TFAI,
      TBL_EQUIPMENT                       TEQ,
      TBL_DIGITALDIAGNOSTIC               TDI,
      TBL_CONANDTRGDETLS                  TCON1,
      TBL_SOURCEDOCUMENTATION             TSOUR,
      TBL_FACIPDETAILS                    TFAC,
      TBL_FACILITYSPONSORTYPES            TFACS,
      TBL_USEREDUCATIONSIP                TUE,
      TBL_PROFEXPERIENCESIP               TPR,
     -- tbl_trngcredits                     TUTS,
     -- tbl_trainingtype                    TUTS1,
      TBL_RESEARCHEXPTRIALTYPESIP         TR1,
      TBL_RESRCHAREAOFINTCLTRPHSIP        TROF,
      TBL_TOTALCLINICALRESRCHEXPSIP       TTC,
	  TBL_CURRENTTHERAUSERMAPSIP TCTA ';

V_PAGE_WHERE_CLAUSE:=' WHERE  TFACIL.Facilityid                            = TFACUSMP.FACILITYID
     AND TFACCON.Contactid                                  = TFACIL.Contactid
     AND TUSERCON.Contactid                                  = TU.Contactid
     AND TU.USERID                                       = TFACUSMP.Userid
     AND TU.ROLEID                                       = TR.ROLEID
     AND TFACIL.FACILITYID                               = TACI.FACILITYID(+)
     AND TFACIL.FACILITYID                               = TFTET.Facilityid(+)
     AND TFTET.ETHNICITYNAME                             = TET.ETHNICITYTITLE(+)
     AND TIR.FACILITYID(+)                               = TFACIL.FACILITYID
     AND TFAI.FACILITYID(+)                              = TFACIL.FACILITYID
     AND TEQ.FACILITYID(+)                               = TFACIL.FACILITYID
     AND TFACIL.FACILITYID                               = TDI.FACILITYID(+)
     AND TCON1.FACILITYID(+)                             = TFACIL.FACILITYID
     AND TSOUR.FACILITYID(+)                             = TFACIL.FACILITYID
     AND TFAC.FACILITYID(+)                              = TFACIL.FACILITYID
     AND TFACS.FACILITYID(+)                             = TFACIL.FACILITYID
     AND TUE.Userid(+)                                   = TU.Userid
     AND TPR.Userid(+)                                   = TU.Userid
     --AND TPR.USERID                                      = TUTS.Userid(+)
     --AND TPR.USERID                                      = TUTS.Requestedfor(+)
    -- AND TUTS1.Trainingtypename(+)                       = TUTS.Trngtype
     --AND TUTS1.User_Id                                   = TUTS.Userid
     AND TR1.USERID(+)                                   = TU.USERID
     AND TROF.USERID(+)                                  = TU.USERID
     AND TTC.Userid(+)                                   = TU.USERID
	 AND TCTA.Userid(+)                                   = TU.USERID
     AND TPHS.FACILITYID(+)                              = TFACIL.FACILITYID
/*     AND TPHS.THERAPEUTICAREAID                          = THERA.THERAPEUTICAREAID(+)
     AND THERA.THERAPEUTICAREAID                         = SUBTHERA.THERAPEUTICAREAID(+)
     AND TTC.THERAPEUTICAREAID                           = THERA.THERAPEUTICAREAID--
     AND TTC.SUBTHERAPEUTICAREAID                        = SUBTHERA.SUBTHERAPEUTICAREAID--*/
     AND TFAC1.FACILITYID(+)                             = TFACIL.FACILITYID
     AND TFAC1.PHASEID                                   = TPHASE1.PHASEOFINTID(+)
     AND TPHASE1.Phaseofintid                            = TPHASE.Phaseid(+)
     AND TU.ISSPONSOR                                    = ''N''';

 IF IP_SORTBY     = 'PINAME' THEN
    V_ORDER      := 'UPPER(PINAME)';
  ELSIF IP_SORTBY = 'LASTNAME' THEN
    V_ORDER      := 'UPPER(TRIM(LASTNAME))';
  ELSIF IP_SORTBY = 'FIRSTNAME' THEN
    V_ORDER      := 'UPPER(TRIM(FIRSTNAME))';
  ELSIF IP_SORTBY = 'MIDDLENAME' THEN
    V_ORDER      := 'UPPER(TRIM(MIDDLENAME))';
  ELSIF IP_SORTBY = 'FACILITYNAME' THEN
    V_ORDER     := 'UPPER(FACILITYNAME)';
  ELSIF IP_SORTBY = 'ADDRESS' THEN
    V_ORDER     := 'UPPER(TRIM(ADDRESS))';
   ELSIF IP_SORTBY = 'CITY' THEN
    V_ORDER     := 'UPPER(TRIM(CITY))';
  ELSIF IP_SORTBY = 'DEPARTMENTNAME' THEN
    V_ORDER     := 'UPPER(DEPARTMENTNAME)';
  ELSIF IP_SORTBY = 'DEPARTMENTTYPE' THEN
    V_ORDER     := 'UPPER(TRIM(DEPARTMENTTYPE))';
  ELSIF IP_SORTBY = 'PHONE' THEN
    V_ORDER     := 'UPPER(TRIM(PHONE))';
  ELSIF IP_SORTBY = 'FACILITYSTATE' THEN
    V_ORDER     := 'UPPER(FACILITYSTATE)';--
  ELSIF IP_SORTBY = 'FACILITYCOUNTRY' THEN
    V_ORDER     := 'UPPER(FACILITYCOUNTRY)';
  ELSE
    V_ORDER := 'UPPER(PINAME)'||','||'UPPER(FACILITYNAME)'||','||'UPPER(DEPARTMENTNAME)'||','||'UPPER(FACILITYCOUNTRY)';
  END IF;



 IF IP_FIRSTNAME IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(pkg_encrypt.fn_decrypt (TU.FIRSTNAME)) LIKE LOWER(''%' || TO_CHAR(IP_FIRSTNAME) || '%'' )';
END IF;

 IF IP_LASTNAME  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(pkg_encrypt.fn_decrypt (TU.LASTNAME)) LIKE LOWER(''%' || TO_CHAR(IP_LASTNAME) || '%'' )';
 END IF;

 IF IP_EMAIL  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(PKG_ENCRYPT.FN_DECRYPT(TUSERCON.EMAIL)) LIKE LOWER(''%' || TO_CHAR(IP_EMAIL) || '%'' )';
 END IF;

  IF IP_STATE  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND TUSERCON.STATE ='''||IP_STATE||'''';
 END IF;

 IF IP_CITY  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND UPPER(TUSERCON.CITY) ='''||UPPER(IP_CITY)||'''';
 END IF;

  IF IP_USERID  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND TU.USERID ='||IP_USERID;
 END IF;

  IF IP_INS_BY_PROF  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND UPPER(TPR.INSTITUTION)  like UPPER(''%'||IP_INS_BY_PROF||'%'')';
 END IF;

  IF IP_INS_BY_EDU  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND UPPER(TUE.INSTITUTION)  like UPPER(''%'||IP_INS_BY_EDU||'%'')';
 END IF;

 IF IP_THERAPEAUTICAREAID.COUNT <> 0 THEN
   FOR i IN 1..IP_THERAPEAUTICAREAID.COUNT LOOP
       EXIT WHEN IP_THERAPEAUTICAREAID(i) = -1;
       IF V_STR_THERAPEAUTICAREAID IS NULL THEN
          V_STR_THERAPEAUTICAREAID := IP_THERAPEAUTICAREAID(i);
       ELSE
          V_STR_THERAPEAUTICAREAID := V_STR_THERAPEAUTICAREAID || ',' || IP_THERAPEAUTICAREAID(i);
       END IF;
   END LOOP;
 END IF;

 IF V_STR_THERAPEAUTICAREAID IS NOT NULL THEN
	V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND TUE.SPECIALTYID IN ('|| V_STR_THERAPEAUTICAREAID ||')';
 END IF;
 
 IF IP_RESEARCHTHERAPEUTICID IS NOT NULL THEN
   IF (IP_NUMCOMPLETEDTRIALS IS NOT NULL OR IP_NUMONGOINGTRIALS IS NOT NULL) THEN
		V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND TTC.THERAPEUTICAREAID IN ('|| IP_RESEARCHTHERAPEUTICID ||')';
	ELSE
		V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND TCTA.THERAPEUTICAREAID IN ('|| IP_RESEARCHTHERAPEUTICID ||')';
	END IF;
 END IF;

 IF IP_TRAINING_TYPE_ID  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' TU.USERID in (SELECT TRNG.USERID FROM TBL_TRNGCREDITS TRNG WHERE TRNG.TRNGTYPE='||IP_TRAINING_TYPE_ID||')';
 END IF;

 IF IP_SPONSORTYPEID.COUNT <> 0 THEN
   FOR i IN 1..IP_SPONSORTYPEID.COUNT LOOP
       EXIT WHEN IP_SPONSORTYPEID(i) = -1;
       IF V_STR_SPONSORTYPEID IS NULL THEN
          V_STR_SPONSORTYPEID := IP_SPONSORTYPEID(i);
       ELSE
          V_STR_SPONSORTYPEID := V_STR_SPONSORTYPEID || ',' || IP_SPONSORTYPEID(i);
       END IF;
   END LOOP;
 END IF;

 IF V_STR_SPONSORTYPEID IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND TR1.SPONSORTYPEID IN ('|| V_STR_SPONSORTYPEID ||')';
 END IF;

 IF IP_PHASEID.COUNT <> 0 THEN
   FOR i IN 1..IP_PHASEID.COUNT LOOP
       EXIT WHEN IP_PHASEID(i) = -1;
       IF V_STR_PHASEID IS NULL THEN
          V_STR_PHASEID := IP_PHASEID(i);
       ELSE
          V_STR_PHASEID := V_STR_PHASEID || ',' || IP_PHASEID(i);
       END IF;
   END LOOP;
 END IF;

 IF V_STR_PHASEID IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND TROF.PHASEID IN ('|| V_STR_PHASEID ||')';
 END IF;

 IF IP_SUBTHERAPEUTICAREAID.COUNT <> 0 THEN
   FOR i IN 1..IP_SUBTHERAPEUTICAREAID.COUNT LOOP
       EXIT WHEN IP_SUBTHERAPEUTICAREAID(i) = -1;
       IF V_STR_SUBTHERAPEUTICAREAID IS NULL THEN
          V_STR_SUBTHERAPEUTICAREAID := IP_SUBTHERAPEUTICAREAID(i);
       ELSE
          V_STR_SUBTHERAPEUTICAREAID := V_STR_SUBTHERAPEUTICAREAID || ',' || IP_SUBTHERAPEUTICAREAID(i);
       END IF;
   END LOOP;
 END IF;

 IF V_STR_SUBTHERAPEUTICAREAID IS NOT NULL THEN    
	IF (IP_NUMCOMPLETEDTRIALS IS NOT NULL OR IP_NUMONGOINGTRIALS IS NOT NULL ) THEN
		V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND TTC.SUBTHERAPEUTICAREAID IN ('|| V_STR_THERAPEAUTICAREAID ||')';
	ELSE
		V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND TCTA.SUBTHERAPEUTICAREAID IN ('|| V_STR_SUBTHERAPEUTICAREAID ||')';
	END IF;
 END IF;

 IF IP_NUMCOMPLETEDTRIALS  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND TTC.NUMCOMPLETEDTRIALS >='||IP_NUMCOMPLETEDTRIALS;
 END IF;

  IF IP_NUMONGOINGTRIALS  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND TTC.NUMONGOINGTRIALS <='||IP_NUMONGOINGTRIALS ;
 END IF;

 IF IP_ROLENAME.COUNT>0 THEN
   FOR I IN 1..IP_ROLENAME.COUNT
    LOOP
      EXIT
    WHEN IP_ROLENAME(I) = '-1';
      IF I            = 1 THEN
        V_STR_ROLENAME := IP_ROLENAME(I);
      ELSE
        V_STR_ROLENAME := V_STR_ROLENAME || ',' || CHR(39) || IP_ROLENAME(I) || CHR(39);
      END IF;
    END LOOP;
  END IF;
  IF V_STR_ROLENAME IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE || ' AND TR.ROLENAME IN ('''|| V_STR_ROLENAME||''')';
  END IF;


 IF IP_COUNTRYID   IS NOT NULL AND IP_COUNTRYID.COUNT>0 THEN
   FOR i IN 1..IP_COUNTRYID.count
      LOOP
        EXIT
      WHEN IP_COUNTRYID(i) = -1;
        IF i            = 1 THEN
          V_STR_COUNTRYID := IP_COUNTRYID(i);
        ELSE
          V_STR_COUNTRYID := V_STR_COUNTRYID || ',' || IP_COUNTRYID(i);
        END IF;
      END LOOP;
    END IF;

  IF V_STR_COUNTRYID IS NOT NULL THEN
     V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE || ' AND TUSERCON.COUNTRYCD IN (SELECT a.countrycd from tbl_countries a where a.countryid=('|| V_STR_COUNTRYID ||'))';
  END IF;

 IF IP_FACILITYNAME  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TFACIL.FACILITYNAME) LIKE LOWER(''%' || Replace(IP_FACILITYNAME,'''','''''') ||'%'')';
 END IF;

  IF IP_DEPARTMENTTYPEID  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND TFACIL.DEPARTMENTTYPEID = (select departmenttypeid from TBL_DEPARTMENTTYPE where DEPARTMENTTYPENAME='''||IP_DEPARTMENTTYPEID||''')';
 END IF;
/*
 IF IP_THERAPEUTICAREANAME  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(THERA.THERAPEUTICAREANAME) LIKE LOWER(''%'||IP_THERAPEUTICAREANAME||'%'')';
 END IF;
 */
 IF IP_THERAPEUTICAREANAME  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND TPHS.THERAPEUTICAREAID IN(' || IP_THERAPEUTICAREANAME || ')';
 END IF;

  /*
    IF IP_SUBTHERAPEUTICAREANAME  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||'  AND SUBTHERA.SUBTHERAPEUTICAREAID ='||IP_SUBTHERAPEUTICAREANAME;
 END IF;*/

     IF IP_SUBTHERAPEUTICAREANAME  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||'  AND TTC.SUBTHERAPEUTICAREAID IN(SELECT SUBTHERA.SUBTHERAPEUTICAREAID FROM TBL_SUBTHERAPEUTICAREA SUBTHERA WHERE LOWER(THERA.SUBTHERAPEUTICAREANAME) LIKE LOWER(''%'||IP_SUBTHERAPEUTICAREANAME||'%''))';
 END IF;

 IF IP_PHASENAME  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||'  AND LOWER(TPHASE.PHASENAME) LIKE LOWER(''%'||IP_PHASENAME||'%'')';
 END IF;

 IF IP_FACILITYCOUNTRYID IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||  ' AND TFACCON.COUNTRYCD IN (SELECT a.countrycd from tbl_countries a where a.countryid=('|| IP_FACILITYCOUNTRYID ||'))';
 END IF;

 IF IP_FACILITYSTATE IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND TFACCON.STATE = ''' || IP_FACILITYSTATE||'''';
 END IF;

 IF IP_FACILITYCITY IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND UPPER(TFACCON.CITY) = ''' || UPPER(IP_FACILITYCITY)||'''';
 END IF;

  IF IP_ISPEDIATRIC  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER( TACI.Ispediatric) LIKE LOWER(''%'||IP_ISPEDIATRIC||'%'')' ;
 END IF;

  IF IP_ISGERIATRIC  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TACI.Isgeriatric) LIKE LOWER(''%'||IP_ISGERIATRIC||'%'')';
 END IF;

 IF IP_ISADULT  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER( TACI.Isadult) LIKE LOWER(''%'||IP_ISADULT||'%'')';
 END IF;

 IF IP_ETHNICITYTITLE.COUNT <> 0 THEN
   FOR i IN 1..IP_ETHNICITYTITLE.COUNT LOOP
       EXIT WHEN IP_ETHNICITYTITLE(i) ='-1';
       IF V_STR_ETHNICITYTITLE IS NULL THEN
          V_STR_ETHNICITYTITLE := IP_ETHNICITYTITLE(i);
       ELSE
          V_STR_ETHNICITYTITLE := V_STR_ETHNICITYTITLE ||''''|| ',' || ''''||IP_ETHNICITYTITLE(i)||'';
       END IF;
   END LOOP;
 END IF;

 IF V_STR_ETHNICITYTITLE IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND TFTET.ETHNICITYNAME IN ('''|| V_STR_ETHNICITYTITLE ||''') AND TFTET.Percentageofpopulation=1';
 END IF;

 IF IP_HASLOCAL  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER( TIR.Haslocal) LIKE LOWER (''%'||IP_HASLOCAL||'%'')';
 END IF;

 IF IP_HASCENTRALASLOCAL  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER( TIR.Hascentralaslocal) LIKE LOWER (''%'||IP_HASCENTRALASLOCAL||'%'')';
 END IF;

  IF IP_HASSPONSORCENTRAL  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER( TIR.Hassponsorcentral) LIKE LOWER (''%'||IP_HASSPONSORCENTRAL||'%'')';
 END IF;

 IF IP_AVGSTARTTIME.COUNT <> 0 THEN
   FOR i IN 1..IP_AVGSTARTTIME.COUNT LOOP
       EXIT WHEN IP_AVGSTARTTIME(i) = -1;
       IF V_STR_AVGSTARTTIME IS NULL THEN
          V_STR_AVGSTARTTIME := IP_AVGSTARTTIME(i);
       ELSE
          V_STR_AVGSTARTTIME := V_STR_AVGSTARTTIME || ',' || IP_AVGSTARTTIME(i);
       END IF;
   END LOOP;
 END IF;

 IF V_STR_AVGSTARTTIME  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND TIR.AVGSTARTTIME IN ('|| V_STR_AVGSTARTTIME ||')';
 END IF;

  IF IP_ISRADIOLABLDIPCAPABLE  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER( TFAI.Isradiolabldipcapable) LIKE LOWER (''%'||IP_ISRADIOLABLDIPCAPABLE||'%'')';
 END IF;

  IF IP_ISINFUSIONCAPABLE  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER( TFAI.Isinfusioncapable) LIKE LOWER (''%'||IP_ISINFUSIONCAPABLE||'%'')';
 END IF;

  IF IP_ISREGULATORYLICENCEPRESENT  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER( TFAI.Isregulatorylicencepresent) LIKE LOWER (''%'||IP_ISREGULATORYLICENCEPRESENT||'%'')';
 END IF;

  IF IP_ISGLOVEBOXVENTED  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER( TFAI.Isgloveboxvented) LIKE LOWER (''%'||IP_ISGLOVEBOXVENTED||'%'')';
 END IF;

  IF IP_ISLAMINARFLOWHOOD  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER( TFAI.ISLAMINARFLOWHOOD ) LIKE LOWER (''%'||IP_ISLAMINARFLOWHOOD||'%'')';
 END IF;

  IF IP_ISGLOVEBOXVENTOUT  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TFAI.ISGLOVEBOXVENTOUT ) LIKE LOWER (''%'||IP_ISGLOVEBOXVENTOUT||'%'')';
 END IF;

  IF IP_CENTRIFUGE  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND  LOWER(TEQ.Centrifuge ) LIKE LOWER (''%'||IP_CENTRIFUGE||'%'')';
 END IF;

  IF IP_REFCENTRIFUGESAMPLES  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER( TEQ.REFCENTRIFUGESAMPLES ) LIKE LOWER (''%'||IP_REFCENTRIFUGESAMPLES||'%'')';
 END IF;

  IF IP_ISMEDICALEMERGENCIES  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER( TEQ.Ismedicalemergencies ) LIKE LOWER (''%'||IP_ISMEDICALEMERGENCIES||'%'')';
 END IF;

  IF IP_ISREFRIGERATOR2TO8  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER( TEQ.ISREFRIGERATOR2TO8 ) LIKE LOWER (''%'||IP_ISREFRIGERATOR2TO8||'%'')';
 END IF;

   IF IP_ISFREEZER20TO30  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER( TEQ.ISFREEZER20TO30 ) LIKE LOWER (''%'||IP_ISFREEZER20TO30||'%'')';
 END IF;

  IF IP_ISFREEZER70TO80  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER( TEQ.ISFREEZER70TO80 ) LIKE LOWER (''%'||IP_ISFREEZER70TO80||'%'')';
 END IF;

  IF IP_ISFREEZER135  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TEQ.ISFREEZER135) LIKE LOWER (''%'||IP_ISFREEZER135||'%'')';
 END IF;

    IF IP_CT  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TDI.CT) LIKE LOWER (''%'||IP_CT||'%'')';
 END IF;

  IF IP_DXA  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TDI.DXA) LIKE LOWER (''%'||IP_DXA||'%'')';
 END IF;

  IF IP_ECG  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TDI.ECG) LIKE LOWER (''%'||IP_ECG||'%'')';
 END IF;

  IF IP_FLRO  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TDI.FLRO) LIKE LOWER (''%'||IP_FLRO||'%'')';
 END IF;

  IF IP_MRA  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TDI.MRA) LIKE LOWER (''%'||IP_MRA||'%'')';
 END IF;

    IF IP_MRI  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TDI.MRI) LIKE LOWER (''%'||IP_MRI||'%'')';
 END IF;

  IF IP_MRS  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TDI.MRS) LIKE LOWER (''%'||IP_MRS||'%'')';
 END IF;

  IF IP_MAMMO  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TDI.MAMMO) LIKE LOWER (''%'||IP_MAMMO||'%'')';
 END IF;

    IF IP_NMED  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TDI.NMED) LIKE LOWER (''%'||IP_NMED||'%'')';
 END IF;

  IF IP_PET  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TDI.PET) LIKE LOWER (''%'||IP_PET||'%'')';
 END IF;

  IF IP_XRAY  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TDI.XRAY) LIKE LOWER (''%'||IP_XRAY||'%'')';
 END IF;

   IF IP_ISMINORASSENTPEDIATRIC  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TCON1.ISMINORASSENTPEDIATRIC) LIKE LOWER (''%'||IP_ISMINORASSENTPEDIATRIC||'%'')';
 END IF;

  IF IP_ISOTHERVULNERABLE  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TCON1.ISOTHERVULNERABLE) LIKE LOWER (''%'||IP_ISOTHERVULNERABLE||'%'')';
 END IF;

    IF IP_SECURERECORDSTORAGE  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TSOUR.SECURERECORDSTORAGE) LIKE LOWER (''%'||IP_SECURERECORDSTORAGE||'%'')';
 END IF;

  IF IP_ONSITEARCHIVING  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TSOUR.ONSITEARCHIVING) LIKE LOWER (''%'||IP_ONSITEARCHIVING||'%'')';
 END IF;

  IF IP_ISIPSTORAGESECURED  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TFAC.ISIPSTORAGESECURED) LIKE LOWER (''%'||IP_ISIPSTORAGESECURED||'%'')';
 END IF;

  IF IP_OPENWEEKEND  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TEQ.OPENWEEKEND) LIKE LOWER (''%'||IP_OPENWEEKEND||'%'')';
 END IF;

  IF IP_ADMITRESEARCHSUBJECTS  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TEQ.ADMITRESEARCHSUBJECTS) LIKE LOWER (''%'||IP_ADMITRESEARCHSUBJECTS||'%'')';
 END IF;

  IF IP_STUDYMATERIAL  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TEQ.STUDYMATERIAL) LIKE LOWER (''%'||IP_STUDYMATERIAL||'%'')';
 END IF;

   IF IP_PKPDCAPABILITY  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TEQ.PKPDCAPABILITY) LIKE LOWER (''%'||IP_PKPDCAPABILITY||'%'')';
 END IF;

  IF IP_ISPGXSAMPLEALLOWED  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TEQ.ISPGXSAMPLEALLOWED) LIKE LOWER (''%'||IP_ISPGXSAMPLEALLOWED||'%'')';
 END IF;

    IF IP_ISENGKNOWLEDGE  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TEQ.ISENGKNOWLEDGE) LIKE LOWER (''%'||IP_ISENGKNOWLEDGE||'%'')';
 END IF;

  IF IP_ISTRANSSUPPORT  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TEQ.ISTRANSSUPPORT) LIKE LOWER (''%'||IP_ISTRANSSUPPORT||'%'')';
 END IF;

  IF IP_DEDICATEDCOMPUTER  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TEQ.DEDICATEDCOMPUTER) LIKE LOWER (''%'||IP_DEDICATEDCOMPUTER||'%'')';
 END IF;

  IF IP_ISINDUSTRY  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TFACS.ISINDUSTRY) LIKE LOWER (''%'||IP_ISINDUSTRY||'%'')';
 END IF;

   IF IP_ISINVESTIGATORINITIATED  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TFACS.ISINVESTIGATORINITIATED) LIKE LOWER (''%'||IP_ISINVESTIGATORINITIATED||'%'')';
 END IF;

  IF IP_ISACADEMIC  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TFACS.ISACADEMIC) LIKE LOWER (''%'||IP_ISACADEMIC||'%'')';
 END IF;

    IF IP_ISGOVERNMENT  IS NOT NULL THEN
    V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TFACS.ISGOVERNMENT) LIKE LOWER (''%'||IP_ISGOVERNMENT||'%'')';
 END IF;

  IF IP_ISOTHERSPONSORTYPES  IS NOT NULL THEN
     V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TFACS.ISOTHERSPONSORTYPES) LIKE LOWER (''%'||IP_ISOTHERSPONSORTYPES||'%'')';
  END IF;

  IF IP_ISEXEPREPARATION IS NOT NULL THEN
     V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TFACS.ISEXEPREPARATION) LIKE LOWER (''%'||IP_ISEXEPREPARATION||'%'')';
  END IF;

  IF IP_ISFLOWHOOD IS NOT NULL THEN
     V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TFACS.ISFLOWHOOD) LIKE LOWER (''%'||IP_ISFLOWHOOD||'%'')';
  END IF;

  IF IP_ISINFORMCONSENT IS NOT NULL THEN
     V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TCON1.ISWRITTENSOP) LIKE LOWER (''%'||IP_ISINFORMCONSENT||'%'')';
  END IF;

  IF IP_ISSHORTFORM IS NOT NULL THEN
     V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TCON1.ISSHORTFORM) LIKE LOWER (''%'||IP_ISSHORTFORM||'%'')';
  END IF;

  IF IP_ISDESTROYIPCAPABLE IS NOT NULL THEN
     V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TFAI.ISDESTROYIPCAPABLE) LIKE LOWER (''%'||IP_ISDESTROYIPCAPABLE||'%'')';
  END IF;

  IF IP_ISDSTRYIPCPBLECONTRLDSUBS IS NOT NULL THEN
     V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TFACS.ISDESTROYIPCAPABLECONTRLDSUBS) LIKE LOWER (''%'||IP_ISDSTRYIPCPBLECONTRLDSUBS||'%'')';
  END IF;


 IF IP_getIsGcpTrainingCompleted IS NOT NULL AND IP_getIsGcpTrainingCompleted='Y' THEN
    V_getIsGcpTrainingCompleted:='GCP';
     V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND TU.userid in ( select requestedfor from  TBL_TRNGCREDITS where COMPLETIONDT is not null and TRNG_STATUS_ID=(select tt.trngstatusid from tbl_trngstatus tt where tt.trngstatus=''COMPLETED'') and TRNGTYPE= '''||V_getIsGcpTrainingCompleted||''' and REJECTIONID is null)';
  END IF;

/*  IF IP_ETHNICITYNAME IS NOT NULL THEN
     V_PAGE_AND_CLAUSE := V_PAGE_AND_CLAUSE ||' AND LOWER(TFTET.ETHNICITYNAME) LIKE LOWER (''%'||IP_ETHNICITYNAME||'%'') AND TFTET.Percentageofpopulation=1';
  END IF;*/

  V_TEMP_ORDRBY := ' ORDER BY ' || IP_SORTBY ;

  IF IP_SORTBY IS NULL  THEN
     V_TEMP_ORDRBY := V_TEMP_ORDRBY||'1';

   END IF;

  V_FINAL_QUERY := V_PAGE_SELECT_CLAUSE  || V_PAGE_FROM_CLAUSE||V_PAGE_WHERE_CLAUSE ||V_PAGE_AND_CLAUSE||' ORDER BY '||V_ORDER||' '||IP_ORDRBY;

  --insert into PI_SEARCH_TEMP values (PI_SEARCH_SEQ_TEMP.nextval, V_FINAL_QUERY);
  --commit;

  V_COUNT_QUERY := 'select count(1) from (' || V_FINAL_QUERY || ')';
   --dbms_output.put_line(V_COUNT_QUERY);
  -- execute immediate 'truncate table temp_table';
  -- insert into temp_table values(V_COUNT_QUERY);
   --commit;
    EXECUTE IMMEDIATE V_COUNT_QUERY INTO OP_COUNT;
    V_PAG_END_ROW           := IP_OFFSET + IP_LIMIT;

    V_FINAL_QUERY           := 'SELECT * FROM (SELECT ROWNUM RNUM , TEMP.* FROM (' || V_FINAL_QUERY  || ' ) TEMP  WHERE ROWNUM < ' || TO_CHAR(V_PAG_END_ROW) || ' ) WHERE RNUM >='|| TO_CHAR(IP_OFFSET);
   --dbms_output.put_line(V_FINAL_QUERY);


 OPEN OP_PI_RESULT FOR V_FINAL_QUERY ;

 END SP_PI_SEARCH;
 
PROCEDURE SP_USER_DETAILS_SEARCH( IP_TRANSCELERATEID  IN VARCHAR2,
                                                    IP_OFFSET           IN NUMBER,
                                                    IP_LIMIT            IN NUMBER,
                                                    IP_COUNT            OUT NUMBER,
                                                    OP_USERDETAILS OUT SYS_REFCURSOR)

                                                   AS
V_SELECT_CLAUSE        VARCHAR2(32000);
V_FROM_CLAUSE          VARCHAR2(32000);
V_WHERE_CLAUSE         VARCHAR2(32000);
V_AND_CLAUSE           VARCHAR2(32000);
V_FINAL_SQL            VARCHAR2(32000);
V_COUNT_QUERY          VARCHAR2(32000);
V_PAG_END_ROW          NUMBER;
BEGIN

V_SELECT_CLAUSE:='SELECT DISTINCT TU.TRANSCELERATEUSERID,
                PKG_ENCRYPT.FN_DECRYPT(TC.PHONE1) PHONE,
                PKG_ENCRYPT.FN_DECRYPT(TC.EMAIL) EMAIL,
                TR.ROLENAME,
                 (SELECT distinct RTRIM(XMLAGG(XMLELEMENT(e, thera.specialtyname|| '';''))
                                       .EXTRACT(''//text()''),
                                       '';'')
                   from TBL_USEREDUCATIONSIP TUSP1,TBL_SPECIALTY THERA
                  WHERE TUSP1.Userid=TU.Userid
                  AND THERA.SPECIALTYID=TUSP1.SPECIALTYID) EDUCATION_SPECIALITY,
                nvl2((select spon.SPONSORTYPENAME from TBL_SPONSORTYPE spon, TBL_RESEARCHEXPTRIALTYPESIP  TRES where  TRES.SPONSORTYPEID  = SPON.SPONSORTYPEID AND TRES.USERID = TU.USERID  and spon.SPONSORTYPENAME=''Academic''),''Y'',''N'') ACADEMIC,
                nvl2((select spon.SPONSORTYPENAME from TBL_SPONSORTYPE  spon, TBL_RESEARCHEXPTRIALTYPESIP  TRES where  TRES.SPONSORTYPEID  = SPON.SPONSORTYPEID   AND TRES.USERID = TU.USERID AND  spon.SPONSORTYPENAME=''Industry''),''Y'',''N'') Industry,
                nvl2((select spon.SPONSORTYPENAME from TBL_SPONSORTYPE spon, TBL_RESEARCHEXPTRIALTYPESIP  TRES where  TRES.SPONSORTYPEID  = SPON.SPONSORTYPEID  AND TRES.USERID = TU.USERID and spon.SPONSORTYPENAME=''Investigator Initiated''),''Y'',''N'') "Investigator Initiated",
                nvl2((select spon.SPONSORTYPENAME from TBL_SPONSORTYPE spon, TBL_RESEARCHEXPTRIALTYPESIP  TRES where  TRES.SPONSORTYPEID  = SPON.SPONSORTYPEID  AND TRES.USERID = TU.USERID and spon.SPONSORTYPENAME=''Government''),''Y'',''N'') Government,
                (select TRES.Other from TBL_SPONSORTYPE spon, TBL_RESEARCHEXPTRIALTYPESIP  TRES where  TRES.SPONSORTYPEID  = SPON.SPONSORTYPEID  AND TRES.USERID = TU.USERID and spon.SPONSORTYPENAME=''Other'') Other,
                nvl2((select spon.PHASEID from TBL_RESRCHAREAOFINTCLTRPHSIP  spon where  TU.USERID  = SPON.Userid(+) and spon.PHASEID=1),''Y'',''N'') "PHASETYPE I",
                nvl2((select spon.PHASEID from TBL_RESRCHAREAOFINTCLTRPHSIP  spon where  TU.USERID = SPON.Userid(+) and spon.PHASEID=2),''Y'',''N'') "PHASETYPE II",
                nvl2((select spon.PHASEID from TBL_RESRCHAREAOFINTCLTRPHSIP  spon where  TU.USERID = SPON.Userid(+) and spon.PHASEID=3),''Y'',''N'') "PHASETYPE III",
                nvl2((select spon.PHASEID from TBL_RESRCHAREAOFINTCLTRPHSIP  spon where  TU.USERID = SPON.Userid(+) and spon.PHASEID=4),''Y'',''N'') "PHASETYPE IV",
                 (SELECT distinct RTRIM(XMLAGG(XMLELEMENT(e, THERA.Therapeuticareaname || '';''))
                                       .EXTRACT(''//text()''),
                                       '';'')
                   from TBL_TOTALCLINICALRESRCHEXPSIP TOTALRCH,TBL_THERAPEUTICAREA THERA
                   WHERE TOTALRCH.USERID=TU.USERID
                   AND THERA.Therapeuticareaid=TOTALRCH.THERAPEUTICAREAID

                    ) "Therapeutic Area",

                (SELECT distinct RTRIM(XMLAGG(XMLELEMENT(e, SUBTHERA.Subtherapeuticareaname || '';''))
                                       .EXTRACT(''//text()''),
                                       '';'')
                   from TBL_TOTALCLINICALRESRCHEXPSIP TOTALRCH,TBL_SUBTHERAPEUTICAREA SUBTHERA
                   WHERE TOTALRCH.USERID=TU.USERID
                   AND SUBTHERA.Subtherapeuticareaid=TOTALRCH.Subtherapeuticareaid) "sUBTherapeutic Area",
                  (select  sum(TOTALRCH1.Numcompletedtrials) from TBL_TOTALCLINICALRESRCHEXPSIP TOTALRCH1 WHERE TOTALRCH1.Userid=TU.Userid ) Numcompletedtrials,
                  (select sum(TOTALRCH1.Numongoingtrials) from TBL_TOTALCLINICALRESRCHEXPSIP TOTALRCH1 WHERE TOTALRCH1.Userid=TU.Userid) Numongoingtrials,
                (CASE
                  WHEN TU.USERID IN
                        (select requestedfor
                          from TBL_TRNGCREDITS
                         where COMPLETIONDT is not null
                           and TRNGTYPE = ''GCP''
                           and REJECTIONID is null) THEN
                   ''Y''
                  ELSE
                   ''N''
                END) "GCP STATUS", 
                TIRLSC.ISACTIVE  "Medical License On-File in SIP"';

V_FROM_CLAUSE :=' FROM TBL_USERPROFILES             TU,
                       TBL_CONTACT                  TC,
                       TBL_ROLES                    TR,
                       TBL_USEREDUCATIONSIP         TUSP,
                     --  TBL_THERAPEUTICAREA          THERA,
                       TBL_SPONSORTYPE              TSPON,
                       TBL_TOTALCLINICALRESRCHEXPSIP   TOTALRCH,
                       TBL_DOCUMENTS                TDOC,
                       TBL_IRUSERLICENSEDOCUMENTMAP TIRLSC  ';

  V_WHERE_CLAUSE :='  WHERE TU.CONTACTID               = TC.CONTACTID
                         AND TU.ROLEID               = TR.ROLEID
                         AND TU.USERID               = TUSP.USERID(+)
                        -- AND TUSP.THERAPEAUTICAREAID = THERA.THERAPEUTICAREAID(+)

                         AND TDOC.DOCUSERID(+)       = TU.USERID
                         AND TDOC.DOCUMENTID         = TIRLSC.DOCID(+)';

   IF IP_TRANSCELERATEID IS NOT NULL THEN
     V_WHERE_CLAUSE:=V_WHERE_CLAUSE||' AND LOWER(TU.TRANSCELERATEUSERID) LIKE LOWER(''%' || IP_TRANSCELERATEID || '%'') order by "Medical License On-File in SIP" ';

   END IF;

 V_FINAL_SQL:=V_SELECT_CLAUSE||V_FROM_CLAUSE||V_WHERE_CLAUSE;
 V_COUNT_QUERY:='SELECT COUNT(*) FROM ('|| V_FINAL_SQL||')';

 --DBMS_OUTPUT.put_line(V_COUNT_QUERY);

  --INSERT INTO TEMP_TABLE VALUES(null,V_COUNT_QUERY);
  --COMMIT;

  EXECUTE IMMEDIATE V_COUNT_QUERY INTO IP_COUNT;
    V_PAG_END_ROW           := IP_OFFSET + IP_LIMIT;

    V_FINAL_SQL          := 'SELECT * FROM (SELECT ROWNUM RNUM , TEMP.* FROM (' || V_FINAL_SQL  || ' ) TEMP  WHERE ROWNUM < ' || TO_CHAR(V_PAG_END_ROW) || ' ) WHERE RNUM >='|| TO_CHAR(IP_OFFSET);

--INSERT INTO TEMP_TABLE VALUES(null,V_FINAL_SQL);
  --COMMIT;
  --DBMS_OUTPUT.put_line(V_FINAL_SQL);

  OPEN OP_USERDETAILS FOR V_FINAL_SQL ;

 END sp_user_details_search;


PROCEDURE SP_FAC_DETAILS_SEARCH( IP_TRANSCELERATEID  IN VARCHAR2,
                                                    IP_FACILITYID       IN NUMBER,
                                                    IP_OFFSET           IN NUMBER,
                                                    IP_LIMIT            IN NUMBER,
                                                    IP_COUNT            OUT NUMBER,
                                                    OP_FACIDETAILS OUT SYS_REFCURSOR)

                                                   AS
V_SELECT_CLAUSE        VARCHAR2(32000);
V_FROM_CLAUSE          VARCHAR2(32000);
V_WHERE_CLAUSE         VARCHAR2(32000);
V_AND_CLAUSE           VARCHAR2(32000);
V_FINAL_SQL            VARCHAR2(32000);
V_COUNT_QUERY          VARCHAR2(32000);
V_PAG_END_ROW          NUMBER;
BEGIN

V_SELECT_CLAUSE:='SELECT  distinct   (SELECT  listagg(THERAPEUTICAREANAME,'';'') WITHIN GROUP(ORDER BY THERAPEUTICAREANAME)
                                     FROM
                                     (
                                     SELECT distinct THERA1.THERAPEUTICAREANAME,THERA.Facilityid
                                     FROM TBL_THERAPEUTICAREA THERA1,TBL_THERAPETICAREAFACILITYMAP THERA
                                     WHERE THERA1.THERAPEUTICAREAID = THERA.Therapeuticareaid
                                     ) WHERE Facilityid =tfacil.facilityid) "TherapeuticArea",
                  tu.transcelerateuserid,
                (SELECT distinct RTRIM(XMLAGG(XMLELEMENT(e, SUBTHERA.SUBTHERAPEUTICAREANAME || '';''))
                                       .EXTRACT(''//text()''),
                                       '';'')
                   from TBL_SUBTHERAPEUTICAREA SUBTHERA,TBL_THERAPETICAREAFACILITYMAP  THERA
                  WHERE thera.therapeuticareaid=SUBTHERA.Therapeuticareaid
                 and SUBTHERA.SUBTHERAPEUTICAREAID = THERA.SUBTHERAPEUTICAREAID
                 and THERA.Facilityid=tfacil.facilityid) "sUBTherapeuticArea",
                 nvl2((select  TPHASE.PHASETYPE from TBL_FACILITYPHASES TFACPH, TBL_PHASE TPHASE where TFACPH.FACILITYID=tfacil.facilityid and
                 TFACPH.Phaseid=TPHASE.PHASEID
                 and  TPHASE.PHASETYPE=''I'' ),''Y'',''N'') PHASE1,

                  nvl2((select  TPHASE.PHASETYPE from TBL_FACILITYPHASES TFACPH, TBL_PHASE TPHASE where TFACPH.FACILITYID=tfacil.facilityid and
                 TFACPH.Phaseid=TPHASE.PHASEID
                 and  TPHASE.PHASETYPE=''II'' ),''Y'',''N'') PHASE2,

                  nvl2((select  TPHASE.PHASETYPE from TBL_FACILITYPHASES TFACPH, TBL_PHASE TPHASE where TFACPH.FACILITYID=tfacil.facilityid and
                 TFACPH.Phaseid=TPHASE.PHASEID
                 and  TPHASE.PHASETYPE=''III'' ),''Y'',''N'') PHASE3,

                 nvl2((select  TPHASE.PHASETYPE from TBL_FACILITYPHASES TFACPH, TBL_PHASE TPHASE where TFACPH.FACILITYID=tfacil.facilityid and
                 TFACPH.Phaseid=TPHASE.PHASEID
                 and  TPHASE.PHASETYPE=''IV'' ),''Y'',''N'') PHASE4,
                TSPONSOR.ISINDUSTRY,
                TSPONSOR.ISINVESTIGATORINITIATED,
                TSPONSOR.ISACADEMIC,
                TSPONSOR.ISGOVERNMENT,
                TSPONSOR.OTHERSPONSORTYPE,
                TDEMO.ISPEDIATRIC,
                TDEMO.ISADULT,
                TDEMO.ISGERIATRIC,
                   nvl2((select ETHAN.Ethnicityname from TBL_ETHNICITYPERCENTAGE ETHAN where ETHAN.Facilityid= TFACIL.FACILITYID and ETHAN.Percentageofpopulation<>''999'' and ETHAN.ETHNICITYNAME=''Hispanic or Latino''),''Y'',''N'') ISHISPANIC,
                 nvl2((select ETHAN.Ethnicityname from TBL_ETHNICITYPERCENTAGE ETHAN where ETHAN.Facilityid= TFACIL.FACILITYID and ETHAN.Percentageofpopulation<>''999'' and ETHAN.ETHNICITYNAME=''American Indian or Alaska Native''),''Y'',''N'') AMERICAN_INDIAN_ALASKA,
                 nvl2((select ETHAN.Ethnicityname from TBL_ETHNICITYPERCENTAGE ETHAN where ETHAN.Facilityid= TFACIL.FACILITYID and ETHAN.Percentageofpopulation<>''999'' and ETHAN.ETHNICITYNAME=''Black or African American''),''Y'',''N'') BLACK_AFRICAN_AMERICAN,
                 nvl2((select ETHAN.Ethnicityname from TBL_ETHNICITYPERCENTAGE ETHAN where ETHAN.Facilityid= TFACIL.FACILITYID and ETHAN.Percentageofpopulation<>''999'' and ETHAN.ETHNICITYNAME=''Native Hawaiian or Other Pacific Islander''),''Y'',''N'') HAWAI_OTHER,
                 nvl2((select ETHAN.Ethnicityname from TBL_ETHNICITYPERCENTAGE ETHAN where ETHAN.Facilityid= TFACIL.FACILITYID and ETHAN.Percentageofpopulation<>''999'' and ETHAN.ETHNICITYNAME=''Caucasian''),''Y'',''N'') CAUCASIAN,
                 nvl2((select ETHAN.Ethnicityname from TBL_ETHNICITYPERCENTAGE ETHAN where ETHAN.Facilityid= TFACIL.FACILITYID and ETHAN.Percentageofpopulation<>''999'' and ETHAN.ETHNICITYNAME=''Asian''),''Y'',''N'') ASIAN,
                 ETHN.PERCENTAGEOFPOPULATION,
                IRBGN.DEDICATEDDEPARTMENT,
                TDIG.NA,
                TDIG.CT,
                TDIG.DXA,
                TDIG.ECG,
                TDIG.FLRO,
                TDIG.MRI,
                TDIG.MRA,
                TDIG.MRS,
                TDIG.MAMMO,
                TDIG.NMED,
                TDIG.PET,
                TDIG.XRAY,
                TDIG.OTHERDIAGNOSTIC DIGITAL_OTHER,
                TCONDG.ISWRITTENSOP,
                TCONDG.ISOTHERVULNERABLE,
                TCONDG.ISMINORASSENTPEDIATRIC ,
                TCONDG.ISLANGTRANSREQ,
                TCONDG.LANGUAGENAME,
                TCONDG.ISSHORTFORM,
                TCONDG.ISTRNGFORRESEARCH,
                TCONDG.ISINCLUDEGCP,
                TCONDG.PROGRAMCOURSENAME,
                TCONDG.ISTRNGPROVPROT,
                TCONDG.ISIATA,
                case when TFACDEPTL.ISROOMTEMPERATURE is null then ''N'' else  ISROOMTEMPERATURE end ISROOMTEMPERATURE,
                TFACDEPTL.ISREFRIGERATOR2TO8,--
               -- TFACDEPTL.ISTEMPSECURED2TO8,
                TFACDEPTL.ISTEMPMONITORLOG20TO30,
                case when TFACDEPTL.Isfreezer70to80 is null then ''N'' else ''Y'' end ISTEMPMONITORLOG70TO80,
               -- TFACDEPTL.ISTEMPMONITORLOG70TO80,
                TFACDEPTL.ISTEMPMONITORLOG135,
                TFACDEPTL.ISMINMAX20TO30,
                TFACDEPTL.ISBACKUP20TO30,
                TFACDEPTL.ISTEMPALARMED,
                TFACDEPTL.ISDESTROYIPCAPABLE,
                TFACDEPTL.ISSOPWRITTEN,
                TFACDEPTL.ISDEDICATEDINVENTORY,
                TFACDEPTL.ISDRUGTRANSPORT,
                TFACDEPTL.ISEXEPREPARATION,
                TFACDEPTL.ISFLOWHOOD,
                TFACDEPTL.ISGLOVEBOXVENTED,
                TFACDEPTL.ISLAMINARFLOWHOOD,
                TFACDEPTL.ISGLOVEBOXVENTOUT,
                TFACDEPTL.ISSTAFFBLIND,
                TSOURCE.Sdpaper,
                TSOURCE.Sdelectronic,
                TSOURCE.SECURERECORDSTORAGE ,
                 TSOURCE.ONSITEARCHIVING ,
                TSOURCE.ISEHRAVAILABLE ,
               (select RTRIM(XMLAGG(XMLELEMENT(e, b.ehrsystemsname|| '';''))
                                       .EXTRACT(''//text()''),
             '';'') from tbl_ehrsystemmap a,TBL_EHRSYSTEMS b where a.ehrsystemid=b.ehrsystemsid and a.facilityid=TFACIL.Facilityid) EHRSYSTEMSNAME,
                 TSOURCE.IS_EMR21CFR,--
                 TSOURCE.IS_EMRREMOTE,--
                TSOURCE.ACCESSLIMITATION,
                FACTYDSMP.ISNONE MONITOR_NONE,--
                FACTYDSMP.ISINFORMSYSTEM,
                FACTYDSMP.ISMEDIDATASYSTEM,
                FACTYDSMP.ISORACLESYSTEM,
                FACTYDSMP.ISOTHER,
                FACTYDSMP.OTHER ,
                TFACIL.ISFACGOVTFUNDED,
                DAYSPER.DAYSPERIODNAME,
                IRBGN.HASLOCAL,
                IRBGN.HASCENTRALASLOCAL,
                IRBGN.HASSPONSORCENTRAL,
                IRBGN.SAFETYREPORTS,
                IRBGN.AREOTHERSTEPS,
                IRBGN.OTHERSTEPSEXPLAIN,
                 case when ADLBAC.isglp is not null 
              then  (ADLBAC.isglp||'',''||ADLBAC.isclia||'',''||ADLBAC.iscap||'',''||ADLBAC.isiso) else null end ACCREDITIONID,
             --   ADLBAC.OTHER LOCLAB_OTHER,
              ( SELECT OTHER FROM TBL_ADDITIONALFACILITYLABACC WHERE   ADDFAC.ADDITIONALFACILITYID =ADDITIONALFACILITYID) LOCLAB_OTHER,
                EQUIP.OPENWEEKEND,
                EQUIP.ADMITRESEARCHSUBJECTS,
                EQUIP.ISENGKNOWLEDGE,
                EQUIP.ISTRANSSUPPORT,
                EQUIP.STUDYMATERIAL,
                EQUIP.PKPDCAPABILITY,
                EQUIP.LABHOURSACCOMODATE,
                EQUIP.ISPGXSAMPLEALLOWED,
                EQUIP.ISSOPPROCESS,
                EQUIP.ISMEDICALEMERGENCIES,
                EQUIP.CENTRIFUGE,
                EQUIP.REFCENTRIFUGESAMPLES,
                EQUIP.DEDICATEDCOMPUTER,
                COMPOP.COMPOPERATINGSYS,
                INTACC.INTERNETACCESS,
                EQUIP.WEBBASED,
                EQUIP.ITSUPPORT,
                TFACDEPTL.ISFREEZER135 ISFREESER_IP,
                TFACDEPTL.ISIPSTORAGESECURED,
                TFACDEPTL.ISMINMAX135,
                TFACDEPTL.ISALARM135,
                TFACDEPTL.ISSOP135,
                TFACDEPTL.ISDESTROYIPCAPABLECONTRLDSUBS,
                TFACDEPTL.ISINFUSIONCAPABLE,
                TFACDEPTL.ISREGULATORYLICENCEPRESENT,
                TFACDEPTL.ISCONTROLLEDSUBSEC,
                TFACDEPTL.ISRADIOLABLDIPCAPABLE,
                FACMACMP.ISPHONE,
                FACMACMP.ISFAX,
                FACMACMP.ISCOPYMACHINE,
                FACMACMP.ISINTERNET,
                FACMACMP.ISNONE ,----
                TFACIL.AFFILIATEDRESEARCHSITES,
                IRBGN.ETHICSSUBMISSION,
                TFACIL.ISUSINGLAB,
                TCONDG.EXTERNALTRAINING,
                IRBGN.AVGSTARTTIME,
                TFACDEPTL.IPSTORAGECAPABILITIES,
                --COMPGMP.COMPOPERATINGID,
                (select RTRIM(XMLAGG(XMLELEMENT(e, b.compoperatingsys|| '';''))
                                       .EXTRACT(''//text()''),
                                       '';'') from TBL_COMPOPERATINGMAP a, tbl_compoperatingsys b
                                       where a.compoperatingid = b.compoperatingsysid
                                         and a.facilityid     = TFACIL.Facilityid) COMPOPERATINGID,
                EQUIP.INTERNETACCESSID,
                case when TFACDEPTL.ISTEMPSECURED135 is not null then ''Y'' else ''N'' end ISTEMPSECURED135,
                EHRSYS.EHRSYSTEMID,
                SAT.SATELLITESITE,
                TSOURCE.SATELLITESITES,
                TFACDEPTL.ISMINMAXTEMP,
                case when EQUIP.ISFREEZER20TO30 is null then ''N'' else ''Y'' end ISFREEZER20TO30 ,
                case when EQUIP.ISFREEZER135 is null then ''N'' else ''Y'' end ISFREEZER135,
                TFACDEPTL.ISREFRIGERATOR2TO8 IP_Isrefrigerator2to8,
                case when EQUIP.Isfreezer70to80 is null then ''N'' else ''Y'' end  Isfreezer70to80_EQUP,
                TFACDEPTL.Isfreezer20to30  IP_Isfreezer20to30_FAC,
                TFACDEPTL.Isfreezer70to80 IP_Isfreezer70to80,
                TFACDEPTL.Isfreezer135 IP_Isfreezer135,
                case when EQUIP.ISREFRIGERATOR2TO8 is null then ''N'' else ''Y'' end  ISREFRIGERATOR2TO8_IP  ';

V_FROM_CLAUSE :=' FROM  TBL_FACILITIES                TFACIL,
       TBL_FACILITYSPONSORTYPES      TSPONSOR,
       TBL_FACILITYDEMOGRAPHY        TDEMO,
       TBL_ETHNICITYPERCENTAGE       ETHN,
       TBL_IRBGENERAL                IRBGN,
       TBL_EQUIPMENT                 EQUIP,
       TBL_DIGITALDIAGNOSTIC         TDIG,
       TBL_USERPROFILES              TU,
       TBL_IRFACILITYUSERMAP         TIRFACMP,
       TBL_CONANDTRGDETLS            TCONDG,
       TBL_FACIPDETAILS              TFACDEPTL,
       TBL_FACILITYEDSMAP            FACTYDSMP,
       TBL_SOURCEDOCUMENTATION       TSOURCE,
       TBL_EHRSYSTEMMAP              EHRSYS,
       TBL_ADDITIONALFACILITY        ADDFAC,
       TBL_ADDITIONALFACILITYLABACC  ADLBAC,
       TBL_COMPOPERATINGMAP          COMPGMP,
       TBL_FACILITYMONACCESSMAP      FACMACMP,
     TBL_DAYSPERIOD          DAYSPER,
     TBL_INTERNETACCESS       INTACC,
     TBL_COMPOPERATINGSYS          COMPOP,
     TBL_EHRSYSTEMS                 EHR,
     TBL_SATELLITESITES            SAT     ';

 V_WHERE_CLAUSE :='   where TFACIL.Facilityid = TSPONSOR.Facilityid(+)
   and TIRFACMP.Facilityid(+) = TFACIL.Facilityid
   and TIRFACMP.Userid = tu.userid
   and TDEMO.Facilityid(+) = TFACIL.Facilityid
   and ETHN.Facilityid(+)= TFACIL.Facilityid
   and IRBGN.Facilityid(+)=TFACIL.Facilityid
   and EQUIP.Facilityid(+)=TFACIL.Facilityid
   and TDIG.Facilityid(+)= TFACIL.Facilityid
   and TCONDG.Facilityid(+)=TFACIL.Facilityid
   and TFACDEPTL.Facilityid(+)=TFACIL.Facilityid
   and FACTYDSMP.Facilityid(+)=TFACIL.Facilityid
   and TSOURCE.Facilityid(+) = TFACIL.Facilityid
   and EHRSYS.Facilityid(+)  = TFACIL.Facilityid
   and ADDFAC.Facilityid(+)  = TFACIL.Facilityid
   and ADLBAC.Additionalfacilityid(+)=ADDFAC.Additionalfacilityid
   and COMPGMP.Facilityid(+) = TFACIL.Facilityid
   and FACMACMP.Facilityid(+)= TFACIL.Facilityid
   and IRBGN.AVGSTARTTIME     =DAYSPER.DAYSPERIODID(+)
   and EQUIP.INTERNETACCESSID =INTACC.INTERNETACCESSID(+)
   and COMPOP.COMPOPERATINGSYSID(+)  =COMPGMP.COMPOPERATINGID
   and EHRSYS.EHRSYSTEMID    =EHR.EHRSYSTEMSID(+)
   and SAT.SATELLITESITEID(+)  =TSOURCE.SATELLITESITES
      --   AND ETHN.PERCENTAGEOFPOPULATION<>999
         /*AND TDIG.NA is not null */';

   IF IP_TRANSCELERATEID IS NOT NULL THEN
     V_WHERE_CLAUSE:=V_WHERE_CLAUSE||' AND LOWER(TU.TRANSCELERATEUSERID) LIKE LOWER(''%' || IP_TRANSCELERATEID || '%'')';

   END IF;
   IF IP_FACILITYID IS NOT NULL THEN
     V_WHERE_CLAUSE:=V_WHERE_CLAUSE||' AND TFACIL.FACILITYID = '||IP_FACILITYID ||' ORDER by ACCREDITIONID desc ' ;
   END IF;

 V_FINAL_SQL:=V_SELECT_CLAUSE||V_FROM_CLAUSE||V_WHERE_CLAUSE;
 V_COUNT_QUERY:='SELECT COUNT(*) FROM ('|| V_FINAL_SQL||')';

  DBMS_OUTPUT.put_line(V_COUNT_QUERY);

 --INSERT INTO TEMP_TABLE VALUES(null,V_COUNT_QUERY);
  --COMMIT;

  EXECUTE IMMEDIATE V_COUNT_QUERY INTO IP_COUNT;
    V_PAG_END_ROW           := IP_OFFSET + IP_LIMIT;

    V_FINAL_SQL          := 'SELECT * FROM (SELECT ROWNUM RNUM , TEMP.* FROM (' || V_FINAL_SQL  || ' ) TEMP  WHERE ROWNUM < ' || TO_CHAR(V_PAG_END_ROW) || ' ) WHERE RNUM >='|| TO_CHAR(IP_OFFSET);

   --INSERT INTO TEMP_TABLE VALUES(null,V_FINAL_SQL);
   --COMMIT;
  OPEN OP_FACIDETAILS FOR V_FINAL_SQL ;

 -- dbms_output.put_line(V_FINAL_SQL);

 END SP_FAC_DETAILS_SEARCH;
 
PROCEDURE SP_GET_DOCDETAILS
(
I_DOCID         IN NUMBER,
I_USERID        IN NUMBER,
I_ORGID         IN NUMBER,
IP_SEARCH_TYPE  IN VARCHAR2,
REF_CUS_USERS   OUT SYS_REFCURSOR
)
AS
  v_final_query   VARCHAR2(32767);
  v_select_clause VARCHAR2(32767);
  v_from_clause   VARCHAR2(32767);
  v_where_clause  VARCHAR2(32767);
  v_issponsor     TBL_USERPROFILES.issponsor%TYPE;
BEGIN

  --Get Document details
  IF UPPER(IP_SEARCH_TYPE) = 'USER' THEN
  
      v_select_clause := ' SELECT TO_CHAR(td.documentid) documentid,
                                 td.url fileentryid,
                                 td.title filename,
                                 CASE 
                                     WHEN td.doctypecd = 1 THEN
                                          ''Abbreviated Curriculum Vitae''
                                     WHEN td.doctypecd = 2 THEN
                                          ''Medical License''
                                     WHEN td.doctypecd = 3 THEN
                                          ''Profile Attachments''
                                 END documenttype,
                                 td.description document_description,
                                 td.createdby uploaded_generated_by,
                                 td.createddt uploaded_generated_on,
                                 pkg_encrypt.fn_decrypt(tup.firstname) user_first_name,
                                 pkg_encrypt.fn_decrypt(tup.lastname) user_last_name,
                                 NULL facilityname,
                                 NULL departmentname,
                                 NULL departmenttypename,
                                 tcn.countryname countrynm,
                                 tst.statename statenm,
                                 tc.city citynm,
                                 pkg_encrypt.fn_decrypt(tc.email) emailid,
                                 tr.rolename rolenm ';
                                 
      v_from_clause := ' FROM TBL_DOCUMENTS td, 
                              TBL_USERPROFILES tup,
                              TBL_ROLES tr,
                              TBL_CONTACT tc,
                              TBL_COUNTRIES tcn,
                              TBL_STATES tst ';
                             
      v_where_clause := ' WHERE td.docuserid = tup.userid
                          AND tup.roleid = tr.roleid
                          AND tup.contactid = tc.contactid
                          AND tc.countrycd = tcn.countrycd
                          AND td.islatest = ''Y''
                          AND tc.state = tst.statecd(+) 
                          AND td.documentid=' || I_DOCID || ' ';
                           
  ELSIF UPPER(ip_search_type) = 'TRAINING' THEN
  
        v_select_clause := ' SELECT tuts.id documentid,
                                   CASE 
                                       WHEN tuts.source = ''SIP'' THEN
                                            tuts.source || ''@#@'' || tuts.requestid || ''@#@''  || tuts.url 
                                       WHEN tuts.source = ''LMS'' THEN
                                            tuts.source || ''@#@'' || tuts.course_id || ''@#@'' || tuts.emppk || ''@#@''  || tuts.url || ''@#@''  || tuts. attempt_id
                                   END fileentryid,
                                   tuts.course_title filename,
                                   ''Training'' documenttype,
                                   NULL document_description,
                                   tuts.createdby uploaded_generated_by,
                                   tuts.createddt uploaded_generated_on,
                                   pkg_encrypt.fn_decrypt(tup.firstname) user_first_name,
                                   pkg_encrypt.fn_decrypt(tup.lastname) user_last_name,
                                   NULL facilityname,
                                   NULL departmentname,
                                   NULL departmenttypename,
                                   tcn.countryname countrynm,
                                   tst.statename statenm,
                                   tc.city citynm,
                                   pkg_encrypt.fn_decrypt(tc.email) emailid,
                                   tr.rolename rolenm ';
                                   
        v_from_clause := ' FROM TBL_USER_TRAINING_STATUS tuts, 
                                TBL_TRAININGTYPE tt,
                                TBL_USERPROFILES tup,
                                TBL_ROLES tr,
                                TBL_CONTACT tc,
                                TBL_COUNTRIES tcn,
                                TBL_STATES tst ';
                               
        v_where_clause := ' WHERE tuts.user_id = tup.userid
                            AND tup.roleid = tr.roleid
                            AND tuts.training_type_id = tt.trainingtypeid
                            AND tup.contactid = tc.contactid
                            AND tc.countrycd = tcn.countrycd
                            AND tc.state = tst.statecd(+) 
                            AND tuts.id=' || I_DOCID || ' ';
                       
  ELSIF UPPER(ip_search_type) = 'FACILITY' THEN
  
        IF i_userid IS NOT NULL THEN
             SELECT up.issponsor INTO v_issponsor FROM TBL_USERPROFILES up WHERE up.userid = i_userid;
        END IF;
  
        v_select_clause := ' SELECT tfdm.facilitydocmetadataid documentid,                                             
                                    df.fileentryid,                                             
                                    df.title filename,                                             
                                    tfdtm.doctype documenttype,                                             
                                    tfdm.documentdescription document_description,                                             
                                    tfdm.createdby uploaded_generated_by,                                             
                                    tfdm.createddt uploaded_generated_on,                                             
                                    NULL user_first_name,                                             
                                    NULL user_last_name,                                             
                                    tf.facilityname,                                             
                                    tf.departmentname,                                             
                                    tdt.departmenttypename,
                                    tcn.countryname countrynm,
                                    tst.statename statenm,
                                    tc.city citynm,
                                    pkg_encrypt.fn_decrypt(tc.email) emailid,
                                    NULL rolenm ';
          
          IF v_issponsor = 'Y' THEN
              v_from_clause := ' FROM TBL_FACILITIES tf,
                                      TBL_FACILITYDOCMETADATA tfdm, 
                                      TBL_FACILITYDOCTYPEMASTER tfdtm, 
                                      TBL_DEPARTMENTTYPE tdt,
                                      DLFILEENTRY df,
                                      TBL_CONTACT tc,
                                      TBL_COUNTRIES tcn,
                                      TBL_STATES tst ';
                                       
              v_where_clause := ' WHERE tf.facilityid = tfdm.facilityid
                                  AND tfdm.documenttypeid = tfdtm.facilitydoctypemasterid
                                  AND tf.departmenttypeid = tdt.departmenttypeid(+)
                                  AND tfdm.fileentryid = df.fileentryid
                                  AND tf.contactid = tc.contactid
                                  AND tc.countrycd = tcn.countrycd
                                  AND tc.state = tst.statecd(+) 
                                  AND tfdm.facilitydocmetadataid=' || I_DOCID || ' ';
          ELSE
              v_from_clause := ' FROM TBL_FACILITIES tf,
                                      TBL_IRFACILITYUSERMAP tfum, 
                                      TBL_FACILITYDOCMETADATA tfdm, 
                                      TBL_FACILITYDOCTYPEMASTER tfdtm, 
                                      TBL_DEPARTMENTTYPE tdt,
                                      DLFILEENTRY df,
                                      TBL_USERPROFILES tup,
                                      TBL_CONTACT tc,
                                      TBL_COUNTRIES tcn,
                                      TBL_STATES tst ';
                                   
              v_where_clause := ' WHERE tf.facilityid = tfum.facilityid
                                  AND tf.facilityid = tfdm.facilityid
                                  AND tfdm.documenttypeid = tfdtm.facilitydoctypemasterid
                                  AND tf.departmenttypeid = tdt.departmenttypeid(+)
                                  AND tfdm.fileentryid = df.fileentryid
                                  AND tfum.userid = tup.userid
                                  AND tf.contactid = tc.contactid
                                  AND tc.countrycd = tcn.countrycd
                                  AND tc.state = tst.statecd(+) 
                                  AND tfdm.facilitydocmetadataid=' || I_DOCID || ' ';          
          END IF;                     
  END IF;
  
  v_final_query := v_select_clause || v_from_clause || v_where_clause;
  --dbms_output.put_line('Final Main Query:' || v_final_query);
  OPEN REF_CUS_USERS FOR v_final_query;
  
END SP_GET_DOCDETAILS;

FUNCTION FN_REPLACE_WILDSPLCHAR
(ip_input_string IN VARCHAR2) RETURN VARCHAR2
IS
v_output_string VARCHAR2(32767);
BEGIN
  v_output_string := ip_input_string;
  --Replace '\' (Slash)
  v_output_string := REPLACE(v_output_string,'\','\\');
  --Replace '_' (Underscore)
  v_output_string := REPLACE(v_output_string,'_','\_');
  --Replace '%' (Percentage)
  v_output_string := REPLACE(v_output_string,'%','\%');
  --Replace ' (Single Quote)
  v_output_string := REPLACE(v_output_string,'''','''''');

  RETURN v_output_string;

END FN_REPLACE_WILDSPLCHAR;
  
 END PKG_SEARCH;
 /