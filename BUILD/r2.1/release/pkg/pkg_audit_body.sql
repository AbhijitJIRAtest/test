CREATE OR REPLACE PACKAGE BODY PKG_AUDIT AS
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
     )
  IS
  BEGIN
    IF (NVL(ip_oldvalue,'@#$%*') <> NVL(ip_newvalue, '@#$%*') AND ip_operation IN (pkg_audit.g_operation_update))
       OR (ip_operation IN(pkg_audit.g_operation_create,pkg_audit.g_operation_delete)) THEN
      INSERT INTO tbl_audit(auditid, entityrefid, tablename, columnname, oldvalue, newvalue, operation, reason, createdby, createddt, modifiedby, modifieddt)
      VALUES(seq_audit.NEXTVAL, ip_entityrefid, ip_tablename, ip_columnname,
                    CASE
                      WHEN ip_operation = pkg_audit.g_operation_create THEN
                          NULL
                      ELSE
                          ip_oldvalue
                    END,
                    CASE
                      WHEN ip_operation = pkg_audit.g_operation_delete THEN
                          NULL
                      ELSE
                          ip_newvalue
                    END,
                    ip_operation, ip_reason,
                    NVL(ip_createdby,NVL(ip_modifiedby,'SYSTEM')),
                    NVL(ip_createddt,NVL(ip_modifieddt,SYSDATE)),
                    NVL(ip_modifiedby,NVL(ip_createdby,'SYSTEM')),
                    NVL(ip_modifieddt,NVL(ip_createddt,SYSDATE)))

      RETURNING auditid INTO op_auditid;

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE(SQLERRM);
         RAISE;
  END sp_set_audit;

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
     )
  IS
  v_row_start           PLS_INTEGER;
  v_row_end             PLS_INTEGER;
  v_where_clause        VARCHAR2(32767);
  v_select_clause       VARCHAR2(32767);
  v_from_clause         VARCHAR2(32767);
  v_orderby_clause      VARCHAR2(32767);
  v_sortby              VARCHAR2(32767);
  v_page_select_clause  VARCHAR2(32767);
  v_page_where_clause   VARCHAR2(32767);
  v_select_cnt_clause   VARCHAR2(32767);
  v_final_cnt_sql       VARCHAR2(32767);
  v_final_sql           VARCHAR2(32767);
  v_sitelist            VARCHAR2(32767);
  v_countrylist         VARCHAR2(32767);
  v_where_temp          VARCHAR2(32767);
  v_where_cnt_temp      VARCHAR2(32767);
  v_cursorid            PLS_INTEGER;
  v_rows_processed      PLS_INTEGER;
  BEGIN

    v_row_start := NVL(ip_offset,1);
    v_row_end := v_row_start + ip_limit;

    IF ip_sortby IS NOT NULL THEN
      IF ip_sortby = 'STUDYID' THEN
          v_sortby := 'tarmp.studyid';
      ELSIF ip_sortby = 'STUDYSITEID' THEN
          v_sortby := 'tarmp.studysiteid';
      END IF;
    ELSE
      --Default Sorting
      v_sortby := 'UPPER(temp.studyid) NULLS FIRST,UPPER(temp.studysiteid) NULLS FIRST,temp.information_area NULLS FIRST,temp.entityrefid NULLS FIRST,temp.createddt,upper(temp.fieldname)';
    END IF;

    v_orderby_clause :=  ' ORDER BY ' || v_sortby;

    v_where_cnt_temp:= '  ) temp ';
    v_where_temp:=  '  ) inner_tmp ) temp ';

    IF ip_ordrby IS NOT NULL THEN
       v_orderby_clause := v_orderby_clause || ' ' || ip_ordrby;
    END IF;

    v_page_select_clause := ' SELECT * FROM(
                              SELECT  report_data.*,ROWNUM rnum FROM( SELECT * FROM(
                              SELECT inner_tmp.*,
                              CASE
                                  WHEN entity = ''Study Details'' THEN
                                      1
                                  WHEN entity = ''Study & Country Milestones'' THEN
                                      2
                                  WHEN entity = ''Central IRB/ERB/Ethics Committee'' THEN
                                      3
                                  WHEN entity = ''Central Laboratory'' THEN
                                      4
                                  WHEN entity = ''Study Contacts'' THEN
                                      5
                                  WHEN entity = ''Systems for Site User Access'' THEN
                                      6
                                  WHEN entity = ''Potential Investigators'' THEN
                                      7
                                  WHEN entity = ''Study Site Profile'' THEN
                                      8
								  WHEN entity = ''PI Address'' THEN
                                      9
								  WHEN entity = ''Primary Facility/Department Address'' THEN
                                      10
								  WHEN entity = ''Additional Location Address'' THEN
                                      11
                                  WHEN entity = ''Study Site IRBs'' THEN
                                      12
                                  WHEN entity = ''Study Site Labs'' THEN
                                      13
                                  WHEN entity = ''Study Site Staff'' THEN
                                      14
                                  WHEN entity = ''IP Shipping Address'' THEN
                                      15
                                  WHEN entity = ''IP Storage Address'' THEN
                                      16
                                  WHEN entity = ''Financial Address'' THEN
                                      17
                                  WHEN entity = ''Lab Kit Shipment Address'' THEN
                                      18
                                  WHEN entity = ''Regulatory Address'' THEN
                                      19
                                  WHEN entity = ''Safety Letter Mailing Address'' THEN
                                      20
                                  WHEN entity = ''Study Supply Address'' THEN
                                      21
                                  WHEN entity = ''Study Documents'' THEN
                                      22
                                  ELSE
                                      99
                              END information_area
                              FROM ( ';

    v_page_where_clause := ' ) report_data
                             WHERE ROWNUM < '|| v_row_end || ' )
                             WHERE rnum >= ' || v_row_start;

    v_select_cnt_clause := ' SELECT COUNT(1) FROM ( SELECT * ';

    v_select_clause:= ' SELECT pkg_audit.fn_get_lov_value(tarmp.studyid,''' ||  pkg_audit.g_lov_study || ''') studyid,
                               pkg_audit.fn_get_lov_value(tarmp.studysiteid,''' ||  pkg_audit.g_lov_site || ''') studysiteid,
                                CASE
                                   WHEN  TAP.tablename=''TBL_CONTACT'' THEN
                                           CASE
										   WHEN  (select contacttype  from TBL_CONTACT co
										   where co.CONTACTID=tap.entityrefid) = ''Facility Address''
										   THEN ''Primary Facility/Department Address''
										   WHEN  (select contacttype  from TBL_CONTACT co
										   where co.CONTACTID=tap.entityrefid) = ''Principal Investigator''
										   THEN ''PI Address''
										   WHEN  (select contacttype  from TBL_CONTACT co
										   where co.CONTACTID=tap.entityrefid) = ''IP Ship to''
										   THEN ''IP Shipping Address''
										   WHEN  (select contacttype  from TBL_CONTACT co
										   where co.CONTACTID=tap.entityrefid) = ''IP Store''
										   THEN ''IP Storage Address''
										   WHEN  (select contacttype  from TBL_CONTACT co
										   where co.CONTACTID=tap.entityrefid) = ''Financial Address''
										   THEN ''Financial Address''
										   WHEN  (select contacttype  from TBL_CONTACT co
										   where co.CONTACTID=tap.entityrefid) = ''Lab Kit Shipment Address''
										   THEN ''Lab Kit Shipment Address''
										   WHEN  (select contacttype  from TBL_CONTACT co
										   where co.CONTACTID=tap.entityrefid) = ''Regulatory Address''
										   THEN ''Regulatory Address''
										   WHEN  (select contacttype  from TBL_CONTACT co
										   where co.CONTACTID=tap.entityrefid) = ''Safety Letter Mailing Address''
										   THEN ''Safety Letter Mailing Address''
										   WHEN  (select contacttype  from TBL_CONTACT co
										   where co.CONTACTID=tap.entityrefid) = ''Central IRB''
										   THEN ''Central IRB/ERB/Ethics Committee''
										   WHEN  (select contacttype  from TBL_CONTACT co
										   where co.CONTACTID=tap.entityrefid) = ''Central Lab''
										   THEN ''Central Laboratory''
										   WHEN  (select contacttype  from TBL_CONTACT co
										   where co.CONTACTID=tap.entityrefid) = ''Study Supply Address''
										   THEN ''Study Supply Address''
										   WHEN  (select contacttype  from TBL_CONTACT co
										   where co.CONTACTID=tap.entityrefid) = ''Additional Location''
										   THEN ''Additional Location Address''
										   WHEN  (select contacttype  from TBL_CONTACT co
										   where co.CONTACTID=tap.entityrefid) = ''IRB''
										   THEN ''Study Site IRBs''
										   WHEN  (select contacttype  from TBL_CONTACT co
										   where co.CONTACTID=tap.entityrefid) = ''LAB''
										   THEN ''Study Site Labs''
										   ELSE ''Contact''
										   END
									WHEN TAP.tablename=''TBL_DOCUMENTS'' and tap.columnname=''DOCUSERID'' AND tarmp.studysiteid IS NULL THEN
											''Study Documents''
									WHEN TAP.tablename=''TBL_STUDYSECTIONSTATUS'' THEN
                                         CASE
                                            WHEN (SELECT tss.sectioncode
                                                  FROM TBL_STUDYSECTIONSTATUS tsss, TBL_STUDYSECTIONS tss
                                                  WHERE tsss.sectionid = tss.studysectionid
                                                  AND tsss.studysectionstatusid = tap.entityrefid) = ''CRB'' THEN
                                                  ''Central IRB/ERB/Ethics Committee''
                                            WHEN (SELECT tss.sectioncode
                                                  FROM TBL_STUDYSECTIONSTATUS tsss, TBL_STUDYSECTIONS tss
                                                  WHERE tsss.sectionid = tss.studysectionid
                                                  AND tsss.studysectionstatusid = tap.entityrefid) = ''LAB'' THEN
                                                  ''Central Laboratory''
                                             ELSE tcp.entity
                                         END
                                    ELSE tcp.entity
							   END  entity,
                               tap.entityrefid,
                               CASE
                                   WHEN tcp.tablename=''TBL_SITE'' and tcp.columnname=''INSTITUTIONNAME'' THEN
                                        (SELECT CASE
                                                    WHEN fac.ISDEPARTMENT = ''Y'' THEN
                                                        ''Department Name''
                                                    ELSE ''Facility Name''
                                                END
                                         FROM TBL_FACILITIES fac, TBL_SITE sit
                                         WHERE fac.FACILITYID=sit.PRINCIPALFACILITYID
                                         AND sit.SITEID=tap.entityrefid )
								  WHEN tcp.tablename=''TBL_POTENTIALINVFACMAP'' and tcp.columnname=''FACILITYID'' THEN
                                        (SELECT CASE
                                                    WHEN fac.ISDEPARTMENT = ''Y'' THEN
                                                        ''Department Name''
                                                    ELSE ''Facility Name''
                                                END
                                         FROM TBL_FACILITIES fac, TBL_POTENTIALINVFACMAP pfac
                                         WHERE fac.FACILITYID=pfac.FACILITYID
                                         AND pfac.POTENTIALINVFACID=tap.entityrefid )
									WHEN TAP.tablename=''TBL_DOCUMENTS'' and tap.columnname=''DOCUSERID'' AND tarmp.studysiteid IS NULL THEN
                                         ''Document User Id''
									WHEN TAP.tablename=''TBL_CONTACT'' and tap.columnname=''ADDRESS1'' THEN
                                         ''Street Name and Number''
									WHEN TAP.tablename=''TBL_CONTACT'' and tap.columnname=''ADDRESS2'' THEN
                                         ''Building/Floor/Room/Suite''
   								    WHEN TAP.tablename=''TBL_CONTACT'' and tap.columnname=''ADDRESS3'' THEN
                                         ''Additional Address Info''
									WHEN TAP.tablename=''TBL_CONTACT'' and tap.columnname=''STATE'' THEN
                                         ''State/Province/Region''
									WHEN TAP.tablename=''TBL_CONTACT'' and tap.columnname=''POSTALCODE'' THEN
                                         ''Zip/Postal Code''
									WHEN TAP.tablename=''TBL_CONTACT'' and tap.columnname=''EMAIL'' THEN
                                         ''Email Address''
   								    WHEN TAP.tablename=''TBL_CONTACT'' and tap.columnname=''FAX'' THEN
                                         ''Fax Number''
									WHEN TAP.tablename=''TBL_CONTACT'' and tap.columnname=''PHONE1'' THEN
                                         ''Phone Number''
									WHEN tcp.entity = ''Study Documents'' AND tcp.fieldname = ''Assigned User'' AND tarmp.studysiteid IS NULL THEN
                                         ''Document User Id''
   								    WHEN TAP.tablename=''TBL_STUDYCOUNTRYMILESTONE'' and tap.columnname IN (''PLANNED_FSFV'',''PLANNED_LSLV'',''PLANNED_SUBJECTENROLLED'',''ACTUAL_SUBJECTENROLLED'') THEN
                                         (SELECT pkg_audit.fn_get_lov_value(tscm.countryid,''COUNTRY_ID'') FROM TBL_STUDYCOUNTRYMILESTONE tscm WHERE tscm.studycountryid = tap.entityrefid) || '' - '' || tcp.fieldname
                                    WHEN TAP.tablename=''TBL_SITESECTIONSTATUS'' AND tap.columnname = ''ISAPPLICABLE'' THEN
                                         CASE
                                            WHEN (SELECT tss.sectioncode
                                                  FROM TBL_SITESECTIONSTATUS tsss, TBL_SITESECTIONS tss
                                                  WHERE tsss.sectionid = tss.sitesectionid
                                                  AND tsss.sitesectionstatusid = tap.entityrefid) = ''ISL'' THEN
                                                  ''Is IP Storage Location Not Applicable?''
                                            WHEN (SELECT tss.sectioncode
                                                  FROM TBL_SITESECTIONSTATUS tsss, TBL_SITESECTIONS tss
                                                  WHERE tsss.sectionid = tss.sitesectionid
                                                  AND tsss.sitesectionstatusid = tap.entityrefid) = ''CSD'' THEN
                                                  ''Is Other Contact/Shipping Details Not Applicable?''
                                             ELSE tcp.fieldname
                                         END
                                    ELSE
                                        tcp.fieldname
                               END fieldname,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.oldvalue)
                                  ELSE
                                      tap.oldvalue
                               END oldvalue,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.newvalue)
                                  ELSE
                                      tap.newvalue
                               END newvalue,
                               tap.operation,
                               (case when tap.createdby = ''SYSTEM'' then ''SYSTEM'' else
                               (SELECT INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname)) || '' ('' ||
                               CASE
                                WHEN up.issponsor = ''Y'' THEN
                                    up.actualtranscelerateuserid
                                ELSE
                                    up.transcelerateuserid
                               END
                               ||'')''
                               FROM tbl_userprofiles up
                               WHERE up.transcelerateuserid = tap.createdby )END ) AS createdby,
                               TO_CHAR(tap.createddt,''DD-Mon-YYYY HH24:MI:SS'') createddt ';

    v_from_clause:= ' FROM tbl_audit tap,
                           tbl_studyauditreportmap tarmp,
                           tbl_columnfieldmap tcp ';

    v_where_clause:= ' WHERE tap.auditid = tarmp.studyauditid
                       AND tap.tablename = tcp.tablename
                       AND tap.columnname = tcp.columnname
                       AND tcp.ISACTIVE = ''Y''
                       AND NOT EXISTS(SELECT 1
                                      FROM TBL_CONTACT tc
                                      WHERE tc.contactid = tap.entityrefid
                                      AND tap.tablename = ''TBL_CONTACT''
                                      AND tap.operation = ''Delete''
                                      AND LOWER(tc.contacttype) IN (''financial address'',
                                      ''lab kit shipment address'',
                                      ''regulatory address'',
                                      ''safety letter mailing address'',
                                      ''study supply address'',
                                      ''ip store'',
                                      ''ip ship to''))
                       AND (tap.oldvalue is not null or tap.newvalue is not null) ';

    IF ip_startdate IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tap.modifieddt >= ' || CHR(39) || TRUNC(ip_startdate) || CHR(39);
    END IF;

    IF ip_enddate IS NOT NULL THEN
      v_where_clause :=   v_where_clause || ' AND tap.modifieddt < ' || CHR(39) || TRUNC(ip_enddate+1) || CHR(39);
    END IF;

    IF ip_changedby IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tap.createdby = ' || CHR(39) || ip_changedby || CHR(39);
    END IF;

    IF ip_studyid IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tarmp.studyid = ' || ip_studyid;
    END IF;

    IF ip_studysiteid.COUNT > 0 THEN
        FOR i IN ip_studysiteid.FIRST..ip_studysiteid.LAST LOOP
            IF v_sitelist IS NOT NULL THEN
               v_sitelist := v_sitelist || ',' || ip_studysiteid(i);
            ELSE
               v_sitelist := ip_studysiteid(i);
            END IF;
        END LOOP;
        v_where_clause :=  v_where_clause || ' AND (tarmp.studysiteid IS NULL OR tarmp.studysiteid IN (' || v_sitelist || ')) ';
    END IF;

    IF ip_countryid.COUNT > 0 THEN
        FOR i IN ip_countryid.FIRST..ip_countryid.LAST LOOP
            IF v_countrylist IS NOT NULL THEN
               v_countrylist := v_countrylist || ',' || ip_countryid(i);
            ELSE
               v_countrylist := ip_countryid(i);
            END IF;
        END LOOP;
        v_where_clause :=  v_where_clause || ' AND (tarmp.studysiteid IS NULL OR
                                                    tarmp.studysiteid IN (SELECT ts.siteid
                                                                          FROM TBL_SITE ts,
                                                                               TBL_FACILITIES tf,
                                                                               TBL_CONTACT tc,
                                                                               TBL_COUNTRIES tcnt
                                                                          WHERE ts.principalfacilityid = tf.facilityid
                                                                          AND tf.contactid = tc.contactid
                                                                          AND tc.countrycd = tcnt.countrycd
                                                                          AND ts.studyid = ' || ip_studyid || '
                                                                          AND tcnt.countryid IN (' || v_countrylist || '))) ';
    END IF;

    v_final_cnt_sql := v_select_cnt_clause || v_from_clause || v_where_clause || v_where_cnt_temp;
    --DBMS_OUTPUT.PUT_LINE(v_final_cnt_sql);

    v_final_sql := v_page_select_clause || v_select_clause || v_from_clause || v_where_clause || v_where_temp || v_orderby_clause || v_page_where_clause;
    --DBMS_OUTPUT.PUT_LINE(v_final_sql);
    v_cursorid := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursorid,v_final_cnt_sql,DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, op_count);
    v_rows_processed := DBMS_SQL.EXECUTE(v_cursorid);
    IF DBMS_SQL.FETCH_ROWS(v_cursorid) <> 0 THEN
       DBMS_SQL.COLUMN_VALUE(v_cursorid,1,op_count);
    END IF;
    DBMS_SQL.CLOSE_CURSOR(v_cursorid);

    OPEN op_audit_report FOR v_final_sql;

  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RAISE;
  END sp_get_study_audit;

  PROCEDURE SP_SET_STUDYAUDITREPORTMAP
    (ip_auditid           IN tbl_studyauditreportmap.STUDYAUDITID%TYPE,
     ip_studyid           IN tbl_studyauditreportmap.STUDYID%TYPE,
     ip_studysiteid       IN tbl_studyauditreportmap.STUDYSITEID%TYPE,
     ip_createddt         IN tbl_studyauditreportmap.CREATEDDT%TYPE,
     ip_createdby         IN tbl_studyauditreportmap.CREATEDBY%TYPE,
     ip_modifieddt        IN tbl_studyauditreportmap.modifieddt%TYPE,
   ip_modifiedby       IN tbl_studyauditreportmap.modifiedby%TYPE
        )

  IS
  BEGIN
    INSERT INTO tbl_studyauditreportmap(studyauditreportmapid, studyauditid, studyid, studysiteid, createddt, createdby, modifieddt, modifiedby)
    VALUES(seq_studyauditreportmap.NEXTVAL, ip_auditid, ip_studyid, ip_studysiteid,
          NVL(ip_createddt,NVL(ip_modifieddt,SYSDATE)),
          NVL(ip_createdby,NVL(ip_modifiedby,'SYSTEM')),
          NVL(ip_modifieddt,NVL(ip_createddt,SYSDATE)),
          NVL(ip_modifiedby,NVL(ip_createdby,'SYSTEM')));

  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RAISE;
  END sp_set_studyauditreportmap;

  PROCEDURE SP_SET_SURVEYAUDITREPORTMAP
    (ip_auditid           IN tbl_surveyauditreportmap.SURVEYAUDITID%TYPE,
     ip_surveyid          IN tbl_surveyauditreportmap.SURVEYID%TYPE,
     ip_surveyname        IN tbl_surveyauditreportmap.SURVEYNAME%TYPE,
     ip_studyid            IN tbl_surveyauditreportmap.STUDYID%TYPE,
     ip_surveyrecipient   IN tbl_surveyauditreportmap.SURVEYRECIPIENT%TYPE,
     ip_createddt         IN tbl_surveyauditreportmap.CREATEDDT%TYPE,
     ip_createdby         IN tbl_surveyauditreportmap.CREATEDBY%TYPE,
     ip_modifieddt        IN tbl_surveyauditreportmap.modifieddt%TYPE,
     ip_modifiedby         IN tbl_surveyauditreportmap.modifiedby%TYPE
     )

  IS
  BEGIN
    INSERT INTO tbl_surveyauditreportmap(surveyauditreportmapid, surveyauditid, surveyname, surveyid, studyid, surveyrecipient, createddt, createdby, modifieddt, modifiedby)
    VALUES(seq_surveyauditreportmap.NEXTVAL, ip_auditid, ip_surveyname,ip_surveyid, ip_studyid,ip_surveyrecipient,
          NVL(ip_createddt,NVL(ip_modifieddt,SYSDATE)),
          NVL(ip_createdby,NVL(ip_modifiedby,'SYSTEM')),
          NVL(ip_modifieddt,NVL(ip_createddt,SYSDATE)),
          NVL(ip_modifiedby,NVL(ip_createdby,'SYSTEM')));

  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RAISE;
  END sp_set_surveyauditreportmap;

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
     )
  IS
  v_row_start           PLS_INTEGER;
  v_row_end             PLS_INTEGER;
  v_where_clause   VARCHAR2(32767);
  v_select_clause  VARCHAR2(32767);
  v_from_clause    VARCHAR2(32767);
  v_orderby_clause VARCHAR2(32767);
  v_sortby              VARCHAR2(32767);
  v_page_select_clause  VARCHAR2(32767);
  v_page_where_clause   VARCHAR2(32767);
  v_select_cnt_clause   VARCHAR2(32767);
  v_final_cnt_sql       VARCHAR2(32767);
  v_final_sql           VARCHAR2(32767);
  v_cursorid            PLS_INTEGER;
  v_rows_processed      PLS_INTEGER;
  BEGIN

    v_row_start := NVL(ip_offset,1);
    v_row_end := v_row_start + ip_limit;

    IF ip_sortby IS NOT NULL THEN

    IF  ip_sortby='SURVEYID' THEN
          v_sortby := 'tarmp.surveyid';
      ELSIF ip_sortby = 'STUDYID' THEN
          v_sortby := 'tarmp.studyid';
      ELSIF ip_sortby = 'RECIPIENT' THEN
          v_sortby := 'tarmp.surveyrecipient';
      ELSIF ip_sortby = 'ENTITY' THEN
          v_sortby := 'tcp.entity';
      ELSIF ip_sortby= 'REFID' THEN
          v_sortby := 'tap.entityrefid';
      ELSIF ip_sortby = 'CHANGEDDT' THEN
          v_sortby := 'tap.createddt';
      END IF;
    ELSE
      --Default Sorting
      v_sortby := ' upper(entity),tap.entityrefid,tap.createddt ';
    END IF;

    v_orderby_clause :=  ' ORDER BY ' || v_sortby;

    IF ip_ordrby IS NOT NULL THEN
       v_orderby_clause := v_orderby_clause || ' ' || ip_ordrby;
    END IF;

    v_page_select_clause := ' SELECT * FROM(
                              SELECT  report_data.*,ROWNUM rnum FROM( ';

    v_page_where_clause := ' ) report_data
                             WHERE ROWNUM < '|| v_row_end || ' )
                             WHERE rnum >= ' || v_row_start;

    v_select_cnt_clause := ' SELECT COUNT(1) ';

    v_select_clause:= ' SELECT tarmp.surveyid,tarmp.surveyname,pkg_audit.fn_get_lov_value(tarmp.studyid,''STUDY'') studyid,tarmp.surveyrecipient,
                                CASE
                                   WHEN  TAP.tablename=''TBL_SURVEYSECTION'' and tap.columnname=''SECTIONTITLE'' THEN
                                           CASE WHEN  (select a.istemplate  from tbl_surveysection a where a.surveysectionid=tap.entityrefid)=''0'' THEN ''Survey Design''  ELSE ''Template Design'' END  --

                                    WHEN  tap.tablename = ''TBL_SURVEYQUESTION'' AND tap.columnname in (''QUESPOSITION'') THEN
                                           CASE WHEN (select b.istemplate  from TBL_SURVEYQUESTION b where b.surveyquesid=tap.entityrefid)=''0'' OR (select b.istemplate  from TBL_SURVEYQUESTION b where b.surveyquesid=tap.entityrefid) is null THEN ''Survey Design''  ELSE ''Template Design'' END --

                                   WHEN tap.tablename = ''TBL_SURVEYANSWER'' AND tap.columnname=''ANSPOSITION'' THEN
                                           CASE WHEN  (select surqstn.istemplate from TBL_SURVEYANSWER surans,TBL_SURVEYQUESTION surqstn where surans.surveyquesid=surqstn.surveyquesid and surans.surveyansid=tap.entityrefid )=''0'' OR (select surqstn.istemplate from TBL_SURVEYANSWER surans,TBL_SURVEYQUESTION surqstn where surans.surveyquesid=surqstn.surveyquesid and surans.surveyansid=tap.entityrefid ) is null THEN ''Survey Design''  ELSE ''Template Design'' END  --

                                   /*WHEN tap.tablename = ''TBL_SURVEY_COUNTRYMAP'' AND tap.columnname in (''COUNTRYID'',''ISTEMPLATE'') THEN
                                            CASE WHEN TAP.NEWVALUE=''0'' THEN ''Survey Design''  ELSE ''Template Design'' END    --*/

                                   WHEN tap.tablename = ''TBL_SURVEY_THERAPEUTICAREAMAP'' AND tap.columnname in (''THERAPEUTICAREAID'') THEN
                                             CASE WHEN (select c.istemplate  from TBL_SURVEY_THERAPEUTICAREAMAP c where c.mapid=tap.entityrefid)=''0'' OR (select c.istemplate  from TBL_SURVEY_THERAPEUTICAREAMAP c where c.mapid=tap.entityrefid) is null  THEN ''Study Details''  ELSE ''Template Details'' END    --

                                   WHEN tap.tablename = ''TBL_SURVEY_COMPOUNDMAP'' AND tap.columnname in (''COMPOUNDID'') THEN
                                             CASE WHEN (select d.istemplate  from TBL_SURVEY_COMPOUNDMAP d where d.mapid=tap.entityrefid )=''0'' OR (select d.istemplate  from TBL_SURVEY_COMPOUNDMAP d where d.mapid=tap.entityrefid ) is null THEN ''Study Details''  ELSE ''Template Details'' END   --

                                   WHEN tap.tablename = ''TBL_SURVEY_INDICATIONMAP'' AND tap.columnname in (''INDICATIONID'') THEN
                                             CASE WHEN (select e.istemplate  from TBL_SURVEY_INDICATIONMAP e where e.mapid=tap.entityrefid)=''0'' OR (select e.istemplate  from TBL_SURVEY_INDICATIONMAP e where e.mapid=tap.entityrefid) is null THEN ''Study Details''  ELSE ''Template Details'' END  --

                                  WHEN tap.tablename = ''TBL_SURVEY_PROGRAMMAP'' AND tap.columnname in (''PROGRAMID'') THEN
                                             CASE WHEN (select f.istemplate  from TBL_SURVEY_PROGRAMMAP f where f.mapid=tap.entityrefid)=''0'' OR (select f.istemplate  from TBL_SURVEY_INDICATIONMAP f where f.mapid=tap.entityrefid) is null THEN ''Study Details''  ELSE ''Template Details'' END   --  --

                                   WHEN tap.tablename = ''TBL_SURVEYLOGICJUMP'' AND tap.columnname=''SURVEYANSID'' THEN
                                             CASE WHEN TAP.Newvalue is not null THEN ''Survey Design''  ELSE ''Template Design'' END  --

                               WHEN tap.tablename = ''TBL_SURVEY'' AND tap.columnname=''SURVEYCLOSEDDT'' THEN
                                             CASE WHEN TAP.NEWVALUE is not null THEN ''Survey Recipients''  ELSE tcp.entity END    --

                                WHEN tap.tablename = ''TBL_RESPONSEMANAGERMAP'' AND tap.columnname=''RESPONSEMANAGERID'' THEN
                                             CASE WHEN TAP.NEWVALUE is not null THEN ''Manage Responses''  ELSE tcp.entity END

                                  WHEN tap.tablename = ''TBL_SURVEYRESPONSE'' AND tap.Columnname=''SURVEYRESPONSEID''  THEN
                                            CASE WHEN TAP.NEWVALUE IS NOT NULL THEN  ''Manage Responses''  ELSE tcp.entity END

                                  WHEN tap.tablename = ''TBL_REASONLIST'' AND tap.Columnname=''LISTNAME'' THEN
                                       CASE WHEN (SELECT COUNT(*) FROM TBL_REASONLIST WHERE REASONLISTID IN (SELECT REASONLISTID FROM TBL_SURVEY)  AND REASONLISTID=TAP.ENTITYREFID AND ISSPONSORDEFAULT<>''Y'')>0 THEN
                                       ''Decline Reasons'' ELSE (CASE WHEN (SELECT COUNT(*) FROM TBL_REASONLIST WHERE REASONLISTID IN (SELECT REASONLISTID FROM TBL_SURVEY)  AND REASONLISTID=TAP.ENTITYREFID AND ISSPONSORDEFAULT=''Y'')>0 THEN ''Sponsor Default Decline Reasons'' ELSE ''Decline Reasons'' END )  END --

                                 WHEN tap.tablename = ''TBL_REASONS'' AND tap.Columnname=''REASON'' THEN
                                       CASE WHEN (SELECT COUNT(*) FROM TBL_REASONS WHERE REASONLISTID IN (SELECT REASONLISTID FROM TBL_SURVEY) AND REASONID=TAP.ENTITYREFID )>0 THEN
                                       ''Decline Reasons'' ELSE (CASE WHEN (SELECT COUNT(*) FROM TBL_REASONS WHERE REASONLISTID IN (SELECT REASONLISTID FROM TBL_SURVEY) AND REASONID=TAP.ENTITYREFID )<0 THEN ''Sponsor Default Decline Reasons'' ELSE ''Decline Reasons'' END ) END     ---


                                    WHEN tap.tablename = ''TBL_SURVEYQUESTION'' AND tap.columnname in (''FIRSTINDICATES'') THEN
                                           CASE WHEN (select g.istemplate  from TBL_SURVEYQUESTION g where g.surveyquesid=tap.entityrefid)=''0'' THEN  ''Survey Design''  ELSE tcp.entity END  --

                                     WHEN tap.tablename = ''TBL_SURVEYQUESTION'' AND tap.columnname in (''LASTINDICATES'') THEN
                                         CASE WHEN (select g.istemplate  from TBL_SURVEYQUESTION g where g.surveyquesid=tap.entityrefid)=''0''  THEN ''Survey Design''  ELSE tcp.entity END  --

                                     /*WHEN tap.tablename = ''TBL_SURVEYRESPONSELIST'' AND tap.columnname=''LISTNAME'' THEN
                                         CASE WHEN TAP.NEWVALUE is not null THEN   ''Site User Survey Response''  ELSE tcp.entity END*/


                                            ELSE
                                                tcp.entity
                                   END
                                       entity   ,tap.entityrefid,
                                     CASE
                                      WHEN TAP.tablename=''TBL_SURVEYSECTION'' and tap.columnname=''SECTIONTITLE'' THEN
                                           CASE WHEN  (select a.istemplate  from tbl_surveysection a where a.surveysectionid=tap.entityrefid)=''0'' THEN ''Survey Section Name''  ELSE ''Template Section Name''      --

                                    END  WHEN tap.tablename = ''TBL_RESPONSEMANAGERMAP'' AND tap.Columnname=''RESPONSEMANAGERID''  THEN
                                            CASE WHEN TAP.NEWVALUE IS NOT NULL THEN  ''Assigned To''  ELSE tcp.fieldname END

                                      WHEN tap.tablename = ''TBL_SURVEYRESPONSE'' AND tap.Columnname=''SURVEYRESPONSEID''  THEN
                                            CASE WHEN TAP.NEWVALUE IS NOT NULL THEN  ''Response''  ELSE tcp.fieldname END

                                    WHEN tap.tablename = ''TBL_REASONLIST'' AND tap.Columnname=''LISTNAME'' THEN
                                       CASE WHEN (SELECT COUNT(*) FROM TBL_REASONLIST WHERE REASONLISTID IN (SELECT REASONLISTID FROM TBL_SURVEY)  AND REASONLISTID=TAP.ENTITYREFID)>0 THEN
                                       ''List Name'' ELSE tcp.fieldname  END   --

                                     WHEN tap.tablename = ''TBL_REASONS'' AND tap.Columnname=''REASON'' THEN
                                       CASE WHEN (SELECT COUNT(*) FROM TBL_REASONS WHERE REASONLISTID IN (SELECT REASONLISTID FROM TBL_SURVEY) AND REASONID=TAP.ENTITYREFID )>0 THEN
                                       ''Decline Reason'' ELSE tcp.fieldname END   --

                                      WHEN tap.tablename = ''TBL_SURVEYQUESTION'' AND tap.columnname in (''FIRSTINDICATES'') THEN
                                           CASE WHEN (select g.istemplate  from TBL_SURVEYQUESTION g where g.surveyquesid=tap.entityrefid)=''0'' THEN   ''First Indicates''  ELSE tcp.fieldname END  --

                                     WHEN tap.tablename = ''TBL_SURVEYQUESTION'' AND tap.columnname in (''LASTINDICATES'') THEN
                                         CASE WHEN (select g.istemplate  from TBL_SURVEYQUESTION g where g.surveyquesid=tap.entityrefid)=''0'' THEN  ''Last Indicates''  ELSE tcp.fieldname END   --

                                    /* WHEN tap.tablename = ''TBL_SURVEYRESPONSELIST'' AND tap.columnname=''LISTNAME'' THEN
                                         CASE WHEN TAP.NEWVALUE is not null THEN   ''Survey ID ''  ELSE tcp.fieldname END*/

                                         WHEN tap.tablename = ''TBL_SURVEY_THERAPEUTICAREAMAP'' AND tap.columnname in (''THERAPEUTICAREAID'') THEN
                                             CASE WHEN (select c.mapid  from TBL_SURVEY_THERAPEUTICAREAMAP c where c.mapid=tap.entityrefid)=''1'' THEN ''Sponsor Therapeutic Area'' ELSE  tcp.fieldname END --

                                            WHEN tap.tablename = ''TBL_SURVEY_INDICATIONMAP'' AND tap.columnname in (''INDICATIONID'') THEN
                                             CASE WHEN (select e.istemplate  from TBL_SURVEY_INDICATIONMAP e where e.mapid=tap.entityrefid)=''0'' THEN ''Indication'' ELSE  tcp.fieldname END  --

                                            ELSE
                                        tcp.fieldname
                               END fieldname,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.oldvalue)
                                  ELSE
                                      tap.oldvalue
                               END oldvalue,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.newvalue)
                                  ELSE
                                      tap.newvalue
                               END newvalue,
                               tap.operation,
                               (SELECT INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname)) || '' ('' ||
                               CASE
                                WHEN up.issponsor = ''Y'' THEN
                                    up.actualtranscelerateuserid
                                ELSE
                                    up.transcelerateuserid
                               END
                               ||'')''
                               FROM tbl_userprofiles up
                               WHERE up.transcelerateuserid = tap.createdby ) createdby,
                               TO_CHAR(tap.createddt,''DD-Mon-YYYY HH24:MI:SS'') createddt,tap.reason ';

    v_from_clause:= ' FROM tbl_audit tap,
                           tbl_surveyauditreportmap tarmp,
                           tbl_columnfieldmap tcp ';

    v_where_clause:= ' WHERE tap.auditid = tarmp.surveyauditid
                       AND tap.tablename = tcp.tablename
                       AND tap.columnname = tcp.columnname
                       AND tcp.ISACTIVE = ''Y''
                       AND (tap.oldvalue is not null or tap.newvalue is not null)';

    IF ip_startdate IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tap.modifieddt >= ' || CHR(39) || TRUNC(ip_startdate) || CHR(39);
    END IF;

    IF ip_enddate IS NOT NULL THEN
      v_where_clause :=   v_where_clause || ' AND tap.modifieddt < ' || CHR(39) || TRUNC(ip_enddate+1) || CHR(39);
    END IF;

    IF ip_changedby IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tap.createdby = ' || CHR(39) || ip_changedby || CHR(39);
    END IF;

    IF ip_surveytitle IS NOT NULL THEN
            v_where_clause :=  v_where_clause || ' AND LOWER(tarmp.SURVEYNAME)  LIKE LOWER(''%' || upper(ip_surveytitle) ||'%'')';
    END IF;

    IF ip_studyid IS NOT NULL THEN
         v_where_clause :=  v_where_clause || ' AND tarmp.STUDYID = ' || ip_studyid;
    END IF;
    IF ip_surveyid IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tarmp.surveyid = ' || ip_surveyid;
    END IF;


    v_final_cnt_sql := v_select_cnt_clause || v_from_clause || v_where_clause || v_orderby_clause;
    --DBMS_OUTPUT.PUT_LINE(v_final_cnt_sql);

    v_final_sql := v_page_select_clause || v_select_clause || v_from_clause || v_where_clause || v_orderby_clause || v_page_where_clause;
    --DBMS_OUTPUT.PUT_LINE(v_final_sql);
   -- INSERT INTO TEMP_TABLE VALUES(v_final_sql);
   -- COMMIT;

    v_cursorid := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursorid,v_final_cnt_sql,DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, op_count);
    v_rows_processed := DBMS_SQL.EXECUTE(v_cursorid);
    IF DBMS_SQL.FETCH_ROWS(v_cursorid) <> 0 THEN
       DBMS_SQL.COLUMN_VALUE(v_cursorid,1,op_count);
    END IF;
    DBMS_SQL.CLOSE_CURSOR(v_cursorid);

    OPEN op_audit_report FOR v_final_sql;

  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RAISE;
  END sp_get_survey_audit;

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
     )


  IS
  v_row_start           PLS_INTEGER;
  v_row_end             PLS_INTEGER;
  v_where_clause   VARCHAR2(32767);
  v_select_clause  VARCHAR2(32767);
  v_from_clause    VARCHAR2(32767);
  v_orderby_clause VARCHAR2(32767);
  v_sortby              VARCHAR2(32767);
  v_page_select_clause  VARCHAR2(32767);
  v_page_where_clause   VARCHAR2(32767);
  v_select_cnt_clause   VARCHAR2(32767);
  v_final_cnt_sql       VARCHAR2(32767);
  v_final_sql      VARCHAR2(32767);

  v_where_clause1  VARCHAR2(32767);
  v_where_clause2  VARCHAR2(32767);
  v_final_cnt_sql1  number;
  v_final_cnt_sql2  number;

  v_final_sql1 VARCHAR2(32767);
  v_final_sql2 VARCHAR2(32767);
  v_end_date  date;
  v_org_check VARCHAR2(32767);
  v_orgcount  varchar2(32767);
  l_orgcount  number;
  v_final_sql_cnt  varchar2(32767);
  v_changedby VARCHAR2(32767);

 v_cursorid            PLS_INTEGER;
 v_rows_processed      PLS_INTEGER;

  BEGIN
    v_end_date :=ip_enddate+1;
    v_row_start := NVL(ip_offset,1);
    v_row_end := v_row_start + ip_limit;

    IF ip_sortby IS NOT NULL THEN
      IF ip_sortby = 'REQUESTEDBY' THEN
          v_sortby := 'requestedby';
      END IF;
    ELSE
      --Default Sorting
        v_sortby := ' upper(requestedby),upper(entity),requestid,createddt,upper(fieldname) ';
    END IF;

    v_orderby_clause :=  ' WHERE REQUESTID IS NOT NULL ORDER BY ' || v_sortby;

    IF ip_ordrby IS NOT NULL THEN
       v_orderby_clause := v_orderby_clause || ' ' || ip_ordrby;
    END IF;

    IF ip_changedby IS NOT NULL THEN
        v_changedby := ' AND tap.createdby LIKE ' || '''%' || ip_changedby || '%'' ';
    ELSE
        v_changedby := ' AND 1 = 1 ';
    END IF;

    v_page_select_clause := ' SELECT * FROM(
                              SELECT  report_data.*,ROWNUM rnum FROM( ';

    v_page_where_clause := ' ) report_data
                             WHERE ROWNUM < '|| v_row_end || ' )
                             WHERE rnum >= ' || v_row_start;

    --v_select_cnt_clause := ' SELECT COUNT(1) ';

    v_org_check:='SELECT  * FROM(SELECT distinct (INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname))) as requestedby,case when trng.Reviewer IS NOT NULL  then  (SELECT REQUESTID FROM TBL_TRNGCREDITS WHERE REQUESTID=tarmp.requestid AND ISMRT=''N'' AND REVIEWER='||ip_orgid||' ) else ---
                                 trng.requestid  end requestid,tcp.entity,tcp.fieldname,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.oldvalue)
                                  ELSE
                                      tap.oldvalue
                               END oldvalue,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.newvalue)
                                  ELSE
                                      tap.newvalue
                               END newvalue,
                               tap.operation,
                                CASE
                                   WHEN PKG_AUDIT.FN_CHECK_USER_ORG(tap.createdby,'||ip_orgid||') <>0 THEN
                                        (SELECT INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname)) || '' ('' ||
                                        CASE
                                            WHEN up.issponsor = ''Y'' THEN
                                                 up.actualtranscelerateuserid
                                        ELSE
                                                 up.transcelerateuserid
                                        END
                                        ||'')''
                                        FROM tbl_userprofiles up
                                        WHERE up.transcelerateuserid = tap.createdby )
                               ELSE
                                   PKG_AUDIT.FN_GET_USER_ORGNAME(tap.createdby)
                               END createdby ,
                               TO_CHAR(tap.createddt,''DD-Mon-YYYY HH24:MI:SS'') createddt  FROM tbl_audit tap,
                           tbl_trngcreditsauditreportmap tarmp,
                           tbl_columnfieldmap tcp, tbl_userprofiles up ,TBL_TRNGCREDITS trng  WHERE tap.auditid = tarmp.trngcreditsauditid
                       AND tap.tablename = tcp.tablename
                       AND tap.columnname = tcp.columnname
                       AND up.userid = tarmp.REQUESTEDFOR
                       And trng.requestid=tarmp.requestid
                       AND tcp.ISACTIVE = ''Y''
                       AND tarmp.requestedfor = '||ip_requestedby||'
                       AND tcp.fieldname not in (''Approver'',''Training Sponsor'')
                        AND (tap.oldvalue is not null or tap.newvalue is not null)
                       UNION ALL
                       SELECT distinct (INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname))) as requestedby,case when trng.Reviewer IS NOT NULL  then  (SELECT REQUESTID FROM TBL_TRNGCREDITS WHERE REQUESTID=tarmp.requestid AND ISMRT=''N'' AND REVIEWER='||ip_orgid||' ) else ---
                                 trng.requestid  end requestid,tcp.entity,tcp.fieldname,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.oldvalue)
                                  ELSE
                                      tap.oldvalue
                               END oldvalue,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.newvalue)
                                  ELSE
                                      tap.newvalue
                               END newvalue,
                               tap.operation,
                                CASE
                                   WHEN PKG_AUDIT.FN_CHECK_USER_ORG(tap.createdby,'||ip_orgid||') <>0 THEN
                                        (SELECT INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname)) || '' ('' ||
                                        CASE
                                            WHEN up.issponsor = ''Y'' THEN
                                                 up.actualtranscelerateuserid
                                        ELSE
                                                 up.transcelerateuserid
                                        END
                                        ||'')''
                                        FROM tbl_userprofiles up
                                        WHERE up.transcelerateuserid = tap.createdby )
                               ELSE
                                   PKG_AUDIT.FN_GET_USER_ORGNAME(tap.createdby)
                               END createdby ,
                               TO_CHAR(tap.createddt,''DD-Mon-YYYY HH24:MI:SS'') createddt  FROM tbl_audit tap,
                           tbl_trngcreditsauditreportmap tarmp,
                           tbl_columnfieldmap tcp, tbl_userprofiles up,TBL_TRNGCREDITS trng  WHERE tap.auditid = tarmp.trngcreditsauditid
                       AND tap.tablename = tcp.tablename
                       AND tap.columnname = tcp.columnname
                       AND up.userid = tarmp.REQUESTEDFOR
                       And trng.requestid=tarmp.requestid
                       AND tcp.ISACTIVE = ''Y''
                       AND tarmp.requestedfor = '||ip_requestedby||'
                       AND tcp.fieldname IN (''Approver'')
                       AND (tap.oldvalue is not null or tap.newvalue is not null)
                       AND Tap.Newvalue in (SELECT CASE
                 WHEN u.issponsor = ''Y'' THEN
                    u.actualtranscelerateuserid
                 ELSE
                    u.transcelerateuserid
             END FROM tbl_userprofiles u WHERE U.Orgid='||ip_orgid||')
                      UNION ALL   SELECT (INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname))) as requestedby,case when trng.Reviewer IS NOT NULL  then  (SELECT REQUESTID FROM TBL_TRNGCREDITS WHERE REQUESTID=tarmp.requestid AND ISMRT=''N'' AND REVIEWER='||ip_orgid||' ) else ---
                                 trng.requestid  end requestid,tcp.entity,tcp.fieldname,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.oldvalue)
                                  ELSE
                                      tap.oldvalue
                               END oldvalue,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.newvalue)
                                  ELSE
                                      tap.newvalue
                               END newvalue,
                               tap.operation,
                              CASE
                                   WHEN PKG_AUDIT.FN_CHECK_USER_ORG(tap.createdby,'||ip_orgid||') <>0 THEN
                                        (SELECT INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname)) || '' ('' ||
                                        CASE
                                            WHEN up.issponsor = ''Y'' THEN
                                                 up.actualtranscelerateuserid
                                        ELSE
                                                 up.transcelerateuserid
                                        END
                                        ||'')''
                                        FROM tbl_userprofiles up
                                        WHERE up.transcelerateuserid = tap.createdby )
                               ELSE
                                   PKG_AUDIT.FN_GET_USER_ORGNAME(tap.createdby)
                               END createdby ,
                               TO_CHAR(tap.createddt,''DD-Mon-YYYY HH24:MI:SS'') createddt  FROM tbl_audit tap,
                           tbl_trngcreditsauditreportmap tarmp,
                           tbl_columnfieldmap tcp, tbl_userprofiles up,TBL_TRNGCREDITS trng  WHERE tap.auditid = tarmp.trngcreditsauditid
                       AND tap.tablename = tcp.tablename
                       AND tap.columnname = tcp.columnname
                       AND up.userid = tarmp.REQUESTEDFOR
                       And trng.requestid=tarmp.requestid
                       AND tcp.ISACTIVE = ''Y''
                       AND tarmp.requestedfor = '||ip_requestedby||'
                       AND tcp.fieldname IN (''Training Sponsor'')
                       AND (tap.oldvalue is not null or tap.newvalue is not null)
                       AND Tap.Newvalue in (SELECT Org.Orgname FROM Tbl_Organization org WHERE org.Orgid='||ip_orgid||'))';

v_orgcount := 'select count(*) from ('||v_org_check||')';

--dbms_output.put_line(v_orgcount);

    v_cursorid := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursorid,v_orgcount,DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, l_orgcount);
    v_rows_processed := DBMS_SQL.EXECUTE(v_cursorid);
    IF DBMS_SQL.FETCH_ROWS(v_cursorid) <> 0 THEN
       DBMS_SQL.COLUMN_VALUE(v_cursorid,1,l_orgcount);
    END IF;
    DBMS_SQL.CLOSE_CURSOR(v_cursorid);

if l_orgcount<>0  then

   v_final_sql:='SELECT  * FROM(SELECT distinct (INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname)) ) as requestedby,case when trng.Reviewer IS NOT NULL  then  (SELECT REQUESTID FROM TBL_TRNGCREDITS WHERE REQUESTID=tarmp.requestid AND ISMRT=''N'' AND REVIEWER='||ip_orgid||' ) else ---
                                 trng.requestid  end requestid,tcp.entity,tcp.fieldname,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.oldvalue)
                                  ELSE
                                      tap.oldvalue
                               END oldvalue,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.newvalue)
                                  ELSE
                                      tap.newvalue
                               END newvalue,
                               tap.operation,
                               CASE
                                   WHEN PKG_AUDIT.FN_CHECK_USER_ORG(tap.createdby,'||ip_orgid||') <>0 THEN
                                        (SELECT INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname)) || '' ('' ||
                                        CASE
                                            WHEN up.issponsor = ''Y'' THEN
                                                 up.actualtranscelerateuserid
                                        ELSE
                                                 up.transcelerateuserid
                                        END
                                        ||'')''
                                        FROM tbl_userprofiles up
                                        WHERE up.transcelerateuserid = tap.createdby )
                               ELSE
                                   PKG_AUDIT.FN_GET_USER_ORGNAME(tap.createdby)
                               END createdby ,
                               TO_CHAR(tap.createddt,''DD-Mon-YYYY HH24:MI:SS'') createddt  FROM tbl_audit tap,
                           tbl_trngcreditsauditreportmap tarmp,
                           tbl_columnfieldmap tcp, tbl_userprofiles up,TBL_TRNGCREDITS trng  WHERE tap.auditid = tarmp.trngcreditsauditid
                       AND tap.tablename = tcp.tablename
                       AND tap.columnname = tcp.columnname
                       AND up.userid = tarmp.REQUESTEDFOR
                       And trng.requestid=tarmp.requestid
                       AND tcp.ISACTIVE = ''Y''
                   AND tap.modifieddt >= '''||ip_startdate||'''
                      AND tap.modifieddt < '''||v_end_date||'''
                       AND tarmp.requestedfor = '||ip_requestedby||
                       v_changedby ||
                       '  AND tcp.fieldname not in (''Approver'',''Training Sponsor'')
                        AND (tap.oldvalue is not null or tap.newvalue is not null)
                       UNION ALL
                       SELECT distinct (INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname)) ) as requestedby,case when trng.Reviewer IS NOT NULL  then  (SELECT REQUESTID FROM TBL_TRNGCREDITS WHERE REQUESTID=tarmp.requestid AND ISMRT=''N'' AND REVIEWER='||ip_orgid||' ) else ---
                                 trng.requestid  end requestid,tcp.entity,tcp.fieldname,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.oldvalue)
                                  ELSE
                                      tap.oldvalue
                               END oldvalue,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.newvalue)
                                  ELSE
                                      tap.newvalue
                               END newvalue,
                               tap.operation,
                              CASE
                                   WHEN PKG_AUDIT.FN_CHECK_USER_ORG(tap.createdby,'||ip_orgid||') <>0 THEN
                                        (SELECT INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname)) || '' ('' ||
                                        CASE
                                            WHEN up.issponsor = ''Y'' THEN
                                                 up.actualtranscelerateuserid
                                        ELSE
                                                 up.transcelerateuserid
                                        END
                                        ||'')''
                                        FROM tbl_userprofiles up
                                        WHERE up.transcelerateuserid = tap.createdby )
                               ELSE
                                   PKG_AUDIT.FN_GET_USER_ORGNAME(tap.createdby)
                               END createdby ,
                               TO_CHAR(tap.createddt,''DD-Mon-YYYY HH24:MI:SS'') createddt  FROM tbl_audit tap,
                           tbl_trngcreditsauditreportmap tarmp,
                           tbl_columnfieldmap tcp, tbl_userprofiles up,TBL_TRNGCREDITS trng  WHERE tap.auditid = tarmp.trngcreditsauditid
                       AND tap.tablename = tcp.tablename
                       AND tap.columnname = tcp.columnname
                       AND up.userid = tarmp.REQUESTEDFOR
                       And trng.requestid=tarmp.requestid
                       AND tcp.ISACTIVE = ''Y''
                    AND tap.modifieddt >= '''||ip_startdate||'''
                      AND tap.modifieddt < '''||v_end_date||'''
                       AND tarmp.requestedfor = '||ip_requestedby||
                       v_changedby ||
                       ' AND tcp.fieldname IN (''Approver'')
                       AND (tap.oldvalue is not null or tap.newvalue is not null)
                       AND Tap.Newvalue in (SELECT CASE
                 WHEN u.issponsor = ''Y'' THEN
                    u.actualtranscelerateuserid
                 ELSE
                    u.transcelerateuserid
             END FROM tbl_userprofiles u WHERE U.Orgid='||ip_orgid||')
                      UNION ALL   SELECT distinct (INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname)))
                                as requestedby,case when trng.Reviewer IS NOT NULL  then  (SELECT REQUESTID FROM TBL_TRNGCREDITS WHERE REQUESTID=tarmp.requestid AND ISMRT=''N'' AND REVIEWER='||ip_orgid||' ) else ---
                                 trng.requestid  end requestid,tcp.entity,tcp.fieldname,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.oldvalue)
                                  ELSE
                                      tap.oldvalue
                               END oldvalue,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.newvalue)
                                  ELSE
                                      tap.newvalue
                               END newvalue,
                               tap.operation,
                              CASE
                                   WHEN PKG_AUDIT.FN_CHECK_USER_ORG(tap.createdby,'||ip_orgid||') <>0 THEN
                                        (SELECT INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname)) || '' ('' ||
                                        CASE
                                            WHEN up.issponsor = ''Y'' THEN
                                                 up.actualtranscelerateuserid
                                        ELSE
                                                 up.transcelerateuserid
                                        END
                                        ||'')''
                                        FROM tbl_userprofiles up
                                        WHERE up.transcelerateuserid = tap.createdby )
                               ELSE
                                   PKG_AUDIT.FN_GET_USER_ORGNAME(tap.createdby)
                               END createdby ,
                               TO_CHAR(tap.createddt,''DD-Mon-YYYY HH24:MI:SS'') createddt  FROM tbl_audit tap,
                           tbl_trngcreditsauditreportmap tarmp,
                           tbl_columnfieldmap tcp, tbl_userprofiles up,TBL_TRNGCREDITS trng  WHERE tap.auditid = tarmp.trngcreditsauditid
                       AND tap.tablename = tcp.tablename
                       AND tap.columnname = tcp.columnname
                       AND up.userid = tarmp.REQUESTEDFOR
                       And trng.requestid=tarmp.requestid
                       AND tcp.ISACTIVE = ''Y''
                    AND tap.modifieddt >= '''||ip_startdate||'''
                      AND tap.modifieddt < '''||v_end_date||'''
                       AND tarmp.requestedfor = '||ip_requestedby||
                       v_changedby ||
                       ' AND tcp.fieldname IN (''Training Sponsor'')
                       AND (tap.oldvalue is not null or tap.newvalue is not null)
                       AND Tap.Newvalue in (SELECT Org.Orgname FROM Tbl_Organization org WHERE org.Orgid='||ip_orgid||')) ';

  if ip_changedby is null then

      v_final_sql_cnt:=v_final_sql||v_where_clause||v_orderby_clause;
   v_final_sql:=v_page_select_clause||v_final_sql||v_where_clause||v_orderby_clause||v_page_where_clause;

      --v_final_sql_cnt:=v_final_sql||v_where_clause||v_orderby_clause;

   v_final_cnt_sql:='select count(*) from ('||v_final_sql_cnt||')';

  -- dbms_output.put_line('count SQL is -->'||v_final_cnt_sql);

   elsif ip_changedby is not null then

        v_final_sql_cnt:=v_final_sql||v_where_clause||v_orderby_clause;
   v_final_sql:=v_page_select_clause||v_final_sql||v_where_clause||v_orderby_clause||v_page_where_clause;

      --v_final_sql_cnt:=v_final_sql||v_where_clause||v_orderby_clause;

   v_final_cnt_sql:='select count(*) from ('||v_final_sql_cnt||')';

   --dbms_output.put_line('count SQL is -->'||v_final_cnt_sql);

   end if;
  elsif l_orgcount=0 then
     v_final_sql:=v_org_check||'where entity <> ''Training Credit Requests''';

       if ip_changedby is not  null then

     v_final_sql_cnt:=v_final_sql||v_where_clause||v_orderby_clause;
    v_final_sql:=v_page_select_clause||v_final_sql||v_where_clause||v_orderby_clause||v_page_where_clause;

end if;

       if ip_changedby is null then

     v_final_sql_cnt:=v_final_sql||v_where_clause||v_orderby_clause ;
    v_final_sql:=v_page_select_clause||v_final_sql||v_where_clause||v_orderby_clause||v_page_where_clause;

end if;
  --v_final_sql_cnt:=v_final_sql||v_where_clause||v_orderby_clause;

  --dbms_output.put_line('count SQL is -->'||v_final_sql_cnt);

   v_final_cnt_sql:='select count(*) from ('||v_final_sql_cnt||')';

    end if;

   --DBMS_OUTPUT.PUT_LINE(v_final_sql);
   --insert into temp_table values(null,v_final_sql);
   --COMMIT;

    v_cursorid := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursorid,v_final_cnt_sql,DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, op_count);
    v_rows_processed := DBMS_SQL.EXECUTE(v_cursorid);
    IF DBMS_SQL.FETCH_ROWS(v_cursorid) <> 0 THEN
       DBMS_SQL.COLUMN_VALUE(v_cursorid,1,op_count);
    END IF;
    DBMS_SQL.CLOSE_CURSOR(v_cursorid);

    OPEN op_audit_report FOR v_final_sql;

  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
  END SP_GET_TRNGCREDITS_AUDIT;

  PROCEDURE SP_SET_TRNGCREDITSATREPORTMAP
    (ip_auditid           IN tbl_trngcreditsauditreportmap.trngcreditsauditid%TYPE,
     ip_requestid         IN tbl_trngcreditsauditreportmap.requestid%TYPE,
     ip_requestedby          IN tbl_trngcreditsauditreportmap.requestedby%TYPE,
     ip_requestedfor      IN tbl_trngcreditsauditreportmap.requestedfor%TYPE,
     ip_createddt         IN tbl_surveyauditreportmap.CREATEDDT%TYPE,
     ip_createdby         IN tbl_trngcreditsauditreportmap.createdby%TYPE,
     ip_modifieddt        IN tbl_trngcreditsauditreportmap.modifieddt%TYPE,
     ip_modifiedby         IN tbl_trngcreditsauditreportmap.modifiedby%TYPE
        )

  IS
  BEGIN
    INSERT INTO tbl_trngcreditsauditreportmap(trngcreditsauditreportmapid, trngcreditsauditid, requestid, requestedby, requestedfor, createddt, createdby, modifieddt, modifiedby)
    VALUES(SEQ_TRNGCREDITSAUDITREPORTMAP.NEXTVAL, ip_auditid, ip_requestid, ip_requestedby,ip_requestedfor,
          NVL(ip_createddt,NVL(ip_modifieddt,SYSDATE)),
          NVL(ip_createdby,NVL(ip_modifiedby,'SYSTEM')),
          NVL(ip_modifieddt,NVL(ip_createddt,SYSDATE)),
          NVL(ip_modifiedby,NVL(ip_createdby,'SYSTEM')));

  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RAISE;
  END SP_SET_TRNGCREDITSATREPORTMAP;

  PROCEDURE SP_SET_TRNGSTATUSATREPORTMAP
    (ip_auditid          IN TBL_TRNGSTATUSAUDITREPORTMAP.TRNGSTATUSAUDITID%TYPE,
    ip_courseid          IN TBL_TRNGSTATUSAUDITREPORTMAP.COURSEID%TYPE,
     ip_userid            IN TBL_TRNGSTATUSAUDITREPORTMAP.USERID%TYPE,
     ip_studyid          IN TBL_TRNGSTATUSAUDITREPORTMAP.STUDYID%TYPE,
     ip_siteid           IN TBL_TRNGSTATUSAUDITREPORTMAP.SITEID%TYPE,
     ip_createddt        IN TBL_TRNGSTATUSAUDITREPORTMAP.CREATEDDT%TYPE,
     ip_createdby        IN TBL_TRNGSTATUSAUDITREPORTMAP.CREATEDBY%TYPE,
     ip_modifieddt       IN TBL_TRNGSTATUSAUDITREPORTMAP.MODIFIEDDT%TYPE,
     ip_modifiedby       IN TBL_TRNGSTATUSAUDITREPORTMAP.MODIFIEDBY%TYPE
        )

  IS
  BEGIN
    INSERT INTO TBL_TRNGSTATUSAUDITREPORTMAP(TRNGSTATUSAUDITREPORTMAPID, TRNGSTATUSAUDITID, COURSEID, USERID, STUDYID, SITEID, CREATEDDT, CREATEDBY, MODIFIEDDT, MODIFIEDBY)
    VALUES(SEQ_TRNGSTATUSAUDITREPORTMAP.NEXTVAL, ip_auditid, ip_courseid, ip_userid, ip_studyid,ip_siteid,
          NVL(ip_createddt,NVL(ip_modifieddt,SYSDATE)),
          NVL(ip_createdby,NVL(ip_modifiedby,'SYSTEM')),
          NVL(ip_modifieddt,NVL(ip_createddt,SYSDATE)),
          NVL(ip_modifiedby,NVL(ip_createdby,'SYSTEM')));

  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RAISE;
  END SP_SET_TRNGSTATUSATREPORTMAP;

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
     )
  IS
  v_row_start           PLS_INTEGER;
  v_row_end             PLS_INTEGER;
  v_where_clause   VARCHAR2(32767);
  v_select_clause  VARCHAR2(32767);
  v_from_clause    VARCHAR2(32767);
  v_orderby_clause VARCHAR2(32767);
  v_sortby              VARCHAR2(32767);
  v_page_select_clause  VARCHAR2(32767);
  v_page_where_clause   VARCHAR2(32767);
  v_select_cnt_clause   VARCHAR2(32767);
  v_final_cnt_sql       VARCHAR2(32767);
  v_final_sql           VARCHAR2(32767);
  v_sitelist            VARCHAR2(32767);
  v_cursorid            PLS_INTEGER;
  v_rows_processed      PLS_INTEGER;
  BEGIN

    v_row_start := NVL(ip_offset,1);
    v_row_end := v_row_start + ip_limit;



      --Default Sorting
      v_sortby := ' trs.courseid,trs.userid,upper(tcp.entity),tap.entityrefid,tap.createddt,upper(tcp.fieldname) ';


    v_orderby_clause :=  ' ORDER BY ' || v_sortby;

    IF ip_ordrby IS NOT NULL THEN
       v_orderby_clause := v_orderby_clause || ' ' || ip_ordrby;
    END IF;

    v_page_select_clause := ' SELECT * FROM(
                              SELECT  report_data.*,ROWNUM rnum FROM( ';

    v_page_where_clause := ' ) report_data
                             WHERE ROWNUM < '|| v_row_end || ' )
                             WHERE rnum >= ' || v_row_start;

    v_select_cnt_clause := ' SELECT COUNT(1) ';

     v_select_clause:= ' select (select distinct course_title  from tbl_user_training_status where course_id  =to_char(trs.courseid) and user_id=trs.USERID ) coursetitle,(SELECT INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname))
                               FROM tbl_userprofiles up
                               WHERE up.userid =trs.userid) username,pkg_audit.fn_get_lov_value(trs.studyid,''' ||  pkg_audit.g_lov_study || ''') studyid,pkg_audit.fn_get_lov_value(trs.siteid,''' ||  pkg_audit.g_lov_site || ''') siteid,tcp.entity,tap.entityrefid,tcp.fieldname,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.oldvalue)
                                  ELSE
                                      tap.oldvalue
                               END oldvalue,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.newvalue)
                                  ELSE
                                      tap.newvalue
                               END newvalue,
                               tap.operation,
                               (SELECT INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname)) || '' ('' ||
                               CASE
                                WHEN up.issponsor = ''Y'' THEN
                                    up.actualtranscelerateuserid
                                ELSE
                                    up.transcelerateuserid
                               END
                               ||'')''
                               FROM tbl_userprofiles up
                               WHERE up.transcelerateuserid = tap.createdby ) createdby,
                               TO_CHAR(tap.createddt,''DD-Mon-YYYY HH24:MI:SS'') createddt,
                               tap.reason';

    v_from_clause:= ' from TBL_TRNGSTATUSAUDITREPORTMAP trs ,
                      tbl_audit tap,
                      tbl_columnfieldmap tcp ';

    v_where_clause:= '  where trs.trngstatusauditid=tap.auditid
                        and  tap.tablename = tcp.tablename
                        AND tap.columnname = tcp.columnname
                        AND tcp.ISACTIVE = ''Y''
                        AND (tap.oldvalue is not null or tap.newvalue is not null)';

    IF ip_startdate IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tap.modifieddt >= ' || CHR(39) || TRUNC(ip_startdate) || CHR(39);
    END IF;

    IF ip_enddate IS NOT NULL THEN
      v_where_clause :=   v_where_clause || ' AND tap.modifieddt < ' || CHR(39) || TRUNC(ip_enddate+1) || CHR(39);
    END IF;

    IF ip_changedby IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tap.createdby = ' || CHR(39) || ip_changedby || CHR(39);
    END IF;

/*  Added by Somajit -- Start */
    IF ip_userid IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND trs.userid = ' || ip_userid;
    END IF;

   IF ip_courseid IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND trs.courseid = ' || ip_courseid;
    END IF;
/* Added by Somajit -- End */

    v_final_cnt_sql := v_select_cnt_clause || v_from_clause || v_where_clause || v_orderby_clause;
   -- DBMS_OUTPUT.PUT_LINE(v_final_cnt_sql);

    v_final_sql := v_page_select_clause || v_select_clause || v_from_clause || v_where_clause || v_orderby_clause || v_page_where_clause;
    --DBMS_OUTPUT.PUT_LINE(v_final_sql);

    v_cursorid := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursorid,v_final_cnt_sql,DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, op_count);
    v_rows_processed := DBMS_SQL.EXECUTE(v_cursorid);
    IF DBMS_SQL.FETCH_ROWS(v_cursorid) <> 0 THEN
       DBMS_SQL.COLUMN_VALUE(v_cursorid,1,op_count);
    END IF;
    DBMS_SQL.CLOSE_CURSOR(v_cursorid);

    OPEN op_trng_audit_report FOR v_final_sql;

  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RAISE;
  END SP_GET_TRNGSTATUSATREPORTMAP;

   PROCEDURE SP_SET_DOCAUDITREPORTMAP
    (ip_auditid           IN TBL_DOCAUDITREPORTMAP.DOCAUDITID%TYPE,
     ip_facilityid        IN TBL_DOCAUDITREPORTMAP.FACILITYID%TYPE,
   ip_userid           IN TBL_DOCAUDITREPORTMAP.USERID%TYPE,
   ip_isforfacility    IN TBL_DOCAUDITREPORTMAP.ISFORFACILITY%TYPE,
   ip_isforuser      IN TBL_DOCAUDITREPORTMAP.ISFORUSER%TYPE,
     ip_createddt         IN TBL_DOCAUDITREPORTMAP.CREATEDDT%TYPE,
     ip_createdby         IN TBL_DOCAUDITREPORTMAP.createdby%TYPE,
     ip_modifieddt        IN TBL_DOCAUDITREPORTMAP.modifieddt%TYPE,
   ip_modifiedby       IN TBL_DOCAUDITREPORTMAP.modifiedby%TYPE,
   ip_documentid      IN TBL_DOCUMENTS.DOCUMENTID%TYPE
     )
  IS
  BEGIN
    INSERT INTO TBL_DOCAUDITREPORTMAP(docauditreportmapid, docauditid, facilityid, userid , isforfacility, isforuser, createddt, createdby, modifieddt, modifiedby,documentid)
    VALUES(SEQ_DOCAUDITREPORTMAP.NEXTVAL, ip_auditid, ip_facilityid, ip_userid,ip_isforfacility, ip_isforuser,
          NVL(ip_createddt,NVL(ip_modifieddt,SYSDATE)),
          NVL(ip_createdby,NVL(ip_modifiedby,'SYSTEM')),
          NVL(ip_modifieddt,NVL(ip_createddt,SYSDATE)),
          NVL(ip_modifiedby,NVL(ip_createdby,'SYSTEM')),
          ip_documentid);

  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RAISE;
  END SP_SET_DOCAUDITREPORTMAP;

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
     )
  IS
  v_row_start           PLS_INTEGER;
  v_row_end             PLS_INTEGER;
  v_where_clause   VARCHAR2(32767);
  v_select_clause  VARCHAR2(32767);
  v_from_clause    VARCHAR2(32767);
  v_orderby_clause VARCHAR2(32767);
  v_sortby              VARCHAR2(32767);
  v_page_select_clause  VARCHAR2(32767);
  v_page_where_clause   VARCHAR2(32767);
  v_select_cnt_clause   VARCHAR2(32767);
  v_final_cnt_sql       VARCHAR2(32767);
  v_final_sql           VARCHAR2(32767);
  v_cursorid            PLS_INTEGER;
  v_rows_processed      PLS_INTEGER;
  BEGIN

    v_row_start := NVL(ip_offset,1);
    v_row_end := v_row_start + ip_limit;

    IF ip_sortby IS NOT NULL THEN
      IF ip_sortby = 'NAME' THEN
          v_sortby := 'tarmp.facilityid';
      END IF;
    ELSE
      --Default Sorting
      v_sortby := 'UPPER(temp.name),UPPER(temp.entity),temp.entityrefid,temp.createddt,UPPER(temp.fieldname) ';
    END IF;

    v_orderby_clause :=  ' ) temp ORDER BY ' || v_sortby;

    IF ip_ordrby IS NOT NULL THEN
       v_orderby_clause := v_orderby_clause || ' ' || ip_ordrby;
    END IF;

    v_page_select_clause := ' SELECT * FROM(
                              SELECT  report_data.*,ROWNUM rnum FROM( SELECT * FROM( ';

    v_page_where_clause := ' ) report_data
                             WHERE ROWNUM < '|| v_row_end || ' )
                             WHERE rnum >= ' || v_row_start;

    v_select_cnt_clause := ' SELECT COUNT(1) ';

    v_select_clause:= ' SELECT (CASE
                                    WHEN ISDEPARTMENT = ''N'' THEN
                                         fac.FACILITYNAME
                                    ELSE fac.departmentname
                               END) || '' ('' || fac.facilityid || '')'' as name,
                               tarmp.documentid,
                               CASE
                                   WHEN tap.tablename = ''TBL_FACILITYDOCMETADATA'' THEN
                                        CASE
                                            WHEN (SELECT tfdm.docuploadedfor
                                                  FROM TBL_FACILITYDOCMETADATA tfdm
                                                  WHERE tfdm.facilitydocmetadataid = tap.entityrefid) = ''IRB'' THEN
                                                  ''Facility Documents - IRB''
                                            WHEN (SELECT tfdm.docuploadedfor
                                                  FROM TBL_FACILITYDOCMETADATA tfdm
                                                  WHERE tfdm.facilitydocmetadataid = tap.entityrefid) = ''LAB'' THEN
                                                  ''Facility Documents - Local Lab''
                                            WHEN (SELECT tfdm.docuploadedfor
                                                  FROM TBL_FACILITYDOCMETADATA tfdm
                                                  WHERE tfdm.facilitydocmetadataid = tap.entityrefid) IN (''CTRLSUB'',''IPATTACH'',''IPCSATTACH'') THEN
                                                  ''Facility Documents - Investigation Product and Controlled Substances''
                                            WHEN (SELECT tfdm.docuploadedfor
                                                  FROM TBL_FACILITYDOCMETADATA tfdm
                                                  WHERE tfdm.facilitydocmetadataid = tap.entityrefid) = ''ATTACHMENT'' THEN
                                                  ''Facility Documents - Additional Information and Attachments''
                                            ELSE
                                                tcp.entity
                                        END
                                   ELSE
                                        tcp.entity
                               END entity,
                               tap.entityrefid,
                               tcp.fieldname,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.oldvalue)
                                  ELSE
                                      tap.oldvalue
                               END oldvalue,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.newvalue)
                                  ELSE
                                      tap.newvalue
                               END newvalue,
                               tap.operation,
                               (SELECT INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname)) || '' ('' ||
                               CASE
                                WHEN up.issponsor = ''Y'' THEN
                                    up.actualtranscelerateuserid
                                ELSE
                                    up.transcelerateuserid
                               END
                               ||'')''
                               FROM tbl_userprofiles up
                               WHERE up.transcelerateuserid = tap.createdby ) createdby,
                               TO_CHAR(tap.createddt,''DD-Mon-YYYY HH24:MI:SS'') createddt,tap.reason ';

    v_from_clause:= ' FROM tbl_audit tap,
                           tbl_docauditreportmap tarmp,
                           tbl_columnfieldmap tcp, tbl_facilities fac ';

    v_where_clause:= ' WHERE tap.auditid = tarmp.DOCAUDITID
                       AND tap.tablename = tcp.tablename
                       AND tap.columnname = tcp.columnname
                       AND fac.facilityid = tarmp.FACILITYID
                       AND tcp.IsActive=''Y''
                        AND (tap.oldvalue is not null or tap.newvalue is not null)';

    IF ip_startdate IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tap.modifieddt >= ' || CHR(39) || TRUNC(ip_startdate) || CHR(39);
    END IF;

    IF ip_enddate IS NOT NULL THEN
      v_where_clause :=   v_where_clause || ' AND tap.modifieddt < ' || CHR(39) || TRUNC(ip_enddate+1) || CHR(39);
    END IF;

    IF ip_changedby IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tap.modifiedby = ' || CHR(39) || ip_changedby || CHR(39);
    END IF;

    IF ip_facilitydeptid IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tarmp.FACILITYID = ' || ip_facilitydeptid;
    END IF;

    v_final_cnt_sql := v_select_cnt_clause || v_from_clause || v_where_clause;
    --DBMS_OUTPUT.PUT_LINE(v_final_cnt_sql);

    v_final_sql := v_page_select_clause || v_select_clause || v_from_clause || v_where_clause || v_orderby_clause || v_page_where_clause;
    --DBMS_OUTPUT.PUT_LINE(v_final_sql);

    v_cursorid := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursorid,v_final_cnt_sql,DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, op_count);
    v_rows_processed := DBMS_SQL.EXECUTE(v_cursorid);
    IF DBMS_SQL.FETCH_ROWS(v_cursorid) <> 0 THEN
       DBMS_SQL.COLUMN_VALUE(v_cursorid,1,op_count);
    END IF;
    DBMS_SQL.CLOSE_CURSOR(v_cursorid);

    OPEN op_audit_report FOR v_final_sql;

  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RAISE;
  END SP_GET_FACDEPTDOC_AUDIT;

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
     )
  IS
  v_row_start           PLS_INTEGER;
  v_row_end             PLS_INTEGER;
  v_where_clause   VARCHAR2(32767);
  v_select_clause  VARCHAR2(32767);
  v_from_clause    VARCHAR2(32767);
  v_orderby_clause VARCHAR2(32767);
  v_sortby              VARCHAR2(32767);
  v_page_select_clause  VARCHAR2(32767);
  v_page_where_clause   VARCHAR2(32767);
  v_select_cnt_clause   VARCHAR2(32767);
  v_final_cnt_sql       VARCHAR2(32767);
  v_final_sql           VARCHAR2(32767);
  v_where_temp          VARCHAR2(32767);
  v_cursorid            PLS_INTEGER;
  v_rows_processed      PLS_INTEGER;
  BEGIN

    v_row_start := NVL(ip_offset,1);
    v_row_end := v_row_start + ip_limit;

    IF ip_sortby IS NOT NULL THEN
      IF ip_sortby = 'NAME' THEN
         v_sortby := 'tarmp.userid';
      END IF;
    ELSE
        --Default Sorting
        v_sortby := 'UPPER(temp.name),UPPER(temp.entity),temp.entityrefid,temp.createddt,UPPER(temp.fieldname) ';
    END IF;

    v_orderby_clause :=  ' ORDER BY ' || v_sortby;

    v_where_temp:=  '  ) temp WHERE (entity,fieldname) NOT IN (SELECT ''User Documents - License Details'',''Document Author Id'' FROM DUAL UNION ALL
                       SELECT ''User Documents - License Details'',''Document Title'' FROM DUAL UNION ALL
                       SELECT ''User Documents - License Details'',''Document Date'' FROM DUAL UNION ALL
                       SELECT ''User Documents - Profile Attachments'',''Document Author Id'' FROM DUAL UNION ALL
                       SELECT ''User Documents - Profile Attachments'',''Document Date'' FROM DUAL)';

    IF ip_ordrby IS NOT NULL THEN
       v_orderby_clause := v_orderby_clause || ' ' || ip_ordrby;
    END IF;

    v_page_select_clause := ' SELECT * FROM(
                              SELECT  report_data.*,ROWNUM rnum FROM( SELECT * FROM( ';

    v_page_where_clause := ' ) report_data
                             WHERE ROWNUM < '|| v_row_end || ' )
                             WHERE rnum >= ' || v_row_start;

    v_select_cnt_clause := 'SELECT count(*) FROM (SELECT  CASE
                           WHEN tap.tablename = ''TBL_DOCUMENTS'' THEN
                                CASE
                                    WHEN (SELECT tdoc.doctypecd
                                          FROM TBL_DOCUMENTS tdoc
                                          WHERE tdoc.documentid = tap.entityrefid) = 1 THEN
                                          ''User Documents - CV''
                                    WHEN (SELECT tdoc.doctypecd
                                          FROM TBL_DOCUMENTS tdoc
                                          WHERE tdoc.documentid = tap.entityrefid) = 2 THEN
                                          ''User Documents - License Details''
                                    WHEN (SELECT tdoc.doctypecd
                                          FROM TBL_DOCUMENTS tdoc
                                          WHERE tdoc.documentid = tap.entityrefid) = 3 THEN
                                          ''User Documents - Profile Attachments''
                                    ELSE
                                        tcp.entity
                                END
                           ELSE
                                tcp.entity
                       END entity,tcp.fieldname ';

    v_select_clause:= ' SELECT (pkg_encrypt.fn_decrypt(up.lastname) || '', '' || pkg_encrypt.fn_decrypt(up.firstname))
                        || '' ('' ||
                        CASE
                            WHEN up.issponsor = ''Y'' THEN
                                up.actualtranscelerateuserid
                            ELSE
                                up.transcelerateuserid
                        END
                        || '')'' as name,
                       tarmp.documentid,
                       CASE
                           WHEN tap.tablename = ''TBL_DOCUMENTS'' THEN
                                CASE
                                    WHEN (SELECT tdoc.doctypecd
                                          FROM TBL_DOCUMENTS tdoc
                                          WHERE tdoc.documentid = tap.entityrefid) = 1 THEN
                                          ''User Documents - CV''
                                    WHEN (SELECT tdoc.doctypecd
                                          FROM TBL_DOCUMENTS tdoc
                                          WHERE tdoc.documentid = tap.entityrefid) = 2 THEN
                                          ''User Documents - License Details''
                                    WHEN (SELECT tdoc.doctypecd
                                          FROM TBL_DOCUMENTS tdoc
                                          WHERE tdoc.documentid = tap.entityrefid) = 3 THEN
                                          ''User Documents - Profile Attachments''
                                    ELSE
                                        tcp.entity
                                END
                           ELSE
                                tcp.entity
                       END entity,
                       tap.entityrefid,tcp.fieldname,
                       CASE
                          WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                              pkg_encrypt.fn_decrypt(tap.oldvalue)
                          ELSE
                              tap.oldvalue
                       END oldvalue,
                       CASE
                          WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                              pkg_encrypt.fn_decrypt(tap.newvalue)
                          ELSE
                              tap.newvalue
                       END newvalue,
                       tap.operation,
                       INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(up.firstname)) || '' ('' ||
                       CASE
                        WHEN up.issponsor = ''Y'' THEN
                            up.actualtranscelerateuserid
                        ELSE
                            up.transcelerateuserid
                       END
                       ||'')'' createdby ,
                       TO_CHAR(tap.createddt,''DD-Mon-YYYY HH24:MI:SS'') createddt, tap.reason ';

    v_from_clause:= ' FROM tbl_audit tap,
                           tbl_docauditreportmap tarmp,
                           tbl_columnfieldmap tcp, tbl_userprofiles up ';

    v_where_clause:= ' WHERE tap.auditid = tarmp.DOCAUDITID
                       AND tap.tablename = tcp.tablename
                       AND tap.columnname = tcp.columnname
                       AND up.userid = tarmp.userid
                       AND tcp.ISACTIVE = ''Y''
                       AND (tap.oldvalue is not null or tap.newvalue is not null)';


    IF ip_startdate IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tap.modifieddt >= ' || CHR(39) || TRUNC(ip_startdate) || CHR(39);
    END IF;

    IF ip_enddate IS NOT NULL THEN
      v_where_clause :=   v_where_clause || ' AND tap.modifieddt < ' || CHR(39) || TRUNC(ip_enddate+1) || CHR(39);
    END IF;

    IF ip_changedby IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tap.modifiedby = ' || CHR(39) || ip_changedby || CHR(39);
    END IF;

    IF ip_userid IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tarmp.userid = ' || ip_userid;
    END IF;

    v_final_cnt_sql := v_select_cnt_clause || v_from_clause || v_where_clause || v_where_temp;

    --DBMS_OUTPUT.PUT_LINE(v_final_cnt_sql);

    v_final_sql := v_page_select_clause || v_select_clause || v_from_clause || v_where_clause || v_where_temp || v_orderby_clause || v_page_where_clause;

    --DBMS_OUTPUT.PUT_LINE(v_final_sql);

    v_cursorid := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursorid,v_final_cnt_sql,DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, op_count);
    v_rows_processed := DBMS_SQL.EXECUTE(v_cursorid);
    IF DBMS_SQL.FETCH_ROWS(v_cursorid) <> 0 THEN
       DBMS_SQL.COLUMN_VALUE(v_cursorid,1,op_count);
    END IF;
    DBMS_SQL.CLOSE_CURSOR(v_cursorid);

    OPEN op_audit_report FOR v_final_sql;

  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RAISE;
  END SP_GET_USERDOC_AUDIT;

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
      USRSRCH OUT SYS_REFCURSOR)
  AS
    STC_SQL_PART1          VARCHAR2(9999 BYTE);
    STC_SQL_PART2          VARCHAR2(9999 BYTE);
     STC_SQL_PART3         VARCHAR2(9999 BYTE);
    QUERY_FINAL            VARCHAR2(9999 BYTE);
    DYNMC_SQL_CLAUSE_PART VARCHAR2(9999 BYTE);
    PAG_END_ROW           NUMBER;
    P_OFFSET              NUMBER;
    V_COUNT_QUERY         VARCHAR2(9999 BYTE);
    V_ORGID               NUMBER(38);
    TEMP_SORTBY            VARCHAR2(9999 BYTE);
    TEMP_ORDRBY              VARCHAR2(9999 BYTE);
   -- P_OFFSET                 NUMBER;
    v_cursorid            PLS_INTEGER;
    v_rows_processed      PLS_INTEGER;
    v_str_country         varchar2(3200);
    v_str_state         varchar2(3200);
  BEGIN
    TEMP_ORDRBY := '';

  --P_OFFSET :=I_OFFSET+1;
  IF I_SORTBY    = 'TRANSCELERATEUSERID' THEN
    TEMP_SORTBY := 'UPPER(TRIM(TRANSCELERATEUSERID))';
  ELSIF I_SORTBY = 'FIRSTNAME' THEN
    TEMP_SORTBY := 'UPPER(TRIM(FIRSTNAME))';
  ELSIF I_SORTBY = 'LASTNAME' THEN
    TEMP_SORTBY := 'UPPER(TRIM(LASTNAME))';
  ELSIF I_SORTBY = 'COUNTRYNAME' THEN
    TEMP_SORTBY := 'UPPER(TRIM(COUNTRYNAME))';
  ELSIF I_SORTBY = 'STATE' THEN
   TEMP_SORTBY := 'UPPER(TRIM(STATE_ACTUAL))';
  ELSIF I_SORTBY = 'CITY' THEN
    TEMP_SORTBY := 'UPPER(TRIM(CITY))';
  ELSE
    TEMP_SORTBY := 'UPPER(TRANSCELERATEUSERID)';
    --INSERT INTO temp_table VALUES (I_SORTBY);
  END IF;

    STC_SQL_PART1 :=
    'SELECT distinct UP.USERID,
     UP.TRANSCELERATEUSERID,
     UP.ACTUALTRANSCELERATEUSERID,
     pkg_encrypt.fn_decrypt(UP.FIRSTNAME) FIRSTNAME,
     pkg_encrypt.fn_decrypt(UP.LASTNAME) LASTNAME,
     UP.COUNTRYID,
     pkg_encrypt.fn_decrypt(CNT.EMAIL) EMAIL,
     CONTRY.COUNTRYNAME COUNTRYNAME,
     CONTRY.COUNTRYCD,
     CNT.STATE STATENAME,
    CNT.CITY CITY,
    CNT.CONTACTID,
    ST.Statename STATE_ACTUAL
    FROM TBL_USERPROFILES UP
    LEFT JOIN TBL_CONTACT CNT
    ON UP.CONTACTID = CNT.CONTACTID
    LEFT JOIN TBL_COUNTRIES CONTRY
    ON CNT.COUNTRYCD = CONTRY.COUNTRYCD
    LEFT JOIN TBL_STATES ST
    ON CNT.STATE = ST.STATECD
    WHERE (UP.ORGID = ' || I_ORGID || ' OR USERID  IN ( select distinct orgs.sitestaffuserid from tbl_orgsitestaffmap orgs where orgs.orgid = '|| I_ORGID || ' ))';


        STC_SQL_PART2 :=
    'SELECT distinct UP.USERID,
     UP.TRANSCELERATEUSERID,
     UP.ACTUALTRANSCELERATEUSERID,
     pkg_encrypt.fn_decrypt(UP.FIRSTNAME) FIRSTNAME,
     pkg_encrypt.fn_decrypt(UP.LASTNAME) LASTNAME,
     UP.COUNTRYID,
     pkg_encrypt.fn_decrypt(CNT.EMAIL) EMAIL,
     CONTRY.COUNTRYNAME COUNTRYNAME,
     CONTRY.COUNTRYCD,
     CNT.STATE STATENAME,
     CNT.CITY CITY,
     CNT.CONTACTID,
     ST.Statename STATE_ACTUAL
    FROM TBL_USERPROFILES UP
    JOIN TBL_ORGSITESTAFFMAP OS
    ON OS.SITESTAFFUSERID = UP.USERID
    JOIN TBL_CONTACT CNT
    ON UP.CONTACTID = CNT.CONTACTID
    JOIN TBL_COUNTRIES CONTRY
    ON CNT.COUNTRYCD = CONTRY.COUNTRYCD
    JOIN TBL_STATES ST
    ON CNT.STATE = ST.STATECD
    WHERE UP.ORGID = '|| I_ORGID ;


   -- DYNMC_SQL_CLAUSE_PART   :=
    IF I_FIRSTNAME          IS NOT NULL THEN
      DYNMC_SQL_CLAUSE_PART := DYNMC_SQL_CLAUSE_PART || ' AND LOWER(pkg_encrypt.fn_decrypt(UP.FIRSTNAME)) LIKE LOWER(''%' || I_FIRSTNAME || '%'')';
    END IF;
  IF I_LASTNAME           IS NOT NULL THEN
      DYNMC_SQL_CLAUSE_PART := DYNMC_SQL_CLAUSE_PART || ' AND LOWER(pkg_encrypt.fn_decrypt(UP.LASTNAME)) LIKE LOWER(''%' || I_LASTNAME || '%'')';
    END IF;
    IF I_EMAIL              IS NOT NULL THEN
      DYNMC_SQL_CLAUSE_PART := DYNMC_SQL_CLAUSE_PART || ' AND LOWER(pkg_encrypt.fn_decrypt(CNT.EMAIL)) LIKE LOWER(''%' || I_EMAIL || '%'')';
    END IF;
   /* IF I_COUNTRYID              IS NOT NULL THEN
      DYNMC_SQL_CLAUSE_PART := DYNMC_SQL_CLAUSE_PART || ' AND UP.COUNTRYID =' || I_COUNTRYID ;
    END IF;
    IF I_STATECD              IS NOT NULL THEN
      DYNMC_SQL_CLAUSE_PART := DYNMC_SQL_CLAUSE_PART || ' AND LOWER(ST.STATECD) LIKE LOWER(''%' || I_STATECD || '%'')';
    END IF;*/
     IF I_COUNTRYID         IS NOT NULL AND I_COUNTRYID.count >0 THEN
    FOR i IN 1..I_COUNTRYID.count
    LOOP
      EXIT
    WHEN I_COUNTRYID(i) = -1;
      IF i             = 1 THEN
      v_str_country := I_COUNTRYID(i);
      ELSE
      v_str_country := v_str_country || ',' || I_COUNTRYID(i);
      END IF;
    END LOOP;
    END IF;
    IF v_str_country              IS NOT NULL THEN
       DYNMC_SQL_CLAUSE_PART :=  DYNMC_SQL_CLAUSE_PART || ' AND CONTRY.COUNTRYID IN (' || v_str_country || ')';
    END IF;

    IF I_STATECD         IS NOT NULL AND I_STATECD.count >0 THEN
    FOR i IN 1..I_STATECD.count
    LOOP
      EXIT
    WHEN I_STATECD(i) = -1;
      IF i             = 1 THEN
      v_str_state := I_STATECD(i);
      ELSE
      v_str_state := v_str_state || ',' || I_STATECD(i);
      END IF;
    END LOOP;
    END IF;
    IF v_str_state              IS NOT NULL THEN
       DYNMC_SQL_CLAUSE_PART :=  DYNMC_SQL_CLAUSE_PART || ' AND ST.STATEID IN (' || v_str_state || ') ';
    END IF;


    IF I_CITY              IS NOT NULL THEN
      DYNMC_SQL_CLAUSE_PART := DYNMC_SQL_CLAUSE_PART || ' AND LOWER(CNT.CITY) LIKE LOWER(''%' || I_CITY || '%'')';
    END IF;

    TEMP_ORDRBY := ' ORDER BY ' || TEMP_SORTBY || ' ' || I_ORDRBY;


  QUERY_FINAL := STC_SQL_PART1  || DYNMC_SQL_CLAUSE_PART || ' UNION ALL ' || STC_SQL_PART2  || DYNMC_SQL_CLAUSE_PART;

    V_COUNT_QUERY := 'select count(1) from (' || QUERY_FINAL || ')';

    dbms_output.put_line(V_COUNT_QUERY);
    v_cursorid := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursorid,v_count_query,DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, i_count);
    v_rows_processed := DBMS_SQL.EXECUTE(v_cursorid);
    IF DBMS_SQL.FETCH_ROWS(v_cursorid) <> 0 THEN
       DBMS_SQL.COLUMN_VALUE(v_cursorid,1,i_count);
    END IF;
    DBMS_SQL.CLOSE_CURSOR(v_cursorid);

    PAG_END_ROW           := I_OFFSET + I_LIMIT;
    P_OFFSET              := I_OFFSET - 1;
    STC_SQL_PART3         := ' SELECT * FROM (SELECT ROWNUM RNM1, TEMP.* FROM (SELECT * FROM (SELECT ROWNUM RNUM , TEMP.* FROM (' || QUERY_FINAL  || ' ) TEMP ' || ' ' || TEMP_ORDRBY ||' ) WHERE ROWNUM <'|| TO_CHAR(PAG_END_ROW)||') TEMP  ) WHERE RNM1> ' || TO_CHAR(P_OFFSET) ;
   -- dbms_output.put_line(STC_SQL_PART3);
    --insert into temp_table values(STC_SQL_PART3);
    --COMMIT;

 OPEN USRSRCH FOR STC_SQL_PART3 ;

  END SP_USR_SEARCH_PROC;




   PROCEDURE SP_SET_USERAUDITREPORTMAP
    (ip_auditid           IN tbl_userauditreportmap.USERAUDITID%TYPE,
     ip_userid           IN tbl_userauditreportmap.USERID%TYPE,
     ip_createddt         IN tbl_userauditreportmap.CREATEDDT%TYPE,
     ip_createdby         IN tbl_userauditreportmap.CREATEDBY%TYPE,
     ip_modifieddt        IN tbl_userauditreportmap.modifieddt%TYPE,
   ip_modifiedby       IN tbl_userauditreportmap.modifiedby%TYPE

     )
  IS
  BEGIN
    INSERT INTO TBL_USERAUDITREPORTMAP(userauditreportmapid, userauditid, userid , createddt, createdby, modifieddt, modifiedby)
    VALUES(SEQ_USERAUDITREPORTMAP.NEXTVAL, ip_auditid, ip_userid,
          NVL(ip_createddt,NVL(ip_modifieddt,SYSDATE)),
          NVL(ip_createdby,NVL(ip_modifiedby,'SYSTEM')),
          NVL(ip_modifieddt,NVL(ip_createddt,SYSDATE)),
          NVL(ip_modifiedby,NVL(ip_createdby,'SYSTEM'))
          );

  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RAISE;
  END SP_SET_USERAUDITREPORTMAP;

     PROCEDURE SP_SET_FACAUDITREPORTMAP
    (ip_auditid           IN tbl_facauditreportmap.FACAUDITID%TYPE,
     ip_facilityid          IN tbl_facauditreportmap.FACILITYID%TYPE,
     ip_createddt         IN tbl_facauditreportmap.CREATEDDT%TYPE,
     ip_createdby         IN tbl_facauditreportmap.CREATEDBY%TYPE,
     ip_modifieddt        IN tbl_facauditreportmap.modifieddt%TYPE,
   ip_modifiedby       IN tbl_facauditreportmap.modifiedby%TYPE

     )
  IS
  BEGIN

      INSERT INTO TBL_FACAUDITREPORTMAP(facauditreportmapid, facauditid, facilityid , createddt, createdby, modifieddt, modifiedby)
    VALUES(SEQ_FACAUDITREPORTMAP.NEXTVAL, ip_auditid, ip_facilityid,
          NVL(ip_createddt,NVL(ip_modifieddt,SYSDATE)),
          NVL(ip_createdby,NVL(ip_modifiedby,'SYSTEM')),
          NVL(ip_modifieddt,NVL(ip_createddt,SYSDATE)),
          NVL(ip_modifiedby,NVL(ip_createdby,'SYSTEM'))
          );

 EXCEPTION
   WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RAISE;
  END SP_SET_FACAUDITREPORTMAP;

PROCEDURE SP_GET_USER_AUDIT
    (ip_startdate     IN TBL_USERAUDITREPORTMAP.createddt%TYPE,
     ip_enddate       IN TBL_USERAUDITREPORTMAP.createddt%TYPE,
     ip_changedby     IN TBL_USERAUDITREPORTMAP.createdby%TYPE,
     ip_userid        IN TBL_USERAUDITREPORTMAP.Userid%TYPE,
     ip_offset        IN NUMBER,
     ip_limit         IN NUMBER,
     ip_ordrby        IN VARCHAR2,
     ip_sortby        IN VARCHAR2,
     op_count         OUT NUMBER,
     op_audit_report  OUT SYS_REFCURSOR
     )
  IS
  v_row_start           PLS_INTEGER;
  v_row_end             PLS_INTEGER;
  v_where_clause   VARCHAR2(32767);
  v_select_clause  VARCHAR2(32767);
  v_from_clause    VARCHAR2(32767);
  v_orderby_clause VARCHAR2(32767);
  v_sortby              VARCHAR2(32767);
  v_page_select_clause  VARCHAR2(32767);
  v_page_where_clause   VARCHAR2(32767);
  v_select_cnt_clause   VARCHAR2(32767);
  v_final_cnt_sql       VARCHAR2(32767);
  v_final_sql           VARCHAR2(32767);
  v_cursorid            PLS_INTEGER;
  v_rows_processed      PLS_INTEGER;
  BEGIN

    v_row_start := NVL(ip_offset,1);
    v_row_end := v_row_start + ip_limit;
    v_sortby := 'upper(pkg_encrypt.fn_decrypt(up.lastname) || pkg_encrypt.fn_decrypt(up.firstname)),upper(tcp.entity),tap.entityrefid,tap.createddt ' ;

      v_orderby_clause :=  ' ORDER BY ' || v_sortby;

    IF ip_ordrby IS NOT NULL THEN
       v_orderby_clause := v_orderby_clause || ' ' || ip_ordrby;
    END IF;

    v_page_select_clause := ' SELECT * FROM(
                              SELECT  report_data.*,ROWNUM rnum FROM( ';

    IF ip_limit is not null then
    v_page_where_clause := ' ) report_data
                             WHERE ROWNUM < '|| v_row_end || ' )
                             WHERE rnum >= ' || v_row_start;
    ELSE
  v_page_where_clause := ' ) report_data
                             )
                             WHERE rnum >= ' || v_row_start;
  END IF;


       v_select_cnt_clause := ' SELECT COUNT(1) ';


         v_select_clause:= ' SELECT (pkg_encrypt.fn_decrypt(up.lastname) || '','' || pkg_encrypt.fn_decrypt(up.firstname)) as name,
                CASE
                                   WHEN tap.tablename = ''TBL_DOCUMENTS'' THEN
                                        CASE
                                            WHEN (SELECT tdoc.doctypecd
                                                  FROM TBL_DOCUMENTS tdoc
                                                  WHERE tdoc.documentid = tap.entityrefid) = 1 THEN
                                            ''User Profile Attachments''
                                            WHEN (SELECT tdoc.doctypecd
                                                  FROM TBL_DOCUMENTS tdoc
                                                  WHERE tdoc.documentid = tap.entityrefid) = 3 THEN
                                           ''User Profile Attachments''
                                        ELSE
                                            ''User Professional License Details''
                                        END
                                   WHEN tap.tablename = ''TBL_TRNGCREDITS'' THEN
                                   ''User GCP Training''
                                   WHEN tap.tablename = ''TBL_IRUSERLICENSEDOCUMENTMAP'' THEN
                                   ''User Professional License Details''
                                   ELSE
                                        tcp.entity
                               END entity,
              tap.entityrefid,
                CASE
                                   WHEN tap.tablename = ''TBL_DOCUMENTS'' THEN
                                        CASE
                                            WHEN  (SELECT tcol.fieldname
                                                  FROM TBL_COLUMNFIELDMAP tcol
                                                  WHERE tcol.TABLENAME = ''TBL_DOCUMENTS'' and tcol.COLUMNNAME = ''TITLE'' ) = tcp.fieldname THEN
                                                  ''Document Name''
                                            WHEN  (SELECT tcol.fieldname
                                                  FROM TBL_COLUMNFIELDMAP tcol
                                                  WHERE tcol.TABLENAME = ''TBL_DOCUMENTS'' and tcol.COLUMNNAME = ''DESCRIPTION'' ) = tcp.fieldname THEN
                                                  ''Document Description''
                                            WHEN  (SELECT tcol.fieldname
                                                  FROM TBL_COLUMNFIELDMAP tcol
                                                  WHERE tcol.TABLENAME = ''TBL_DOCUMENTS'' and tcol.COLUMNNAME = ''COMMENTS'' ) = tcp.fieldname THEN
                                                  ''Comments''
                                        END
                                      WHEN  tap.tablename = ''TBL_TRNGCREDITS'' THEN
                                      CASE
                                            WHEN  (SELECT tcol.fieldname
                                                  FROM TBL_COLUMNFIELDMAP tcol
                                                  WHERE tcol.TABLENAME = ''TBL_TRNGCREDITS'' and tcol.COLUMNNAME = ''TRNGPROVIDERNAME'' ) = tcp.fieldname THEN
                                                  ''Course Provider''
                                            WHEN  (SELECT tcol.fieldname
                                                  FROM TBL_COLUMNFIELDMAP tcol
                                                  WHERE tcol.TABLENAME = ''TBL_TRNGCREDITS'' and tcol.COLUMNNAME = ''COMPLETIONDT'' ) = tcp.fieldname THEN
                                                  ''Date Completed''
                                            WHEN  (SELECT tcol.fieldname
                                                  FROM TBL_COLUMNFIELDMAP tcol
                                                  WHERE tcol.TABLENAME = ''TBL_TRNGCREDITS'' and tcol.COLUMNNAME = ''TRNG_STATUS_ID'' ) = tcp.fieldname THEN
                                                  ''Status''
                                             WHEN  (SELECT tcol.fieldname
                                                  FROM TBL_COLUMNFIELDMAP tcol
                                                  WHERE tcol.TABLENAME = ''TBL_TRNGCREDITS'' and tcol.COLUMNNAME = ''COURSETITLE'' ) = tcp.fieldname THEN
                                                  ''Course Title''
                                        END
                                        WHEN  tap.tablename = ''TBL_IRUSERLICENSEDOCUMENTMAP'' THEN
                                      CASE
                                         WHEN   (SELECT tcol.fieldname
                                                  FROM TBL_COLUMNFIELDMAP tcol
                                                  WHERE tcol.TABLENAME = ''TBL_IRUSERLICENSEDOCUMENTMAP'' and tcol.COLUMNNAME = ''DOCID'' ) = tcp.fieldname THEN
                                                  ''Document Name''
                                            END
                                   ELSE
                                        tcp.fieldname
                               END fieldname,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.oldvalue)
                                  ELSE
                                      tap.oldvalue
                               END oldvalue,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.newvalue)
                                  ELSE
                                      tap.newvalue
                               END newvalue,
                               tap.operation,
                               (SELECT INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname)) || '' ('' ||
                               CASE
                                WHEN up.issponsor = ''Y'' THEN
                                    up.actualtranscelerateuserid
                                ELSE
                                    up.transcelerateuserid
                               END
                               ||'')''
                               FROM tbl_userprofiles up
                               WHERE up.transcelerateuserid = tap.createdby ) createdby,
                               TO_CHAR(tap.createddt,''DD-Mon-YYYY HH24:MI:SS'') createddt,tap.reason ';

    v_from_clause:= ' FROM tbl_audit tap,
                           tbl_userauditreportmap tarmp,
                           tbl_columnfieldmap tcp,
                           tbl_userprofiles up ';

    v_where_clause:= ' WHERE tap.auditid = tarmp.userauditid
                       AND tap.tablename = tcp.tablename
                       AND tap.columnname = tcp.columnname
                       AND up.userid = tarmp.userid
                       AND tcp.ISACTIVE = ''Y''
                       AND (tap.oldvalue is not null or tap.newvalue is not null)';


         IF ip_startdate IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tap.modifieddt >= ' || CHR(39) || TRUNC(ip_startdate) || CHR(39);
    END IF;

    IF ip_enddate IS NOT NULL THEN
      v_where_clause :=   v_where_clause || ' AND tap.modifieddt < ' || CHR(39) || TRUNC(ip_enddate+1) || CHR(39);
    END IF;

    IF ip_changedby IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tap.createdby = ' || CHR(39) || ip_changedby || CHR(39);
    END IF;

    IF ip_userid IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tarmp.userid = ' || ip_userid;
    END IF;


    v_final_cnt_sql := v_select_cnt_clause || v_from_clause || v_where_clause || v_orderby_clause;
    -- DBMS_OUTPUT.PUT_LINE(v_final_cnt_sql);

    v_final_sql := v_page_select_clause || v_select_clause || v_from_clause || v_where_clause || v_orderby_clause || v_page_where_clause;
    -- DBMS_OUTPUT.PUT_LINE(v_final_sql);

    v_cursorid := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursorid,v_final_cnt_sql,DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, op_count);
    v_rows_processed := DBMS_SQL.EXECUTE(v_cursorid);
    IF DBMS_SQL.FETCH_ROWS(v_cursorid) <> 0 THEN
       DBMS_SQL.COLUMN_VALUE(v_cursorid,1,op_count);
    END IF;
    DBMS_SQL.CLOSE_CURSOR(v_cursorid);

    OPEN op_audit_report FOR v_final_sql;

  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RAISE;
  END SP_GET_USER_AUDIT ;

    PROCEDURE SP_GET_FACILITY_AUDIT
    (ip_startdate     IN TBL_FACAUDITREPORTMAP.createddt%TYPE,
     ip_enddate       IN TBL_FACAUDITREPORTMAP.createddt%TYPE,
     ip_changedby     IN TBL_FACAUDITREPORTMAP.createdby%TYPE,
     ip_facilityid    IN TBL_FACAUDITREPORTMAP.facilityid%TYPE,
   ip_informationarea  IN NUMBER,
     ip_offset        IN NUMBER,
     ip_limit         IN NUMBER,
     ip_ordrby        IN VARCHAR2,
     ip_sortby        IN VARCHAR2,
     op_count         OUT NUMBER,
     op_audit_report  OUT SYS_REFCURSOR
     )
  IS
  v_row_start           PLS_INTEGER;
  v_row_end             PLS_INTEGER;
  v_where_clause   VARCHAR2(32767);
  v_select_clause  VARCHAR2(32767);
  v_from_clause    VARCHAR2(32767);
  v_orderby_clause VARCHAR2(32767);
  v_sortby              VARCHAR2(32767);
  v_page_select_clause  VARCHAR2(32767);
  v_page_where_clause   VARCHAR2(32767);
  v_select_cnt_clause   VARCHAR2(32767);
  v_final_cnt_sql       VARCHAR2(32767);
  v_final_sql           VARCHAR2(32767);
  v_infoarea            VARCHAR2(32767);
  v_cursorid            PLS_INTEGER;
  v_rows_processed      PLS_INTEGER;
  BEGIN

    v_row_start := NVL(ip_offset,1);
    v_row_end := v_row_start + ip_limit;

    IF ip_sortby IS NOT NULL THEN
      IF ip_sortby = 'NAME' THEN
          v_sortby := 'tarmp.facilityid';
      END IF;
    ELSE
      --Default Sorting
      v_sortby := 'UPPER(fac.facilityname),upper(tcp.entity),tap.entityrefid,tap.createddt ';
    END IF;

    v_orderby_clause :=  ' ORDER BY ' || v_sortby;

    IF ip_ordrby IS NOT NULL THEN
       v_orderby_clause := v_orderby_clause || ' ' || ip_ordrby;
    END IF;

    v_page_select_clause := ' SELECT * FROM(
                              SELECT  report_data.*,ROWNUM rnum FROM( ';

  IF ip_limit is not null then
    v_page_where_clause := ' ) report_data
                             WHERE ROWNUM < '|| v_row_end || ' )
                             WHERE rnum >= ' || v_row_start;
    ELSE
  v_page_where_clause := ' ) report_data
                             )
                             WHERE rnum >= ' || v_row_start;
  END IF;


    v_select_cnt_clause := ' SELECT COUNT(1) ';

    v_select_clause:= ' SELECT (CASE
                                    WHEN ISDEPARTMENT = ''N'' THEN
                                         fac.FACILITYNAME
                                    ELSE fac.departmentname
                               END) as name,
                                CASE
                                   WHEN tap.tablename = ''TBL_CONTACT'' THEN
                                   ''Investigational Product ''|| CHR(38) ||'' Controlled Substances-Investigational Product Storage Location''
                                   WHEN tap.tablename = ''TBL_CONTACT_IRB'' THEN
                                   ''IRB/ERB/Ethics Committee-General Questions''
                   ELSE
                                        tcp.entity
                               END entity,
                               tap.entityrefid,
                                  CASE
                                   WHEN tap.tablename = ''TBL_CONTACT'' THEN
                                        CASE
                                            WHEN  (SELECT tcol.fieldname
                                                  FROM TBL_COLUMNFIELDMAP tcol
                                                  WHERE tcol.TABLENAME = ''TBL_CONTACT'' and tcol.COLUMNNAME = ''ADDRESS1'' ) = tcp.fieldname THEN
                                                  ''Street Name and Number''
                                            WHEN  (SELECT tcol.fieldname
                                                  FROM TBL_COLUMNFIELDMAP tcol
                                                  WHERE tcol.TABLENAME = ''TBL_CONTACT'' and tcol.COLUMNNAME = ''ADDRESS2'' ) = tcp.fieldname THEN
                                                  ''Building/Floor/Room/Suite''
                                            WHEN  (SELECT tcol.fieldname
                                                  FROM TBL_COLUMNFIELDMAP tcol
                                                  WHERE tcol.TABLENAME = ''TBL_CONTACT'' and tcol.COLUMNNAME = ''ADDRESS3'' ) = tcp.fieldname THEN
                                                  ''Additional Address Info''
                                            WHEN  (SELECT tcol.fieldname
                                                  FROM TBL_COLUMNFIELDMAP tcol
                                                  WHERE tcol.TABLENAME = ''TBL_CONTACT'' and tcol.COLUMNNAME = ''COUNTRYCD'' ) = tcp.fieldname THEN
                                                  ''Country''
                                            WHEN  (SELECT tcol.fieldname
                                                  FROM TBL_COLUMNFIELDMAP tcol
                                                  WHERE tcol.TABLENAME = ''TBL_CONTACT'' and tcol.COLUMNNAME = ''STATE'' ) = tcp.fieldname THEN
                                                  ''State/Province/Region''
                                            WHEN  (SELECT tcol.fieldname
                                                  FROM TBL_COLUMNFIELDMAP tcol
                                                  WHERE tcol.TABLENAME = ''TBL_CONTACT'' and tcol.COLUMNNAME = ''CITY'' ) = tcp.fieldname THEN
                                                  ''City''
                                            WHEN  (SELECT tcol.fieldname
                                                  FROM TBL_COLUMNFIELDMAP tcol
                                                  WHERE tcol.TABLENAME = ''TBL_CONTACT'' and tcol.COLUMNNAME = ''POSTALCODE'' ) = tcp.fieldname THEN
                                                  ''Zip/Postal Code''
                                            WHEN  (SELECT tcol.fieldname
                                                  FROM TBL_COLUMNFIELDMAP tcol
                                                  WHERE tcol.TABLENAME = ''TBL_CONTACT'' and tcol.COLUMNNAME = ''PHONE1'' ) = tcp.fieldname THEN
                                                  ''Phone Number''
                                            WHEN  (SELECT tcol.fieldname
                                                  FROM TBL_COLUMNFIELDMAP tcol
                                                  WHERE tcol.TABLENAME = ''TBL_CONTACT'' and tcol.COLUMNNAME = ''FAX'' ) = tcp.fieldname THEN
                                                  ''Fax Number''
                      WHEN  (SELECT tcol.fieldname
                                                  FROM TBL_COLUMNFIELDMAP tcol
                                                  WHERE tcol.TABLENAME = ''TBL_CONTACT'' and tcol.COLUMNNAME = ''EMAIL'' ) = tcp.fieldname THEN
                                                  ''Email Address''
                      END
                                   ELSE
                                        tcp.fieldname
                               END fieldname,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.oldvalue)
                                  ELSE
                                      tap.oldvalue
                               END oldvalue,
                               CASE
                                  WHEN (tap.tablename,tap.columnname) IN (SELECT tec.tablename,tec.columnname FROM tbl_encryptioncolumn tec WHERE isactive = ''Y'') THEN
                                      pkg_encrypt.fn_decrypt(tap.newvalue)
                                  ELSE
                                      tap.newvalue
                               END newvalue,
                               tap.operation,
                               (SELECT INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || '', ''  || INITCAP(pkg_encrypt.fn_decrypt(firstname)) || '' ('' ||
                               CASE
                                WHEN up.issponsor = ''Y'' THEN
                                    up.actualtranscelerateuserid
                                ELSE
                                    up.transcelerateuserid
                               END
                               ||'')''
                               FROM tbl_userprofiles up
                               WHERE up.transcelerateuserid = tap.createdby ) createdby,
                               TO_CHAR(tap.createddt,''DD-Mon-YYYY HH24:MI:SS'') createddt,tap.reason ';

    v_from_clause:= ' FROM tbl_audit tap,
                           TBL_FACAUDITREPORTMAP tarmp,
                           tbl_columnfieldmap tcp, tbl_facilities fac ';

    v_where_clause:= ' WHERE tap.auditid = tarmp.FACAUDITID
                       AND tap.tablename = tcp.tablename
                       AND tap.columnname = tcp.columnname
                       AND fac.facilityid = tarmp.FACILITYID
                       AND tcp.IsActive=''Y''
             AND (tap.oldvalue is not null or tap.newvalue is not null)';

    IF ip_startdate IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tap.modifieddt >= ' || CHR(39) || TRUNC(ip_startdate) || CHR(39);
    END IF;

    IF ip_enddate IS NOT NULL THEN
      v_where_clause :=   v_where_clause || ' AND tap.modifieddt < ' || CHR(39) || TRUNC(ip_enddate+1) || CHR(39);
    END IF;

    IF ip_changedby IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tap.modifiedby = ' || CHR(39) || ip_changedby || CHR(39);
    END IF;

    IF ip_facilityid IS NOT NULL THEN
      v_where_clause :=  v_where_clause || ' AND tarmp.FACILITYID = ' || ip_facilityid;
    END IF;

  IF ip_informationarea IS NOT NULL AND ip_informationarea = 8 THEN
      v_where_clause :=  v_where_clause || ' AND (tcp.ENTITY IN ( SELECT SUBINFORMATIONAREANAME FROM TBL_INFOAREAMAP WHERE INFORMATIONAREAID = ' || ip_informationarea || ' ) OR tap.tablename = ''TBL_CONTACT'' )';
    ELSE
    v_where_clause :=  v_where_clause || ' AND tcp.ENTITY IN ( SELECT SUBINFORMATIONAREANAME FROM TBL_INFOAREAMAP WHERE INFORMATIONAREAID = ' || ip_informationarea ||' ) ';
  END IF;

    v_final_cnt_sql := v_select_cnt_clause || v_from_clause || v_where_clause || v_orderby_clause;
   -- DBMS_OUTPUT.PUT_LINE(v_final_cnt_sql);

    v_final_sql := v_page_select_clause || v_select_clause || v_from_clause || v_where_clause || v_orderby_clause || v_page_where_clause;
   -- DBMS_OUTPUT.PUT_LINE(v_final_sql);

    v_cursorid := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursorid,v_final_cnt_sql,DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, op_count);
    v_rows_processed := DBMS_SQL.EXECUTE(v_cursorid);
    IF DBMS_SQL.FETCH_ROWS(v_cursorid) <> 0 THEN
       DBMS_SQL.COLUMN_VALUE(v_cursorid,1,op_count);
    END IF;
    DBMS_SQL.CLOSE_CURSOR(v_cursorid);

    OPEN op_audit_report FOR v_final_sql;

  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RAISE;
  END SP_GET_FACILITY_AUDIT ;

FUNCTION fn_get_lov_value
(ip_lovid     IN VARCHAR2,
ip_lovtype  IN VARCHAR2
)
RETURN VARCHAR2
IS
v_lovvalue          VARCHAR2(4000);
v_sql               VARCHAR2(32767);
v_cursorid          PLS_INTEGER;
v_rows_processed    PLS_INTEGER;
BEGIN

  IF ip_lovtype = g_lov_organization THEN
      SELECT o.orgname
      INTO v_lovvalue
      FROM TBL_ORGANIZATION o
      WHERE o.orgid = ip_lovid;
  ELSIF ip_lovtype = g_lov_program THEN
      SELECT p.progname
      INTO v_lovvalue
      FROM TBL_PROGRAM p
      WHERE p.progid = ip_lovid;
  ELSIF ip_lovtype = g_lov_compound THEN
      SELECT c.compoundname
      INTO v_lovvalue
      FROM TBL_COMPOUND c
      WHERE c.compoundid = ip_lovid;
  ELSIF ip_lovtype = g_lov_disease THEN
      SELECT d.diseasename
      INTO v_lovvalue
      FROM TBL_DISEASE d
      WHERE d.diseaseid = ip_lovid;
  ELSIF ip_lovtype = g_lov_indication THEN
      SELECT i.indicationname
      INTO v_lovvalue
      FROM TBL_INDICATION i
      WHERE i.indicationid = ip_lovid;
  ELSIF ip_lovtype = g_lov_language THEN
      SELECT l.languagename
      INTO v_lovvalue
      FROM TBL_LANGUAGEMASTER l
      WHERE l.languageid = ip_lovid;
  ELSIF ip_lovtype = g_lov_country_id THEN
      SELECT c.countryname
      INTO v_lovvalue
      FROM TBL_COUNTRIES c
      WHERE c.countryid = ip_lovid;
  ELSIF ip_lovtype = g_lov_country_code THEN
      SELECT c.countryname
      INTO v_lovvalue
      FROM TBL_COUNTRIES c
      WHERE c.countrycd = ip_lovid;
  ELSIF ip_lovtype = g_lov_state_id THEN
      SELECT s.statename
      INTO v_lovvalue
      FROM TBL_STATES s
      WHERE s.stateid = ip_lovid;
  ELSIF ip_lovtype = g_lov_state_code THEN
      SELECT s.statename
      INTO v_lovvalue
      FROM TBL_STATES s
      WHERE s.statecd = ip_lovid;
  ELSIF ip_lovtype = g_lov_timezone THEN
      SELECT t.tzname
      INTO v_lovvalue
      FROM TBL_TIMEZONE t
      WHERE t.timezoneid = ip_lovid;
  ELSIF ip_lovtype = g_lov_alertnotifitype THEN
      SELECT a.typedesc
      INTO v_lovvalue
      FROM TBL_ALERTANDNOTIFICATIONTYPE a
      WHERE a.alertnotificationtypeid = ip_lovid;
  ELSIF ip_lovtype = g_lov_doctype THEN
      SELECT d.doctype
      INTO v_lovvalue
      FROM TBL_DOCTYPEMASTER d
      WHERE d.doctypeid = ip_lovid;
  ELSIF ip_lovtype = g_lov_docpkg THEN
      SELECT d.docpkg
      INTO v_lovvalue
      FROM TBL_DOCPKGMASTER d
      WHERE d.docpkgid = ip_lovid;
  ELSIF ip_lovtype = g_lov_role THEN
      SELECT r.rolename
      INTO v_lovvalue
      FROM TBL_ROLES r
      WHERE r.roleid = ip_lovid;
  ELSIF ip_lovtype = g_lov_trngrejection THEN
      SELECT t.rejectiondesc
      INTO v_lovvalue
      FROM TBL_TRNGREJMASTER t
      WHERE t.rejectionid = ip_lovid;
  ELSIF ip_lovtype = g_lov_task THEN
      SELECT t.description
      INTO v_lovvalue
      FROM TBL_TASK t
      WHERE t.taskid = ip_lovid;
  ELSIF ip_lovtype = g_lov_trngstatus THEN
      SELECT t.trngstatus
      INTO v_lovvalue
      FROM TBL_TRNGSTATUS t
      WHERE t.trngstatusid = ip_lovid;
  ELSIF ip_lovtype = g_lov_phase THEN
      SELECT p.phasetype
      INTO v_lovvalue
      FROM TBL_PHASE p
      WHERE p.phaseid = ip_lovid;
  ELSIF ip_lovtype = g_lov_notifconfig THEN
      SELECT n.freq
      INTO v_lovvalue
      FROM TBL_NOTIFICATIONCONFIG n
      WHERE n.notifconfigid = ip_lovid;
  ELSIF ip_lovtype = g_lov_userprofile_userid_trans THEN
       SELECT INITCAP(pkg_encrypt.fn_decrypt(u.lastname)) || ', ' || INITCAP(pkg_encrypt.fn_decrypt(u.firstname))||' '|| INITCAP(pkg_encrypt.fn_decrypt(u.middlename))
      INTO v_lovvalue
      FROM TBL_USERPROFILES u
      WHERE u.userid = ip_lovid;

  ELSIF ip_lovtype = g_lov_userprofile_user_flname THEN
      SELECT INITCAP(pkg_encrypt.fn_decrypt(u.lastname)) || ', ' || INITCAP(pkg_encrypt.fn_decrypt(u.firstname))||' '|| INITCAP(pkg_encrypt.fn_decrypt(u.middlename))
      INTO v_lovvalue
      FROM TBL_USERPROFILES u
      WHERE u.userid = ip_lovid;
  ELSIF ip_lovtype = g_lov_userprofile_trans_flname THEN
      SELECT INITCAP(pkg_encrypt.fn_decrypt(u.lastname)) || ', ' || INITCAP(pkg_encrypt.fn_decrypt(u.firstname))||' '|| INITCAP(pkg_encrypt.fn_decrypt(u.middlename))
      INTO v_lovvalue
      FROM TBL_USERPROFILES u
      WHERE u.transcelerateuserid = ip_lovid;
  ELSIF ip_lovtype = g_lov_recipientlist THEN
      SELECT r.listname
      INTO v_lovvalue
      FROM TCSIP_CPORTAL.TBL_RECIPIENTLIST r
      WHERE r.listid = ip_lovid;
  ELSIF ip_lovtype = g_lov_surveysection THEN
      SELECT s.sectiontitle
      INTO v_lovvalue
      FROM TCSIP_CPORTAL.TBL_SURVEYSECTION s
      WHERE s.surveysectionid = ip_lovid;
  ELSIF ip_lovtype = g_lov_surveyquestion THEN
      SELECT q.surveyquestitle
      INTO v_lovvalue
      FROM TCSIP_CPORTAL.TBL_SURVEYQUESTION q
      WHERE q.surveyquesid = ip_lovid;
  ELSIF ip_lovtype = g_lov_surveyanswer THEN
      SELECT a.surveyanstitle
      INTO v_lovvalue
      FROM TCSIP_CPORTAL.TBL_SURVEYANSWER a
      WHERE a.surveyansid = ip_lovid;
  ELSIF ip_lovtype = g_lov_therapeuticarea THEN
      SELECT t.THERAPETICAREANAME
      INTO v_lovvalue
      FROM tbl_orgtherapeuticarea t
      WHERE t.ORGTHERAPEUTICAREAID = ip_lovid;
  ELSIF ip_lovtype = g_lov_subtherapeuticarea THEN
      SELECT st.subtherapeuticareaname
      INTO v_lovvalue
      FROM TBL_SUBTHERAPEUTICAREA st
      WHERE st.subtherapeuticareaid = ip_lovid;
  ELSIF ip_lovtype = g_lov_reasonlist THEN
      SELECT r.listname
      INTO v_lovvalue
      FROM TCSIP_CPORTAL.TBL_REASONLIST r
      WHERE r.reasonlistid = ip_lovid;
  ELSIF ip_lovtype = g_lov_template THEN
      SELECT t.titletemplate
      INTO v_lovvalue
      FROM TBL_TEMPLATE t
      WHERE t.templateid = ip_lovid;
  ELSIF ip_lovtype = g_lov_surveymetadatatype THEN
      SELECT m.metadatatypename
      INTO v_lovvalue
      FROM TCSIP_CPORTAL.TBL_SURVEYMETADATATYPE m
      WHERE m.surveymetadatatypeid = ip_lovid;
  ELSIF ip_lovtype = g_lov_surveylogic THEN
      SELECT l.surveylogicdesc
      INTO v_lovvalue
      FROM TCSIP_CPORTAL.TBL_SURVEYLOGICJUMP l
      WHERE l.surveylogicid = ip_lovid;
  ELSIF ip_lovtype = g_lov_reasons THEN
      v_sql := 'SELECT LISTAGG(r.reason,''|'') WITHIN GROUP (ORDER BY reasonid)
               FROM TCSIP_CPORTAL.TBL_REASONS r
               WHERE r.reasonid IN ('||  REPLACE(ip_lovid,'|',',') || ')';
      v_cursorid := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE(v_cursorid,v_sql,DBMS_SQL.NATIVE);
      DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, v_lovvalue,4000);
      v_rows_processed := DBMS_SQL.EXECUTE(v_cursorid);
      IF DBMS_SQL.FETCH_ROWS(v_cursorid) <> 0 THEN
         DBMS_SQL.COLUMN_VALUE(v_cursorid,1,v_lovvalue);
      END IF;
      DBMS_SQL.CLOSE_CURSOR(v_cursorid);

  ELSIF ip_lovtype = g_lov_surveyresponselist THEN
      SELECT r.listname
      INTO v_lovvalue
      FROM TCSIP_CPORTAL.TBL_SURVEYRESPONSELIST r
      WHERE r.responselistid = ip_lovid;
  ELSIF ip_lovtype = g_lov_surveystatus THEN
      SELECT case when m.surveymetadataid=28 THEN 'Section Delegated' when m.surveymetadataid=29 then 'Question Delegated' else  m.metadatavalue end
      INTO v_lovvalue
      FROM TCSIP_CPORTAL.TBL_SURVEYMETADATA m, TCSIP_CPORTAL.TBL_SURVEYMETADATATYPE mt
      WHERE m.surveymetadatatypeid = mt.surveymetadatatypeid
    --  AND mt.metadatatypename = g_lov_surveystatus
      AND m.surveymetadataid =  ip_lovid;
  
   ELSIF ip_lovtype=g_lov_recptstatus THEN 
   SELECT m.metadatavalue 
      INTO v_lovvalue
      FROM TCSIP_CPORTAL.TBL_SURVEYMETADATA m
      WHERE m.surveymetadataid =  ip_lovid;   
      
  ELSIF ip_lovtype = g_lov_study THEN
      SELECT s.studyname
      INTO v_lovvalue
      FROM TBL_STUDY s
      WHERE s.studyid = ip_lovid;
  ELSIF ip_lovtype = g_lov_survey_id THEN
      SELECT surv.surveytitle
      INTO v_lovvalue
      FROM TBL_SURVEY surv
      Where surv.surveyid=ip_lovid;
  ELSIF ip_lovtype = g_lov_surveytype_id THEN
      SELECT m.metadatavalue
      INTO v_lovvalue
      FROM TCSIP_CPORTAL.TBL_SURVEYMETADATA m, TCSIP_CPORTAL.TBL_SURVEYMETADATATYPE mt
      WHERE m.surveymetadatatypeid = mt.surveymetadatatypeid
      AND mt.metadatatypename = g_lov_surveytype_id
      AND m.surveymetadataid =  ip_lovid;
  ELSIF ip_lovtype = g_lov_site THEN
      SELECT s.sitename
      INTO v_lovvalue
      FROM TBL_SITE s
      WHERE s.siteid = ip_lovid;
  ELSIF ip_lovtype = g_lov_surveyquestion_type THEN
      SELECT m.metadatavalue
      INTO v_lovvalue
      FROM TCSIP_CPORTAL.TBL_SURVEYMETADATA m, TCSIP_CPORTAL.TBL_SURVEYMETADATATYPE mt
      WHERE m.surveymetadatatypeid = mt.surveymetadatatypeid
      AND mt.metadatatypename = g_lov_surveyquestion_type
      AND m.surveymetadataid =  ip_lovid;
  ELSIF ip_lovtype = g_lov_trngtype THEN
      SELECT t.trainingtypename
      INTO v_lovvalue
      FROM TBL_TRAININGTYPE t
      WHERE t.trainingtypeid = ip_lovid;
  ELSIF ip_lovtype = g_lov_facility THEN
      SELECT case WHEN t.ISDEPARTMENT='Y' THEN t.DEPARTMENTNAME||' (Facility - '||t.FACILITYNAME||')' ELSE t.FACILITYNAME END
      INTO v_lovvalue
      FROM TBL_FACILITIES t
      WHERE t.facilityid = ip_lovid;
  ELSIF ip_lovtype = g_lov_docexchangever THEN
      SELECT tde.doctitle
      INTO v_lovvalue
      FROM TBL_DOCEXCHANGE tde, TBL_DOCEXCHANGEVERSION tdev
      WHERE tde.docexchangeid = tdev.docexchangeid
      AND tdev.docexchangeverid = ip_lovid;

  ELSIF ip_lovtype = g_lov_reviewer THEN
      SELECT pkg_encrypt.fn_decrypt(rv.lastname) || ',' || pkg_encrypt.fn_decrypt(rv.firstname) || '(' ||
      CASE
           WHEN u.issponsor = 'Y' THEN
              u.actualtranscelerateuserid
           ELSE
              u.transcelerateuserid
       END || ')'
      INTO v_lovvalue
      FROM TBL_REVIEWER rv, TBL_USERPROFILES u
      WHERE rv.tranecelerateid = u.transcelerateuserid
      AND rv.reviewerid=ip_lovid;
  ELSIF ip_lovtype = g_lov_responsemanager THEN
      SELECT pkg_encrypt.fn_decrypt(rm.lastname) || ',' || pkg_encrypt.fn_decrypt(rm.firstname) || '(' ||
      CASE
           WHEN u.issponsor = 'Y' THEN
              u.actualtranscelerateuserid
           ELSE
              u.transcelerateuserid
       END || ')'
      INTO v_lovvalue
      FROM TBL_RESPONSEMANAGER rm, TBL_USERPROFILES u
      WHERE rm.tranecelerateid = u.transcelerateuserid
      AND rm.RESPONSEMANAGERID=ip_lovid;
  ELSIF ip_lovtype = g_lov_statuscd THEN
      SELECT cd.codevalue
      INTO v_lovvalue
      FROM TBL_CODE cd
      Where upper(cd.CodeName)= Upper(ip_lovid);
  ELSIF ip_lovtype = g_lov_potinv THEN
    SELECT INITCAP(pkg_encrypt.fn_decrypt(u.lastname)) || ', ' || INITCAP(pkg_encrypt.fn_decrypt(u.firstname))||' '|| INITCAP(pkg_encrypt.fn_decrypt(u.middlename))
      INTO v_lovvalue
      FROM Tbl_PotentialInvestigator pi, TBL_USERPROFILES u
      WHERE pi.transcelerateuserid = u.transcelerateuserid
      AND pi.PotentialInvUserId=ip_lovid;
  ELSIF ip_lovtype = g_lov_studysystem THEN
      SELECT systemname
      INTO v_lovvalue
      FROM Tbl_studysystems ss
      Where ss.StudySystemId=ip_lovid;

  ELSIF ip_lovtype = g_lov_surveyusermap THEN
      SELECT TRANECELERATEID
      INTO v_lovvalue
      FROM tbl_surveyusermap sum
      Where sum.SURVEYUSERMAPID=ip_lovid;

  ELSIF ip_lovtype = g_lov_facilitydoctype THEN
      SELECT DOCTYPE
      INTO v_lovvalue
      FROM TBL_FACILITYDOCTYPEMASTER FDTM
      Where FDTM.FACILITYDOCTYPEMASTERID=ip_lovid;


  ELSIF ip_lovtype = g_lov_addlfacility THEN
      SELECT case when MASTERFACILITYTYPECODE='LAB' then LABNAME when MASTERFACILITYTYPECODE='IRB' then IRBNAME end
      INTO v_lovvalue
      FROM TBL_ADDITIONALFACILITY AF
      Where AF.ADDITIONALFACILITYID=ip_lovid;

  ELSIF ip_lovtype = g_lov_facilitydoctitle THEN
      SELECT TITLE
      INTO v_lovvalue
      FROM dlfileentry AF
      Where AF.FILEENTRYID=ip_lovid;

   ELSIF ip_lovtype=g_lov_trngstatus_new THEN
   select trngstatus into v_lovvalue from tbl_trngstatus where trngstatusid=ip_lovid;

    ELSIF ip_lovtype = g_lov_sponsortype THEN
      SELECT SPONSORTYPENAME
      INTO v_lovvalue
      FROM TBL_SPONSORTYPE ST
      Where ST.SPONSORTYPEID=ip_lovid;

  ELSIF ip_lovtype = g_lov_irfacuser_flname THEN
      SELECT INITCAP(pkg_encrypt.fn_decrypt(u.lastname)) || ', ' || INITCAP(pkg_encrypt.fn_decrypt(u.firstname))
      INTO v_lovvalue
      FROM TBL_USERPROFILES u
      WHERE u.userid = (select distinct userid from TBL_IRFACILITYUSERMAP where IRFACILITYUSERMAPID = ip_lovid );

  ELSIF ip_lovtype = g_lov_internetaccess THEN
      SELECT INTERNETACCESS
      INTO v_lovvalue
      FROM TBL_INTERNETACCESS IA
      Where IA.INTERNETACCESSID=ip_lovid;

      ELSIF ip_lovtype = g_lov_compopsys THEN
      SELECT COMPOPERATINGSYS
      INTO v_lovvalue
      FROM TBL_COMPOPERATINGSYS CS
      Where CS.COMPOPERATINGSYSID=ip_lovid;

    ELSIF ip_lovtype = g_lov_docname THEN
      SELECT TITLE
      INTO v_lovvalue
      FROM TBL_DOCUMENTS DOC
      Where DOC.DOCUMENTID=ip_lovid;

     ELSIF ip_lovtype = g_lov_study_trng THEN
      SELECT s.studyname
      INTO v_lovvalue
      FROM TBL_STUDY s
      WHERE s.studyid = ip_lovid;

    ELSIF ip_lovtype = g_lov_tempmeasure THEN
      SELECT TEMPMEASUREMENT
      INTO v_lovvalue
      FROM TBL_TEMPMEASUREMENT TEMP
      Where TEMP.TEMPMEASUREMENTID=ip_lovid;

	  ELSIF ip_lovtype = g_lov_specialty THEN
      SELECT SPECIALTYNAME
      INTO v_lovvalue
      FROM TBL_SPECIALTY SPEC
      Where SPEC.SPECIALTYID=ip_lovid;

	  ELSIF ip_lovtype = g_lov_satellitesites THEN
      SELECT SATELLITESITE
      INTO v_lovvalue
      FROM TBL_SATELLITESITES SAT
      Where SAT.SATELLITESITEID=ip_lovid;

	  ELSIF ip_lovtype = g_lov_phaseofint THEN
      SELECT PHASEOFINTNAME
      INTO v_lovvalue
      FROM TBL_PHASEOFINT POT
      Where POT.PHASEOFINTID=ip_lovid;

	  ELSIF ip_lovtype = g_lov_pottitle THEN
      SELECT TITLENAME
      INTO v_lovvalue
      FROM TBL_POTENTIALINVTITLES POTINV
      Where POTINV.TITLEID=ip_lovid;

	  ELSIF ip_lovtype = g_lov_labacc THEN
      SELECT LABACCREDITATIONNAME
      INTO v_lovvalue
      FROM TBL_LABACCREDITATION LABACC
      Where LABACC.LABACCREDITATIONID=ip_lovid;

	  ELSIF ip_lovtype = g_lov_orgsysname THEN
      SELECT SYSTEMNAME
      INTO v_lovvalue
      FROM TBL_ORGSYSTEMACCESS ORGSYS
      Where ORGSYS.ORGSYSTEMID=ip_lovid;

  	  ELSIF ip_lovtype = g_lov_access THEN
      SELECT ACCESSTYPE
      INTO v_lovvalue
      FROM TBL_ORGSYSTEMACCESS ORGSYS
      Where ORGSYS.ORGSYSTEMID=ip_lovid;

      ELSIF ip_lovtype = g_lov_surveycd THEN
      SELECT surv.surveycd
      INTO v_lovvalue
      FROM TBL_SURVEY surv
      Where surv.surveyid=ip_lovid;

	  ELSIF ip_lovtype = g_lov_studytheraarea THEN
      SELECT THERAPETICAREANAME
      INTO v_lovvalue
      FROM TBL_ORGTHERAPEUTICAREA ORGTHERA
      Where ORGTHERA.ORGTHERAPEUTICAREAID=ip_lovid;
      ELSIF ip_lovtype = g_lov_activeflag THEN
            IF ip_lovid = 'Y' THEN
               v_lovvalue := 'Active';
            ELSIF ip_lovid = 'N' THEN
               v_lovvalue := 'Inactive';
            ELSIF ip_lovid = 'D' THEN
               v_lovvalue := 'Delete' ;
            END IF;
      ELSIF ip_lovtype = g_lov_irbtype THEN
            SELECT tirt.irbtypename
            INTO v_lovvalue
            FROM TBL_IRBTYPE tirt
            WHERE tirt.irbtypeid = ip_lovid;
      ELSIF ip_lovtype = g_lov_pkgsub THEN
            SELECT tps.packagesubname
            INTO v_lovvalue
            FROM TBL_PACKAGESUBMISSION tps
            WHERE tps.packagesubid = ip_lovid;
      ELSIF ip_lovtype = g_lov_meetfreq THEN
            SELECT tmf.meetingfreqname
            INTO v_lovvalue
            FROM TBL_MEETINGFREQ tmf
            WHERE tmf.meetingfreqid = ip_lovid;
	  ELSIF ip_lovtype = g_lov_surveytype THEN
           SELECT tmf.metadataname
           INTO v_lovvalue
           FROM tbl_surveymetadata tmf
           WHERE tmf.surveymetadataid = ip_lovid;
     ELSIF ip_lovtype = g_lov_surveyans THEN
           SELECT SURANS.SURVEYANSTITLE
           INTO v_lovvalue
           FROM TCSIP_CPORTAL.TBL_SURVEYANSWER SURANS
           WHERE SURANS.SURVEYANSID = ip_lovid;
	  
	  ELSIF ip_lovtype=g_lov_surveycreator THEN 
         
      SELECT INITCAP(pkg_encrypt.fn_decrypt(up.lastname))  || ', '  || INITCAP(pkg_encrypt.fn_decrypt(firstname)) || ' (' ||
                               CASE
                                WHEN up.issponsor = 'Y' THEN
                                    up.actualtranscelerateuserid
                                ELSE
                                    up.transcelerateuserid
                               END
                               ||')' INTO v_lovvalue
                               FROM tbl_userprofiles up
                               WHERE up.transcelerateuserid =ip_lovid;	   

      ELSIF ip_lovtype = g_lov_notapplicable THEN
            IF ip_lovid = 'Y' THEN
               v_lovvalue := 'N';
            ELSIF ip_lovid = 'N' THEN
               v_lovvalue := 'Y';
            ELSE
               v_lovvalue := ip_lovid;
            END IF;
  END IF;

  RETURN v_lovvalue;

EXCEPTION
  WHEN OTHERS THEN
      RETURN NULL;
END fn_get_lov_value;

FUNCTION fn_get_del_createdby
(ip_tablename     IN VARCHAR2,
 ip_primary_key    IN VARCHAR2
) RETURN VARCHAR2
IS
v_createdby  TBL_USERPROFILES.transcelerateuserid%TYPE;
BEGIN

  SELECT createdby
  INTO v_createdby
  FROM (
  SELECT td.transcelerateuserid createdby
  FROM tbl_deletedrecord td
  WHERE td.tablename = ip_tablename
  AND td.primary_key = ip_primary_key
  ORDER BY deletedrecordid DESC)
  WHERE ROWNUM = 1;

  RETURN v_createdby;

EXCEPTION
  WHEN OTHERS THEN
      RETURN 'SYSTEM';
END fn_get_del_createdby;

FUNCTION fn_get_del_createddt
(ip_tablename     IN VARCHAR2,
 ip_primary_key    IN VARCHAR2
) RETURN DATE
IS
v_createddt  TBL_USERPROFILES.createddt%TYPE;
BEGIN

  SELECT createddt
  INTO v_createddt
  FROM (
  SELECT td.createddt
  FROM tbl_deletedrecord td
  WHERE td.tablename = ip_tablename
  AND td.primary_key = ip_primary_key
  ORDER BY deletedrecordid DESC)
  WHERE ROWNUM = 1;

  RETURN v_createddt;

EXCEPTION
  WHEN OTHERS THEN
      RETURN SYSDATE;
END fn_get_del_createddt;

PROCEDURE sp_del_deletedrecords
(ip_tablename     IN VARCHAR2,
 ip_primary_key   IN VARCHAR2)
IS
BEGIN

  DELETE FROM tbl_deletedrecord td
  WHERE td.tablename = ip_tablename
  AND td.primary_key = ip_primary_key;

END sp_del_deletedrecords;

FUNCTION FN_GET_USER_ORGID
(ip_transcelerateuserid IN TBL_USERPROFILES.TRANSCELERATEUSERID%TYPE)
RETURN NUMBER
IS
v_orgid       TBL_ORGANIZATION.orgid%TYPE;
V_ISSPONSOR   tbl_userprofiles.issponsor%TYPE;
BEGIN
  select TU.ISSPONSOR,TU.ORGID into V_ISSPONSOR,v_orgid from tbl_userprofiles TU where TU.Transcelerateuserid=ip_transcelerateuserid;

  IF V_ISSPONSOR ='N' THEN


   SELECT  ORGID INTO v_orgid from (select org.orgid  FROM TBL_ORGSITESTAFFMAP ORG,TBL_USERPROFILES TU
    WHERE ORG.SITESTAFFUSERID =TU.USERID
    AND  TU.Transcelerateuserid=ip_transcelerateuserid
    order by org.createddt desc)
    where rownum<=1;


   END IF;
  RETURN v_orgid;
  EXCEPTION  when OTHERS THEN
   RETURN NULL;
END FN_GET_USER_ORGID;

FUNCTION FN_GET_USER_ORGNAME
(ip_transcelerateuserid IN TBL_USERPROFILES.TRANSCELERATEUSERID%TYPE)
RETURN varchar2
IS
v_orgname      TBL_ORGANIZATION.Orgname%TYPE;
BEGIN
 SELECT ORGNAME INTO v_orgname FROM TBL_ORGANIZATION WHERE ORGID=FN_GET_USER_ORGID(ip_transcelerateuserid);


 return v_orgname;
EXCEPTION  when OTHERS THEN
   RETURN NULL;

END FN_GET_USER_ORGNAME;

FUNCTION FN_CHECK_USER_ORG
(ip_transcelerateuserid IN TBL_USERPROFILES.TRANSCELERATEUSERID%TYPE,
 ip_loggedinorgid               IN TBL_USERPROFILES.ORGID%TYPE)
RETURN NUMBER
IS
V_ORG_COUNT   PLS_INTEGER:=0;
v_orgid       TBL_ORGANIZATION.orgid%TYPE;
V_ISSPONSOR   tbl_userprofiles.issponsor%TYPE;
BEGIN
  select TU.ISSPONSOR into V_ISSPONSOR from tbl_userprofiles TU
   where TU.Transcelerateuserid=ip_transcelerateuserid;

  IF V_ISSPONSOR ='N' THEN

 SELECT count(1) into V_ORG_COUNT  FROM TBL_ORGSITESTAFFMAP ORG,TBL_USERPROFILES TU
        WHERE    ORG.SITESTAFFUSERID =TU.USERID
          AND  TU.Transcelerateuserid=ip_transcelerateuserid
          AND ORG.orgid =ip_loggedinorgid;
  ELSE
      select count(1) into V_ORG_COUNT from tbl_userprofiles TU
   where TU.Transcelerateuserid=ip_transcelerateuserid
   and tu.orgid=ip_loggedinorgid;

   END IF;

 RETURN V_ORG_COUNT;
 EXCEPTION  when OTHERS THEN
   RETURN 0;
 END FN_CHECK_USER_ORG;

END pkg_audit;
/