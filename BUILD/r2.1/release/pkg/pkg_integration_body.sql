CREATE OR REPLACE PACKAGE BODY PKG_INTEGRATION AS

PROCEDURE SP_SET_STUDY_INT
(
ip_studyid    IN TBL_STUDY.studyid%TYPE,
ip_operation  IN TBL_INTEGRATION.operation%TYPE, 
op_study      OUT SYS_REFCURSOR
)
IS
v_integrationid       TBL_INTEGRATION.integrationid%TYPE;
v_createddt           DATE:= SYSDATE;
v_studycountry        SYS_REFCURSOR;
BEGIN

  --Study Integration
  SELECT seq_integration.NEXTVAL INTO v_integrationid FROM DUAL;
  
  INSERT INTO TBL_INTEGRATION
        (integrationid,studyid,sipstudyid,studyname,docexstudyid,studyshortdesc,
         studylongdesc,plannednextdatabaselock,plannedfinaldatabaselock,
         subjectsplanned,subjectsenrolled,iscreatedbyintegration,progid,
         progname,memberprogramcd,compoundid,compoundname,membercompoundcd,
         therapeuticareaid,therapeuticareacd,therapeuticareaname,diseaseid,
         diseasename,memberdiseasecd,indicationid,indicationname,memberindicationcd,
         docexcompoundid,veeva_compoundgroupforpi,veeva_compoundgroupfornonpi,
         orgid,orgcode,docexsystemid,docexsystemname,
         operation,createdby,createddt,modifiedby,modifieddt)
  SELECT v_integrationid,ts.studyid,ts.sipstudyid,ts.studyname,tsdm.docexstudyid,ts.studyshortdesc,
         ts.studylongdesc,ts.plannednextdatabaselock,ts.plannedfinaldatabaselock,
         ts.subjectsplanned,ts.subjectsenrolled,ts.iscreatedbyintegration,tp.progid,
         tp.progname,tp.memberprogramcd,tc.compoundid,tc.compoundname,tc.membercompoundcd,
         tt.therapeuticareaid,tt.therapeuticareacd,tt.therapeuticareaname,td.diseaseid,
         td.diseasename,td.memberdiseasecd,ti.indicationid,ti.indicationname,ti.memberindicationcd,
         tcdm.docexsystemcompid docex_compoundid,tcdm.veeva_compoundgroupforpi,tcdm.veeva_compoundgroupfornonpi,
         tor.orgid,tor.orgcd orgcode,tdcs.docexsystemid,tdcs.docexsystemname,
         ip_operation,gv_createdby,v_createddt,NULL,NULL
  FROM TBL_STUDY ts, 
       TBL_PROGRAM tp, 
       TBL_ORGANIZATION tor, 
       TBL_COMPOUND tc,
       TBL_THERAPEUTICAREA tt, 
       TBL_DISEASE td, 
       TBL_INDICATION ti,
       TBL_COMPOUNDDOCEXMAP tcdm,
       TBL_STUDYDOCEXMAP tsdm,
       TBL_DOCEXSYSTEM tdcs
  WHERE ts.progid = tp.progid
  AND tp.orgid = tor.orgid
  AND ts.compoundid = tc.compoundid
  AND ts.therapeuticareaid = tt.therapeuticareaid
  AND ts.diseaseid = td.diseaseid(+)
  AND ts.indicationid = ti.indicationid
  AND ts.compoundid = tcdm.compoundid(+)
  AND ts.studyid = tsdm.studyid(+)
  AND tsdm.docexsystemid = tdcs.docexsystemid(+)
  AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay
  AND ts.studyid = ip_studyid;
  
  --Study Country Integration
  /*FOR i IN (SELECT ts.studyid, tscm.studycountryid
            FROM TBL_STUDY ts,
                 TBL_STUDYCOUNTRYMILESTONE tscm,
                 TBL_STUDYDOCEXMAP tsdm,
                 TBL_DOCEXSYSTEM tdcs
            WHERE ts.studyid = tscm.studyid
            AND ts.studyid = tsdm.studyid(+)
            AND tsdm.docexsystemid = tdcs.docexsystemid(+)
            AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay
            AND tscm.studyid = ip_studyid
            AND tscm.isactive = 'Y') LOOP
      SP_SET_STUDYCOUNTRY_INT(i.studycountryid,gv_operation_addstudycountry,v_studycountry);
  END LOOP;*/
  
  OPEN op_study FOR
       SELECT * 
       FROM TBL_INTEGRATION
       WHERE integrationid = v_integrationid;
  
END SP_SET_STUDY_INT;

PROCEDURE SP_SET_SITE_INT
(
ip_siteid     IN TBL_SITE.siteid%TYPE,
ip_operation  IN TBL_INTEGRATION.operation%TYPE,
op_site       OUT SYS_REFCURSOR
)
IS
v_integrationid       TBL_INTEGRATION.integrationid%TYPE;
v_createddt             DATE:= SYSDATE;
BEGIN

  --Site Integration
    SELECT seq_integration.NEXTVAL INTO v_integrationid FROM DUAL;
    
    INSERT INTO TBL_INTEGRATION
          (integrationid,studyid,sipstudyid,studyname,docexstudyid,siteid,sipsiteid,sitename,isaffiliated,
           piid,principalfacilityid,docexsiteid,study_countrycd,study_countryname,docexstudycountryid,
           userid,transcelerateuserid,sipuserid,veeva_userid,veeva_personid,docexcommonvaultuserid,
           prefix,title,firstname,middlename,lastname,suffix,initials,isactive,
           timezoneid,user_contactid,user_contacttype,user_addresstype,user_address1,user_address2,
           user_address3,user_city,user_statename,user_statecd,user_countryname,user_countrycd,
           user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,facilityid,facilityname,
           irfacilityid,masterfacilitytypecode,isdepartment,departmentid,departmentname,departmenttypeid,
           irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,fac_address1,fac_address2,
           fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,fac_countrycd,fac_postalcode,
           fac_phone1,fac_phone1ext,fac_fax,fac_email,dept_contactid,dept_contacttype,dept_addresstype,
           dept_address1,dept_address2,dept_address3,dept_city,dept_statename,dept_statecd,dept_countryname,
           dept_countrycd,dept_postalcode,dept_phone1,dept_phone1ext,dept_fax,dept_email,orgid,orgcode,
           docexsystemid,docexsystemname,compoundid,compoundname,membercompoundcd,docexcompoundid,
           veeva_compoundgroupforpi,veeva_compoundgroupfornonpi,operation,createdby,createddt,modifiedby,modifieddt)
    SELECT v_integrationid,tsd.studyid,tsd.sipstudyid,tsd.studyname,tsdm.docexstudyid,ts.siteid,ts.sipsiteid,ts.sitename,ts.isaffiliated,
           ts.piid,ts.principalfacilityid,ts.docexsiteid,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                   (SELECT tcnt.countrycd
                    FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_DOCEXSTUDYCNTRYMSTONEMAP tdscm,TBL_COUNTRIES tcnt
                    WHERE tscm.studycountryid = tdscm.studycountryid(+)
                    AND tscm.countryid = tcnt.countryid
                    AND tscm.studyid = tsd.studyid
                    AND tcnt.countrycd = tcf.countrycd
                    AND tscm.isactive = 'Y')
               ELSE 
                  (SELECT tcnt.countrycd
                   FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_DOCEXSTUDYCNTRYMSTONEMAP tdscm,TBL_COUNTRIES tcnt
                   WHERE tscm.studycountryid = tdscm.studycountryid(+)
                   AND tscm.countryid = tcnt.countryid
                   AND tscm.studyid = tsd.studyid
                   AND tcnt.countrycd = tcd.countrycd
                   AND tscm.isactive = 'Y')
           END study_countrycd,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                   (SELECT tcnt.countryname
                    FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_DOCEXSTUDYCNTRYMSTONEMAP tdscm,TBL_COUNTRIES tcnt
                    WHERE tscm.studycountryid = tdscm.studycountryid(+)
                    AND tscm.countryid = tcnt.countryid
                    AND tscm.studyid = tsd.studyid
                    AND tcnt.countrycd = tcf.countrycd
                    AND tscm.isactive = 'Y') 
               ELSE 
                  (SELECT tcnt.countryname
                   FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_DOCEXSTUDYCNTRYMSTONEMAP tdscm,TBL_COUNTRIES tcnt
                   WHERE tscm.studycountryid = tdscm.studycountryid(+)
                   AND tscm.countryid = tcnt.countryid
                   AND tscm.studyid = tsd.studyid
                   AND tcnt.countrycd = tcd.countrycd
                   AND tscm.isactive = 'Y')
           END study_countryname,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                   (SELECT tdscm.docexstudycountryid
                    FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_DOCEXSTUDYCNTRYMSTONEMAP tdscm,TBL_COUNTRIES tcnt
                    WHERE tscm.studycountryid = tdscm.studycountryid(+)
                    AND tscm.countryid = tcnt.countryid
                    AND tscm.studyid = tsd.studyid
                    AND tcnt.countrycd = tcf.countrycd
                    AND tscm.isactive = 'Y')
               ELSE 
                  (SELECT tdscm.docexstudycountryid
                   FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_DOCEXSTUDYCNTRYMSTONEMAP tdscm,TBL_COUNTRIES tcnt
                   WHERE tscm.studycountryid = tdscm.studycountryid(+)
                   AND tscm.countryid = tcnt.countryid
                   AND tscm.studyid = tsd.studyid
                   AND tcnt.countrycd = tcd.countrycd
                   AND tscm.isactive = 'Y')
           END docexstudycountryid,
           tu.userid,tu.transcelerateuserid,tu.sipuserid,
          (SELECT tud.docexuserid
           FROM TBL_USERDOCEXMAP tud
           WHERE tud.userid = tu.userid
           AND tud.orgid = tor.orgid) veeva_userid,
          (SELECT tud.docexpersonid
           FROM TBL_USERDOCEXMAP tud
           WHERE tud.userid = tu.userid
           AND tud.orgid = tor.orgid) veeva_personid,
          (SELECT tud.docexcommonvaultuserid
           FROM TBL_USERDOCEXMAP tud
           WHERE tud.userid = tu.userid
           AND tud.orgid = tor.orgid) docexcommonvaultuserid,
           tu.prefix,tu.title,tu.firstname,tu.middlename,tu.lastname,tu.suffix,
           tu.initials,tu.isactive,tu.timezoneid,tcu.contactid user_contactid,tcu.contacttype user_contacttype,
           tcu.addresstype user_addresstype,tcu.address1 user_address1,tcu.address2 user_address2,
           tcu.address3 user_address3,tcu.city user_city,
           (SELECT tst.statename
           FROM TBL_STATES tst, TBL_COUNTRIES tcnt
           WHERE tst.countryid = tcnt.countryid
           AND tcnt.countrycd = tcu.countrycd
           AND tst.statecd = tcu.state) user_statename,
           tcu.state fac_statecd,
           (SELECT tcnt.countryname 
           FROM TBL_COUNTRIES tcnt
           WHERE tcnt.countrycd = tcu.countrycd) user_countryname,
           tcu.countrycd user_countrycd,tcu.postalcode user_postalcode,tcu.phone1 user_phone1,tcu.phone1ext user_phone1ext,
           tcu.fax user_fax,tcu.email user_email,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tf.facilityfordept 
               ELSE tf.facilityid     
           END facilityid,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tpf.facilityname 
               ELSE tf.facilityname     
           END facilityname,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tpf.irfacilityid 
               ELSE tf.irfacilityid     
           END irfacilityid,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tpf.masterfacilitytypecode 
               ELSE tf.masterfacilitytypecode     
           END masterfacilitytypecode,
           tf.isdepartment,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tf.facilityid 
               ELSE NULL     
           END departmentid,
           tf.departmentname,
           tf.departmenttypeid,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tf.irfacilityid 
               ELSE NULL    
           END irdepartmentid,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcd.contactid  
               ELSE tcf.contactid     
           END fac_contactid,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcd.contacttype  
               ELSE tcf.contacttype     
           END fac_contacttype,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcd.addresstype  
               ELSE tcf.addresstype     
           END fac_addresstype,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcd.address1  
               ELSE tcf.address1     
           END fac_address1,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcd.address2  
               ELSE tcf.address2     
           END fac_address2,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcd.address3  
               ELSE tcf.address3     
           END fac_address3,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcd.city  
               ELSE tcf.city     
           END fac_city,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    (SELECT tst.statename
                     FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                     WHERE tst.countryid = tcnt.countryid
                     AND tcnt.countrycd = tcd.countrycd
                     AND tst.statecd = tcd.state)  
               ELSE (SELECT tst.statename
                     FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                     WHERE tst.countryid = tcnt.countryid
                     AND tcnt.countrycd = tcf.countrycd
                     AND tst.statecd = tcf.state)     
           END fac_statename,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcd.state  
               ELSE tcf.state     
           END fac_statecd,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    (SELECT tcnt.countryname 
                     FROM TBL_COUNTRIES tcnt
                     WHERE tcnt.countrycd = tcd.countrycd)  
               ELSE (SELECT tcnt.countryname 
                     FROM TBL_COUNTRIES tcnt
                     WHERE tcnt.countrycd = tcf.countrycd)     
           END fac_countryname,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcd.countrycd  
               ELSE tcf.countrycd     
           END fac_countrycd,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcd.postalcode  
               ELSE tcf.postalcode     
           END fac_postalcode,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcd.phone1  
               ELSE tcf.phone1     
           END fac_phone1,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcd.phone1ext  
               ELSE tcf.phone1ext     
           END fac_phone1ext,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcd.fax  
               ELSE tcf.fax     
           END fac_fax,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcd.email  
               ELSE tcf.email     
           END fac_email,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcf.contactid  
               ELSE NULL     
           END dept_contactid,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcf.contacttype  
               ELSE NULL     
           END dept_contacttype,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcf.addresstype  
               ELSE NULL     
           END dept_addresstype,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcf.address1  
               ELSE NULL     
           END dept_address1,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcf.address2  
               ELSE NULL     
           END dept_address2,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcf.address3  
               ELSE NULL     
           END dept_address3,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcf.city  
               ELSE NULL     
           END dept_city,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    (SELECT tst.statename
                     FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                     WHERE tst.countryid = tcnt.countryid
                     AND tcnt.countrycd = tcf.countrycd
                     AND tst.statecd = tcf.state)  
               ELSE NULL     
           END dept_statename,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcf.state  
               ELSE NULL     
           END dept_statecd,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    (SELECT tcnt.countryname 
                     FROM TBL_COUNTRIES tcnt
                     WHERE tcnt.countrycd = tcf.countrycd)  
               ELSE NULL     
           END dept_countryname,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcf.countrycd  
               ELSE NULL     
           END dept_countrycd,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcf.postalcode  
               ELSE NULL     
           END dept_postalcode,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcf.phone1  
               ELSE NULL     
           END dept_phone1,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcf.phone1ext  
               ELSE NULL     
           END dept_phone1ext,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcf.fax  
               ELSE NULL     
           END dept_fax,
           CASE 
               WHEN tf.isdepartment = 'Y' THEN
                    tcf.email  
               ELSE NULL     
           END dept_email,
           tor.orgid,tor.orgcd orgcode,tdcs.docexsystemid,tdcs.docexsystemname,
           tc.compoundid,tc.compoundname,tc.membercompoundcd,
           tcdm.docexsystemcompid docex_compoundid,tcdm.veeva_compoundgroupforpi,tcdm.veeva_compoundgroupfornonpi,
           ip_operation,gv_createdby,v_createddt,NULL,NULL
    FROM TBL_STUDY tsd, 
         TBL_PROGRAM tp, 
         TBL_ORGANIZATION tor,
         TBL_SITE ts, 
         TBL_CONTACT tcu, 
         TBL_COMPOUND tc, 
         TBL_COMPOUNDDOCEXMAP tcdm,
         TBL_USERPROFILES tu, 
         TBL_FACILITIES tf,  
         TBL_CONTACT tcf,
         TBL_FACILITIES tpf, 
         TBL_CONTACT tcd,
         TBL_STUDYDOCEXMAP tsdm,
         TBL_DOCEXSYSTEM tdcs
    WHERE tsd.studyid = ts.studyid
    AND tsd.progid = tp.progid
    AND tp.orgid = tor.orgid
    AND tsd.compoundid = tc.compoundid
    AND tsd.compoundid = tcdm.compoundid(+)
    AND ts.piid = tu.userid
    AND tu.contactid = tcu.contactid(+)
    AND ts.principalfacilityid = tf.facilityid(+)
    AND tf.contactid = tcf.contactid(+)
    AND tf.facilityfordept = tpf.facilityid(+)
    AND tpf.contactid = tcd.contactid(+)
    AND tsd.studyid = tsdm.studyid(+)
    AND tsdm.docexsystemid = tdcs.docexsystemid(+)
    AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay
    AND ts.siteid = ip_siteid;
  
    OPEN op_site FOR
        SELECT * 
        FROM TBL_INTEGRATION 
        WHERE integrationid = v_integrationid;
  
END SP_SET_SITE_INT;

PROCEDURE SP_SET_UPDATESITE_INT
(
ip_siteid         IN TBL_SITE.siteid%TYPE,
ip_oldfacilityid  IN TBL_FACILITIES.facilityid%TYPE,
ip_newfacilityid  IN TBL_FACILITIES.facilityid%TYPE,
ip_operation      IN TBL_INTEGRATION.operation%TYPE,
op_site           OUT SYS_REFCURSOR
)
IS
v_createddt           DATE:= SYSDATE;
BEGIN

    --Update Site Integration
    SP_SET_SITE_INT(ip_siteid,ip_operation,op_site);
    
    INSERT INTO TBL_INTEGRATION
          (integrationid,roleid,rolename,description,effectivestartdate,effectiveenddate,rolechangereason,
           studyid,studyname,docexstudyid,siteid,sitename,docexsiteid,userid,transcelerateuserid,sipuserid,veeva_userid,
           veeva_personid,docexcommonvaultuserid,prefix,title,firstname,middlename,lastname,suffix,initials,isactive,
           timezoneid,user_contactid,user_contacttype,user_addresstype,user_address1,user_address2,
           user_address3,user_city,user_statename,user_statecd,user_countryname,user_countrycd,
           user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,orgid,orgcode,
           docexsystemid,docexsystemname,operation,createdby,createddt,modifiedby,modifieddt)
    SELECT SEQ_INTEGRATION.NEXTVAL,tr.roleid,tr.rolename,tr.description,turm.effectivestartdate,turm.effectiveenddate,
           turm.rolechangereason,tsd.studyid,tsd.studyname,tsdm.docexstudyid,ts.siteid,ts.sitename,ts.docexsiteid,
           tu.userid,tu.transcelerateuserid,tu.sipuserid,
          (SELECT tud.docexuserid
           FROM TBL_USERDOCEXMAP tud
           WHERE tud.userid = tu.userid
           AND tud.orgid = tor.orgid) veeva_userid,
          (SELECT tud.docexpersonid
           FROM TBL_USERDOCEXMAP tud
           WHERE tud.userid = tu.userid
           AND tud.orgid = tor.orgid) veeva_personid,
          (SELECT tud.docexcommonvaultuserid
           FROM TBL_USERDOCEXMAP tud
           WHERE tud.userid = tu.userid
           AND tud.orgid = tor.orgid) docexcommonvaultuserid,
           tu.prefix,tu.title,tu.firstname,tu.middlename,tu.lastname,tu.suffix,tu.initials,tu.isactive,tu.timezoneid,
           tcu.contactid user_contactid,tcu.contacttype user_contacttype,tcu.addresstype user_addresstype,
           tcu.address1 user_address1,tcu.address2 user_address2,tcu.address3 user_address3,tcu.city user_city,
           (SELECT tst.statename 
            FROM TBL_STATES tst, TBL_COUNTRIES tcnt
            WHERE tst.statecd = tcu.state
            AND tst.countryid = tcnt.countryid
            AND tcnt.countrycd = tcu.countrycd) user_statename,
           (SELECT tcu.state 
            FROM TBL_STATES tst, TBL_COUNTRIES tcnt
            WHERE tst.statecd = tcu.state
            AND tst.countryid = tcnt.countryid
            AND tcnt.countrycd = tcu.countrycd) user_statecd,
           (SELECT tcnt.countryname 
            FROM TBL_COUNTRIES tcnt
            WHERE tcnt.countrycd = tcu.countrycd) user_countryname,
           (SELECT tcu.countrycd 
            FROM TBL_COUNTRIES tcnt
            WHERE tcnt.countrycd = tcu.countrycd) user_countrycd,
           tcu.postalcode user_postalcode,tcu.phone1 user_phone1,tcu.phone1ext user_phone1ext,tcu.fax user_fax,tcu.email user_email,
           tu.orgid,tor.orgcd orgcode,tdcs.docexsystemid,tdcs.docexsystemname,
           ip_operation,gv_createdby,v_createddt,NULL,NULL
    FROM TBL_USERROLEMAP turm,
         TBL_ROLES tr,
         TBL_STUDY tsd,
         TBL_SITE ts,
         TBL_USERPROFILES tu,
         TBL_ORGANIZATION tor,
         TBL_CONTACT tcu,
         TBL_STUDYDOCEXMAP tsdm,
         TBL_DOCEXSYSTEM tdcs
    WHERE turm.roleid = tr.roleid 
    AND turm.studyid = tsd.studyid
    AND turm.siteid = ts.siteid
    AND turm.userid = tu.userid
    AND tu.orgid = tor.orgid(+)
    AND tu.contactid = tcu.contactid(+)
    AND tsd.studyid = tsdm.studyid(+)
    AND tsdm.docexsystemid = tdcs.docexsystemid(+)
    AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay
    AND turm.userid IN (SELECT tfum.userid
                        FROM TBL_IRFACILITYUSERMAP tfum
                        WHERE tfum.facilityid = ip_oldfacilityid
                        AND tfum.isactive = 'Y'
                        MINUS
                        SELECT tfum.userid
                        FROM TBL_IRFACILITYUSERMAP tfum
                        WHERE tfum.facilityid = ip_newfacilityid
                        AND tfum.isactive = 'Y')
    AND ts.siteid = ip_siteid;
    
END SP_SET_UPDATESITE_INT;

PROCEDURE SP_SET_USERACCESS_INT
(
ip_userroleid       IN TBL_USERROLEMAP.userroleid%TYPE,
ip_operation        IN TBL_INTEGRATION.operation%TYPE,
op_useraccess       OUT SYS_REFCURSOR
)
IS
v_integrationid     TBL_INTEGRATION.integrationid%TYPE;
v_createddt           DATE:= SYSDATE;
BEGIN
  --User Access Integration
  SELECT seq_integration.NEXTVAL INTO v_integrationid FROM DUAL;
  
  INSERT INTO TBL_INTEGRATION
        (integrationid,roleid,rolename,description,effectivestartdate,effectiveenddate,rolechangereason,
         studyid,studyname,docexstudyid,siteid,sitename,docexsiteid,study_countrycd,study_countryname,docexstudycountryid,
         userid,transcelerateuserid,sipuserid,veeva_userid,veeva_personid,
         docexcommonvaultuserid,userroleid,docexuserroleid,prefix,title,firstname,middlename,lastname,suffix,initials,isactive,
         timezoneid,user_contactid,user_contacttype,user_addresstype,user_address1,user_address2,
         user_address3,user_city,user_statename,user_statecd,user_countryname,user_countrycd,
         user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,facilityid,facilityname,
         irfacilityid,masterfacilitytypecode,isdepartment,departmentid,departmentname,departmenttypeid,
         irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,fac_address1,fac_address2,
         fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,fac_countrycd,fac_postalcode,
         fac_phone1,fac_phone1ext,fac_fax,fac_email,dept_contactid,dept_contacttype,dept_addresstype,
         dept_address1,dept_address2,dept_address3,dept_city,dept_statename,dept_statecd,dept_countryname,
         dept_countrycd,dept_postalcode,dept_phone1,dept_phone1ext,dept_fax,dept_email,orgid,orgcode,
         docexsystemid,docexsystemname,compoundid,compoundname,membercompoundcd,docexcompoundid,
         veeva_compoundgroupforpi,veeva_compoundgroupfornonpi,operation,createdby,createddt,modifiedby,modifieddt)
  SELECT v_integrationid,tr.roleid,tr.rolename,tr.description,turm.effectivestartdate,turm.effectiveenddate,
         turm.rolechangereason,tsd.studyid,tsd.studyname,tsdm.docexstudyid,ts.siteid,ts.sitename,ts.docexsiteid,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                 (SELECT tcnt.countrycd
                  FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_COUNTRIES tcnt
                  WHERE tscm.countryid = tcnt.countryid
                  AND tscm.studyid = tsd.studyid
                  AND tcnt.countrycd = tcf.countrycd
                  AND tscm.isactive = 'Y')
             ELSE 
                 (SELECT tcnt.countrycd
                  FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_COUNTRIES tcnt
                  WHERE tscm.countryid = tcnt.countryid
                  AND tscm.studyid = tsd.studyid
                  AND tcnt.countrycd = tcd.countrycd
                  AND tscm.isactive = 'Y')
        END study_countrycd,
        CASE 
            WHEN tf.isdepartment = 'Y' THEN
               (SELECT tcnt.countryname
                FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_COUNTRIES tcnt
                WHERE tscm.countryid = tcnt.countryid
                AND tscm.studyid = tsd.studyid
                AND tcnt.countrycd = tcf.countrycd
                AND tscm.isactive = 'Y') 
            ELSE 
              (SELECT tcnt.countryname
               FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_COUNTRIES tcnt
               WHERE tscm.countryid = tcnt.countryid
               AND tscm.studyid = tsd.studyid
               AND tcnt.countrycd = tcd.countrycd
               AND tscm.isactive = 'Y')
        END study_countryname,
        CASE 
           WHEN tf.isdepartment = 'Y' THEN
               (SELECT tdscm.docexstudycountryid
                FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_DOCEXSTUDYCNTRYMSTONEMAP tdscm,TBL_COUNTRIES tcnt
                WHERE tscm.studycountryid = tdscm.studycountryid(+)
                AND tscm.countryid = tcnt.countryid
                AND tscm.studyid = tsd.studyid
                AND tcnt.countrycd = tcf.countrycd
                AND tscm.isactive = 'Y')
           ELSE 
              (SELECT tdscm.docexstudycountryid
               FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_DOCEXSTUDYCNTRYMSTONEMAP tdscm,TBL_COUNTRIES tcnt
               WHERE tscm.studycountryid = tdscm.studycountryid(+)
               AND tscm.countryid = tcnt.countryid
               AND tscm.studyid = tsd.studyid
               AND tcnt.countrycd = tcd.countrycd
               AND tscm.isactive = 'Y')
        END docexstudycountryid,
         tu.userid,tu.transcelerateuserid,tu.sipuserid,
        (SELECT tud.docexuserid
         FROM TBL_USERDOCEXMAP tud
         WHERE tud.userid = tu.userid
         AND tud.orgid = tor.orgid) veeva_userid,
        (SELECT tud.docexpersonid
         FROM TBL_USERDOCEXMAP tud
         WHERE tud.userid = tu.userid
         AND tud.orgid = tor.orgid) veeva_personid,
        (SELECT tud.docexcommonvaultuserid
         FROM TBL_USERDOCEXMAP tud
         WHERE tud.userid = tu.userid
         AND tud.orgid = tor.orgid) docexcommonvaultuserid,
         turm.userroleid,turm.docexuserroleid,tu.prefix,tu.title,tu.firstname,tu.middlename,tu.lastname,tu.suffix,tu.initials,tu.isactive,tu.timezoneid,
         tcu.contactid user_contactid,tcu.contacttype user_contacttype,tcu.addresstype user_addresstype,
         tcu.address1 user_address1,tcu.address2 user_address2,tcu.address3 user_address3,tcu.city user_city,
         (SELECT tst.statename 
          FROM TBL_STATES tst, TBL_COUNTRIES tcnt
          WHERE tst.statecd = tcu.state
          AND tst.countryid = tcnt.countryid
          AND tcnt.countrycd = tcu.countrycd) user_statename,
         (SELECT tcu.state 
          FROM TBL_STATES tst, TBL_COUNTRIES tcnt
          WHERE tst.statecd = tcu.state
          AND tst.countryid = tcnt.countryid
          AND tcnt.countrycd = tcu.countrycd) user_statecd,
         (SELECT tcnt.countryname 
          FROM TBL_COUNTRIES tcnt
          WHERE tcnt.countrycd = tcu.countrycd) user_countryname,
         (SELECT tcu.countrycd 
          FROM TBL_COUNTRIES tcnt
          WHERE tcnt.countrycd = tcu.countrycd) user_countrycd,
         tcu.postalcode user_postalcode,tcu.phone1 user_phone1,tcu.phone1ext user_phone1ext,tcu.fax user_fax,tcu.email user_email,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tf.facilityfordept 
             ELSE tf.facilityid     
         END facilityid,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tpf.facilityname 
             ELSE tf.facilityname     
         END facilityname,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tpf.irfacilityid 
             ELSE tf.irfacilityid     
         END irfacilityid,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tpf.masterfacilitytypecode 
             ELSE tf.masterfacilitytypecode     
         END masterfacilitytypecode,
         tf.isdepartment,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tf.facilityid 
             ELSE NULL     
         END departmentid,
         tf.departmentname,
         tf.departmenttypeid,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tf.irfacilityid 
             ELSE NULL    
         END irdepartmentid,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.contactid  
             ELSE tcf.contactid     
         END fac_contactid,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.contacttype  
             ELSE tcf.contacttype     
         END fac_contacttype,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.addresstype  
             ELSE tcf.addresstype     
         END fac_addresstype,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.address1  
             ELSE tcf.address1     
         END fac_address1,
         CASE 
              WHEN tf.isdepartment = 'Y' THEN
                   tcd.address2  
              ELSE tcf.address2     
         END fac_address2,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.address3  
             ELSE tcf.address3     
         END fac_address3,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.city  
             ELSE tcf.city     
         END fac_city,
         CASE 
            WHEN tf.isdepartment = 'Y' THEN
                 (SELECT tst.statename
                  FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                  WHERE tst.countryid = tcnt.countryid
                  AND tcnt.countrycd = tcd.countrycd
                  AND tst.statecd = tcd.state)  
            ELSE (SELECT tst.statename
                  FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                  WHERE tst.countryid = tcnt.countryid
                  AND tcnt.countrycd = tcf.countrycd
                  AND tst.statecd = tcf.state)     
         END fac_statename,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.state  
             ELSE tcf.state     
         END fac_statecd,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                 (SELECT tcnt.countryname 
                  FROM TBL_COUNTRIES tcnt
                  WHERE tcnt.countrycd = tcd.countrycd)  
             ELSE (SELECT tcnt.countryname 
                  FROM TBL_COUNTRIES tcnt
                  WHERE tcnt.countrycd = tcf.countrycd)     
         END fac_countryname,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.countrycd  
             ELSE tcf.countrycd     
         END fac_countrycd,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.postalcode  
             ELSE tcf.postalcode     
         END fac_postalcode,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.phone1  
             ELSE tcf.phone1     
         END fac_phone1,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.phone1ext  
             ELSE tcf.phone1ext     
         END fac_phone1ext,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.fax  
             ELSE tcf.fax     
         END fac_fax,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.email  
             ELSE tcf.email     
         END fac_email,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.contactid  
             ELSE NULL     
         END dept_contactid,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.contacttype  
             ELSE NULL     
         END dept_contacttype,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.addresstype  
             ELSE NULL     
         END dept_addresstype,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.address1  
             ELSE NULL     
         END dept_address1,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.address2  
             ELSE NULL     
         END dept_address2,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.address3  
             ELSE NULL     
         END dept_address3,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.city  
             ELSE NULL     
         END dept_city,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  (SELECT tst.statename
                   FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                   WHERE tst.countryid = tcnt.countryid
                   AND tcnt.countrycd = tcf.countrycd
                   AND tst.statecd = tcf.state)  
             ELSE NULL     
         END dept_statename,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.state  
             ELSE NULL     
         END dept_statecd,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  (SELECT tcnt.countryname 
                   FROM TBL_COUNTRIES tcnt
                   WHERE tcnt.countrycd = tcf.countrycd)  
             ELSE NULL     
         END dept_countryname,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.countrycd  
             ELSE NULL     
         END dept_countrycd,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.postalcode  
             ELSE NULL     
         END dept_postalcode,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.phone1  
             ELSE NULL     
         END dept_phone1,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.phone1ext  
             ELSE NULL     
         END dept_phone1ext,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.fax  
             ELSE NULL     
         END dept_fax,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.email  
             ELSE NULL     
         END dept_email,
         tor.orgid,tor.orgcd orgcode,tdcs.docexsystemid,tdcs.docexsystemname,
         tc.compoundid,tc.compoundname,tc.membercompoundcd,
         tcdm.docexsystemcompid docex_compoundid,tcdm.veeva_compoundgroupforpi,tcdm.veeva_compoundgroupfornonpi,
         ip_operation,gv_createdby,v_createddt,NULL,NULL
  FROM TBL_USERROLEMAP turm,
       TBL_ROLES tr,
       TBL_STUDY tsd,
       TBL_PROGRAM tp,
       TBL_ORGANIZATION tor,
       TBL_COMPOUND tc, 
       TBL_COMPOUNDDOCEXMAP tcdm,
       TBL_SITE ts,
       TBL_USERPROFILES tu,
       TBL_CONTACT tcu,
       TBL_FACILITIES tf,  
       TBL_CONTACT tcf,
       TBL_FACILITIES tpf, 
       TBL_CONTACT tcd,
       TBL_STUDYDOCEXMAP tsdm,
       TBL_DOCEXSYSTEM tdcs
  WHERE turm.roleid = tr.roleid 
  AND turm.studyid = tsd.studyid
  AND tsd.progid = tp.progid
  AND tp.orgid = tor.orgid
  AND EXISTS (SELECT 1 FROM TBL_ORGDOCEXMAP todm WHERE todm.orgid = tp.orgid)
  AND tsd.compoundid = tc.compoundid
  AND tsd.compoundid = tcdm.compoundid(+)
  AND turm.siteid = ts.siteid(+)
  AND turm.userid = tu.userid
  AND tu.contactid = tcu.contactid(+)
  AND ts.principalfacilityid = tf.facilityid(+)
  AND tf.contactid = tcf.contactid(+)
  AND tf.facilityfordept = tpf.facilityid(+)
  AND tpf.contactid = tcd.contactid(+)
  AND tsd.studyid = tsdm.studyid(+)
  AND tsdm.docexsystemid = tdcs.docexsystemid(+)
  AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay
  AND turm.userroleid = ip_userroleid;
    
  OPEN op_useraccess FOR
       SELECT * 
       FROM TBL_INTEGRATION
       WHERE integrationid = v_integrationid;
  
END SP_SET_USERACCESS_INT;

PROCEDURE SP_SET_STAFFROLE_INT
(
ip_userroleid       IN TBL_USERROLEMAP.userroleid%TYPE,
ip_operation        IN TBL_INTEGRATION.operation%TYPE,
op_staffrole        OUT SYS_REFCURSOR
)
IS
v_integrationid         TBL_INTEGRATION.integrationid%TYPE;
v_createddt             DATE:= SYSDATE;
v_siteusercv_operation  TBL_INTEGRATION.operation%TYPE := 'user-cv-to-site';
BEGIN
  --Staff Role Integration
  SELECT seq_integration.NEXTVAL INTO v_integrationid FROM DUAL;
  
  INSERT INTO TBL_INTEGRATION
        (integrationid,roleid,rolename,description,effectivestartdate,effectiveenddate,rolechangereason,
         studyid,studyname,docexstudyid,siteid,sitename,docexsiteid,study_countrycd,study_countryname,docexstudycountryid,
         userid,transcelerateuserid,sipuserid,veeva_userid,veeva_personid,
         docexcommonvaultuserid,userroleid,docexuserroleid,prefix,title,firstname,middlename,lastname,suffix,initials,isactive,
         timezoneid,user_contactid,user_contacttype,user_addresstype,user_address1,user_address2,
         user_address3,user_city,user_statename,user_statecd,user_countryname,user_countrycd,
         user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,facilityid,facilityname,
         irfacilityid,masterfacilitytypecode,isdepartment,departmentid,departmentname,departmenttypeid,
         irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,fac_address1,fac_address2,
         fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,fac_countrycd,fac_postalcode,
         fac_phone1,fac_phone1ext,fac_fax,fac_email,dept_contactid,dept_contacttype,dept_addresstype,
         dept_address1,dept_address2,dept_address3,dept_city,dept_statename,dept_statecd,dept_countryname,
         dept_countrycd,dept_postalcode,dept_phone1,dept_phone1ext,dept_fax,dept_email,orgid,orgcode,
         docexsystemid,docexsystemname,compoundid,compoundname,membercompoundcd,docexcompoundid,
         veeva_compoundgroupforpi,veeva_compoundgroupfornonpi,operation,createdby,createddt,modifiedby,modifieddt)
  SELECT v_integrationid,tr.roleid,tr.rolename,tr.description,turm.effectivestartdate,turm.effectiveenddate,
         turm.rolechangereason,tsd.studyid,tsd.studyname,tsdm.docexstudyid,ts.siteid,ts.sitename,ts.docexsiteid,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                 (SELECT tcnt.countrycd
                  FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_COUNTRIES tcnt
                  WHERE tscm.countryid = tcnt.countryid
                  AND tscm.studyid = tsd.studyid
                  AND tcnt.countrycd = tcf.countrycd
                  AND tscm.isactive = 'Y')
             ELSE 
                 (SELECT tcnt.countrycd
                  FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_COUNTRIES tcnt
                  WHERE tscm.countryid = tcnt.countryid
                  AND tscm.studyid = tsd.studyid
                  AND tcnt.countrycd = tcd.countrycd
                  AND tscm.isactive = 'Y')
        END study_countrycd,
        CASE 
            WHEN tf.isdepartment = 'Y' THEN
               (SELECT tcnt.countryname
                FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_COUNTRIES tcnt
                WHERE tscm.countryid = tcnt.countryid
                AND tscm.studyid = tsd.studyid
                AND tcnt.countrycd = tcf.countrycd
                AND tscm.isactive = 'Y') 
            ELSE 
              (SELECT tcnt.countryname
               FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_COUNTRIES tcnt
               WHERE tscm.countryid = tcnt.countryid
               AND tscm.studyid = tsd.studyid
               AND tcnt.countrycd = tcd.countrycd
               AND tscm.isactive = 'Y')
        END study_countryname,
        CASE 
           WHEN tf.isdepartment = 'Y' THEN
               (SELECT tdscm.docexstudycountryid
                FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_DOCEXSTUDYCNTRYMSTONEMAP tdscm,TBL_COUNTRIES tcnt
                WHERE tscm.studycountryid = tdscm.studycountryid(+)
                AND tscm.countryid = tcnt.countryid
                AND tscm.studyid = tsd.studyid
                AND tcnt.countrycd = tcf.countrycd
                AND tscm.isactive = 'Y')
           ELSE 
              (SELECT tdscm.docexstudycountryid
               FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_DOCEXSTUDYCNTRYMSTONEMAP tdscm,TBL_COUNTRIES tcnt
               WHERE tscm.studycountryid = tdscm.studycountryid(+)
               AND tscm.countryid = tcnt.countryid
               AND tscm.studyid = tsd.studyid
               AND tcnt.countrycd = tcd.countrycd
               AND tscm.isactive = 'Y')
        END docexstudycountryid,
         tu.userid,tu.transcelerateuserid,tu.sipuserid,
        (SELECT tud.docexuserid
         FROM TBL_USERDOCEXMAP tud
         WHERE tud.userid = tu.userid
         AND tud.orgid = tor.orgid) veeva_userid,
        (SELECT tud.docexpersonid
         FROM TBL_USERDOCEXMAP tud
         WHERE tud.userid = tu.userid
         AND tud.orgid = tor.orgid) veeva_personid,
        (SELECT tud.docexcommonvaultuserid
         FROM TBL_USERDOCEXMAP tud
         WHERE tud.userid = tu.userid
         AND tud.orgid = tor.orgid) docexcommonvaultuserid,
         turm.userroleid,turm.docexuserroleid,tu.prefix,tu.title,tu.firstname,tu.middlename,tu.lastname,tu.suffix,tu.initials,tu.isactive,tu.timezoneid,
         tcu.contactid user_contactid,tcu.contacttype user_contacttype,tcu.addresstype user_addresstype,
         tcu.address1 user_address1,tcu.address2 user_address2,tcu.address3 user_address3,tcu.city user_city,
         (SELECT tst.statename 
          FROM TBL_STATES tst, TBL_COUNTRIES tcnt
          WHERE tst.statecd = tcu.state
          AND tst.countryid = tcnt.countryid
          AND tcnt.countrycd = tcu.countrycd) user_statename,
         (SELECT tcu.state 
          FROM TBL_STATES tst, TBL_COUNTRIES tcnt
          WHERE tst.statecd = tcu.state
          AND tst.countryid = tcnt.countryid
          AND tcnt.countrycd = tcu.countrycd) user_statecd,
         (SELECT tcnt.countryname 
          FROM TBL_COUNTRIES tcnt
          WHERE tcnt.countrycd = tcu.countrycd) user_countryname,
         (SELECT tcu.countrycd 
          FROM TBL_COUNTRIES tcnt
          WHERE tcnt.countrycd = tcu.countrycd) user_countrycd,
         tcu.postalcode user_postalcode,tcu.phone1 user_phone1,tcu.phone1ext user_phone1ext,tcu.fax user_fax,tcu.email user_email,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tf.facilityfordept 
             ELSE tf.facilityid     
         END facilityid,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tpf.facilityname 
             ELSE tf.facilityname     
         END facilityname,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tpf.irfacilityid 
             ELSE tf.irfacilityid     
         END irfacilityid,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tpf.masterfacilitytypecode 
             ELSE tf.masterfacilitytypecode     
         END masterfacilitytypecode,
         tf.isdepartment,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tf.facilityid 
             ELSE NULL     
         END departmentid,
         tf.departmentname,
         tf.departmenttypeid,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tf.irfacilityid 
             ELSE NULL    
         END irdepartmentid,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.contactid  
             ELSE tcf.contactid     
         END fac_contactid,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.contacttype  
             ELSE tcf.contacttype     
         END fac_contacttype,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.addresstype  
             ELSE tcf.addresstype     
         END fac_addresstype,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.address1  
             ELSE tcf.address1     
         END fac_address1,
         CASE 
              WHEN tf.isdepartment = 'Y' THEN
                   tcd.address2  
              ELSE tcf.address2     
         END fac_address2,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.address3  
             ELSE tcf.address3     
         END fac_address3,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.city  
             ELSE tcf.city     
         END fac_city,
         CASE 
            WHEN tf.isdepartment = 'Y' THEN
                 (SELECT tst.statename
                  FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                  WHERE tst.countryid = tcnt.countryid
                  AND tcnt.countrycd = tcd.countrycd
                  AND tst.statecd = tcd.state)  
            ELSE (SELECT tst.statename
                  FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                  WHERE tst.countryid = tcnt.countryid
                  AND tcnt.countrycd = tcf.countrycd
                  AND tst.statecd = tcf.state)     
         END fac_statename,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.state  
             ELSE tcf.state     
         END fac_statecd,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                 (SELECT tcnt.countryname 
                  FROM TBL_COUNTRIES tcnt
                  WHERE tcnt.countrycd = tcd.countrycd)  
             ELSE (SELECT tcnt.countryname 
                  FROM TBL_COUNTRIES tcnt
                  WHERE tcnt.countrycd = tcf.countrycd)     
         END fac_countryname,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.countrycd  
             ELSE tcf.countrycd     
         END fac_countrycd,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.postalcode  
             ELSE tcf.postalcode     
         END fac_postalcode,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.phone1  
             ELSE tcf.phone1     
         END fac_phone1,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.phone1ext  
             ELSE tcf.phone1ext     
         END fac_phone1ext,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.fax  
             ELSE tcf.fax     
         END fac_fax,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcd.email  
             ELSE tcf.email     
         END fac_email,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.contactid  
             ELSE NULL     
         END dept_contactid,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.contacttype  
             ELSE NULL     
         END dept_contacttype,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.addresstype  
             ELSE NULL     
         END dept_addresstype,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.address1  
             ELSE NULL     
         END dept_address1,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.address2  
             ELSE NULL     
         END dept_address2,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.address3  
             ELSE NULL     
         END dept_address3,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.city  
             ELSE NULL     
         END dept_city,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  (SELECT tst.statename
                   FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                   WHERE tst.countryid = tcnt.countryid
                   AND tcnt.countrycd = tcf.countrycd
                   AND tst.statecd = tcf.state)  
             ELSE NULL     
         END dept_statename,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.state  
             ELSE NULL     
         END dept_statecd,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  (SELECT tcnt.countryname 
                   FROM TBL_COUNTRIES tcnt
                   WHERE tcnt.countrycd = tcf.countrycd)  
             ELSE NULL     
         END dept_countryname,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.countrycd  
             ELSE NULL     
         END dept_countrycd,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.postalcode  
             ELSE NULL     
         END dept_postalcode,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.phone1  
             ELSE NULL     
         END dept_phone1,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.phone1ext  
             ELSE NULL     
         END dept_phone1ext,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.fax  
             ELSE NULL     
         END dept_fax,
         CASE 
             WHEN tf.isdepartment = 'Y' THEN
                  tcf.email  
             ELSE NULL     
         END dept_email,
         tor.orgid,tor.orgcd orgcode,tdcs.docexsystemid,tdcs.docexsystemname,
         tc.compoundid,tc.compoundname,tc.membercompoundcd,
         tcdm.docexsystemcompid docex_compoundid,tcdm.veeva_compoundgroupforpi,tcdm.veeva_compoundgroupfornonpi,
         ip_operation,gv_createdby,v_createddt,NULL,NULL
  FROM TBL_USERROLEMAP turm,
       TBL_ROLES tr,
       TBL_STUDY tsd,
       TBL_PROGRAM tp,
       TBL_ORGANIZATION tor,
       TBL_COMPOUND tc, 
       TBL_COMPOUNDDOCEXMAP tcdm,
       TBL_SITE ts,
       TBL_USERPROFILES tu,
       TBL_CONTACT tcu,
       TBL_FACILITIES tf,  
       TBL_CONTACT tcf,
       TBL_FACILITIES tpf, 
       TBL_CONTACT tcd,
       TBL_STUDYDOCEXMAP tsdm,
       TBL_DOCEXSYSTEM tdcs
  WHERE turm.roleid = tr.roleid 
  AND turm.studyid = tsd.studyid
  AND tsd.progid = tp.progid
  AND tp.orgid = tor.orgid
  AND EXISTS (SELECT 1 FROM TBL_ORGDOCEXMAP todm WHERE todm.orgid = tp.orgid)
  AND tsd.compoundid = tc.compoundid
  AND tsd.compoundid = tcdm.compoundid(+)
  AND turm.siteid = ts.siteid(+)
  AND turm.userid = tu.userid
  AND tu.contactid = tcu.contactid(+)
  AND ts.principalfacilityid = tf.facilityid(+)
  AND tf.contactid = tcf.contactid(+)
  AND tf.facilityfordept = tpf.facilityid(+)
  AND tpf.contactid = tcd.contactid(+)
  AND tsd.studyid = tsdm.studyid(+)
  AND tsdm.docexsystemid = tdcs.docexsystemid(+)
  AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay
  AND turm.userroleid = ip_userroleid;
    
  OPEN op_staffrole FOR
       SELECT *
       FROM TBL_INTEGRATION
       WHERE integrationid = v_integrationid;
  
  --user-cv-to-site
  INSERT INTO TBL_INTEGRATION
            (integrationid,userid,transcelerateuserid,sipuserid,veeva_userid,veeva_personid,docexcommonvaultuserid,documentid,url,
             firstname,middlename,lastname,docexsystemid,docexsystemname,orgid,orgcode,
             studyid,studyname,docexstudyid,siteid,sitename,docexsiteid,roleid,rolename,userroleid,docexuserroleid,
             operation,createdby,createddt,modifiedby,modifieddt)
          SELECT seq_integration.NEXTVAL,tu.userid,tu.transcelerateuserid,tu.sipuserid,
                (SELECT tud.docexuserid
                 FROM TBL_USERDOCEXMAP tud
                 WHERE tud.userid = tu.userid
                 AND tud.orgid = tor.orgid) veeva_userid,
                (SELECT tud.docexpersonid
                 FROM TBL_USERDOCEXMAP tud
                 WHERE tud.userid = tu.userid
                 AND tud.orgid = tor.orgid) veeva_personid,
                (SELECT tud.docexcommonvaultuserid
                 FROM TBL_USERDOCEXMAP tud
                 WHERE tud.userid = tu.userid
                 AND tud.orgid = tor.orgid) docexcommonvaultuserid,
                 td.documentid,td.url,
                 tu.firstname,tu.middlename,tu.lastname,tdcs.docexsystemid,tdcs.docexsystemname,tor.orgid,tor.orgcd orgcode,
                 ts.studyid,ts.studyname,tsdm.docexstudyid,tsi.siteid,tsi.sitename,tsi.docexsiteid,
                 tr.roleid,tr.rolename,turm.userroleid,turm.docexuserroleid,
                 v_siteusercv_operation operation,gv_createdby,v_createddt,NULL,NULL
          FROM TBL_DOCUMENTS td, 
               TBL_USERPROFILES tu, 
               TBL_USERROLEMAP turm,
               TBL_STUDY ts,
               TBL_STUDYDOCEXMAP tsdm,
               TBL_SITE tsi,
               TBL_PROGRAM tp, 
               TBL_ORGANIZATION tor,
               TBL_DOCEXSYSTEM tdcs,
               TBL_ROLES tr
          WHERE td.docuserid = tu.userid
          AND tu.userid = turm.userid
          AND (turm.effectiveenddate IS NULL OR TRUNC(turm.effectiveenddate) >= TRUNC(v_createddt))
          AND turm.studyid = ts.studyid
          AND ts.studyid = tsdm.studyid(+)
          AND turm.siteid = tsi.siteid
          AND ts.isactive = 'Y'
          AND tsi.isactive = 'Y'
          AND ts.progid = tp.progid
          AND tp.orgid = tor.orgid
          AND tsdm.docexsystemid = tdcs.docexsystemid
          AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay
          AND turm.roleid = tr.roleid
          AND td.islatest = 'Y'
          AND td.isdeleted = 'N'
          AND turm.userroleid = ip_userroleid;
  
END SP_SET_STAFFROLE_INT;

PROCEDURE SP_SET_SITEUSER_INT
(
ip_userid       IN TBL_USERPROFILES.userid%TYPE,
ip_operation    IN TBL_INTEGRATION.operation%TYPE,
op_siteuser     OUT SYS_REFCURSOR
)
IS
v_integrationidlist     NUM_ARRAY := NUM_ARRAY();
v_createddt             DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT DISTINCT tu.userid,tu.transcelerateuserid,tu.sipuserid,tu.prefix,tu.title,tu.firstname,tu.middlename,
             tu.lastname,tu.suffix,tu.initials,tu.isactive,tu.timezoneid,tcu.contactid user_contactid,
             tcu.contacttype user_contacttype,tcu.addresstype user_addresstype,tcu.address1 user_address1,
             tcu.address2 user_address2,tcu.address3 user_address3,tcu.city user_city,
             (SELECT tst.statename 
              FROM TBL_STATES tst, TBL_COUNTRIES tcnt
              WHERE tst.statecd = tcu.state
              AND tst.countryid = tcnt.countryid
              AND tcnt.countrycd = tcu.countrycd) user_statename,
             (SELECT tcu.state 
              FROM TBL_STATES tst, TBL_COUNTRIES tcnt
              WHERE tst.statecd = tcu.state
              AND tst.countryid = tcnt.countryid
              AND tcnt.countrycd = tcu.countrycd) user_statecd,
             (SELECT tcnt.countryname 
              FROM TBL_COUNTRIES tcnt
              WHERE tcnt.countrycd = tcu.countrycd) user_countryname,
             (SELECT tcu.countrycd 
              FROM TBL_COUNTRIES tcnt
              WHERE tcnt.countrycd = tcu.countrycd) user_countrycd,
             tcu.postalcode user_postalcode,
             tcu.phone1 user_phone1,tcu.phone1ext user_phone1ext,tcu.fax user_fax,tcu.email user_email,
             tor.orgid,tor.orgcd orgcode,tdcs.docexsystemid,tdcs.docexsystemname
      FROM TBL_USERPROFILES tu,
           TBL_CONTACT tcu,
           TBL_USERROLEMAP turm,
           TBL_STUDY ts,
           TBL_PROGRAM tp,
           TBL_ORGANIZATION tor,
           TBL_ORGDOCEXMAP todm,
           TBL_DOCEXSYSTEM tdcs
      WHERE tu.contactid = tcu.contactid(+)
      AND tu.userid = turm.userid
      AND (turm.effectiveenddate IS NULL OR TRUNC(turm.effectiveenddate) >= TRUNC(v_createddt))
      AND turm.studyid = ts.studyid
      AND ts.progid = tp.progid
      AND tp.orgid = tor.orgid
      AND tor.orgid = todm.orgid(+)
      AND todm.docexsystemid = tdcs.docexsystemid(+)
      AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay
      AND tu.userid = ip_userid;
            
TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

BEGIN
  --Site User Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;
      
      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEGRATION
                (integrationid,userid,transcelerateuserid,sipuserid,prefix,title,firstname,middlename,lastname,
                 suffix,initials,isactive,timezoneid,user_contactid,user_contacttype,user_addresstype,
                 user_address1,user_address2,user_address3,user_city,user_statename,user_statecd,user_countryname,
                 user_countrycd,user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,orgid,orgcode,
                 docexsystemid,docexsystemname,operation,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integration.NEXTVAL,v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).sipuserid,v_cur_rec(i).prefix,v_cur_rec(i).title,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,
                 v_cur_rec(i).suffix,v_cur_rec(i).initials,v_cur_rec(i).isactive,v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,
                 v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,v_cur_rec(i).user_address3,v_cur_rec(i).user_city,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,
                 v_cur_rec(i).user_countrycd,v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,v_cur_rec(i).user_email,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,
                 v_cur_rec(i).docexsystemid,v_cur_rec(i).docexsystemname,ip_operation,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integrationid BULK COLLECT INTO v_integrationidlist;
         
  END LOOP;
  CLOSE cur_rec;

  OPEN op_siteuser FOR
       SELECT * 
       FROM TBL_INTEGRATION
       WHERE integrationid IN (SELECT * FROM TABLE(v_integrationidlist));
       
END SP_SET_SITEUSER_INT;

PROCEDURE SP_SET_CLOSESTUDY_INT
(
ip_studyid        IN TBL_STUDY.studyid%TYPE,
ip_operation      IN TBL_INTEGRATION.operation%TYPE, 
op_closestudy     OUT SYS_REFCURSOR
)
IS
v_integrationid     TBL_INTEGRATION.integrationid%TYPE;
v_createddt           DATE:= SYSDATE;
BEGIN

  --Study Integration
  SELECT seq_integration.NEXTVAL INTO v_integrationid FROM DUAL;
  
  INSERT INTO TBL_INTEGRATION
        (integrationid,studyid,studyname,docexstudyid,orgid,orgcode,
         docexsystemid,docexsystemname,operation,createdby,createddt,modifiedby,modifieddt)
  SELECT v_integrationid,ts.studyid,ts.studyname,tsdm.docexstudyid,
         tor.orgid,tor.orgcd orgcode,tdcs.docexsystemid,tdcs.docexsystemname,
         ip_operation,gv_createdby,v_createddt,NULL,NULL
  FROM TBL_STUDY ts, 
       TBL_PROGRAM tp, 
       TBL_ORGANIZATION tor,
       TBL_STUDYDOCEXMAP tsdm,
       TBL_DOCEXSYSTEM tdcs
  WHERE ts.progid = tp.progid
  AND tp.orgid = tor.orgid
  AND ts.studyid = tsdm.studyid(+)
  AND tsdm.docexsystemid = tdcs.docexsystemid(+)
  AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay
  AND ts.studyid = ip_studyid;
  
  OPEN op_closestudy FOR
       SELECT *
       FROM TBL_INTEGRATION
       WHERE integrationid = v_integrationid;

END SP_SET_CLOSESTUDY_INT;

PROCEDURE SP_SET_CLOSESITE_INT
(
ip_siteid     IN TBL_SITE.siteid%TYPE,
ip_operation  IN TBL_INTEGRATION.operation%TYPE,
op_closesite  OUT SYS_REFCURSOR
)
IS
v_integrationid     TBL_INTEGRATION.integrationid%TYPE;
v_createddt           DATE:= SYSDATE;
BEGIN

  --Study Integration
  SELECT seq_integration.NEXTVAL INTO v_integrationid FROM DUAL;
  
  INSERT INTO TBL_INTEGRATION
        (integrationid,studyid,studyname,docexstudyid,siteid,sitename,docexsiteid,orgid,orgcode,
         docexsystemid,docexsystemname,operation,createdby,createddt,modifiedby,modifieddt)
  SELECT v_integrationid,tsd.studyid,tsd.studyname,tsdm.docexstudyid,ts.siteid,ts.sitename,ts.docexsiteid,
         tor.orgid,tor.orgcd orgcode,tdcs.docexsystemid,tdcs.docexsystemname,
         ip_operation,gv_createdby,v_createddt,NULL,NULL
  FROM TBL_STUDY tsd, 
       TBL_SITE ts, 
       TBL_PROGRAM tp, 
       TBL_ORGANIZATION tor,
       TBL_STUDYDOCEXMAP tsdm,
       TBL_DOCEXSYSTEM tdcs
  WHERE tsd.studyid = ts.studyid
  AND tsd.progid = tp.progid
  AND tp.orgid = tor.orgid
  AND ts.studyid = tsdm.studyid(+)
  AND tsdm.docexsystemid = tdcs.docexsystemid(+)
  AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay
  AND ts.siteid = ip_siteid;
  
  OPEN op_closesite FOR
       SELECT * 
       FROM TBL_INTEGRATION
       WHERE integrationid = v_integrationid;

END SP_SET_CLOSESITE_INT;

PROCEDURE SP_SET_UPDATESITEREF_INT
(
ip_siteid         IN TBL_SITE.siteid%TYPE,
ip_operation      IN TBL_INTEGRATION.operation%TYPE,
op_updatesiteref  OUT SYS_REFCURSOR
)
IS
v_integrationid     TBL_INTEGRATION.integrationid%TYPE;
v_createddt           DATE:= SYSDATE;
BEGIN

  --Update Site Reference Integration
  SP_SET_SITE_INT(ip_siteid,ip_operation,op_updatesiteref);

END SP_SET_UPDATESITEREF_INT;

PROCEDURE SP_SET_USERDOC_INT
(
ip_documentid     IN TBL_DOCUMENTS.documentid%TYPE,
ip_operation      IN TBL_INTEGRATION.operation%TYPE,
op_userdoc        OUT SYS_REFCURSOR
)
IS
v_integrationidlist     NUM_ARRAY := NUM_ARRAY();
v_createddt             DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT DISTINCT tu.userid,tu.transcelerateuserid,tu.sipuserid,
            (SELECT tud.docexuserid
             FROM TBL_USERDOCEXMAP tud
             WHERE tud.userid = tu.userid
             AND tud.orgid = tor.orgid) veeva_userid,
            (SELECT tud.docexpersonid
             FROM TBL_USERDOCEXMAP tud
             WHERE tud.userid = tu.userid
             AND tud.orgid = tor.orgid) veeva_personid,
            (SELECT tud.docexcommonvaultuserid
             FROM TBL_USERDOCEXMAP tud
             WHERE tud.userid = tu.userid
             AND tud.orgid = tor.orgid) docexcommonvaultuserid,
             td.documentid,td.url,tor.orgid,tor.orgcd orgcode,tdcs.docexsystemid,tdcs.docexsystemname
          FROM TBL_DOCUMENTS td, 
               TBL_USERPROFILES tu, 
               TBL_USERROLEMAP turm,
               TBL_STUDY ts,
               TBL_STUDYDOCEXMAP tsdm,
               TBL_SITE tsi,
               TBL_PROGRAM tp, 
               TBL_ORGANIZATION tor,
               TBL_ORGDOCEXMAP todm,
               TBL_DOCEXSYSTEM tdcs
          WHERE td.docuserid = tu.userid
          AND tu.userid = turm.userid
          AND (turm.effectiveenddate IS NULL OR TRUNC(turm.effectiveenddate) >= TRUNC(v_createddt))
          AND turm.studyid = ts.studyid
          AND ts.studyid = tsdm.studyid(+)
          AND turm.siteid = tsi.siteid
          AND ts.isactive = 'Y'
          AND tsi.isactive = 'Y'
          AND ts.progid = tp.progid
          AND tp.orgid = tor.orgid
          AND tor.orgid = todm.orgid(+)
          AND todm.docexsystemid = tdcs.docexsystemid(+)
          AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay
          AND td.islatest = 'Y'
          AND td.documentid = ip_documentid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

BEGIN
  --Document(CV) Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEGRATION
                (integrationid,userid,transcelerateuserid,sipuserid,veeva_userid,veeva_personid,docexcommonvaultuserid,documentid,url,
                 orgid,orgcode,docexsystemid,docexsystemname,operation,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integration.NEXTVAL,v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).sipuserid,v_cur_rec(i).veeva_userid,v_cur_rec(i).veeva_personid,v_cur_rec(i).docexcommonvaultuserid,v_cur_rec(i).documentid,v_cur_rec(i).url,
                 v_cur_rec(i).orgid,v_cur_rec(i).orgcode,v_cur_rec(i).docexsystemid,v_cur_rec(i).docexsystemname,ip_operation,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integrationid BULK COLLECT INTO v_integrationidlist;

  END LOOP;
  CLOSE cur_rec;
 
  OPEN op_userdoc FOR
       SELECT *
       FROM TBL_INTEGRATION
       WHERE integrationid IN (SELECT * FROM TABLE(v_integrationidlist));
       
END SP_SET_USERDOC_INT;

--Procedure for Study Country Integration
PROCEDURE SP_SET_STUDYCOUNTRY_INT
(
ip_studycountryid IN TBL_STUDYCOUNTRYMILESTONE.studycountryid%TYPE,
ip_operation      IN TBL_INTEGRATION.operation%TYPE,
op_studycountry   OUT SYS_REFCURSOR
)
IS
v_integrationid     TBL_INTEGRATION.integrationid%TYPE;
v_createddt           DATE:= SYSDATE;
BEGIN
  --Study Country Integration
  SELECT seq_integration.NEXTVAL INTO v_integrationid FROM DUAL;
  
  INSERT INTO TBL_INTEGRATION
        (integrationid,studyid,studyname,docexstudyid,studycountryid,study_countrycd,study_countryname,docexstudycountryid,
         orgid,orgcode,docexsystemid,docexsystemname,operation,createdby,createddt,modifiedby,modifieddt)
  SELECT v_integrationid,ts.studyid,ts.studyname,tsdm.docexstudyid,tscm.studycountryid,tc.countrycd,tc.countryname,tdscm.docexstudycountryid,
         tor.orgid,tor.orgcd orgcode,tdcs.docexsystemid,tdcs.docexsystemname,
         ip_operation,gv_createdby,v_createddt,NULL,NULL
  FROM TBL_STUDY ts, 
       TBL_STUDYCOUNTRYMILESTONE tscm,
       TBL_DOCEXSTUDYCNTRYMSTONEMAP tdscm,
       TBL_COUNTRIES tc,
       TBL_PROGRAM tp, 
       TBL_ORGANIZATION tor,
       TBL_STUDYDOCEXMAP tsdm,
       TBL_DOCEXSYSTEM tdcs
  WHERE ts.studyid = tscm.studyid
  AND tscm.studycountryid = tdscm.studycountryid(+)
  AND tscm.countryid = tc.countryid
  AND ts.progid = tp.progid
  AND tp.orgid = tor.orgid
  AND ts.studyid = tsdm.studyid(+)
  AND tsdm.docexsystemid = tdcs.docexsystemid(+)
  AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay
  AND tscm.studycountryid = ip_studycountryid;
  
  OPEN op_studycountry FOR
       SELECT *
       FROM TBL_INTEGRATION
       WHERE integrationid = v_integrationid;
END SP_SET_STUDYCOUNTRY_INT;

PROCEDURE SP_SET_SPONSOR_USERACCESS_INT
(
ip_userroleid       IN TBL_USERROLEMAP.userroleid%TYPE,
ip_operation        IN TBL_INTEGRATION.operation%TYPE,
op_useraccess       OUT SYS_REFCURSOR
)
IS
v_integrationidlist     NUM_ARRAY := NUM_ARRAY();
v_createddt             DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT tr.roleid,tr.rolename,tr.description,turm.effectivestartdate,turm.effectiveenddate,
              turm.rolechangereason,tsd.studyid,tsd.studyname,tsdm.docexstudyid,ts.siteid,ts.sitename,ts.docexsiteid,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                     (SELECT tcnt.countrycd
                      FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_COUNTRIES tcnt
                      WHERE tscm.countryid = tcnt.countryid
                      AND tscm.studyid = tsd.studyid
                      AND tcnt.countrycd = tcf.countrycd
                      AND tscm.isactive = 'Y')
                 ELSE 
                     (SELECT tcnt.countrycd
                      FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_COUNTRIES tcnt
                      WHERE tscm.countryid = tcnt.countryid
                      AND tscm.studyid = tsd.studyid
                      AND tcnt.countrycd = tcd.countrycd
                      AND tscm.isactive = 'Y')
            END study_countrycd,
            CASE 
                WHEN tf.isdepartment = 'Y' THEN
                   (SELECT tcnt.countryname
                    FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_COUNTRIES tcnt
                    WHERE tscm.countryid = tcnt.countryid
                    AND tscm.studyid = tsd.studyid
                    AND tcnt.countrycd = tcf.countrycd
                    AND tscm.isactive = 'Y') 
                ELSE 
                  (SELECT tcnt.countryname
                   FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_COUNTRIES tcnt
                   WHERE tscm.countryid = tcnt.countryid
                   AND tscm.studyid = tsd.studyid
                   AND tcnt.countrycd = tcd.countrycd
                   AND tscm.isactive = 'Y')
            END study_countryname,
            CASE 
               WHEN tf.isdepartment = 'Y' THEN
                   (SELECT tdscm.docexstudycountryid
                    FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_DOCEXSTUDYCNTRYMSTONEMAP tdscm,TBL_COUNTRIES tcnt
                    WHERE tscm.studycountryid = tdscm.studycountryid(+)
                    AND tscm.countryid = tcnt.countryid
                    AND tscm.studyid = tsd.studyid
                    AND tcnt.countrycd = tcf.countrycd
                    AND tscm.isactive = 'Y')
               ELSE 
                  (SELECT tdscm.docexstudycountryid
                   FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_DOCEXSTUDYCNTRYMSTONEMAP tdscm,TBL_COUNTRIES tcnt
                   WHERE tscm.studycountryid = tdscm.studycountryid(+)
                   AND tscm.countryid = tcnt.countryid
                   AND tscm.studyid = tsd.studyid
                   AND tcnt.countrycd = tcd.countrycd
                   AND tscm.isactive = 'Y')
            END docexstudycountryid,
           tu.userid,tu.transcelerateuserid,tu.sipuserid,
          (SELECT tud.docexuserid
           FROM TBL_USERDOCEXMAP tud
           WHERE tud.userid = tu.userid
           AND tud.orgid = tor.orgid) veeva_userid,
          (SELECT tud.docexpersonid
           FROM TBL_USERDOCEXMAP tud
           WHERE tud.userid = tu.userid
           AND tud.orgid = tor.orgid) veeva_personid,
          (SELECT tud.docexcommonvaultuserid
           FROM TBL_USERDOCEXMAP tud
           WHERE tud.userid = tu.userid
           AND tud.orgid = tor.orgid) docexcommonvaultuserid,
           turm.userroleid,turm.docexuserroleid,tu.prefix,tu.title,tu.firstname,tu.middlename,tu.lastname,tu.suffix,tu.initials,tu.isactive,tu.timezoneid,
           tcu.contactid user_contactid,tcu.contacttype user_contacttype,tcu.addresstype user_addresstype,
           tcu.address1 user_address1,tcu.address2 user_address2,tcu.address3 user_address3,tcu.city user_city,
           (SELECT tst.statename 
            FROM TBL_STATES tst, TBL_COUNTRIES tcnt
            WHERE tst.statecd = tcu.state
            AND tst.countryid = tcnt.countryid
            AND tcnt.countrycd = tcu.countrycd) user_statename,
           (SELECT tcu.state 
            FROM TBL_STATES tst, TBL_COUNTRIES tcnt
            WHERE tst.statecd = tcu.state
            AND tst.countryid = tcnt.countryid
            AND tcnt.countrycd = tcu.countrycd) user_statecd,
           (SELECT tcnt.countryname 
            FROM TBL_COUNTRIES tcnt
            WHERE tcnt.countrycd = tcu.countrycd) user_countryname,
           (SELECT tcu.countrycd 
            FROM TBL_COUNTRIES tcnt
            WHERE tcnt.countrycd = tcu.countrycd) user_countrycd,
           tcu.postalcode user_postalcode,tcu.phone1 user_phone1,tcu.phone1ext user_phone1ext,tcu.fax user_fax,tcu.email user_email,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tf.facilityfordept 
                 ELSE tf.facilityid     
             END facilityid,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tpf.facilityname 
                 ELSE tf.facilityname     
             END facilityname,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tpf.irfacilityid 
                 ELSE tf.irfacilityid     
             END irfacilityid,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tpf.masterfacilitytypecode 
                 ELSE tf.masterfacilitytypecode     
             END masterfacilitytypecode,
             tf.isdepartment,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tf.facilityid 
                 ELSE NULL     
             END departmentid,
             tf.departmentname,
             tf.departmenttypeid,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tf.irfacilityid 
                 ELSE NULL    
             END irdepartmentid,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcd.contactid  
                 ELSE tcf.contactid     
             END fac_contactid,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcd.contacttype  
                 ELSE tcf.contacttype     
             END fac_contacttype,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcd.addresstype  
                 ELSE tcf.addresstype     
             END fac_addresstype,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcd.address1  
                 ELSE tcf.address1     
             END fac_address1,
             CASE 
                  WHEN tf.isdepartment = 'Y' THEN
                       tcd.address2  
                  ELSE tcf.address2     
             END fac_address2,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcd.address3  
                 ELSE tcf.address3     
             END fac_address3,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcd.city  
                 ELSE tcf.city     
             END fac_city,
             CASE 
                WHEN tf.isdepartment = 'Y' THEN
                     (SELECT tst.statename
                      FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                      WHERE tst.countryid = tcnt.countryid
                      AND tcnt.countrycd = tcd.countrycd
                      AND tst.statecd = tcd.state)  
                ELSE (SELECT tst.statename
                      FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                      WHERE tst.countryid = tcnt.countryid
                      AND tcnt.countrycd = tcf.countrycd
                      AND tst.statecd = tcf.state)     
             END fac_statename,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcd.state  
                 ELSE tcf.state     
             END fac_statecd,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                     (SELECT tcnt.countryname 
                      FROM TBL_COUNTRIES tcnt
                      WHERE tcnt.countrycd = tcd.countrycd)  
                 ELSE (SELECT tcnt.countryname 
                      FROM TBL_COUNTRIES tcnt
                      WHERE tcnt.countrycd = tcf.countrycd)     
             END fac_countryname,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcd.countrycd  
                 ELSE tcf.countrycd     
             END fac_countrycd,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcd.postalcode  
                 ELSE tcf.postalcode     
             END fac_postalcode,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcd.phone1  
                 ELSE tcf.phone1     
             END fac_phone1,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcd.phone1ext  
                 ELSE tcf.phone1ext     
             END fac_phone1ext,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcd.fax  
                 ELSE tcf.fax     
             END fac_fax,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcd.email  
                 ELSE tcf.email     
             END fac_email,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcf.contactid  
                 ELSE NULL     
             END dept_contactid,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcf.contacttype  
                 ELSE NULL     
             END dept_contacttype,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcf.addresstype  
                 ELSE NULL     
             END dept_addresstype,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcf.address1  
                 ELSE NULL     
             END dept_address1,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcf.address2  
                 ELSE NULL     
             END dept_address2,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcf.address3  
                 ELSE NULL     
             END dept_address3,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcf.city  
                 ELSE NULL     
             END dept_city,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      (SELECT tst.statename
                       FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                       WHERE tst.countryid = tcnt.countryid
                       AND tcnt.countrycd = tcf.countrycd
                       AND tst.statecd = tcf.state)  
                 ELSE NULL     
             END dept_statename,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcf.state  
                 ELSE NULL     
             END dept_statecd,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      (SELECT tcnt.countryname 
                       FROM TBL_COUNTRIES tcnt
                       WHERE tcnt.countrycd = tcf.countrycd)  
                 ELSE NULL     
             END dept_countryname,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcf.countrycd  
                 ELSE NULL     
             END dept_countrycd,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcf.postalcode  
                 ELSE NULL     
             END dept_postalcode,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcf.phone1  
                 ELSE NULL     
             END dept_phone1,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcf.phone1ext  
                 ELSE NULL     
             END dept_phone1ext,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcf.fax  
                 ELSE NULL     
             END dept_fax,
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tcf.email  
                 ELSE NULL     
             END dept_email,               
           tor.orgid,tor.orgcd orgcode,tdcs.docexsystemid,tdcs.docexsystemname,
           tc.compoundid,tc.compoundname,tc.membercompoundcd,
           tcdm.docexsystemcompid docexcompoundid,tcdm.veeva_compoundgroupforpi,tcdm.veeva_compoundgroupfornonpi
    FROM TBL_USERROLEMAP turm,
         TBL_ROLES tr,
         TBL_STUDY tsd,
         TBL_STUDYDOCEXMAP tsdm,
         TBL_ORGANIZATION tor,
         TBL_COMPOUND tc, 
         TBL_COMPOUNDDOCEXMAP tcdm,
         TBL_SITE ts,
         TBL_USERPROFILES tu,
         TBL_CONTACT tcu,
         TBL_FACILITIES tf,  
         TBL_CONTACT tcf,
         TBL_FACILITIES tpf, 
         TBL_CONTACT tcd,
         TBL_ORGDOCEXMAP todm,
         TBL_DOCEXSYSTEM tdcs
    WHERE turm.roleid = tr.roleid 
    AND turm.studyid = tsd.studyid(+)
    AND tsd.studyid = tsdm.studyid(+)
    AND tu.orgid = tor.orgid
    AND EXISTS (SELECT 1 FROM TBL_ORGDOCEXMAP todm WHERE todm.orgid = tu.orgid)
    AND tsd.compoundid = tc.compoundid(+)
    AND tsd.compoundid = tcdm.compoundid(+)
    AND turm.siteid = ts.siteid(+)
    AND turm.userid = tu.userid
    AND tu.contactid = tcu.contactid(+)
    AND ts.principalfacilityid = tf.facilityid(+)
    AND tf.contactid = tcf.contactid(+)
    AND tf.facilityfordept = tpf.facilityid(+)
    AND tpf.contactid = tcd.contactid(+)
    AND tor.orgid = todm.orgid(+)
    AND todm.docexsystemid = tdcs.docexsystemid(+)
    AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay
    AND turm.userroleid = ip_userroleid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

BEGIN
  --Sponsor User Access Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEGRATION
              (integrationid,roleid,rolename,description,effectivestartdate,effectiveenddate,rolechangereason,
               studyid,studyname,docexstudyid,siteid,sitename,docexsiteid,study_countrycd,study_countryname,docexstudycountryid,
               userid,transcelerateuserid,sipuserid,veeva_userid,veeva_personid,
               docexcommonvaultuserid,userroleid,docexuserroleid,prefix,title,firstname,middlename,lastname,suffix,initials,isactive,
               timezoneid,user_contactid,user_contacttype,user_addresstype,user_address1,user_address2,
               user_address3,user_city,user_statename,user_statecd,user_countryname,user_countrycd,
               user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,facilityid,facilityname,
               irfacilityid,masterfacilitytypecode,isdepartment,departmentid,departmentname,departmenttypeid,
               irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,fac_address1,fac_address2,
               fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,fac_countrycd,fac_postalcode,
               fac_phone1,fac_phone1ext,fac_fax,fac_email,dept_contactid,dept_contacttype,dept_addresstype,
               dept_address1,dept_address2,dept_address3,dept_city,dept_statename,dept_statecd,dept_countryname,
               dept_countrycd,dept_postalcode,dept_phone1,dept_phone1ext,dept_fax,dept_email,orgid,orgcode,
               docexsystemid,docexsystemname,compoundid,compoundname,membercompoundcd,docexcompoundid,
               veeva_compoundgroupforpi,veeva_compoundgroupfornonpi,operation,createdby,createddt,modifiedby,modifieddt)
        VALUES(seq_integration.NEXTVAL,v_cur_rec(i).roleid,v_cur_rec(i).rolename,v_cur_rec(i).description,v_cur_rec(i).effectivestartdate,v_cur_rec(i).effectiveenddate,v_cur_rec(i).rolechangereason,
               v_cur_rec(i).studyid,v_cur_rec(i).studyname,v_cur_rec(i).docexstudyid,v_cur_rec(i).siteid,v_cur_rec(i).sitename,v_cur_rec(i).docexsiteid,v_cur_rec(i).study_countrycd,v_cur_rec(i).study_countryname,v_cur_rec(i).docexstudycountryid,
               v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).sipuserid,v_cur_rec(i).veeva_userid,v_cur_rec(i).veeva_personid,
               v_cur_rec(i).docexcommonvaultuserid,v_cur_rec(i).userroleid,v_cur_rec(i).docexuserroleid,v_cur_rec(i).prefix,v_cur_rec(i).title,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,v_cur_rec(i).suffix,v_cur_rec(i).initials,v_cur_rec(i).isactive,
               v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,
               v_cur_rec(i).user_address3,v_cur_rec(i).user_city,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,v_cur_rec(i).user_countrycd,
               v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,v_cur_rec(i).user_email,v_cur_rec(i).facilityid,v_cur_rec(i).facilityname,
               v_cur_rec(i).irfacilityid,v_cur_rec(i).masterfacilitytypecode,v_cur_rec(i).isdepartment,v_cur_rec(i).departmentid,v_cur_rec(i).departmentname,v_cur_rec(i).departmenttypeid,
               v_cur_rec(i).irdepartmentid,v_cur_rec(i).fac_contactid,v_cur_rec(i).fac_contacttype,v_cur_rec(i).fac_addresstype,v_cur_rec(i).fac_address1,v_cur_rec(i).fac_address2,
               v_cur_rec(i).fac_address3,v_cur_rec(i).fac_city,v_cur_rec(i).fac_statename,v_cur_rec(i).fac_statecd,v_cur_rec(i).fac_countryname,v_cur_rec(i).fac_countrycd,v_cur_rec(i).fac_postalcode,
               v_cur_rec(i).fac_phone1,v_cur_rec(i).fac_phone1ext,v_cur_rec(i).fac_fax,v_cur_rec(i).fac_email,v_cur_rec(i).dept_contactid,v_cur_rec(i).dept_contacttype,v_cur_rec(i).dept_addresstype,
               v_cur_rec(i).dept_address1,v_cur_rec(i).dept_address2,v_cur_rec(i).dept_address3,v_cur_rec(i).dept_city,v_cur_rec(i).dept_statename,v_cur_rec(i).dept_statecd,v_cur_rec(i).dept_countryname,
               v_cur_rec(i).dept_countrycd,v_cur_rec(i).dept_postalcode,v_cur_rec(i).dept_phone1,v_cur_rec(i).dept_phone1ext,v_cur_rec(i).dept_fax,v_cur_rec(i).dept_email,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,
               v_cur_rec(i).docexsystemid,v_cur_rec(i).docexsystemname,v_cur_rec(i).compoundid,v_cur_rec(i).compoundname,v_cur_rec(i).membercompoundcd,v_cur_rec(i).docexcompoundid,
               v_cur_rec(i).veeva_compoundgroupforpi,v_cur_rec(i).veeva_compoundgroupfornonpi,ip_operation,gv_createdby,v_createddt,NULL,NULL)
        RETURNING integrationid BULK COLLECT INTO v_integrationidlist;

  END LOOP;
  CLOSE cur_rec;  
    
  OPEN op_useraccess FOR
       SELECT * 
       FROM TBL_INTEGRATION
       WHERE integrationid IN (SELECT * FROM TABLE(v_integrationidlist));
  
END SP_SET_SPONSOR_USERACCESS_INT;

PROCEDURE SP_SET_SPONSOR_INT
(
ip_transcelerateuserid IN TBL_USERPROFILES.transcelerateuserid%TYPE,
ip_operation           IN TBL_INTEGRATION.operation%TYPE,
op_sponsor             OUT SYS_REFCURSOR
)
IS
v_integrationidlist     NUM_ARRAY := NUM_ARRAY();
v_orgidlist             NUM_ARRAY := NUM_ARRAY();
v_createddt             DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT tu.userid,tu.transcelerateuserid,tu.sipuserid,tu.prefix,tu.title,tu.firstname,tu.middlename,
               tu.lastname,tu.suffix,tu.initials,tu.isactive,tu.timezoneid,tcu.contactid user_contactid,
               tcu.contacttype user_contacttype,tcu.addresstype user_addresstype,tcu.address1 user_address1,
               tcu.address2 user_address2,tcu.address3 user_address3,tcu.city user_city,
               (SELECT tst.statename 
                FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                WHERE tst.statecd = tcu.state
                AND tst.countryid = tcnt.countryid
                AND tcnt.countrycd = tcu.countrycd) user_statename,
               (SELECT tcu.state 
                FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                WHERE tst.statecd = tcu.state
                AND tst.countryid = tcnt.countryid
                AND tcnt.countrycd = tcu.countrycd) user_statecd,
               (SELECT tcnt.countryname 
                FROM TBL_COUNTRIES tcnt
                WHERE tcnt.countrycd = tcu.countrycd) user_countryname,
               (SELECT tcu.countrycd 
                FROM TBL_COUNTRIES tcnt
                WHERE tcnt.countrycd = tcu.countrycd) user_countrycd,
               tcu.postalcode user_postalcode,
               tcu.phone1 user_phone1,tcu.phone1ext user_phone1ext,tcu.fax user_fax,tcu.email user_email,
               tor.orgid,tor.orgcd orgcode,tdcs.docexsystemid,tdcs.docexsystemname
        FROM TBL_USERPROFILES tu,
             TBL_CONTACT tcu,
             TBL_ORGANIZATION tor,
             TBL_ORGDOCEXMAP todm,
             TBL_DOCEXSYSTEM tdcs
        WHERE tu.contactid = tcu.contactid(+)
        AND tu.orgid = tor.orgid
        AND tor.orgid = todm.orgid(+)
        AND todm.docexsystemid = tdcs.docexsystemid(+)
        AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay
        AND tu.transcelerateuserid = ip_transcelerateuserid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

CURSOR cur_rec1 IS
       SELECT turm.userroleid
       FROM TBL_USERROLEMAP turm, TBL_USERPROFILES tu
       WHERE turm.userid = tu.userid
       AND tu.transcelerateuserid = ip_transcelerateuserid;

TYPE typ_cur_rec1 IS TABLE OF cur_rec1%ROWTYPE;
v_cur_rec1 typ_cur_rec1;

v_useraccess          SYS_REFCURSOR;
v_operation_sponsor   TBL_INTEGRATION.operation%TYPE := 'add-sponsor-role-outbound';
BEGIN
  --Sponsor User Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEGRATION
                  (integrationid,userid,transcelerateuserid,sipuserid,prefix,title,firstname,middlename,lastname,
                   suffix,initials,isactive,timezoneid,user_contactid,user_contacttype,user_addresstype,
                   user_address1,user_address2,user_address3,user_city,user_statename,user_statecd,user_countryname,
                   user_countrycd,user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,orgid,orgcode,
                   docexsystemid,docexsystemname,operation,createdby,createddt,modifiedby,modifieddt)
            VALUES(seq_integration.NEXTVAL,v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).sipuserid,v_cur_rec(i).prefix,v_cur_rec(i).title,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,
                   v_cur_rec(i).suffix,v_cur_rec(i).initials,v_cur_rec(i).isactive,v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,
                   v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,v_cur_rec(i).user_address3,v_cur_rec(i).user_city,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,
                   v_cur_rec(i).user_countrycd,v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,v_cur_rec(i).user_email,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,
                   v_cur_rec(i).docexsystemid,v_cur_rec(i).docexsystemname,ip_operation,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integrationid BULK COLLECT INTO v_integrationidlist;

  END LOOP;
  CLOSE cur_rec;
  
  OPEN op_sponsor FOR
       SELECT * 
       FROM TBL_INTEGRATION
       WHERE integrationid IN (SELECT * FROM TABLE(v_integrationidlist));
  
  IF ip_operation <> 'update-sponsor-outbound' THEN
      OPEN cur_rec1;
      LOOP
          FETCH cur_rec1 BULK COLLECT INTO v_cur_rec1 LIMIT gv_rec_limit;
          EXIT WHEN v_cur_rec1.COUNT = 0;
    
          FOR j IN v_cur_rec1.FIRST..v_cur_rec1.LAST LOOP
              SP_SET_SPONSOR_USERACCESS_INT(v_cur_rec1(j).userroleid,v_operation_sponsor,v_useraccess);
          END LOOP;   
      END LOOP;
      CLOSE cur_rec1;     
  END IF;
  
END SP_SET_SPONSOR_INT;

PROCEDURE SP_SET_SPONSOR_DEACT_INT
(
ip_userid              IN TBL_USERPROFILES.userid%TYPE,
ip_studyid             IN TBL_STUDY.studyid%TYPE,
ip_siteid              IN TBL_SITE.siteid%TYPE,
ip_operation           IN TBL_INTEGRATION.operation%TYPE,
op_sponsor             OUT SYS_REFCURSOR
)
IS
v_integrationidlist     NUM_ARRAY := NUM_ARRAY();
v_createddt             DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT tu.userid,tu.transcelerateuserid,tu.sipuserid,tu.prefix,tu.title,tu.firstname,tu.middlename,
               tu.lastname,tu.suffix,tu.initials,tu.isactive,tu.timezoneid,tcu.contactid user_contactid,
               tcu.contacttype user_contacttype,tcu.addresstype user_addresstype,tcu.address1 user_address1,
               tcu.address2 user_address2,tcu.address3 user_address3,tcu.city user_city,
               (SELECT tst.statename 
                FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                WHERE tst.statecd = tcu.state
                AND tst.countryid = tcnt.countryid
                AND tcnt.countrycd = tcu.countrycd) user_statename,
               (SELECT tcu.state 
                FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                WHERE tst.statecd = tcu.state
                AND tst.countryid = tcnt.countryid
                AND tcnt.countrycd = tcu.countrycd) user_statecd,
               (SELECT tcnt.countryname 
                FROM TBL_COUNTRIES tcnt
                WHERE tcnt.countrycd = tcu.countrycd) user_countryname,
               (SELECT tcu.countrycd 
                FROM TBL_COUNTRIES tcnt
                WHERE tcnt.countrycd = tcu.countrycd) user_countrycd,
               tcu.postalcode user_postalcode,
               tcu.phone1 user_phone1,tcu.phone1ext user_phone1ext,tcu.fax user_fax,tcu.email user_email,
              (SELECT tud.docexuserid
               FROM TBL_USERDOCEXMAP tud
               WHERE tud.userid = tu.userid
               AND tud.orgid = tor.orgid) veeva_userid,
              (SELECT tud.docexpersonid
               FROM TBL_USERDOCEXMAP tud
               WHERE tud.userid = tu.userid
               AND tud.orgid = tor.orgid) veeva_personid,
              (SELECT tud.docexcommonvaultuserid
               FROM TBL_USERDOCEXMAP tud
               WHERE tud.userid = tu.userid
               AND tud.orgid = tor.orgid) docexcommonvaultuserid,
               tor.orgid,tor.orgcd orgcode,
               NULL studyid,
               NULL studyname,
               NULL docexstudyid,
               NULL siteid,
               NULL sitename,
               NULL docexsiteid,
               tdcs.docexsystemid,tdcs.docexsystemname
        FROM TBL_USERPROFILES tu,
             TBL_CONTACT tcu,
             TBL_ORGANIZATION tor,
             TBL_ORGDOCEXMAP todm,
             TBL_DOCEXSYSTEM tdcs
        WHERE tu.contactid = tcu.contactid(+)
        AND tu.orgid = tor.orgid
        AND tor.orgid = todm.orgid(+)
        AND todm.docexsystemid = tdcs.docexsystemid(+)
        AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay
        AND tu.userid = ip_userid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

CURSOR cur_rec1 IS
       SELECT tu.userid,tu.transcelerateuserid,tu.sipuserid,tu.prefix,tu.title,tu.firstname,tu.middlename,
               tu.lastname,tu.suffix,tu.initials,tu.isactive,tu.timezoneid,tcu.contactid user_contactid,
               tcu.contacttype user_contacttype,tcu.addresstype user_addresstype,tcu.address1 user_address1,
               tcu.address2 user_address2,tcu.address3 user_address3,tcu.city user_city,
               (SELECT tst.statename 
                FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                WHERE tst.statecd = tcu.state
                AND tst.countryid = tcnt.countryid
                AND tcnt.countrycd = tcu.countrycd) user_statename,
               (SELECT tcu.state 
                FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                WHERE tst.statecd = tcu.state
                AND tst.countryid = tcnt.countryid
                AND tcnt.countrycd = tcu.countrycd) user_statecd,
               (SELECT tcnt.countryname 
                FROM TBL_COUNTRIES tcnt
                WHERE tcnt.countrycd = tcu.countrycd) user_countryname,
               (SELECT tcu.countrycd 
                FROM TBL_COUNTRIES tcnt
                WHERE tcnt.countrycd = tcu.countrycd) user_countrycd,
               tcu.postalcode user_postalcode,
               tcu.phone1 user_phone1,tcu.phone1ext user_phone1ext,tcu.fax user_fax,tcu.email user_email,
              (SELECT tud.docexuserid
               FROM TBL_USERDOCEXMAP tud
               WHERE tud.userid = tu.userid
               AND tud.orgid = tor.orgid) veeva_userid,
              (SELECT tud.docexpersonid
               FROM TBL_USERDOCEXMAP tud
               WHERE tud.userid = tu.userid
               AND tud.orgid = tor.orgid) veeva_personid,
              (SELECT tud.docexcommonvaultuserid
               FROM TBL_USERDOCEXMAP tud
               WHERE tud.userid = tu.userid
               AND tud.orgid = tor.orgid) docexcommonvaultuserid,
               tor.orgid,tor.orgcd orgcode,
               tsd.studyid,
               tsd.studyname,
               tsdm.docexstudyid,
               NULL siteid,
               NULL sitename,
               NULL docexsiteid,
               tdcs.docexsystemid,tdcs.docexsystemname
        FROM TBL_USERPROFILES tu,
             TBL_CONTACT tcu,
             TBL_ORGANIZATION tor,
             TBL_USERROLEMAP turm,
             TBL_STUDY tsd,
             TBL_STUDYDOCEXMAP tsdm,
             TBL_DOCEXSYSTEM tdcs
        WHERE tu.contactid = tcu.contactid(+)
        AND tu.orgid = tor.orgid
        AND tu.userid = turm.userid
        AND turm.siteid IS NULL
        AND turm.studyid = tsd.studyid 
        AND tsd.studyid = tsdm.studyid(+)
        AND tsdm.docexsystemid = tdcs.docexsystemid(+)
        AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay
        AND tu.userid = ip_userid
        AND turm.studyid = ip_studyid;

TYPE typ_cur_rec1 IS TABLE OF cur_rec1%ROWTYPE;
v_cur_rec1 typ_cur_rec1;

CURSOR cur_rec2 IS
       SELECT tu.userid,tu.transcelerateuserid,tu.sipuserid,tu.prefix,tu.title,tu.firstname,tu.middlename,
               tu.lastname,tu.suffix,tu.initials,tu.isactive,tu.timezoneid,tcu.contactid user_contactid,
               tcu.contacttype user_contacttype,tcu.addresstype user_addresstype,tcu.address1 user_address1,
               tcu.address2 user_address2,tcu.address3 user_address3,tcu.city user_city,
               (SELECT tst.statename 
                FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                WHERE tst.statecd = tcu.state
                AND tst.countryid = tcnt.countryid
                AND tcnt.countrycd = tcu.countrycd) user_statename,
               (SELECT tcu.state 
                FROM TBL_STATES tst, TBL_COUNTRIES tcnt
                WHERE tst.statecd = tcu.state
                AND tst.countryid = tcnt.countryid
                AND tcnt.countrycd = tcu.countrycd) user_statecd,
               (SELECT tcnt.countryname 
                FROM TBL_COUNTRIES tcnt
                WHERE tcnt.countrycd = tcu.countrycd) user_countryname,
               (SELECT tcu.countrycd 
                FROM TBL_COUNTRIES tcnt
                WHERE tcnt.countrycd = tcu.countrycd) user_countrycd,
               tcu.postalcode user_postalcode,
               tcu.phone1 user_phone1,tcu.phone1ext user_phone1ext,tcu.fax user_fax,tcu.email user_email,
              (SELECT tud.docexuserid
               FROM TBL_USERDOCEXMAP tud
               WHERE tud.userid = tu.userid
               AND tud.orgid = tor.orgid) veeva_userid,
              (SELECT tud.docexpersonid
               FROM TBL_USERDOCEXMAP tud
               WHERE tud.userid = tu.userid
               AND tud.orgid = tor.orgid) veeva_personid,
              (SELECT tud.docexcommonvaultuserid
               FROM TBL_USERDOCEXMAP tud
               WHERE tud.userid = tu.userid
               AND tud.orgid = tor.orgid) docexcommonvaultuserid,
               tor.orgid,tor.orgcd orgcode,
               tsd.studyid,
               tsd.studyname,
               tsdm.docexstudyid,
               ts.siteid,
               ts.sitename,
               ts.docexsiteid,
               tdcs.docexsystemid,tdcs.docexsystemname
        FROM TBL_USERPROFILES tu,
             TBL_CONTACT tcu,
             TBL_ORGANIZATION tor,
             TBL_USERROLEMAP turm,
             TBL_STUDY tsd,
             TBL_SITE ts,
             TBL_STUDYDOCEXMAP tsdm,
             TBL_DOCEXSYSTEM tdcs
        WHERE tu.contactid = tcu.contactid(+)
        AND tu.orgid = tor.orgid
        AND tu.userid = turm.userid
        AND turm.siteid IS NULL
        AND turm.studyid = tsd.studyid 
        AND tsd.studyid = ts.studyid
        AND tsd.studyid = tsdm.studyid(+)
        AND tsdm.docexsystemid = tdcs.docexsystemid(+)
        AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay
        AND tu.userid = ip_userid
        AND turm.studyid = ip_studyid
        AND ts.siteid = ip_siteid;

TYPE typ_cur_rec2 IS TABLE OF cur_rec2%ROWTYPE;
v_cur_rec2 typ_cur_rec2;

BEGIN
  --Sponsor User Deactivation Integration
  
  IF ip_userid IS NOT NULL AND ip_studyid IS NULL AND ip_siteid IS NULL THEN
      OPEN cur_rec;
      LOOP
          FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
          EXIT WHEN v_cur_rec.COUNT = 0;
    
          FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
              INSERT INTO TBL_INTEGRATION
                      (integrationid,userid,transcelerateuserid,sipuserid,prefix,title,firstname,middlename,lastname,
                       suffix,initials,isactive,timezoneid,user_contactid,user_contacttype,user_addresstype,
                       user_address1,user_address2,user_address3,user_city,user_statename,user_statecd,user_countryname,
                       user_countrycd,user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,
                       veeva_userid,veeva_personid,docexcommonvaultuserid,orgid,orgcode,
                       studyid,studyname,docexstudyid,siteid,sitename,docexsiteid,
                       docexsystemid,docexsystemname,operation,createdby,createddt,modifiedby,modifieddt)
              VALUES(seq_integration.NEXTVAL,v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).sipuserid,v_cur_rec(i).prefix,v_cur_rec(i).title,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,
                       v_cur_rec(i).suffix,v_cur_rec(i).initials,v_cur_rec(i).isactive,v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,
                       v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,v_cur_rec(i).user_address3,v_cur_rec(i).user_city,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,
                       v_cur_rec(i).user_countrycd,v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,v_cur_rec(i).user_email,
                       v_cur_rec(i).veeva_userid,v_cur_rec(i).veeva_personid,v_cur_rec(i).docexcommonvaultuserid,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,
                       v_cur_rec(i).studyid,v_cur_rec(i).studyname,v_cur_rec(i).docexstudyid,v_cur_rec(i).siteid,v_cur_rec(i).sitename,v_cur_rec(i).docexsiteid,
                       v_cur_rec(i).docexsystemid,v_cur_rec(i).docexsystemname,ip_operation,gv_createdby,v_createddt,NULL,NULL)
              RETURNING integrationid BULK COLLECT INTO v_integrationidlist;
    
      END LOOP;
      CLOSE cur_rec;  
  
  ELSIF ip_userid IS NOT NULL AND ip_studyid IS NOT NULL AND ip_siteid IS NULL THEN
        
      OPEN cur_rec1;
      LOOP
          FETCH cur_rec1 BULK COLLECT INTO v_cur_rec1 LIMIT gv_rec_limit;
          EXIT WHEN v_cur_rec1.COUNT = 0;
    
          FORALL i IN v_cur_rec1.FIRST..v_cur_rec1.LAST
              INSERT INTO TBL_INTEGRATION
                      (integrationid,userid,transcelerateuserid,sipuserid,prefix,title,firstname,middlename,lastname,
                       suffix,initials,isactive,timezoneid,user_contactid,user_contacttype,user_addresstype,
                       user_address1,user_address2,user_address3,user_city,user_statename,user_statecd,user_countryname,
                       user_countrycd,user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,
                       veeva_userid,veeva_personid,docexcommonvaultuserid,orgid,orgcode,
                       studyid,studyname,docexstudyid,siteid,sitename,docexsiteid,
                       docexsystemid,docexsystemname,operation,createdby,createddt,modifiedby,modifieddt)
              VALUES(seq_integration.NEXTVAL,v_cur_rec1(i).userid,v_cur_rec1(i).transcelerateuserid,v_cur_rec1(i).sipuserid,v_cur_rec1(i).prefix,v_cur_rec1(i).title,v_cur_rec1(i).firstname,v_cur_rec1(i).middlename,v_cur_rec1(i).lastname,
                       v_cur_rec1(i).suffix,v_cur_rec1(i).initials,v_cur_rec1(i).isactive,v_cur_rec1(i).timezoneid,v_cur_rec1(i).user_contactid,v_cur_rec1(i).user_contacttype,v_cur_rec1(i).user_addresstype,
                       v_cur_rec1(i).user_address1,v_cur_rec1(i).user_address2,v_cur_rec1(i).user_address3,v_cur_rec1(i).user_city,v_cur_rec1(i).user_statename,v_cur_rec1(i).user_statecd,v_cur_rec1(i).user_countryname,
                       v_cur_rec1(i).user_countrycd,v_cur_rec1(i).user_postalcode,v_cur_rec1(i).user_phone1,v_cur_rec1(i).user_phone1ext,v_cur_rec1(i).user_fax,v_cur_rec1(i).user_email,
                       v_cur_rec1(i).veeva_userid,v_cur_rec1(i).veeva_personid,v_cur_rec1(i).docexcommonvaultuserid,v_cur_rec1(i).orgid,v_cur_rec1(i).orgcode,
                       v_cur_rec1(i).studyid,v_cur_rec1(i).studyname,v_cur_rec1(i).docexstudyid,v_cur_rec1(i).siteid,v_cur_rec1(i).sitename,v_cur_rec1(i).docexsiteid,
                       v_cur_rec1(i).docexsystemid,v_cur_rec1(i).docexsystemname,ip_operation,gv_createdby,v_createddt,NULL,NULL)
              RETURNING integrationid BULK COLLECT INTO v_integrationidlist;
    
      END LOOP;
      CLOSE cur_rec1;
            
  ELSIF ip_userid IS NOT NULL AND ip_studyid IS NOT NULL AND ip_siteid IS NOT NULL THEN
        
      OPEN cur_rec2;
      LOOP
          FETCH cur_rec2 BULK COLLECT INTO v_cur_rec2 LIMIT gv_rec_limit;
          EXIT WHEN v_cur_rec2.COUNT = 0;
    
          FORALL i IN v_cur_rec2.FIRST..v_cur_rec2.LAST
              INSERT INTO TBL_INTEGRATION
                      (integrationid,userid,transcelerateuserid,sipuserid,prefix,title,firstname,middlename,lastname,
                       suffix,initials,isactive,timezoneid,user_contactid,user_contacttype,user_addresstype,
                       user_address1,user_address2,user_address3,user_city,user_statename,user_statecd,user_countryname,
                       user_countrycd,user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,
                       veeva_userid,veeva_personid,docexcommonvaultuserid,orgid,orgcode,
                       studyid,studyname,docexstudyid,siteid,sitename,docexsiteid,
                       docexsystemid,docexsystemname,operation,createdby,createddt,modifiedby,modifieddt)
              VALUES(seq_integration.NEXTVAL,v_cur_rec2(i).userid,v_cur_rec2(i).transcelerateuserid,v_cur_rec2(i).sipuserid,v_cur_rec2(i).prefix,v_cur_rec2(i).title,v_cur_rec2(i).firstname,v_cur_rec2(i).middlename,v_cur_rec2(i).lastname,
                       v_cur_rec2(i).suffix,v_cur_rec2(i).initials,v_cur_rec2(i).isactive,v_cur_rec2(i).timezoneid,v_cur_rec2(i).user_contactid,v_cur_rec2(i).user_contacttype,v_cur_rec2(i).user_addresstype,
                       v_cur_rec2(i).user_address1,v_cur_rec2(i).user_address2,v_cur_rec2(i).user_address3,v_cur_rec2(i).user_city,v_cur_rec2(i).user_statename,v_cur_rec2(i).user_statecd,v_cur_rec2(i).user_countryname,
                       v_cur_rec2(i).user_countrycd,v_cur_rec2(i).user_postalcode,v_cur_rec2(i).user_phone1,v_cur_rec2(i).user_phone1ext,v_cur_rec2(i).user_fax,v_cur_rec2(i).user_email,
                       v_cur_rec2(i).veeva_userid,v_cur_rec2(i).veeva_personid,v_cur_rec2(i).docexcommonvaultuserid,v_cur_rec2(i).orgid,v_cur_rec2(i).orgcode,
                       v_cur_rec2(i).studyid,v_cur_rec2(i).studyname,v_cur_rec2(i).docexstudyid,v_cur_rec2(i).siteid,v_cur_rec2(i).sitename,v_cur_rec2(i).docexsiteid,
                       v_cur_rec2(i).docexsystemid,v_cur_rec2(i).docexsystemname,ip_operation,gv_createdby,v_createddt,NULL,NULL)
              RETURNING integrationid BULK COLLECT INTO v_integrationidlist;
    
      END LOOP;
      CLOSE cur_rec2;
        
  END IF;
  
  OPEN op_sponsor FOR
       SELECT * 
       FROM TBL_INTEGRATION
       WHERE integrationid IN (SELECT * FROM TABLE(v_integrationidlist));
  
END SP_SET_SPONSOR_DEACT_INT;

PROCEDURE SP_SET_USERACCESS_ACT_INT
IS
v_operation_siteuser    TBL_INTEGRATION.operation%TYPE := 'add-user-to-site';
v_operation_sponsor     TBL_INTEGRATION.operation%TYPE := 'add-sponsor-role-outbound';
v_useraccess            SYS_REFCURSOR;

v_integrationidlist     NUM_ARRAY := NUM_ARRAY();
v_createddt             DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT turm.userroleid,tu.issponsor
       FROM TBL_USERROLEMAP turm, TBL_USERPROFILES tu
       WHERE turm.userid = tu.userid
       AND turm.act_isintegrated = 'N'
       AND (turm.rolechangereason IS NULL OR
            turm.rolechangereason NOT IN ('DEACTIVATION_FORCAUSE',
                                          'DEACTIVATION_FORSITE',
                                          'DEACTIVATION_FORCAUSEPLATFORM',
                                          'DEACTIVATION_FROMPLATFORM',
                                          'DEACTIVATION_FORSTUDY',
                                          'ACCESSMODIFICATION_ROLEDEACT'))
       AND turm.effectivestartdate <= SYSDATE
       ORDER BY turm.userroleid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

BEGIN

  --User Access Activation Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FOR i IN v_cur_rec.FIRST..v_cur_rec.LAST LOOP
          IF v_cur_rec(i).issponsor = 'Y' THEN      
             SP_SET_SPONSOR_USERACCESS_INT(v_cur_rec(i).userroleid,v_operation_sponsor,v_useraccess);
          ELSE
             SP_SET_USERACCESS_INT(v_cur_rec(i).userroleid,v_operation_siteuser,v_useraccess);
          END IF;
          
          --Mark Activation Integrated as 'Y'
          UPDATE TBL_USERROLEMAP turm
          SET turm.act_isintegrated = 'Y'
          WHERE turm.userroleid = v_cur_rec(i).userroleid;
      END LOOP;
      
  END LOOP;
  CLOSE cur_rec;  
 
END SP_SET_USERACCESS_ACT_INT;

PROCEDURE SP_SET_USERACCESS_DEACT_INT
IS
v_operation_siteuser    TBL_INTEGRATION.operation%TYPE := 'remove-user-from-site';
v_operation_sponsor     TBL_INTEGRATION.operation%TYPE := 'remove-sponsor-role-outbound';
v_useraccess            SYS_REFCURSOR;

v_integrationidlist     NUM_ARRAY := NUM_ARRAY();
v_createddt             DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT turm.userroleid,tu.issponsor
       FROM TBL_USERROLEMAP turm, TBL_USERPROFILES tu
       WHERE turm.userid = tu.userid
       AND turm.deact_isintegrated = 'N'
       AND (turm.rolechangereason IS NULL OR
            turm.rolechangereason NOT IN ('DEACTIVATION_FORCAUSE',
                                          'DEACTIVATION_FORSITE',
                                          'DEACTIVATION_FORCAUSEPLATFORM',
                                          'DEACTIVATION_FROMPLATFORM',
                                          'DEACTIVATION_FORSTUDY',
                                          'ACCESSMODIFICATION_ROLEDEACT'))
       AND turm.effectiveenddate IS NOT NULL
       AND turm.effectiveenddate <= SYSDATE
       ORDER BY turm.userroleid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

BEGIN

  --User Access Deactivation Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FOR i IN v_cur_rec.FIRST..v_cur_rec.LAST LOOP
          IF v_cur_rec(i).issponsor = 'Y' THEN      
             SP_SET_SPONSOR_USERACCESS_INT(v_cur_rec(i).userroleid,v_operation_sponsor,v_useraccess);
          ELSE
             SP_SET_USERACCESS_INT(v_cur_rec(i).userroleid,v_operation_siteuser,v_useraccess);
          END IF;
          
          --Mark Deactivation Integrated as 'Y'
          UPDATE TBL_USERROLEMAP turm
          SET turm.deact_isintegrated = 'Y'
          WHERE turm.userroleid = v_cur_rec(i).userroleid;
      END LOOP;
      
  END LOOP;
  CLOSE cur_rec;  
  
END SP_SET_USERACCESS_DEACT_INT;

PROCEDURE SP_SET_FACDOC_INT
(
ip_facilitydocmetadataid     IN TBL_FACILITYDOCMETADATA.facilitydocmetadataid%TYPE,
ip_operation                 IN TBL_INTEGRATION.operation%TYPE,
op_facdoc                    OUT SYS_REFCURSOR
)
IS
v_integrationidlist     NUM_ARRAY := NUM_ARRAY();
v_createddt             DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT DISTINCT tf.facilityid, tf.facilityname, tf.irfacilityid, tf.masterfacilitytypecode, tf.isdepartment, 
              CASE
                  WHEN tf.isdepartment = 'Y' THEN
                       tf.facilityid
                  ELSE NULL
              END departmentid,
              tf.departmentname, tf.departmenttypeid,           
              CASE
                       WHEN tf.isdepartment = 'Y' THEN
                            tf.irfacilityid
                       ELSE NULL
              END irdepartmentid,
              tcf.contactid fac_contactid,tcf.contacttype fac_contacttype,tcf.addresstype fac_addresstype,
              tcf.address1 fac_address1,tcf.address2 fac_address2,tcf.address3 fac_address3,tcf.city fac_city,
              (SELECT tst.statename
              FROM TBL_STATES tst, TBL_COUNTRIES tcnt
              WHERE tst.countryid = tcnt.countryid
              AND tcnt.countrycd = tcf.countrycd
              AND tst.statecd = tcf.state) fac_statename,
              tcf.state fac_statecd,
              (SELECT tcnt.countryname
              FROM TBL_COUNTRIES tcnt
              WHERE tcnt.countrycd = tcf.countrycd) fac_countryname,
              tcf.countrycd fac_countrycd,tcf.postalcode fac_postalcode,tcf.phone1 fac_phone1,tcf.phone1ext fac_phone1ext,
              tcf.fax fac_fax,tcf.email fac_email,
              tcd.contactid dept_contactid,tcd.contacttype dept_contacttype,tcd.addresstype dept_addresstype,
              tcd.address1 dept_address1,tcd.address2 dept_address2,tcd.address3 dept_address3,tcd.city dept_city,
              (SELECT tst.statename
              FROM TBL_STATES tst, TBL_COUNTRIES tcnt
              WHERE tst.countryid = tcnt.countryid
              AND tcnt.countrycd = tcd.countrycd
              AND tst.statecd = tcd.state) dept_statename,
              tcd.state dept_statecd,
              (SELECT tcnt.countryname
              FROM TBL_COUNTRIES tcnt
              WHERE tcnt.countrycd = tcd.countrycd) dept_countryname,
              tcd.countrycd dept_countrycd,tcd.postalcode dept_postalcode,tcd.phone1 dept_phone1,tcd.phone1ext dept_phone1ext,
              tcd.fax dept_fax,tcd.email dept_email, tfdm.documentdescription description, 
              tdcs.docexsystemid,tdcs.docexsystemname, tor.orgid, tor.orgcd orgcode, tfdm.facilitydocmetadataid documentid
      FROM TBL_FACILITYDOCMETADATA tfdm,
           TBL_FACILITIES tf,
           TBL_SITE tsi,
           TBL_STUDY ts,
           TBL_STUDYDOCEXMAP tsdm,
           TBL_CONTACT tcf,
           TBL_FACILITIES tpf,
           TBL_CONTACT tcd,
           TBL_ORGANIZATION tor,
           TBL_ORGDOCEXMAP todm,
           TBL_DOCEXSYSTEM tdcs
      WHERE tfdm.facilityid = tf.facilityid
      AND tf.facilityid = tsi.principalfacilityid
      AND tsi.studyid = ts.studyid
      AND ts.studyid = tsdm.studyid(+)
      AND tsi.isactive = 'Y'
      AND ts.orgid = tor.orgid
      AND tor.orgid = todm.orgid(+)
      AND todm.docexsystemid = tdcs.docexsystemid(+)
      AND tf.contactid = tcf.contactid(+)
      AND tf.contactid = tcf.contactid(+)
      AND tf.facilityfordept = tpf.facilityid(+)
      AND tpf.contactid = tcd.contactid(+)
      AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay 
      AND tfdm.facilitydocmetadataid = ip_facilitydocmetadataid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

BEGIN

  --Facility Document Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEGRATION
                 (integrationid,facilityid,facilityname,irfacilityid,masterfacilitytypecode,isdepartment,departmentid,departmentname,departmenttypeid,          
                  irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,fac_address1,fac_address2,fac_address3,fac_city,fac_statename,fac_statecd,               
                  fac_countryname,fac_countrycd,fac_postalcode,fac_phone1,fac_phone1ext,fac_fax,fac_email,dept_contactid,dept_contacttype,dept_addresstype,          
                  dept_address1,dept_address2,dept_address3,dept_city,dept_statename,dept_statecd,dept_countryname,dept_countrycd,dept_postalcode,           
                  dept_phone1,dept_phone1ext,dept_fax,dept_email,description,docexsystemid,docexsystemname,orgid,orgcode,documentid,
                  operation, createddt, createdby, modifieddt, modifiedby)
          VALUES(seq_integration.NEXTVAL,v_cur_rec(i).facilityid,v_cur_rec(i).facilityname,v_cur_rec(i).irfacilityid,v_cur_rec(i).masterfacilitytypecode,v_cur_rec(i).isdepartment,v_cur_rec(i).departmentid,v_cur_rec(i).departmentname,v_cur_rec(i).departmenttypeid,         
                  v_cur_rec(i).irdepartmentid,v_cur_rec(i).fac_contactid,v_cur_rec(i).fac_contacttype,v_cur_rec(i).fac_addresstype,v_cur_rec(i).fac_address1,v_cur_rec(i).fac_address2,v_cur_rec(i).fac_address3,v_cur_rec(i).fac_city,v_cur_rec(i).fac_statename,v_cur_rec(i).fac_statecd,               
                  v_cur_rec(i).fac_countryname,v_cur_rec(i).fac_countrycd,v_cur_rec(i).fac_postalcode,v_cur_rec(i).fac_phone1,v_cur_rec(i).fac_phone1ext,v_cur_rec(i).fac_fax,v_cur_rec(i).fac_email,v_cur_rec(i).dept_contactid,v_cur_rec(i).dept_contacttype,v_cur_rec(i).dept_addresstype,          
                  v_cur_rec(i).dept_address1,v_cur_rec(i).dept_address2,v_cur_rec(i).dept_address3,v_cur_rec(i).dept_city,v_cur_rec(i).dept_statename,v_cur_rec(i).dept_statecd,v_cur_rec(i).dept_countryname,v_cur_rec(i).dept_countrycd,v_cur_rec(i).dept_postalcode,           
                  v_cur_rec(i).dept_phone1,v_cur_rec(i).dept_phone1ext,v_cur_rec(i).dept_fax,v_cur_rec(i).dept_email,v_cur_rec(i).description,v_cur_rec(i).docexsystemid,v_cur_rec(i).docexsystemname,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,v_cur_rec(i).documentid,ip_operation,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integrationid BULK COLLECT INTO v_integrationidlist;

  END LOOP;
  CLOSE cur_rec;
    
  OPEN op_facdoc FOR
       SELECT *
       FROM TBL_INTEGRATION
       WHERE integrationid IN (SELECT * FROM TABLE(v_integrationidlist));
    
END SP_SET_FACDOC_INT;

PROCEDURE SP_SET_USER_TRAINING_INT
(
ip_id           IN TBL_USER_TRAINING_STATUS.id%TYPE,
ip_operation    IN TBL_INTEGRATION.operation%TYPE,
op_usertrng     OUT SYS_REFCURSOR
)
IS
v_integrationidlist     NUM_ARRAY := NUM_ARRAY();
v_createddt             DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT ts.studyid,ts.studyname,tsdm.docexstudyid,ts.sipstudyid,tsi.sipsiteid,tsi.siteid,tsi.sitename,tsi.isaffiliated,
             tsi.piid,tsi.principalfacilityid,tsi.docexsiteid,tu.userid,tu.transcelerateuserid,
             (SELECT tud.docexuserid
             FROM TBL_USERDOCEXMAP tud
             WHERE tud.userid = tu.userid
             AND tud.orgid = tor.orgid) veeva_userid,
            (SELECT tud.docexpersonid
             FROM TBL_USERDOCEXMAP tud
             WHERE tud.userid = tu.userid
             AND tud.orgid = tor.orgid) veeva_personid,
             tu.prefix,tu.title,tu.firstname,tu.middlename,tu.lastname,tu.suffix,tu.initials,tu.isactive,tu.timezoneid,
             tcu.contactid user_contactid,tcu.contacttype user_contacttype,tcu.addresstype user_addresstype,tcu.address1 user_address1,
             tcu.address2 user_address2,tcu.address3 user_address3,tcu.city user_city,
            (SELECT tst.statename 
             FROM TBL_STATES tst, TBL_COUNTRIES tcnt
             WHERE tst.statecd = tcu.state
             AND tst.countryid = tcnt.countryid
             AND tcnt.countrycd = tcu.countrycd) user_statename,
            (SELECT tcu.state 
             FROM TBL_STATES tst, TBL_COUNTRIES tcnt
             WHERE tst.statecd = tcu.state
             AND tst.countryid = tcnt.countryid
             AND tcnt.countrycd = tcu.countrycd) user_statecd,
            (SELECT tcnt.countryname 
             FROM TBL_COUNTRIES tcnt
             WHERE tcnt.countrycd = tcu.countrycd) user_countryname,
            (SELECT tcu.countrycd 
             FROM TBL_COUNTRIES tcnt
             WHERE tcnt.countrycd = tcu.countrycd) user_countrycd,
             tcu.postalcode user_postalcode,tcu.phone1 user_phone1,tcu.phone1ext user_phone1ext,tcu.fax user_fax,tcu.email user_email,
             id documentid, tdcs.docexsystemid,tdcs.docexsystemname, tor.orgid, tor.orgcd orgcode
      FROM TBL_USER_TRAINING_STATUS tuts,
           TBL_STUDY ts,
           TBL_SITE tsi,
           TBL_STUDYDOCEXMAP tsdm,
           TBL_USERPROFILES tu,
           TBL_CONTACT tcu,
           TBL_ORGANIZATION tor,
           TBL_ORGDOCEXMAP todm,
           TBL_DOCEXSYSTEM tdcs
      WHERE tuts.study_id = ts.studyid
      AND tuts.site_id = tsi.siteid
      AND ts.studyid = tsi.studyid
      AND tsi.isactive = 'Y'
      AND ts.studyid = tsdm.studyid(+)
      AND tuts.user_id = tu.userid
      AND tu.contactid = tcu.contactid(+)
      AND ts.orgid = tor.orgid
      AND tor.orgid = todm.orgid(+)
      AND todm.docexsystemid = tdcs.docexsystemid(+)
      AND LOWER(tdcs.docexsystemname) <> gv_docexsys_liferay
      AND tuts.id = ip_id;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

BEGIN

  --User Training Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEGRATION
                 (integrationid,studyid,studyname,docexstudyid,sipstudyid,sipsiteid,siteid,sitename,isaffiliated,piid,principalfacilityid,
                  docexsiteid,userid,transcelerateuserid,veeva_userid,veeva_personid,prefix,title,firstname,middlename,lastname,suffix,
                  initials,isactive,timezoneid,user_contactid,user_contacttype,user_addresstype,user_address1,user_address2,user_address3,
                  user_city,user_statename,user_statecd,user_countryname,user_countrycd,user_postalcode,user_phone1,user_phone1ext,user_fax,
                  user_email,documentid,docexsystemid,docexsystemname,orgid,orgcode, 
                  operation,createddt,createdby,modifieddt,modifiedby)
          VALUES(seq_integration.NEXTVAL,v_cur_rec(i).studyid,v_cur_rec(i).studyname,v_cur_rec(i).docexstudyid,v_cur_rec(i).sipstudyid,v_cur_rec(i).sipsiteid,v_cur_rec(i).siteid,v_cur_rec(i).sitename,v_cur_rec(i).isaffiliated,v_cur_rec(i).piid,v_cur_rec(i).principalfacilityid,
                 v_cur_rec(i).docexsiteid,v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).veeva_userid,v_cur_rec(i).veeva_personid,v_cur_rec(i).prefix,v_cur_rec(i).title,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,v_cur_rec(i).suffix,
                 v_cur_rec(i).initials,v_cur_rec(i).isactive,v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,v_cur_rec(i).user_address3,
                 v_cur_rec(i).user_city,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,v_cur_rec(i).user_countrycd,v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,
                 v_cur_rec(i).user_email,v_cur_rec(i).documentid,v_cur_rec(i).docexsystemid,v_cur_rec(i).docexsystemname,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,ip_operation,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integrationid BULK COLLECT INTO v_integrationidlist;

  END LOOP;
  CLOSE cur_rec;
    
  OPEN op_usertrng FOR
       SELECT *
       FROM TBL_INTEGRATION
       WHERE integrationid IN (SELECT * FROM TABLE(v_integrationidlist));

END SP_SET_USER_TRAINING_INT;

END PKG_INTEGRATION;
/