CREATE OR REPLACE PACKAGE BODY PKG_INTEG AS

PROCEDURE SP_SET_STUDY_INT
(
ip_studyid      IN TBL_STUDY.studyid%TYPE,
ip_sipeventid   IN TBL_SIP_EVENT.sipeventid%TYPE, 
op_study        OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT DISTINCT ts.studyid,ts.sipstudyid,ts.studyname,ts.studyshortdesc,
              ts.studylongdesc,ts.plannednextdatabaselock,ts.plannedfinaldatabaselock,
              ts.subjectsplanned,ts.subjectsenrolled,ts.iscreatedbyintegration,tph.phasename studyphase,
              ts.sip_studyclosuredate expirydate,tp.progid,tp.progname,tp.memberprogramcd,
              (SELECT LISTAGG(tc.countrycd,',') WITHIN GROUP (ORDER BY tscm.countryid)
               FROM TBL_STUDYCOUNTRYMILESTONE tscm, TBL_COUNTRIES tc
               WHERE tscm.countryid = tc.countryid
               AND tscm.isactive = 'Y'
               AND tscm.studyid = ts.studyid) study_countrycd,
              (SELECT LISTAGG(tsc.compoundid,',') WITHIN GROUP (ORDER BY tsc.compoundid)
               FROM TBL_STUDYCOMPOUND tsc
               WHERE tsc.studyid = ts.studyid) compoundid,
               NULL compoundname,NULL membercompoundcd,
              (SELECT LISTAGG(tsta.therapeuticareaid,',') WITHIN GROUP (ORDER BY tsta.therapeuticareaid)
               FROM TBL_STUDYTHERAPEUTICAREA tsta
               WHERE tsta.studyid = ts.studyid) therapeuticareaid,
               NULL therapeuticareacd,NULL therapeuticareaname,td.diseaseid,td.diseasename,td.memberdiseasecd,
              (SELECT LISTAGG(tsi.indicationid,',') WITHIN GROUP (ORDER BY tsi.indicationid)
               FROM TBL_STUDYINDICATION tsi
               WHERE tsi.studyid = ts.studyid) indicationid,
               NULL indicationname,NULL memberindicationcd,tor.orgid,tor.orgcd orgcode
       FROM TBL_STUDY ts, 
            TBL_PROGRAM tp, 
            TBL_ORGANIZATION tor, 
            TBL_DISEASE td,
            TBL_PHASE tph
       WHERE ts.progid = tp.progid
       AND tp.orgid = tor.orgid
       AND ts.diseaseid = td.diseaseid(+)
       AND ts.studyphase = tph.phaseid(+)
       AND ts.studyid = ip_studyid;
            
TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

BEGIN

  --Study Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;
      
      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEG
                (integid,studyid,sipstudyid,studyname,studyshortdesc,
                 studylongdesc,plannednextdatabaselock,plannedfinaldatabaselock,
                 subjectsplanned,subjectsenrolled,iscreatedbyintegration,studyphase,
                 expirydate,progid,progname,memberprogramcd,
                 study_countrycd,compoundid,compoundname,membercompoundcd,
                 therapeuticareaid,therapeuticareacd,therapeuticareaname,diseaseid,
                 diseasename,memberdiseasecd,indicationid,indicationname,memberindicationcd,
                 orgid,orgcode,sipeventid,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integ.NEXTVAL,v_cur_rec(i).studyid,v_cur_rec(i).sipstudyid,v_cur_rec(i).studyname,v_cur_rec(i).studyshortdesc,
                 v_cur_rec(i).studylongdesc,v_cur_rec(i).plannednextdatabaselock,v_cur_rec(i).plannedfinaldatabaselock,
                 v_cur_rec(i).subjectsplanned,v_cur_rec(i).subjectsenrolled,v_cur_rec(i).iscreatedbyintegration,v_cur_rec(i).studyphase,
                 v_cur_rec(i).expirydate,v_cur_rec(i).progid,v_cur_rec(i).progname,v_cur_rec(i).memberprogramcd,
                 v_cur_rec(i).study_countrycd,v_cur_rec(i).compoundid,v_cur_rec(i).compoundname,v_cur_rec(i).membercompoundcd,
                 v_cur_rec(i).therapeuticareaid,v_cur_rec(i).therapeuticareacd,v_cur_rec(i).therapeuticareaname,v_cur_rec(i).diseaseid,
                 v_cur_rec(i).diseasename,v_cur_rec(i).memberdiseasecd,v_cur_rec(i).indicationid,v_cur_rec(i).indicationname,v_cur_rec(i).memberindicationcd,
                 v_cur_rec(i).orgid,v_cur_rec(i).orgcode,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;
          
          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_studyid,v_orgidlist(j),ip_sipeventid,gv_eventtype_study);
          END LOOP;
          
  END LOOP;
  CLOSE cur_rec;

  OPEN op_study FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));
    
END SP_SET_STUDY_INT;

PROCEDURE SP_SET_SITE_INT
(
ip_siteid        IN TBL_SITE.siteid%TYPE,
ip_sipeventid    IN TBL_SIP_EVENT.sipeventid%TYPE,
op_site          OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT tsd.studyid,tsd.sipstudyid,tsd.studyname,ts.siteid,ts.sipsiteid,ts.sitename,ts.isaffiliated,
              ts.piid,ts.principalfacilityid,ts.safety_notification_startdate effectivestartdate,ts.safety_notification_enddate effectiveenddate,ts.plannedenddate due_date,ts.closuredt expirydate,
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
               tu.userid,tu.transcelerateuserid,tu.sipuserid,tiru.irid useririd,
               tu.prefix,tu.title,tu.firstname,tu.middlename,tu.lastname,tu.suffix,
               tu.initials,tu.isactive,tu.timezoneid,tcu.contactid user_contactid,tcu.contacttype user_contacttype,
               tcu.addresstype user_addresstype,tcu.address1 user_address1,tcu.address2 user_address2,
               tcu.address3 user_address3,tcu.city user_city,
               (SELECT tst.statename
               FROM TBL_STATES tst, TBL_COUNTRIES tcnt
               WHERE tst.countryid = tcnt.countryid
               AND tcnt.countrycd = tcu.countrycd
               AND tst.statecd = tcu.state) user_statename,
               tcu.state user_statecd,
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
               CASE 
                   WHEN tf.isdepartment = 'Y' THEN
                        tpf.sqtfacilitiestype 
                   ELSE tf.sqtfacilitiestype     
               END sqtfacilitiestype,
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
               tor.orgid,tor.orgcd orgcode,tc.compoundid,tc.compoundname,tc.membercompoundcd
        FROM TBL_STUDY tsd, 
             TBL_PROGRAM tp, 
             TBL_ORGANIZATION tor,
             TBL_SITE ts, 
             TBL_CONTACT tcu, 
             TBL_COMPOUND tc, 
             TBL_USERPROFILES tu,
             TBL_IRUSERMAP tiru,
             TBL_FACILITIES tf,  
             TBL_CONTACT tcf,
             TBL_FACILITIES tpf, 
             TBL_CONTACT tcd
        WHERE tsd.studyid = ts.studyid
        AND tsd.progid = tp.progid
        AND tp.orgid = tor.orgid
        AND tsd.compoundid = tc.compoundid
        AND ts.piid = tu.userid
        AND tu.transcelerateuserid = tiru.transcelerateuserid(+)
        AND tu.contactid = tcu.contactid(+)
        AND ts.principalfacilityid = tf.facilityid(+)
        AND tf.contactid = tcf.contactid(+)
        AND tf.facilityfordept = tpf.facilityid(+)
        AND tpf.contactid = tcd.contactid(+)
        AND ts.siteid = ip_siteid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

BEGIN

  --Site Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEG
                 (integid,studyid,sipstudyid,studyname,siteid,sipsiteid,sitename,isaffiliated,
                  piid,principalfacilityid,effectivestartdate,effectiveenddate,due_date,expirydate,
                  study_countrycd,study_countryname,userid,transcelerateuserid,
                  sipuserid,useririd,prefix,title,firstname,middlename,lastname,suffix,initials,isactive,
                  timezoneid,user_contactid,user_contacttype,user_addresstype,user_address1,user_address2,
                  user_address3,user_city,user_statename,user_statecd,user_countryname,user_countrycd,
                  user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,facilityid,facilityname,
                  irfacilityid,masterfacilitytypecode,sqtfacilitiestype,isdepartment,departmentid,departmentname,departmenttypeid,
                  irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,fac_address1,fac_address2,
                  fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,fac_countrycd,fac_postalcode,
                  fac_phone1,fac_phone1ext,fac_fax,fac_email,dept_contactid,dept_contacttype,dept_addresstype,
                  dept_address1,dept_address2,dept_address3,dept_city,dept_statename,dept_statecd,dept_countryname,
                  dept_countrycd,dept_postalcode,dept_phone1,dept_phone1ext,dept_fax,dept_email,orgid,orgcode,
                  compoundid,compoundname,membercompoundcd,sipeventid,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integ.NEXTVAL,v_cur_rec(i).studyid,v_cur_rec(i).sipstudyid,v_cur_rec(i).studyname,v_cur_rec(i).siteid,v_cur_rec(i).sipsiteid,v_cur_rec(i).sitename,v_cur_rec(i).isaffiliated,
                 v_cur_rec(i).piid,v_cur_rec(i).principalfacilityid,v_cur_rec(i).effectivestartdate,v_cur_rec(i).effectiveenddate,v_cur_rec(i).due_date,v_cur_rec(i).expirydate,
                 v_cur_rec(i).study_countrycd,v_cur_rec(i).study_countryname,v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,
                 v_cur_rec(i).sipuserid,v_cur_rec(i).useririd,v_cur_rec(i).prefix,v_cur_rec(i).title,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,v_cur_rec(i).suffix,v_cur_rec(i).initials,v_cur_rec(i).isactive,
                 v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,
                 v_cur_rec(i).user_address3,v_cur_rec(i).user_city,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,v_cur_rec(i).user_countrycd,
                 v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,v_cur_rec(i).user_email,v_cur_rec(i).facilityid,v_cur_rec(i).facilityname,
                 v_cur_rec(i).irfacilityid,v_cur_rec(i).masterfacilitytypecode,v_cur_rec(i).sqtfacilitiestype,v_cur_rec(i).isdepartment,v_cur_rec(i).departmentid,v_cur_rec(i).departmentname,v_cur_rec(i).departmenttypeid,
                 v_cur_rec(i).irdepartmentid,v_cur_rec(i).fac_contactid,v_cur_rec(i).fac_contacttype,v_cur_rec(i).fac_addresstype,v_cur_rec(i).fac_address1,v_cur_rec(i).fac_address2,
                 v_cur_rec(i).fac_address3,v_cur_rec(i).fac_city,v_cur_rec(i).fac_statename,v_cur_rec(i).fac_statecd,v_cur_rec(i).fac_countryname,v_cur_rec(i).fac_countrycd,v_cur_rec(i).fac_postalcode,
                 v_cur_rec(i).fac_phone1,v_cur_rec(i).fac_phone1ext,v_cur_rec(i).fac_fax,v_cur_rec(i).fac_email,v_cur_rec(i).dept_contactid,v_cur_rec(i).dept_contacttype,v_cur_rec(i).dept_addresstype,
                 v_cur_rec(i).dept_address1,v_cur_rec(i).dept_address2,v_cur_rec(i).dept_address3,v_cur_rec(i).dept_city,v_cur_rec(i).dept_statename,v_cur_rec(i).dept_statecd,v_cur_rec(i).dept_countryname,
                 v_cur_rec(i).dept_countrycd,v_cur_rec(i).dept_postalcode,v_cur_rec(i).dept_phone1,v_cur_rec(i).dept_phone1ext,v_cur_rec(i).dept_fax,v_cur_rec(i).dept_email,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,
                 v_cur_rec(i).compoundid,v_cur_rec(i).compoundname,v_cur_rec(i).membercompoundcd,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_siteid,v_orgidlist(j),ip_sipeventid,gv_eventtype_site);
          END LOOP;

  END LOOP;
  CLOSE cur_rec;
  
  OPEN op_site FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));
  
END SP_SET_SITE_INT;

PROCEDURE SP_SET_UPDATESITE_INT
(
ip_siteid         IN TBL_SITE.siteid%TYPE,
ip_oldfacilityid  IN TBL_FACILITIES.facilityid%TYPE,
ip_newfacilityid  IN TBL_FACILITIES.facilityid%TYPE,
ip_sipeventid     IN TBL_SIP_EVENT.sipeventid%TYPE,
op_site           OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT tr.roleid,tr.rolename,tr.description,turm.effectivestartdate,turm.effectiveenddate,
                     turm.rolechangereason,tsd.studyid,tsd.sipstudyid,tsd.studyname,ts.siteid,ts.sipsiteid,ts.sitename,
                     tu.userid,tu.transcelerateuserid,tu.sipuserid,
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
                     tu.orgid,tor.orgcd orgcode
       FROM TBL_USERROLEMAP turm,
            TBL_ROLES tr,
            TBL_STUDY tsd,
            TBL_SITE ts,
            TBL_USERPROFILES tu,
            TBL_ORGANIZATION tor,
            TBL_CONTACT tcu
       WHERE turm.roleid = tr.roleid 
       AND turm.studyid = tsd.studyid
       AND turm.siteid = ts.siteid
       AND turm.userid = tu.userid
       AND tu.orgid = tor.orgid(+)
       AND tu.contactid = tcu.contactid(+)
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

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

BEGIN
  --Site Integration
  SP_SET_SITE_INT(ip_siteid,ip_sipeventid,op_site);
    
  --Update Site Integration
  /*OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEG
                (integid,roleid,rolename,description,effectivestartdate,effectiveenddate,rolechangereason,
                 studyid,studyname,siteid,sitename,userid,transcelerateuserid,sipuserid,
                 prefix,title,firstname,middlename,lastname,suffix,initials,isactive,
                 timezoneid,user_contactid,user_contacttype,user_addresstype,user_address1,user_address2,
                 user_address3,user_city,user_statename,user_statecd,user_countryname,user_countrycd,
                 user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,orgid,orgcode,
                 sipeventid,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integ.NEXTVAL,v_cur_rec(i).roleid,v_cur_rec(i).rolename,v_cur_rec(i).description,v_cur_rec(i).effectivestartdate,v_cur_rec(i).effectiveenddate,v_cur_rec(i).rolechangereason,
                 v_cur_rec(i).studyid,v_cur_rec(i).studyname,v_cur_rec(i).siteid,v_cur_rec(i).sitename,v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).sipuserid,
                 v_cur_rec(i).prefix,v_cur_rec(i).title,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,v_cur_rec(i).suffix,v_cur_rec(i).initials,v_cur_rec(i).isactive,
                 v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,
                 v_cur_rec(i).user_address3,v_cur_rec(i).user_city,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,v_cur_rec(i).user_countrycd,
                 v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,v_cur_rec(i).user_email,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,
                 ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_siteid,v_orgidlist(j),ip_sipeventid,gv_eventtype_updatesite);
          END LOOP;

  END LOOP;
  CLOSE cur_rec; */   
    
END SP_SET_UPDATESITE_INT;

PROCEDURE SP_SET_STUDYCOUNTRY_INT
(
ip_studycountryid IN TBL_STUDYCOUNTRYMILESTONE.studycountryid%TYPE,
ip_sipeventid     IN TBL_SIP_EVENT.sipeventid%TYPE,
op_studycountry   OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT ts.studyid,ts.studyname,tscm.studycountryid,tc.countrycd study_countrycd,tc.countryname study_countryname,
              ts.sipstudyid,tor.orgid,tor.orgcd orgcode
       FROM TBL_STUDY ts, 
            TBL_STUDYCOUNTRYMILESTONE tscm,
            TBL_COUNTRIES tc,
            TBL_PROGRAM tp, 
            TBL_ORGANIZATION tor
       WHERE ts.studyid = tscm.studyid
       AND tscm.countryid = tc.countryid
       AND ts.progid = tp.progid
       AND tp.orgid = tor.orgid
       AND tscm.studycountryid = ip_studycountryid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

BEGIN
  --Study Country Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEG
                (integid,studyid,studyname,studycountryid,study_countrycd,study_countryname,
                 sipstudyid,orgid,orgcode,sipeventid,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integ.NEXTVAL,v_cur_rec(i).studyid,v_cur_rec(i).studyname,v_cur_rec(i).studycountryid,v_cur_rec(i).study_countrycd,v_cur_rec(i).study_countryname,
                 v_cur_rec(i).sipstudyid,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_studycountryid,v_orgidlist(j),ip_sipeventid,gv_eventtype_studycountry);
          END LOOP;

  END LOOP;
  CLOSE cur_rec;    
    
  OPEN op_studycountry FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));
    
END SP_SET_STUDYCOUNTRY_INT;

PROCEDURE SP_SET_STAFFROLE_INT
(
ip_userroleid       IN TBL_USERROLEMAP.userroleid%TYPE,
ip_sipeventid       IN TBL_SIP_EVENT.sipeventid%TYPE,
op_staffrole        OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT tr.roleid,tr.rolename,tr.description,turm.effectivestartdate,turm.effectiveenddate,
              turm.rolechangereason,tsd.studyid,tsd.sipstudyid,tsd.studyname,ts.siteid,ts.sipsiteid,ts.sitename,
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
             tu.userid,tu.transcelerateuserid,tu.sipuserid,turm.userroleid,tu.prefix,tu.title,
             tu.firstname,tu.middlename,tu.lastname,tu.suffix,tu.initials,tu.isactive,tu.timezoneid,
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
             tor.orgid,tor.orgcd orgcode,tc.compoundid,tc.compoundname,tc.membercompoundcd
      FROM TBL_USERROLEMAP turm,
           TBL_ROLES tr,
           TBL_STUDY tsd,
           TBL_PROGRAM tp,
           TBL_ORGANIZATION tor,
           TBL_COMPOUND tc, 
           TBL_SITE ts,
           TBL_USERPROFILES tu,
           TBL_CONTACT tcu,
           TBL_FACILITIES tf,  
           TBL_CONTACT tcf,
           TBL_FACILITIES tpf, 
           TBL_CONTACT tcd
      WHERE turm.roleid = tr.roleid 
      AND turm.studyid = tsd.studyid
      AND tsd.progid = tp.progid
      AND tp.orgid = tor.orgid
      AND tsd.compoundid = tc.compoundid
      AND turm.siteid = ts.siteid(+)
      AND turm.userid = tu.userid
      AND tu.contactid = tcu.contactid(+)
      AND ts.principalfacilityid = tf.facilityid(+)
      AND tf.contactid = tcf.contactid(+)
      AND tf.facilityfordept = tpf.facilityid(+)
      AND tpf.contactid = tcd.contactid(+)
      AND turm.userroleid = ip_userroleid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

CURSOR cur_rec1 IS
       SELECT tu.userid,tu.transcelerateuserid,tu.sipuserid,td.documentid,td.url,
              tu.firstname,tu.middlename,tu.lastname,tor.orgid,tor.orgcd orgcode,
              ts.studyid,ts.sipstudyid,ts.studyname,tsi.siteid,tsi.sipsiteid,tsi.sitename,tr.roleid,tr.rolename,turm.userroleid
       FROM TBL_DOCUMENTS td, 
            TBL_USERPROFILES tu, 
            TBL_USERROLEMAP turm,
            TBL_STUDY ts,
            TBL_SITE tsi,
            TBL_PROGRAM tp, 
            TBL_ORGANIZATION tor,
            TBL_ROLES tr
       WHERE td.docuserid = tu.userid
       AND tu.userid = turm.userid
       AND (turm.effectiveenddate IS NULL OR TRUNC(turm.effectiveenddate) >= TRUNC(v_createddt))
       AND turm.studyid = ts.studyid
       AND turm.siteid = tsi.siteid
       AND ts.isactive = 'Y'
       AND tsi.isactive = 'Y'
       AND ts.progid = tp.progid
       AND tp.orgid = tor.orgid
       AND turm.roleid = tr.roleid
       AND td.islatest = 'Y'
       AND td.isdeleted = 'N'
       AND td.doctypecd = 1 --CV
       AND turm.userroleid = ip_userroleid;

TYPE typ_cur_rec1 IS TABLE OF cur_rec1%ROWTYPE;
v_cur_rec1 typ_cur_rec1;

v_sipevent_siteusercv   TBL_SIP_EVENT.eventname%TYPE := 'user-cv-after-addstaff-outbound';
v_sipeventid            TBL_SIP_EVENT.sipeventid%TYPE;
v_eventforcv            PLS_INTEGER:=0;
BEGIN
  --Staff Role Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEG
                (integid,roleid,rolename,description,effectivestartdate,effectiveenddate,rolechangereason,
                 studyid,sipstudyid,studyname,siteid,sipsiteid,sitename,study_countrycd,study_countryname,userid,transcelerateuserid,
                 sipuserid,userroleid,prefix,title,firstname,middlename,lastname,suffix,initials,isactive,
                 timezoneid,user_contactid,user_contacttype,user_addresstype,user_address1,user_address2,
                 user_address3,user_city,user_statename,user_statecd,user_countryname,user_countrycd,
                 user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,facilityid,facilityname,
                 irfacilityid,masterfacilitytypecode,isdepartment,departmentid,departmentname,departmenttypeid,
                 irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,fac_address1,fac_address2,
                 fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,fac_countrycd,fac_postalcode,
                 fac_phone1,fac_phone1ext,fac_fax,fac_email,dept_contactid,dept_contacttype,dept_addresstype,
                 dept_address1,dept_address2,dept_address3,dept_city,dept_statename,dept_statecd,dept_countryname,
                 dept_countrycd,dept_postalcode,dept_phone1,dept_phone1ext,dept_fax,dept_email,orgid,orgcode,
                 compoundid,compoundname,membercompoundcd,sipeventid,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integ.NEXTVAL,v_cur_rec(i).roleid,v_cur_rec(i).rolename,v_cur_rec(i).description,v_cur_rec(i).effectivestartdate,v_cur_rec(i).effectiveenddate,v_cur_rec(i).rolechangereason,
                 v_cur_rec(i).studyid,v_cur_rec(i).sipstudyid,v_cur_rec(i).studyname,v_cur_rec(i).siteid,v_cur_rec(i).sipsiteid,v_cur_rec(i).sitename,v_cur_rec(i).study_countrycd,v_cur_rec(i).study_countryname,v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).sipuserid,
                 v_cur_rec(i).userroleid,v_cur_rec(i).prefix,v_cur_rec(i).title,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,v_cur_rec(i).suffix,v_cur_rec(i).initials,v_cur_rec(i).isactive,
                 v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,
                 v_cur_rec(i).user_address3,v_cur_rec(i).user_city,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,v_cur_rec(i).user_countrycd,
                 v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,v_cur_rec(i).user_email,v_cur_rec(i).facilityid,v_cur_rec(i).facilityname,
                 v_cur_rec(i).irfacilityid,v_cur_rec(i).masterfacilitytypecode,v_cur_rec(i).isdepartment,v_cur_rec(i).departmentid,v_cur_rec(i).departmentname,v_cur_rec(i).departmenttypeid,
                 v_cur_rec(i).irdepartmentid,v_cur_rec(i).fac_contactid,v_cur_rec(i).fac_contacttype,v_cur_rec(i).fac_addresstype,v_cur_rec(i).fac_address1,v_cur_rec(i).fac_address2,
                 v_cur_rec(i).fac_address3,v_cur_rec(i).fac_city,v_cur_rec(i).fac_statename,v_cur_rec(i).fac_statecd,v_cur_rec(i).fac_countryname,v_cur_rec(i).fac_countrycd,v_cur_rec(i).fac_postalcode,
                 v_cur_rec(i).fac_phone1,v_cur_rec(i).fac_phone1ext,v_cur_rec(i).fac_fax,v_cur_rec(i).fac_email,v_cur_rec(i).dept_contactid,v_cur_rec(i).dept_contacttype,v_cur_rec(i).dept_addresstype,
                 v_cur_rec(i).dept_address1,v_cur_rec(i).dept_address2,v_cur_rec(i).dept_address3,v_cur_rec(i).dept_city,v_cur_rec(i).dept_statename,v_cur_rec(i).dept_statecd,v_cur_rec(i).dept_countryname,
                 v_cur_rec(i).dept_countrycd,v_cur_rec(i).dept_postalcode,v_cur_rec(i).dept_phone1,v_cur_rec(i).dept_phone1ext,v_cur_rec(i).dept_fax,v_cur_rec(i).dept_email,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,
                 v_cur_rec(i).compoundid,v_cur_rec(i).compoundname,v_cur_rec(i).membercompoundcd,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_userroleid,v_orgidlist(j),ip_sipeventid,gv_eventtype_staffrole);
              --Populate System Access for Integ ID
              SP_SET_INTEG_MULTIVALUE(v_integidlist(j),ip_userroleid,NULL,gv_keytype_systemaccess);
          END LOOP;

  END LOOP;
  CLOSE cur_rec;
    
  --User CV to Site
  SELECT COUNT(1) INTO v_eventforcv FROM TBL_SIP_EVENT where eventname = gv_event_addusertosite and sipeventid = ip_sipeventid;
  SELECT sipeventid INTO v_sipeventid FROM TBL_SIP_EVENT where eventname = v_sipevent_siteusercv;
  --Add CV Only if event is 'add-user-to-site-outbound'
  IF v_eventforcv <> 0 THEN
  OPEN cur_rec1;
  LOOP
      FETCH cur_rec1 BULK COLLECT INTO v_cur_rec1 LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec1.COUNT = 0;

      FORALL i IN v_cur_rec1.FIRST..v_cur_rec1.LAST
          INSERT INTO TBL_INTEG
                (integid,userid,transcelerateuserid,sipuserid,documentid,url,
                 firstname,middlename,lastname,orgid,orgcode,
                 studyid,sipstudyid,studyname,siteid,sipsiteid,sitename,roleid,rolename,userroleid,
                 sipeventid,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integ.NEXTVAL,v_cur_rec1(i).userid,v_cur_rec1(i).transcelerateuserid,v_cur_rec1(i).sipuserid,v_cur_rec1(i).documentid,v_cur_rec1(i).url,
                 v_cur_rec1(i).firstname,v_cur_rec1(i).middlename,v_cur_rec1(i).lastname,v_cur_rec1(i).orgid,v_cur_rec1(i).orgcode,
                 v_cur_rec1(i).studyid,v_cur_rec1(i).sipstudyid,v_cur_rec1(i).studyname,v_cur_rec1(i).siteid,v_cur_rec1(i).sipsiteid,v_cur_rec1(i).sitename,v_cur_rec1(i).roleid,v_cur_rec1(i).rolename,v_cur_rec1(i).userroleid,
                 v_sipeventid,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_userroleid,v_orgidlist(j),v_sipeventid,gv_eventtype_usercv);
          END LOOP;

  END LOOP;
  CLOSE cur_rec1;
  END IF;
  
  OPEN op_staffrole FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));
    
END SP_SET_STAFFROLE_INT;

PROCEDURE SP_SET_SITEUSER_INT
(
ip_userid       IN TBL_USERPROFILES.userid%TYPE,
ip_sipeventid   IN TBL_SIP_EVENT.sipeventid%TYPE,
op_siteuser     OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT DISTINCT tu.userid,tu.transcelerateuserid,tu.sipuserid,tu.prefix,tu.title,tu.firstname,tu.middlename,
             tu.lastname,tu.suffix,tu.initials,tu.isactive,tu.timezoneid,tcu.contactid user_contactid,
             tcu.contacttype user_contacttype,tcu.addresstype user_addresstype,tcu.address1 user_address1,
             tcu.address2 user_address2,tcu.address3 user_address3,tcu.city user_city,tcu.institution,
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
             tcu.maindaytime daytime_phone,tcu.evening evening_phone,tcu.hour24 hours24_phone,tcu.pager,
             tor.orgid,tor.orgcd orgcode
      FROM TBL_USERPROFILES tu,
           TBL_CONTACT tcu,
           TBL_USERROLEMAP turm,
           TBL_STUDY ts,
           TBL_PROGRAM tp,
           TBL_ORGANIZATION tor
      WHERE tu.contactid = tcu.contactid(+)
      AND tu.userid = turm.userid
      AND (turm.effectiveenddate IS NULL OR TRUNC(turm.effectiveenddate) >= TRUNC(v_createddt))
      AND turm.studyid = ts.studyid
      AND ts.progid = tp.progid
      AND tp.orgid = tor.orgid
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
          INSERT INTO TBL_INTEG
                (integid,userid,transcelerateuserid,sipuserid,prefix,title,firstname,middlename,lastname,
                 suffix,initials,isactive,timezoneid,user_contactid,user_contacttype,user_addresstype,
                 user_address1,user_address2,user_address3,user_city,institution,user_statename,user_statecd,user_countryname,
                 user_countrycd,user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,
                 daytime_phone,evening_phone,hours24_phone,pager,
                 orgid,orgcode,sipeventid,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integ.NEXTVAL,v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).sipuserid,v_cur_rec(i).prefix,v_cur_rec(i).title,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,
                 v_cur_rec(i).suffix,v_cur_rec(i).initials,v_cur_rec(i).isactive,v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,
                 v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,v_cur_rec(i).user_address3,v_cur_rec(i).user_city,v_cur_rec(i).institution,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,
                 v_cur_rec(i).user_countrycd,v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,v_cur_rec(i).user_email,
                 v_cur_rec(i).daytime_phone,v_cur_rec(i).evening_phone,v_cur_rec(i).hours24_phone,v_cur_rec(i).pager,
                 v_cur_rec(i).orgid,v_cur_rec(i).orgcode,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_userid,v_orgidlist(j),ip_sipeventid,gv_eventtype_siteuser);
          END LOOP;

  END LOOP;
  CLOSE cur_rec;

  OPEN op_siteuser FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));
    
END SP_SET_SITEUSER_INT;

PROCEDURE SP_SET_USERDOC_INT
(
ip_documentid     IN TBL_DOCUMENTS.documentid%TYPE,
ip_sipeventid     IN TBL_SIP_EVENT.sipeventid%TYPE,
op_userdoc        OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT DISTINCT tu.userid,tu.transcelerateuserid,tu.sipuserid,td.documentid,td.url,
                     ts.studyid,ts.sipstudyid,ts.studyname,tsi.siteid,tsi.sipsiteid,tsi.sitename,tor.orgid,tor.orgcd orgcode
       FROM TBL_DOCUMENTS td, 
            TBL_USERPROFILES tu, 
            TBL_USERROLEMAP turm,
            TBL_STUDY ts,
            TBL_SITE tsi,
            TBL_PROGRAM tp, 
            TBL_ORGANIZATION tor
       WHERE td.docuserid = tu.userid
       AND tu.userid = turm.userid
       AND (turm.effectiveenddate IS NULL OR TRUNC(turm.effectiveenddate) >= TRUNC(v_createddt))
       AND turm.studyid = ts.studyid
       AND turm.siteid = tsi.siteid
       AND tsi.isactive = 'Y'
       AND ts.progid = tp.progid
       AND tp.orgid = tor.orgid
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
          INSERT INTO TBL_INTEG
                (integid,userid,transcelerateuserid,sipuserid,documentid,url,
                 studyid,sipstudyid,studyname,siteid,sipsiteid,sitename,orgid,orgcode,sipeventid,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integ.NEXTVAL,v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).sipuserid,v_cur_rec(i).documentid,v_cur_rec(i).url,
                 v_cur_rec(i).studyid,v_cur_rec(i).sipstudyid,v_cur_rec(i).studyname,v_cur_rec(i).siteid,v_cur_rec(i).sipsiteid,v_cur_rec(i).sitename,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_documentid,v_orgidlist(j),ip_sipeventid,gv_eventtype_userdoc);
          END LOOP;

  END LOOP;
  CLOSE cur_rec; 

  OPEN op_userdoc FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));

END SP_SET_USERDOC_INT;

PROCEDURE SP_SET_1572_INT
(
ip_documentid     IN TBL_DOCUMENTS.documentid%TYPE,
ip_sipeventid     IN TBL_SIP_EVENT.sipeventid%TYPE,
op_1572doc        OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT DISTINCT td.documentid,td.url,ts.studyid,ts.sipstudyid,ts.studyname,
              tsi.siteid,tsi.sipsiteid,tsi.sitename,tor.orgid,tor.orgcd orgcode
       FROM TBL_DOCUMENTS td, 
            TBL_STUDY ts,
            TBL_SITE tsi,
            TBL_PROGRAM tp, 
            TBL_ORGANIZATION tor
       WHERE td.siteid = tsi.siteid
       AND ts.studyid = tsi.studyid
       AND tsi.isactive = 'Y'
       AND ts.progid = tp.progid
       AND tp.orgid = tor.orgid
       AND td.islatest = 'Y'
       AND td.documentid = ip_documentid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;
BEGIN

  --1572 Document Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEG
                (integid,documentid,url,studyid,sipstudyid,studyname,siteid,sipsiteid,sitename,
                 orgid,orgcode,sipeventid,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integ.NEXTVAL,v_cur_rec(i).documentid,v_cur_rec(i).url,
                 v_cur_rec(i).studyid,v_cur_rec(i).sipstudyid,v_cur_rec(i).studyname,
                 v_cur_rec(i).siteid,v_cur_rec(i).sipsiteid,v_cur_rec(i).sitename,
                 v_cur_rec(i).orgid,v_cur_rec(i).orgcode,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_documentid,v_orgidlist(j),ip_sipeventid,gv_eventtype_1572);
          END LOOP;

  END LOOP;
  CLOSE cur_rec; 

  OPEN op_1572doc FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));

END SP_SET_1572_INT;

PROCEDURE SP_SET_MEDICAL_LICENSE_INT
(
ip_iruserlicensedocumentmapid    IN TBL_IRUSERLICENSEDOCUMENTMAP.iruserlicensedocumentmapid%TYPE,
ip_sipeventid                    IN TBL_SIP_EVENT.sipeventid%TYPE,
op_medlic                        OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT DISTINCT tu.sipuserid,tu.transcelerateuserid,tiru.irid useririd,tu.firstname,tu.middlename,tu.lastname,
       tld.typeoflicense type_of_license,tld.licence_issuer license_issuer,tld.licensenumber,
       tld.issue_date,tld.licenseexpirydate expirydate,tc.countryname,tc.countrycd,tst.statename,tst.statecd,
       tor.orgid,tor.orgcd orgcode
       FROM TBL_IRUSERLICENSEDOCUMENTMAP tld
            JOIN TBL_USERPROFILES tu
            ON (tld.transcelerateuserid = tu.transcelerateuserid)
            LEFT JOIN TBL_IRUSERMAP tiru
            ON (tu.transcelerateuserid = tiru.transcelerateuserid)
            LEFT JOIN TBL_USERROLEMAP turm
            ON (tu.userid = turm.userid)
            LEFT JOIN TBL_SITE tsi
            ON (turm.siteid = tsi.siteid)
            LEFT JOIN TBL_STUDY ts
            ON (tsi.studyid = ts.studyid)
            LEFT JOIN TBL_COUNTRIES tc
            ON (tld.countrycode = tc.countrycd)
            LEFT JOIN TBL_STATES tst
            ON (tld.statecode = tst.statecd)
            LEFT JOIN TBL_ORGANIZATION tor
            ON (ts.orgid = tor.orgid)
       WHERE tld.iruserlicensedocumentmapid = ip_iruserlicensedocumentmapid
       AND tsi.isactive = 'Y';

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;
BEGIN
  --Medical License Document Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEG
                (integid,sipuserid,transcelerateuserid,useririd,firstname,middlename,lastname,
                 type_of_license,license_issuer,licensenumber,issue_date,expirydate,
                 countryname,countrycd,statename,statecd,orgid,orgcode,
                 sipeventid,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integ.NEXTVAL,v_cur_rec(i).sipuserid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).useririd,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,
                 v_cur_rec(i).type_of_license,v_cur_rec(i).license_issuer,v_cur_rec(i).licensenumber,v_cur_rec(i).issue_date,v_cur_rec(i).expirydate,
                 v_cur_rec(i).countryname,v_cur_rec(i).countrycd,v_cur_rec(i).statename,v_cur_rec(i).statecd,
                 v_cur_rec(i).orgid,v_cur_rec(i).orgcode,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_iruserlicensedocumentmapid,v_orgidlist(j),ip_sipeventid,gv_eventtype_medlic);
          END LOOP;

  END LOOP;
  CLOSE cur_rec; 
  
  OPEN op_medlic FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));

END SP_SET_MEDICAL_LICENSE_INT;

PROCEDURE SP_SET_SPONSOR_INT
(
ip_transcelerateuserid IN TBL_USERPROFILES.transcelerateuserid%TYPE,
ip_sipeventid          IN TBL_SIP_EVENT.sipeventid%TYPE,
op_sponsor             OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

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
               tor.orgid,tor.orgcd orgcode
        FROM TBL_USERPROFILES tu,
             TBL_CONTACT tcu,
             TBL_ORGANIZATION tor
        WHERE tu.contactid = tcu.contactid(+)
        AND tu.orgid = tor.orgid
        AND tu.transcelerateuserid = ip_transcelerateuserid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

BEGIN
    --Sponsor User Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEG
                (integid,userid,transcelerateuserid,sipuserid,prefix,title,firstname,middlename,lastname,
                 suffix,initials,isactive,timezoneid,user_contactid,user_contacttype,user_addresstype,
                 user_address1,user_address2,user_address3,user_city,user_statename,user_statecd,user_countryname,
                 user_countrycd,user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,orgid,orgcode,
                 sipeventid,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integ.NEXTVAL,v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).sipuserid,v_cur_rec(i).prefix,v_cur_rec(i).title,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,
                 v_cur_rec(i).suffix,v_cur_rec(i).initials,v_cur_rec(i).isactive,v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,
                 v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,v_cur_rec(i).user_address3,v_cur_rec(i).user_city,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,
                 v_cur_rec(i).user_countrycd,v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,v_cur_rec(i).user_email,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,
                 ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_transcelerateuserid,v_orgidlist(j),ip_sipeventid,gv_eventtype_sponsor);
          END LOOP;

  END LOOP;
  CLOSE cur_rec; 
      
  OPEN op_sponsor FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));
    
END SP_SET_SPONSOR_INT;

PROCEDURE SP_SET_SPONSOR_DEACT_INT
(
ip_userid              IN TBL_USERPROFILES.userid%TYPE,
ip_studyid             IN TBL_STUDY.studyid%TYPE,
ip_siteid              IN TBL_SITE.siteid%TYPE,
ip_sipeventid          IN TBL_SIP_EVENT.sipeventid%TYPE,
op_sponsor             OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

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
               tor.orgid,tor.orgcd orgcode,
               NULL studyid,
               NULL studyname,
               NULL siteid,
               NULL sitename
        FROM TBL_USERPROFILES tu,
             TBL_CONTACT tcu,
             TBL_ORGANIZATION tor
        WHERE tu.contactid = tcu.contactid(+)
        AND tu.orgid = tor.orgid
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
               tor.orgid,tor.orgcd orgcode,
               tsd.studyid,
               tsd.studyname,
               NULL siteid,
               NULL sitename
        FROM TBL_USERPROFILES tu,
             TBL_CONTACT tcu,
             TBL_ORGANIZATION tor,
             TBL_USERROLEMAP turm,
             TBL_STUDY tsd
        WHERE tu.contactid = tcu.contactid(+)
        AND tu.orgid = tor.orgid
        AND tu.userid = turm.userid
        AND turm.siteid IS NULL
        AND turm.studyid = tsd.studyid 
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
             tor.orgid,tor.orgcd orgcode,
             tsd.studyid,
             tsd.studyname,
             ts.siteid,
             ts.sitename
      FROM TBL_USERPROFILES tu,
           TBL_CONTACT tcu,
           TBL_ORGANIZATION tor,
           TBL_USERROLEMAP turm,
           TBL_STUDY tsd,
           TBL_SITE ts
      WHERE tu.contactid = tcu.contactid(+)
      AND tu.orgid = tor.orgid
      AND tu.userid = turm.userid
      AND turm.siteid IS NULL
      AND turm.studyid = tsd.studyid 
      AND tsd.studyid = ts.studyid
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
               INSERT INTO TBL_INTEG
                     (integid,userid,transcelerateuserid,sipuserid,prefix,title,firstname,middlename,lastname,
                      suffix,initials,isactive,timezoneid,user_contactid,user_contacttype,user_addresstype,
                      user_address1,user_address2,user_address3,user_city,user_statename,user_statecd,user_countryname,
                      user_countrycd,user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,orgid,orgcode,
                      studyid,studyname,siteid,sitename,sipeventid,createdby,createddt,modifiedby,modifieddt)
               VALUES(seq_integ.NEXTVAL,v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).sipuserid,v_cur_rec(i).prefix,v_cur_rec(i).title,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,
                      v_cur_rec(i).suffix,v_cur_rec(i).initials,v_cur_rec(i).isactive,v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,
                      v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,v_cur_rec(i).user_address3,v_cur_rec(i).user_city,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,
                      v_cur_rec(i).user_countrycd,v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,v_cur_rec(i).user_email,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,
                      v_cur_rec(i).studyid,v_cur_rec(i).studyname,v_cur_rec(i).siteid,v_cur_rec(i).sitename,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
               RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;
        
               FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
                   SP_INTEG(v_integidlist(j),ip_userid||'@'||ip_studyid||'@'||ip_siteid,v_orgidlist(j),ip_sipeventid,gv_eventtype_sponsordeact);
               END LOOP;
       
       END LOOP;
       CLOSE cur_rec;        
        
    ELSIF ip_userid IS NOT NULL AND ip_studyid IS NOT NULL AND ip_siteid IS NULL THEN
       OPEN cur_rec1;
       LOOP
           FETCH cur_rec1 BULK COLLECT INTO v_cur_rec1 LIMIT gv_rec_limit;
           EXIT WHEN v_cur_rec1.COUNT = 0;
        
           FORALL i IN v_cur_rec1.FIRST..v_cur_rec1.LAST
               INSERT INTO TBL_INTEG
                     (integid,userid,transcelerateuserid,sipuserid,prefix,title,firstname,middlename,lastname,
                      suffix,initials,isactive,timezoneid,user_contactid,user_contacttype,user_addresstype,
                      user_address1,user_address2,user_address3,user_city,user_statename,user_statecd,user_countryname,
                      user_countrycd,user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,orgid,orgcode,
                      studyid,studyname,siteid,sitename,sipeventid,createdby,createddt,modifiedby,modifieddt)
               VALUES(seq_integ.NEXTVAL,v_cur_rec1(i).userid,v_cur_rec1(i).transcelerateuserid,v_cur_rec1(i).sipuserid,v_cur_rec1(i).prefix,v_cur_rec1(i).title,v_cur_rec1(i).firstname,v_cur_rec1(i).middlename,v_cur_rec1(i).lastname,
                      v_cur_rec1(i).suffix,v_cur_rec1(i).initials,v_cur_rec1(i).isactive,v_cur_rec1(i).timezoneid,v_cur_rec1(i).user_contactid,v_cur_rec1(i).user_contacttype,v_cur_rec1(i).user_addresstype,
                      v_cur_rec1(i).user_address1,v_cur_rec1(i).user_address2,v_cur_rec1(i).user_address3,v_cur_rec1(i).user_city,v_cur_rec1(i).user_statename,v_cur_rec1(i).user_statecd,v_cur_rec1(i).user_countryname,
                      v_cur_rec1(i).user_countrycd,v_cur_rec1(i).user_postalcode,v_cur_rec1(i).user_phone1,v_cur_rec1(i).user_phone1ext,v_cur_rec1(i).user_fax,v_cur_rec1(i).user_email,v_cur_rec1(i).orgid,v_cur_rec1(i).orgcode,
                      v_cur_rec1(i).studyid,v_cur_rec1(i).studyname,v_cur_rec1(i).siteid,v_cur_rec1(i).sitename,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
               RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;
        
               FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
                   SP_INTEG(v_integidlist(j),ip_userid||'@'||ip_studyid||'@'||ip_siteid,v_orgidlist(j),ip_sipeventid,gv_eventtype_sponsordeact);
               END LOOP;
       
       END LOOP;
       CLOSE cur_rec1;    
       
    ELSIF ip_userid IS NOT NULL AND ip_studyid IS NOT NULL AND ip_siteid IS NOT NULL THEN
       OPEN cur_rec2;
       LOOP
           FETCH cur_rec2 BULK COLLECT INTO v_cur_rec2 LIMIT gv_rec_limit;
           EXIT WHEN v_cur_rec2.COUNT = 0;
        
           FORALL i IN v_cur_rec2.FIRST..v_cur_rec2.LAST
               INSERT INTO TBL_INTEG
                     (integid,userid,transcelerateuserid,sipuserid,prefix,title,firstname,middlename,lastname,
                      suffix,initials,isactive,timezoneid,user_contactid,user_contacttype,user_addresstype,
                      user_address1,user_address2,user_address3,user_city,user_statename,user_statecd,user_countryname,
                      user_countrycd,user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,orgid,orgcode,
                      studyid,studyname,siteid,sitename,sipeventid,createdby,createddt,modifiedby,modifieddt)
               VALUES(seq_integ.NEXTVAL,v_cur_rec2(i).userid,v_cur_rec2(i).transcelerateuserid,v_cur_rec2(i).sipuserid,v_cur_rec2(i).prefix,v_cur_rec2(i).title,v_cur_rec2(i).firstname,v_cur_rec2(i).middlename,v_cur_rec2(i).lastname,
                      v_cur_rec2(i).suffix,v_cur_rec2(i).initials,v_cur_rec2(i).isactive,v_cur_rec2(i).timezoneid,v_cur_rec2(i).user_contactid,v_cur_rec2(i).user_contacttype,v_cur_rec2(i).user_addresstype,
                      v_cur_rec2(i).user_address1,v_cur_rec2(i).user_address2,v_cur_rec2(i).user_address3,v_cur_rec2(i).user_city,v_cur_rec2(i).user_statename,v_cur_rec2(i).user_statecd,v_cur_rec2(i).user_countryname,
                      v_cur_rec2(i).user_countrycd,v_cur_rec2(i).user_postalcode,v_cur_rec2(i).user_phone1,v_cur_rec2(i).user_phone1ext,v_cur_rec2(i).user_fax,v_cur_rec2(i).user_email,v_cur_rec2(i).orgid,v_cur_rec2(i).orgcode,
                      v_cur_rec2(i).studyid,v_cur_rec2(i).studyname,v_cur_rec2(i).siteid,v_cur_rec2(i).sitename,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
               RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;
        
               FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
                   SP_INTEG(v_integidlist(j),ip_userid||'@'||ip_studyid||'@'||ip_siteid,v_orgidlist(j),ip_sipeventid,gv_eventtype_sponsordeact);
               END LOOP;
       
       END LOOP;
       CLOSE cur_rec2;        
       
    END IF;
    
    OPEN op_sponsor FOR
         SELECT * FROM TBL_INTEG
         WHERE integid IN (SELECT * FROM TABLE(v_integidlist));
    
END SP_SET_SPONSOR_DEACT_INT;

PROCEDURE SP_SET_USERACCESS_INT
(
ip_userroleid       IN TBL_USERROLEMAP.userroleid%TYPE,
ip_sipeventid       IN TBL_SIP_EVENT.sipeventid%TYPE,
op_useraccess       OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT tr.roleid,tr.rolename,tr.description,turm.effectivestartdate,turm.effectiveenddate,
             turm.rolechangereason,tsd.studyid,tsd.sipstudyid,tsd.studyname,ts.siteid,ts.sipsiteid,ts.sitename,
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
             tu.userid,tu.transcelerateuserid,tu.sipuserid,turm.userroleid,
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
             tor.orgid,tor.orgcd orgcode,tc.compoundid,tc.compoundname,tc.membercompoundcd
      FROM TBL_USERROLEMAP turm,
           TBL_ROLES tr,
           TBL_STUDY tsd,
           TBL_PROGRAM tp,
           TBL_ORGANIZATION tor,
           TBL_COMPOUND tc, 
           TBL_SITE ts,
           TBL_USERPROFILES tu,
           TBL_CONTACT tcu,
           TBL_FACILITIES tf,  
           TBL_CONTACT tcf,
           TBL_FACILITIES tpf, 
           TBL_CONTACT tcd
      WHERE turm.roleid = tr.roleid 
      AND turm.studyid = tsd.studyid
      AND tsd.progid = tp.progid
      AND tp.orgid = tor.orgid
      AND tsd.compoundid = tc.compoundid
      AND turm.siteid = ts.siteid(+)
      AND turm.userid = tu.userid
      AND tu.contactid = tcu.contactid(+)
      AND ts.principalfacilityid = tf.facilityid(+)
      AND tf.contactid = tcf.contactid(+)
      AND tf.facilityfordept = tpf.facilityid(+)
      AND tpf.contactid = tcd.contactid(+)
      AND turm.userroleid = ip_userroleid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

BEGIN
    --User Access Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
         INSERT INTO TBL_INTEG
                (integid,roleid,rolename,description,effectivestartdate,effectiveenddate,rolechangereason,
                 studyid,sipstudyid,studyname,siteid,sipsiteid,sitename,study_countrycd,study_countryname,
                 userid,transcelerateuserid,sipuserid,userroleid,prefix,title,firstname,middlename,lastname,suffix,initials,isactive,
                 timezoneid,user_contactid,user_contacttype,user_addresstype,user_address1,user_address2,
                 user_address3,user_city,user_statename,user_statecd,user_countryname,user_countrycd,
                 user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,facilityid,facilityname,
                 irfacilityid,masterfacilitytypecode,isdepartment,departmentid,departmentname,departmenttypeid,
                 irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,fac_address1,fac_address2,
                 fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,fac_countrycd,fac_postalcode,
                 fac_phone1,fac_phone1ext,fac_fax,fac_email,dept_contactid,dept_contacttype,dept_addresstype,
                 dept_address1,dept_address2,dept_address3,dept_city,dept_statename,dept_statecd,dept_countryname,
                 dept_countrycd,dept_postalcode,dept_phone1,dept_phone1ext,dept_fax,dept_email,orgid,orgcode,
                 compoundid,compoundname,membercompoundcd,sipeventid,createdby,createddt,modifiedby,modifieddt)
         VALUES(seq_integ.NEXTVAL,v_cur_rec(i).roleid,v_cur_rec(i).rolename,v_cur_rec(i).description,v_cur_rec(i).effectivestartdate,v_cur_rec(i).effectiveenddate,v_cur_rec(i).rolechangereason,
                v_cur_rec(i).studyid,v_cur_rec(i).sipstudyid,v_cur_rec(i).studyname,v_cur_rec(i).siteid,v_cur_rec(i).sipsiteid,v_cur_rec(i).sitename,v_cur_rec(i).study_countrycd,v_cur_rec(i).study_countryname,v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).sipuserid,v_cur_rec(i).userroleid,
                v_cur_rec(i).prefix,v_cur_rec(i).title,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,v_cur_rec(i).suffix,v_cur_rec(i).initials,v_cur_rec(i).isactive,
                v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,
                v_cur_rec(i).user_address3,v_cur_rec(i).user_city,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,v_cur_rec(i).user_countrycd,
                v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,v_cur_rec(i).user_email,v_cur_rec(i).facilityid,v_cur_rec(i).facilityname,
                v_cur_rec(i).irfacilityid,v_cur_rec(i).masterfacilitytypecode,v_cur_rec(i).isdepartment,v_cur_rec(i).departmentid,v_cur_rec(i).departmentname,v_cur_rec(i).departmenttypeid,
                v_cur_rec(i).irdepartmentid,v_cur_rec(i).fac_contactid,v_cur_rec(i).fac_contacttype,v_cur_rec(i).fac_addresstype,v_cur_rec(i).fac_address1,v_cur_rec(i).fac_address2,
                v_cur_rec(i).fac_address3,v_cur_rec(i).fac_city,v_cur_rec(i).fac_statename,v_cur_rec(i).fac_statecd,v_cur_rec(i).fac_countryname,v_cur_rec(i).fac_countrycd,v_cur_rec(i).fac_postalcode,
                v_cur_rec(i).fac_phone1,v_cur_rec(i).fac_phone1ext,v_cur_rec(i).fac_fax,v_cur_rec(i).fac_email,v_cur_rec(i).dept_contactid,v_cur_rec(i).dept_contacttype,v_cur_rec(i).dept_addresstype,
                v_cur_rec(i).dept_address1,v_cur_rec(i).dept_address2,v_cur_rec(i).dept_address3,v_cur_rec(i).dept_city,v_cur_rec(i).dept_statename,v_cur_rec(i).dept_statecd,v_cur_rec(i).dept_countryname,
                v_cur_rec(i).dept_countrycd,v_cur_rec(i).dept_postalcode,v_cur_rec(i).dept_phone1,v_cur_rec(i).dept_phone1ext,v_cur_rec(i).dept_fax,v_cur_rec(i).dept_email,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,
                v_cur_rec(i).compoundid,v_cur_rec(i).compoundname,v_cur_rec(i).membercompoundcd,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
         RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_userroleid,v_orgidlist(j),ip_sipeventid,gv_eventtype_useraccess);
          END LOOP;

  END LOOP;
  CLOSE cur_rec;
  
  --Make entry into TBL_USERROLE_EXTSYS_MAP for USERROLEID and External System ID Mapping
  SP_USERROLE_EXTSYS(ip_userroleid,ip_sipeventid);

  OPEN op_useraccess FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));

END SP_SET_USERACCESS_INT;

PROCEDURE SP_SET_SPONSOR_USERACCESS_INT
(
ip_userroleid       IN TBL_USERROLEMAP.userroleid%TYPE,
ip_sipeventid       IN TBL_SIP_EVENT.sipeventid%TYPE,
op_useraccess       OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT tr.roleid,tr.rolename,tr.description,turm.effectivestartdate,turm.effectiveenddate,
             turm.rolechangereason,tsd.studyid,tsd.sipstudyid,tsd.studyname,ts.siteid,ts.sipsiteid,ts.sitename,
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
             tu.userid,tu.transcelerateuserid,tu.sipuserid,turm.userroleid,
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
            tor.orgid,tor.orgcd orgcode,tc.compoundid,tc.compoundname,tc.membercompoundcd
      FROM TBL_USERROLEMAP turm,
           TBL_ROLES tr,
           TBL_STUDY tsd,
           TBL_ORGANIZATION tor,
           TBL_COMPOUND tc, 
           TBL_SITE ts,
           TBL_USERPROFILES tu,
           TBL_CONTACT tcu,
           TBL_FACILITIES tf,  
           TBL_CONTACT tcf,
           TBL_FACILITIES tpf, 
           TBL_CONTACT tcd
      WHERE turm.roleid = tr.roleid 
      AND turm.studyid = tsd.studyid(+)
      AND tu.orgid = tor.orgid
      AND tsd.compoundid = tc.compoundid(+)
      AND turm.siteid = ts.siteid(+)
      AND turm.userid = tu.userid
      AND tu.contactid = tcu.contactid(+)
      AND ts.principalfacilityid = tf.facilityid(+)
      AND tf.contactid = tcf.contactid(+)
      AND tf.facilityfordept = tpf.facilityid(+)
      AND tpf.contactid = tcd.contactid(+)
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
          INSERT INTO TBL_INTEG
                (integid,roleid,rolename,description,effectivestartdate,effectiveenddate,rolechangereason,
                 studyid,sipstudyid,studyname,siteid,sipsiteid,sitename,study_countrycd,study_countryname,
                 userid,transcelerateuserid,sipuserid,userroleid,prefix,title,firstname,middlename,lastname,suffix,initials,isactive,
                 timezoneid,user_contactid,user_contacttype,user_addresstype,user_address1,user_address2,
                 user_address3,user_city,user_statename,user_statecd,user_countryname,user_countrycd,
                 user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,facilityid,facilityname,
                 irfacilityid,masterfacilitytypecode,isdepartment,departmentid,departmentname,departmenttypeid,
                 irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,fac_address1,fac_address2,
                 fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,fac_countrycd,fac_postalcode,
                 fac_phone1,fac_phone1ext,fac_fax,fac_email,dept_contactid,dept_contacttype,dept_addresstype,
                 dept_address1,dept_address2,dept_address3,dept_city,dept_statename,dept_statecd,dept_countryname,
                 dept_countrycd,dept_postalcode,dept_phone1,dept_phone1ext,dept_fax,dept_email,orgid,orgcode,
                  compoundid,compoundname,membercompoundcd,sipeventid,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integ.NEXTVAL,v_cur_rec(i).roleid,v_cur_rec(i).rolename,v_cur_rec(i).description,v_cur_rec(i).effectivestartdate,v_cur_rec(i).effectiveenddate,v_cur_rec(i).rolechangereason,
                 v_cur_rec(i).studyid,v_cur_rec(i).sipstudyid,v_cur_rec(i).studyname,v_cur_rec(i).siteid,v_cur_rec(i).sipsiteid,v_cur_rec(i).sitename,v_cur_rec(i).study_countrycd,v_cur_rec(i).study_countryname,
                 v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).sipuserid,v_cur_rec(i).userroleid,v_cur_rec(i).prefix,v_cur_rec(i).title,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,v_cur_rec(i).suffix,v_cur_rec(i).initials,v_cur_rec(i).isactive,
                 v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,
                 v_cur_rec(i).user_address3,v_cur_rec(i).user_city,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,v_cur_rec(i).user_countrycd,
                 v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,v_cur_rec(i).user_email,v_cur_rec(i).facilityid,v_cur_rec(i).facilityname,
                 v_cur_rec(i).irfacilityid,v_cur_rec(i).masterfacilitytypecode,v_cur_rec(i).isdepartment,v_cur_rec(i).departmentid,v_cur_rec(i).departmentname,v_cur_rec(i).departmenttypeid,
                 v_cur_rec(i).irdepartmentid,v_cur_rec(i).fac_contactid,v_cur_rec(i).fac_contacttype,v_cur_rec(i).fac_addresstype,v_cur_rec(i).fac_address1,v_cur_rec(i).fac_address2,
                 v_cur_rec(i).fac_address3,v_cur_rec(i).fac_city,v_cur_rec(i).fac_statename,v_cur_rec(i).fac_statecd,v_cur_rec(i).fac_countryname,v_cur_rec(i).fac_countrycd,v_cur_rec(i).fac_postalcode,
                 v_cur_rec(i).fac_phone1,v_cur_rec(i).fac_phone1ext,v_cur_rec(i).fac_fax,v_cur_rec(i).fac_email,v_cur_rec(i).dept_contactid,v_cur_rec(i).dept_contacttype,v_cur_rec(i).dept_addresstype,
                 v_cur_rec(i).dept_address1,v_cur_rec(i).dept_address2,v_cur_rec(i).dept_address3,v_cur_rec(i).dept_city,v_cur_rec(i).dept_statename,v_cur_rec(i).dept_statecd,v_cur_rec(i).dept_countryname,
                 v_cur_rec(i).dept_countrycd,v_cur_rec(i).dept_postalcode,v_cur_rec(i).dept_phone1,v_cur_rec(i).dept_phone1ext,v_cur_rec(i).dept_fax,v_cur_rec(i).dept_email,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,
                 v_cur_rec(i).compoundid,v_cur_rec(i).compoundname,v_cur_rec(i).membercompoundcd,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
         RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_userroleid,v_orgidlist(j),ip_sipeventid,gv_eventtype_sponsoraccess);
          END LOOP;

  END LOOP;
  CLOSE cur_rec;
     
  --Make entry into TBL_USERROLE_EXTSYS_MAP for USERROLEID and External System ID Mapping
  SP_USERROLE_EXTSYS(ip_userroleid,ip_sipeventid);
    
  OPEN op_useraccess FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));

END SP_SET_SPONSOR_USERACCESS_INT;

PROCEDURE SP_SET_FACDOC_INT
(
ip_facilitydocmetadataid    IN TBL_FACILITYDOCMETADATA.facilitydocmetadataid%TYPE,
ip_sipeventid               IN TBL_SIP_EVENT.sipeventid%TYPE,
op_facdoc                   OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

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
             tor.orgid, tor.orgcd orgcode, tfdm.facilitydocmetadataid documentid
      FROM TBL_FACILITYDOCMETADATA tfdm,
           TBL_FACILITIES tf,
           TBL_SITE tsi,
           TBL_STUDY ts,
           TBL_CONTACT tcf,
           TBL_FACILITIES tpf,
           TBL_CONTACT tcd,
           TBL_ORGANIZATION tor
      WHERE tfdm.facilityid = tf.facilityid
      AND tf.facilityid = tsi.principalfacilityid
      AND tsi.studyid = ts.studyid
      AND tsi.isactive = 'Y'
      AND ts.orgid = tor.orgid
      AND tf.contactid = tcf.contactid(+)
      AND tf.contactid = tcf.contactid(+)
      AND tf.facilityfordept = tpf.facilityid(+)
      AND tpf.contactid = tcd.contactid(+)
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
          INSERT INTO TBL_INTEG
                 (integid, facilityid, facilityname, irfacilityid, masterfacilitytypecode, isdepartment, departmentid, departmentname, departmenttypeid,           
                  irdepartmentid, fac_contactid, fac_contacttype, fac_addresstype, fac_address1, fac_address2, fac_address3, fac_city, fac_statename, fac_statecd,                
                  fac_countryname, fac_countrycd, fac_postalcode, fac_phone1, fac_phone1ext, fac_fax, fac_email, dept_contactid, dept_contacttype, dept_addresstype,           
                  dept_address1, dept_address2, dept_address3, dept_city, dept_statename, dept_statecd, dept_countryname, dept_countrycd, dept_postalcode,            
                  dept_phone1, dept_phone1ext, dept_fax, dept_email, description, orgid, orgcode, documentid, 
                  sipeventid,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integ.NEXTVAL,v_cur_rec(i).facilityid,v_cur_rec(i).facilityname,v_cur_rec(i).irfacilityid,v_cur_rec(i).masterfacilitytypecode,v_cur_rec(i).isdepartment,v_cur_rec(i).departmentid,v_cur_rec(i).departmentname,v_cur_rec(i).departmenttypeid,          
                 v_cur_rec(i).irdepartmentid,v_cur_rec(i).fac_contactid,v_cur_rec(i).fac_contacttype,v_cur_rec(i).fac_addresstype,v_cur_rec(i).fac_address1,v_cur_rec(i).fac_address2,v_cur_rec(i).fac_address3,v_cur_rec(i).fac_city,v_cur_rec(i).fac_statename,v_cur_rec(i).fac_statecd,               
                 v_cur_rec(i).fac_countryname,v_cur_rec(i).fac_countrycd,v_cur_rec(i).fac_postalcode,v_cur_rec(i).fac_phone1,v_cur_rec(i).fac_phone1ext,v_cur_rec(i).fac_fax,v_cur_rec(i).fac_email,v_cur_rec(i).dept_contactid,v_cur_rec(i).dept_contacttype,v_cur_rec(i).dept_addresstype,          
                 v_cur_rec(i).dept_address1,v_cur_rec(i).dept_address2,v_cur_rec(i).dept_address3,v_cur_rec(i).dept_city,v_cur_rec(i).dept_statename,v_cur_rec(i).dept_statecd,v_cur_rec(i).dept_countryname,v_cur_rec(i).dept_countrycd,v_cur_rec(i).dept_postalcode,           
                 v_cur_rec(i).dept_phone1,v_cur_rec(i).dept_phone1ext,v_cur_rec(i).dept_fax,v_cur_rec(i).dept_email,v_cur_rec(i).description,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,v_cur_rec(i).documentid, 
                 ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_facilitydocmetadataid,v_orgidlist(j),ip_sipeventid,gv_eventtype_facdoc);
          END LOOP;

  END LOOP;
  CLOSE cur_rec;
    
  OPEN op_facdoc FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));
         
END SP_SET_FACDOC_INT;

PROCEDURE SP_SET_USER_TRAINING_INT
(
ip_id           IN TBL_USER_TRAINING_STATUS.id%TYPE,
ip_sipeventid   IN TBL_SIP_EVENT.sipeventid%TYPE,
op_usertrng     OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT tuts.id refid,tuts.course_title coursetitle,
             (SELECT tt.trainingtypename
             FROM TBL_TRAININGTYPE tt
             WHERE tt.trainingtypeid = tuts.training_type_id) trngtype,tuts.completion_date completiondt,
             tuts.course_id courseid,tuts.category,tuts.trngprovidername,tuts.requirement_type,tuts.due_date,tuts.expirydate,tuts.course_status,tuts.assigneddate,
             ts.studyid,ts.studyname,ts.sipstudyid,tsi.sipsiteid,tsi.siteid,tsi.sitename,tsi.isaffiliated,
             tsi.piid,tsi.principalfacilityid,tu.userid,tu.transcelerateuserid,tiru.irid useririd,tu.sipuserid,
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
             id documentid, tor.orgid, tor.orgcd orgcode
      FROM TBL_USER_TRAINING_STATUS tuts,
           TBL_STUDY ts,
           TBL_SITE tsi,
           TBL_USERPROFILES tu,
           TBL_IRUSERMAP tiru,
           TBL_CONTACT tcu,
           TBL_ORGANIZATION tor
      WHERE tuts.study_id = ts.studyid
      AND tuts.site_id = tsi.siteid
      AND ts.studyid = tsi.studyid
      AND tsi.isactive = 'Y'
      AND tuts.user_id = tu.userid
      AND tu.transcelerateuserid = tiru.transcelerateuserid(+)
      AND tu.contactid = tcu.contactid(+)
      AND ts.orgid = tor.orgid
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
          INSERT INTO TBL_INTEG
                 (integid,refid,coursetitle,trngtype,completiondt,
                  courseid,category,trngprovidername,requirement_type,due_date,expirydate,course_status,assigneddate,
                  studyid,studyname,sipstudyid,sipsiteid,siteid,sitename,isaffiliated,piid,principalfacilityid,
                  userid,transcelerateuserid,useririd,sipuserid,prefix,title,firstname,middlename,lastname,suffix,
                  initials,isactive,timezoneid,user_contactid,user_contacttype,user_addresstype,user_address1,user_address2,user_address3,
                  user_city,user_statename,user_statecd,user_countryname,user_countrycd,user_postalcode,user_phone1,user_phone1ext,user_fax,
                  user_email,documentid,orgid,orgcode,sipeventid,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integ.NEXTVAL,v_cur_rec(i).refid,v_cur_rec(i).coursetitle,v_cur_rec(i).trngtype,v_cur_rec(i).completiondt,
                 v_cur_rec(i).courseid,v_cur_rec(i).category,v_cur_rec(i).trngprovidername,v_cur_rec(i).requirement_type,v_cur_rec(i).due_date,v_cur_rec(i).expirydate,v_cur_rec(i).course_status,v_cur_rec(i).assigneddate,
                 v_cur_rec(i).studyid,v_cur_rec(i).studyname,v_cur_rec(i).sipstudyid,v_cur_rec(i).sipsiteid,v_cur_rec(i).siteid,v_cur_rec(i).sitename,v_cur_rec(i).isaffiliated,v_cur_rec(i).piid,v_cur_rec(i).principalfacilityid,
                 v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).useririd,v_cur_rec(i).sipuserid,v_cur_rec(i).prefix,v_cur_rec(i).title,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,v_cur_rec(i).suffix,
                 v_cur_rec(i).initials,v_cur_rec(i).isactive,v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,v_cur_rec(i).user_address3,
                 v_cur_rec(i).user_city,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,v_cur_rec(i).user_countrycd,v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,
                 v_cur_rec(i).user_email,v_cur_rec(i).documentid,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_id,v_orgidlist(j),ip_sipeventid,gv_eventtype_usertrng);
          END LOOP;

  END LOOP;
  CLOSE cur_rec;
    
  OPEN op_usertrng FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));
       
END SP_SET_USER_TRAINING_INT;

PROCEDURE SP_SET_USERACCESS_ACT_INT
IS
v_sipevent_siteuser     TBL_SIP_EVENT.eventname%TYPE := 'add-user-to-site-outbound';
v_sipevent_sponsor      TBL_SIP_EVENT.eventname%TYPE := 'add-sponsor-role-outbound';
v_sipeventid            TBL_SIP_EVENT.sipeventid%TYPE;
v_useraccess            SYS_REFCURSOR;

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
             SELECT sipeventid INTO v_sipeventid FROM TBL_SIP_EVENT where eventname = v_sipevent_sponsor;
             SP_SET_SPONSOR_USERACCESS_INT(v_cur_rec(i).userroleid,v_sipeventid,v_useraccess);
          ELSE
             SELECT sipeventid INTO v_sipeventid FROM TBL_SIP_EVENT where eventname = v_sipevent_siteuser;
             SP_SET_USERACCESS_INT(v_cur_rec(i).userroleid,v_sipeventid,v_useraccess);
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
v_sipevent_siteuser     TBL_SIP_EVENT.eventname%TYPE := 'remove-user-from-site-outbound';
v_sipevent_sponsor      TBL_SIP_EVENT.eventname%TYPE := 'remove-sponsor-role-outbound';
v_sipeventid            TBL_SIP_EVENT.sipeventid%TYPE;
v_useraccess            SYS_REFCURSOR;

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
             SELECT sipeventid INTO v_sipeventid FROM TBL_SIP_EVENT where eventname = v_sipevent_sponsor;
             SP_SET_SPONSOR_USERACCESS_INT(v_cur_rec(i).userroleid,v_sipeventid,v_useraccess);
          ELSE
             SELECT sipeventid INTO v_sipeventid FROM TBL_SIP_EVENT where eventname = v_sipevent_siteuser;
             SP_SET_USERACCESS_INT(v_cur_rec(i).userroleid,v_sipeventid,v_useraccess);
          END IF;
    
          --Mark Deactivation Integrated as 'Y'
          UPDATE TBL_USERROLEMAP turm
          SET turm.deact_isintegrated = 'Y'
          WHERE turm.userroleid = v_cur_rec(i).userroleid;
      END LOOP;
  END LOOP;
  CLOSE cur_rec;
  
END SP_SET_USERACCESS_DEACT_INT;

PROCEDURE SP_SET_SITECONTACT_INT
(
ip_sitecontactid IN TBL_SITECONTACTMAP.sitecontactid%TYPE,
ip_sipeventid    IN TBL_SIP_EVENT.sipeventid%TYPE,
op_sitecontact   OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT tscm.sitecontactid refid,ts.studyid,ts.sipstudyid,ts.studyname,tsi.siteid,tsi.sipsiteid,tsi.sitename,
             tscm.firstname,tscm.lastname,
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
             tcf.contactid fac_contactid,
             tscm.sipsitecontactid,
             tscm.startdate effectivestartdate,
             tscm.enddate effectiveenddate,
             tscm.contacttype fac_contacttype,
             tcf.addresstype fac_addresstype,
             tcf.address1 fac_address1,
             tcf.address2 fac_address2,
             tcf.address3 fac_address3,
             tcf.city fac_city,
            (SELECT tst.statename
             FROM TBL_STATES tst, TBL_COUNTRIES tcnt
             WHERE tst.countryid = tcnt.countryid
             AND tcnt.countrycd = tcf.countrycd
             AND tst.statecd = tcf.state) fac_statename,
             tcf.state fac_statecd,
            (SELECT tcnt.countryname 
             FROM TBL_COUNTRIES tcnt
             WHERE tcnt.countrycd = tcf.countrycd) fac_countryname,
             tcf.countrycd fac_countrycd,
             tcf.postalcode fac_postalcode,
             tcf.phone1 fac_phone1,
             tcf.phone1ext fac_phone1ext,
             tcf.fax fac_fax,
             tcf.email fac_email,
             tscm.isactive,ts.orgid,tor.orgcd orgcode
       FROM TBL_SITECONTACTMAP tscm,
            TBL_SITE tsi,
            TBL_STUDY ts,
            TBL_FACILITIES tf,
            TBL_CONTACT tcf,
            TBL_FACILITIES tpf, 
            TBL_ORGANIZATION tor
       WHERE tscm.siteid = tsi.siteid
       AND tsi.studyid = ts.studyid
       AND tscm.facilityid = tf.facilityid(+)
       AND tscm.contactid = tcf.contactid(+)
       AND tf.facilityfordept = tpf.facilityid(+)
       AND ts.orgid = tor.orgid
       AND tscm.sitecontactid = ip_sitecontactid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

CURSOR cur_loccon IS
       SELECT tscm.sitecontactid refid,ts.studyid,sipstudyid,ts.studyname,tsi.siteid,tsi.sipsiteid,tsi.sitename,
             tscm.firstname,tscm.lastname,
             tscm.facilityid,
             NULL facilityname,
             NULL irfacilityid,
             NULL masterfacilitytypecode,
             NULL isdepartment,
             NULL departmentid,
             NULL departmentname,
             NULL departmenttypeid,
             NULL irdepartmentid,
             tscm.contactid fac_contactid,
             tscm.sipsitecontactid,
             tscm.startdate effectivestartdate,
             tscm.enddate effectiveenddate,
             tscm.contacttype fac_contacttype,
             tcf.addresstype fac_addresstype,
             tcf.address1 fac_address1,
             tcf.address2 fac_address2,
             tcf.address3 fac_address3,
             tcf.city fac_city,
             (SELECT tst.statename
              FROM TBL_STATES tst, TBL_COUNTRIES tcnt
              WHERE tst.countryid = tcnt.countryid
              AND tcnt.countrycd = tcf.countrycd
              AND tst.statecd = tcf.state) fac_statename,
             tcf.state fac_statecd,
             (SELECT tcnt.countryname 
              FROM TBL_COUNTRIES tcnt
              WHERE tcnt.countrycd = tcf.countrycd) fac_countryname,
             tcf.countrycd fac_countrycd,
             tcf.postalcode fac_postalcode,
             tcf.phone1 fac_phone1,
             tcf.phone1ext fac_phone1ext,
             tcf.fax fac_fax,
             tcf.email fac_email,
             tscm.isactive,ts.orgid,tor.orgcd orgcode
       FROM TBL_SITECONTACTMAP tscm,
            TBL_SITE tsi,
            TBL_STUDY ts,
            TBL_CONTACT tcf,
            TBL_ORGANIZATION tor
       WHERE tscm.siteid = tsi.siteid
       AND tsi.studyid = ts.studyid
       AND tscm.contactid = tcf.contactid
       AND ts.orgid = tor.orgid
       AND tscm.sitecontactid = ip_sitecontactid;

TYPE typ_cur_loccon IS TABLE OF cur_loccon%ROWTYPE;
v_cur_loccon typ_cur_loccon;

v_facility_exists   PLS_INTEGER:=0;

BEGIN

  --Site Contact Integration
  SELECT COUNT(1) INTO v_facility_exists FROM TBL_SITECONTACTMAP tscm WHERE tscm.sitecontactid = ip_sitecontactid AND tscm.facilityid IS NOT NULL;
  IF v_facility_exists <> 0 THEN
      OPEN cur_rec;
      LOOP
          FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
          EXIT WHEN v_cur_rec.COUNT = 0;
    
          FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
              INSERT INTO TBL_INTEG
                    (integid,refid,studyid,sipstudyid,studyname,siteid,sipsiteid,sitename,firstname,lastname,facilityid,facilityname,irfacilityid,masterfacilitytypecode,isdepartment,departmentid,
                     departmentname,departmenttypeid,irdepartmentid,fac_contactid,sipsitecontactid,effectivestartdate,effectiveenddate,fac_contacttype,fac_addresstype,
                     fac_address1,fac_address2,fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,
                     fac_countrycd,fac_postalcode,fac_phone1,fac_phone1ext,fac_fax,fac_email,
                     orgid,orgcode,isactive,sipeventid,createdby,createddt,modifiedby,modifieddt)
              VALUES(seq_integ.NEXTVAL,v_cur_rec(i).refid,v_cur_rec(i).studyid,v_cur_rec(i).sipstudyid,v_cur_rec(i).studyname,v_cur_rec(i).siteid,v_cur_rec(i).sipsiteid,v_cur_rec(i).sitename,
                     v_cur_rec(i).firstname,v_cur_rec(i).lastname,v_cur_rec(i).facilityid,v_cur_rec(i).facilityname,v_cur_rec(i).irfacilityid,v_cur_rec(i).masterfacilitytypecode,v_cur_rec(i).isdepartment,v_cur_rec(i).departmentid,
                     v_cur_rec(i).departmentname,v_cur_rec(i).departmenttypeid,v_cur_rec(i).irdepartmentid,v_cur_rec(i).fac_contactid,
                     v_cur_rec(i).sipsitecontactid,v_cur_rec(i).effectivestartdate,v_cur_rec(i).effectiveenddate,v_cur_rec(i).fac_contacttype,v_cur_rec(i).fac_addresstype,
                     v_cur_rec(i).fac_address1,v_cur_rec(i).fac_address2,v_cur_rec(i).fac_address3,v_cur_rec(i).fac_city,v_cur_rec(i).fac_statename,v_cur_rec(i).fac_statecd,v_cur_rec(i).fac_countryname,
                     v_cur_rec(i).fac_countrycd,v_cur_rec(i).fac_postalcode,v_cur_rec(i).fac_phone1,v_cur_rec(i).fac_phone1ext,v_cur_rec(i).fac_fax,v_cur_rec(i).fac_email,
                     v_cur_rec(i).orgid,v_cur_rec(i).orgcode,v_cur_rec(i).isactive,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
              RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;
    
              FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
                  SP_INTEG(v_integidlist(j),ip_sitecontactid,v_orgidlist(j),ip_sipeventid,gv_eventtype_sitecontact);
              END LOOP;
    
      END LOOP;
      CLOSE cur_rec;
  ELSE
      OPEN cur_loccon;
      LOOP
          FETCH cur_loccon BULK COLLECT INTO v_cur_loccon LIMIT gv_rec_limit;
          EXIT WHEN v_cur_loccon.COUNT = 0;
    
          FORALL i IN v_cur_loccon.FIRST..v_cur_loccon.LAST
              INSERT INTO TBL_INTEG
                    (integid,refid,studyid,sipstudyid,studyname,siteid,sipsiteid,sitename,firstname,lastname,facilityid,facilityname,irfacilityid,masterfacilitytypecode,isdepartment,departmentid,
                     departmentname,departmenttypeid,irdepartmentid,fac_contactid,sipsitecontactid,effectivestartdate,effectiveenddate,fac_contacttype,fac_addresstype,
                     fac_address1,fac_address2,fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,
                     fac_countrycd,fac_postalcode,fac_phone1,fac_phone1ext,fac_fax,fac_email,
                     orgid,orgcode,isactive,sipeventid,createdby,createddt,modifiedby,modifieddt)
              VALUES(seq_integ.NEXTVAL,v_cur_loccon(i).refid,v_cur_loccon(i).studyid,v_cur_loccon(i).sipstudyid,v_cur_loccon(i).studyname,v_cur_loccon(i).siteid,v_cur_loccon(i).sipsiteid,v_cur_loccon(i).sitename,
                     v_cur_loccon(i).firstname,v_cur_loccon(i).lastname,v_cur_loccon(i).facilityid,v_cur_loccon(i).facilityname,v_cur_loccon(i).irfacilityid,v_cur_loccon(i).masterfacilitytypecode,v_cur_loccon(i).isdepartment,v_cur_loccon(i).departmentid,
                     v_cur_loccon(i).departmentname,v_cur_loccon(i).departmenttypeid,v_cur_loccon(i).irdepartmentid,v_cur_loccon(i).fac_contactid,
                     v_cur_loccon(i).sipsitecontactid,v_cur_loccon(i).effectivestartdate,v_cur_loccon(i).effectiveenddate,v_cur_loccon(i).fac_contacttype,v_cur_loccon(i).fac_addresstype,
                     v_cur_loccon(i).fac_address1,v_cur_loccon(i).fac_address2,v_cur_loccon(i).fac_address3,v_cur_loccon(i).fac_city,v_cur_loccon(i).fac_statename,v_cur_loccon(i).fac_statecd,v_cur_loccon(i).fac_countryname,
                     v_cur_loccon(i).fac_countrycd,v_cur_loccon(i).fac_postalcode,v_cur_loccon(i).fac_phone1,v_cur_loccon(i).fac_phone1ext,v_cur_loccon(i).fac_fax,v_cur_loccon(i).fac_email,
                     v_cur_loccon(i).orgid,v_cur_loccon(i).orgcode,v_cur_loccon(i).isactive,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
              RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;
    
              FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
                  SP_INTEG(v_integidlist(j),ip_sitecontactid,v_orgidlist(j),ip_sipeventid,gv_eventtype_sitecontact);
              END LOOP;
    
      END LOOP;
      CLOSE cur_loccon;  
  END IF;
  
  OPEN op_sitecontact FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));
    
END SP_SET_SITECONTACT_INT;

PROCEDURE SP_SET_SITEIRB_INT
(
ip_siteirbid     IN TBL_SITEIRBMAP.siteirbid%TYPE,
ip_sipeventid    IN TBL_SIP_EVENT.sipeventid%TYPE,
op_siteirb       OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT tsirb.siteirbid refid,ts.studyid,ts.sipstudyid,ts.studyname,tsi.siteid,tsi.sipsiteid,tsi.sitename,tsirb.irbtype,tsirb.irbname,
             tsirb.startdate effectivestartdate,tsirb.enddate effectiveenddate,tsirb.meetingfrequency,tsirb.othmtngfreqname,
             tsirb.packsubmission,tsirb.reqpaymentapproval,tsirb.reqbudgetapproval,tsirb.externalcentralirbid,
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
             tcf.contactid fac_contactid,
             tcf.contacttype fac_contacttype,
             tcf.addresstype fac_addresstype,
             tcf.address1 fac_address1,
             tcf.address2 fac_address2,
             tcf.address3 fac_address3,
             tcf.city fac_city,
            (SELECT tst.statename
             FROM TBL_STATES tst, TBL_COUNTRIES tcnt
             WHERE tst.countryid = tcnt.countryid
             AND tcnt.countrycd = tcf.countrycd
             AND tst.statecd = tcf.state) fac_statename,
             tcf.state fac_statecd,
            (SELECT tcnt.countryname 
             FROM TBL_COUNTRIES tcnt
             WHERE tcnt.countrycd = tcf.countrycd) fac_countryname,
             tcf.countrycd fac_countrycd,
             tcf.postalcode fac_postalcode,
             tcf.phone1 fac_phone1,
             tcf.phone1ext fac_phone1ext,
             tcf.fax fac_fax,
             tcf.email fac_email,
             tsirb.status isactive,tor.orgid,tor.orgcd orgcode
          FROM TBL_SITEIRBMAP tsirb,
               TBL_SITE tsi,
               TBL_STUDY ts,
               TBL_FACILITIES tf,
               TBL_CONTACT tcf,
               TBL_FACILITIES tpf, 
               TBL_ORGANIZATION tor
          WHERE tsirb.siteid = tsi.siteid
          AND tsi.studyid = ts.studyid
          AND tsirb.facilityid = tf.facilityid(+)
          AND tsirb.contactid = tcf.contactid(+)
          AND tf.facilityfordept = tpf.facilityid(+)
          AND ts.orgid = tor.orgid
          AND tsirb.siteirbid = ip_siteirbid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

CURSOR cur_locirb IS
       SELECT tsirb.siteirbid refid,ts.studyid,ts.sipstudyid,ts.studyname,tsi.siteid,tsi.sipsiteid,tsi.sitename,tsirb.irbtype,tsirb.irbname,
             tsirb.startdate effectivestartdate,tsirb.enddate effectiveenddate,tsirb.meetingfrequency,tsirb.othmtngfreqname,
             tsirb.packsubmission,tsirb.reqpaymentapproval,tsirb.reqbudgetapproval,tsirb.externalcentralirbid,
             tsirb.facilityid,
             NULL facilityname,
             NULL irfacilityid,
             NULL masterfacilitytypecode,
             NULL isdepartment,
             NULL departmentid,
             NULL departmentname,
             NULL departmenttypeid,
             NULL irdepartmentid,
             tsirb.contactid fac_contactid,
             tcf.contacttype fac_contacttype,
             tcf.addresstype fac_addresstype,
             tcf.address1 fac_address1,
             tcf.address2 fac_address2,
             tcf.address3 fac_address3,
             tcf.city fac_city,
             (SELECT tst.statename
              FROM TBL_STATES tst, TBL_COUNTRIES tcnt
              WHERE tst.countryid = tcnt.countryid
              AND tcnt.countrycd = tcf.countrycd
              AND tst.statecd = tcf.state) fac_statename,
             tcf.state fac_statecd,
             (SELECT tcnt.countryname 
              FROM TBL_COUNTRIES tcnt
              WHERE tcnt.countrycd = tcf.countrycd) fac_countryname,
             tcf.countrycd fac_countrycd,
             tcf.postalcode fac_postalcode,
             tcf.phone1 fac_phone1,
             tcf.phone1ext fac_phone1ext,
             tcf.fax fac_fax,
             tcf.email fac_email,
             tsirb.status isactive,tor.orgid,tor.orgcd orgcode
          FROM TBL_SITEIRBMAP tsirb,
               TBL_SITE tsi,
               TBL_STUDY ts,
               TBL_CONTACT tcf,
               TBL_ORGANIZATION tor
          WHERE tsirb.siteid = tsi.siteid
          AND tsi.studyid = ts.studyid
          AND tsirb.contactid = tcf.contactid(+)
          AND ts.orgid = tor.orgid
          AND tsirb.siteirbid = ip_siteirbid;

TYPE typ_cur_locirb IS TABLE OF cur_locirb%ROWTYPE;
v_cur_locirb typ_cur_locirb;

v_facility_exists   PLS_INTEGER:=0;

BEGIN

  --Site IRB Integration
  SELECT COUNT(1) INTO v_facility_exists FROM TBL_SITEIRBMAP tsirb WHERE tsirb.siteirbid = ip_siteirbid AND tsirb.facilityid IS NOT NULL;
  IF v_facility_exists <> 0 THEN
      OPEN cur_rec;
      LOOP
          FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
          EXIT WHEN v_cur_rec.COUNT = 0;
    
          FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
              INSERT INTO TBL_INTEG
                    (integid,refid,studyid,sipstudyid,studyname,siteid,sipsiteid,sitename,
                     irbtype,irbname,effectivestartdate,effectiveenddate,meetingfrequency,othmtngfreqname,
                     packsubmission,reqpaymentapproval,reqbudgetapproval,externalcentralirbid,
                     facilityid,facilityname,irfacilityid,masterfacilitytypecode,isdepartment,departmentid,
                     departmentname,departmenttypeid,irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,
                     fac_address1,fac_address2,fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,
                     fac_countrycd,fac_postalcode,fac_phone1,fac_phone1ext,fac_fax,fac_email,
                     orgid,orgcode,isactive,sipeventid,createdby,createddt,modifiedby,modifieddt)
              VALUES(seq_integ.NEXTVAL,v_cur_rec(i).refid,v_cur_rec(i).studyid,v_cur_rec(i).sipstudyid,v_cur_rec(i).studyname,v_cur_rec(i).siteid,v_cur_rec(i).sipsiteid,v_cur_rec(i).sitename,
                     v_cur_rec(i).irbtype,v_cur_rec(i).irbname,v_cur_rec(i).effectivestartdate,v_cur_rec(i).effectiveenddate,v_cur_rec(i).meetingfrequency,v_cur_rec(i).othmtngfreqname,
                     v_cur_rec(i).packsubmission,v_cur_rec(i).reqpaymentapproval,v_cur_rec(i).reqbudgetapproval,v_cur_rec(i).externalcentralirbid,
                     v_cur_rec(i).facilityid,v_cur_rec(i).facilityname,v_cur_rec(i).irfacilityid,v_cur_rec(i).masterfacilitytypecode,v_cur_rec(i).isdepartment,v_cur_rec(i).departmentid,
                     v_cur_rec(i).departmentname,v_cur_rec(i).departmenttypeid,v_cur_rec(i).irdepartmentid,v_cur_rec(i).fac_contactid,v_cur_rec(i).fac_contacttype,v_cur_rec(i).fac_addresstype,
                     v_cur_rec(i).fac_address1,v_cur_rec(i).fac_address2,v_cur_rec(i).fac_address3,v_cur_rec(i).fac_city,v_cur_rec(i).fac_statename,v_cur_rec(i).fac_statecd,v_cur_rec(i).fac_countryname,
                     v_cur_rec(i).fac_countrycd,v_cur_rec(i).fac_postalcode,v_cur_rec(i).fac_phone1,v_cur_rec(i).fac_phone1ext,v_cur_rec(i).fac_fax,v_cur_rec(i).fac_email,
                     v_cur_rec(i).orgid,v_cur_rec(i).orgcode,v_cur_rec(i).isactive,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
              RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;
    
              FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
                  SP_INTEG(v_integidlist(j),ip_siteirbid,v_orgidlist(j),ip_sipeventid,gv_eventtype_siteirb);
                  --Populate Registration Number and Body for Integ ID
                  SP_SET_INTEG_MULTIVALUE(v_integidlist(j),ip_siteirbid,NULL,gv_keytype_regnumbody);
              END LOOP;
    
      END LOOP;
      CLOSE cur_rec;
  ELSE
      OPEN cur_locirb;
      LOOP
          FETCH cur_locirb BULK COLLECT INTO v_cur_locirb LIMIT gv_rec_limit;
          EXIT WHEN v_cur_locirb.COUNT = 0;
    
          FORALL i IN v_cur_locirb.FIRST..v_cur_locirb.LAST
              INSERT INTO TBL_INTEG
                    (integid,refid,studyid,sipstudyid,studyname,siteid,sipsiteid,sitename,
                     irbtype,irbname,effectivestartdate,effectiveenddate,meetingfrequency,othmtngfreqname,
                     packsubmission,reqpaymentapproval,reqbudgetapproval,externalcentralirbid,
                     facilityid,facilityname,irfacilityid,masterfacilitytypecode,isdepartment,departmentid,
                     departmentname,departmenttypeid,irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,
                     fac_address1,fac_address2,fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,
                     fac_countrycd,fac_postalcode,fac_phone1,fac_phone1ext,fac_fax,fac_email,
                     orgid,orgcode,isactive,sipeventid,createdby,createddt,modifiedby,modifieddt)
              VALUES(seq_integ.NEXTVAL,v_cur_locirb(i).refid,v_cur_locirb(i).studyid,v_cur_locirb(i).sipstudyid,v_cur_locirb(i).studyname,v_cur_locirb(i).siteid,v_cur_locirb(i).sipsiteid,v_cur_locirb(i).sitename,
                     v_cur_locirb(i).irbtype,v_cur_locirb(i).irbname,v_cur_locirb(i).effectivestartdate,v_cur_locirb(i).effectiveenddate,v_cur_locirb(i).meetingfrequency,v_cur_locirb(i).othmtngfreqname,
                     v_cur_locirb(i).packsubmission,v_cur_locirb(i).reqpaymentapproval,v_cur_locirb(i).reqbudgetapproval,v_cur_locirb(i).externalcentralirbid,
                     v_cur_locirb(i).facilityid,v_cur_locirb(i).facilityname,v_cur_locirb(i).irfacilityid,v_cur_locirb(i).masterfacilitytypecode,v_cur_locirb(i).isdepartment,v_cur_locirb(i).departmentid,
                     v_cur_locirb(i).departmentname,v_cur_locirb(i).departmenttypeid,v_cur_locirb(i).irdepartmentid,v_cur_locirb(i).fac_contactid,v_cur_locirb(i).fac_contacttype,v_cur_locirb(i).fac_addresstype,
                     v_cur_locirb(i).fac_address1,v_cur_locirb(i).fac_address2,v_cur_locirb(i).fac_address3,v_cur_locirb(i).fac_city,v_cur_locirb(i).fac_statename,v_cur_locirb(i).fac_statecd,v_cur_locirb(i).fac_countryname,
                     v_cur_locirb(i).fac_countrycd,v_cur_locirb(i).fac_postalcode,v_cur_locirb(i).fac_phone1,v_cur_locirb(i).fac_phone1ext,v_cur_locirb(i).fac_fax,v_cur_locirb(i).fac_email,
                     v_cur_locirb(i).orgid,v_cur_locirb(i).orgcode,v_cur_locirb(i).isactive,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
              RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;
    
              FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
                  SP_INTEG(v_integidlist(j),ip_siteirbid,v_orgidlist(j),ip_sipeventid,gv_eventtype_siteirb);
                  --Populate Registration Number and Body for Integ ID
                  SP_SET_INTEG_MULTIVALUE(v_integidlist(j),ip_siteirbid,NULL,gv_keytype_regnumbody);
              END LOOP;
    
      END LOOP;
      CLOSE cur_locirb;  
  END IF;
    
  OPEN op_siteirb FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));
    
END SP_SET_SITEIRB_INT;

PROCEDURE SP_SET_SITELAB_INT
(
ip_sitelabid     IN TBL_SITELABMAP.sitelabid%TYPE,
ip_sipeventid    IN TBL_SIP_EVENT.sipeventid%TYPE,
op_sitelab       OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT tslab.sitelabid refid,ts.studyid,ts.sipstudyid,ts.studyname,tsi.siteid,tsi.sipsiteid,tsi.sitename,tslab.labtype,tslab.labname,
             tslab.startdate effectivestartdate,tslab.enddate effectiveenddate,tslab.externalcentrallabid,
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
             tcf.contactid fac_contactid,
             tcf.contacttype fac_contacttype,
             tcf.addresstype fac_addresstype,
             tcf.address1 fac_address1,
             tcf.address2 fac_address2,
             tcf.address3 fac_address3,
             tcf.city fac_city,
            (SELECT tst.statename
             FROM TBL_STATES tst, TBL_COUNTRIES tcnt
             WHERE tst.countryid = tcnt.countryid
             AND tcnt.countrycd = tcf.countrycd
             AND tst.statecd = tcf.state) fac_statename,
             tcf.state fac_statecd,
            (SELECT tcnt.countryname 
             FROM TBL_COUNTRIES tcnt
             WHERE tcnt.countrycd = tcf.countrycd) fac_countryname,
             tcf.countrycd fac_countrycd,
             tcf.postalcode fac_postalcode,
             tcf.phone1 fac_phone1,
             tcf.phone1ext fac_phone1ext,
             tcf.fax fac_fax,
             tcf.email fac_email,
             tslab.status isactive,tor.orgid,tor.orgcd orgcode
          FROM TBL_SITELABMAP tslab,
               TBL_SITE tsi,
               TBL_STUDY ts,
               TBL_FACILITIES tf,
               TBL_CONTACT tcf,
               TBL_FACILITIES tpf, 
               TBL_ORGANIZATION tor
          WHERE tslab.siteid = tsi.siteid
          AND tsi.studyid = ts.studyid
          AND tslab.facilityid = tf.facilityid(+)
          AND tslab.contactid = tcf.contactid(+)
          AND tf.facilityfordept = tpf.facilityid(+)
          AND ts.orgid = tor.orgid
          AND tslab.sitelabid = ip_sitelabid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

CURSOR cur_loclab IS
       SELECT tslab.sitelabid refid,ts.studyid,ts.sipstudyid,ts.studyname,tsi.siteid,tsi.sipsiteid,tsi.sitename,tslab.labtype,tslab.labname,
             tslab.startdate effectivestartdate,tslab.enddate effectiveenddate,tslab.externalcentrallabid,
             tslab.facilityid,
             NULL facilityname,
             NULL irfacilityid,
             NULL masterfacilitytypecode,
             NULL isdepartment,
             NULL departmentid,
             NULL departmentname,
             NULL departmenttypeid,
             NULL irdepartmentid,
             tslab.contactid fac_contactid,
             tcf.contacttype fac_contacttype,
             tcf.addresstype fac_addresstype,
             tcf.address1 fac_address1,
             tcf.address2 fac_address2,
             tcf.address3 fac_address3,
             tcf.city fac_city,
             (SELECT tst.statename
              FROM TBL_STATES tst, TBL_COUNTRIES tcnt
              WHERE tst.countryid = tcnt.countryid
              AND tcnt.countrycd = tcf.countrycd
              AND tst.statecd = tcf.state) fac_statename,
             tcf.state fac_statecd,
             (SELECT tcnt.countryname 
              FROM TBL_COUNTRIES tcnt
              WHERE tcnt.countrycd = tcf.countrycd) fac_countryname,
             tcf.countrycd fac_countrycd,
             tcf.postalcode fac_postalcode,
             tcf.phone1 fac_phone1,
             tcf.phone1ext fac_phone1ext,
             tcf.fax fac_fax,
             tcf.email fac_email,
             tslab.status isactive,tor.orgid,tor.orgcd orgcode
          FROM TBL_SITELABMAP tslab,
               TBL_SITE tsi,
               TBL_STUDY ts,
               TBL_CONTACT tcf,
               TBL_ORGANIZATION tor
          WHERE tslab.siteid = tsi.siteid
          AND tsi.studyid = ts.studyid
          AND tslab.contactid = tcf.contactid(+)
          AND ts.orgid = tor.orgid
          AND tslab.sitelabid = ip_sitelabid;

TYPE typ_cur_loclab IS TABLE OF cur_loclab%ROWTYPE;
v_cur_loclab typ_cur_loclab;

v_facility_exists   PLS_INTEGER:=0;

BEGIN

  --Site LAB Integration
  SELECT COUNT(1) INTO v_facility_exists FROM TBL_SITELABMAP tslab WHERE tslab.sitelabid = ip_sitelabid AND tslab.facilityid IS NOT NULL;
  IF v_facility_exists <> 0 THEN
      OPEN cur_rec;
      LOOP
          FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
          EXIT WHEN v_cur_rec.COUNT = 0;
    
          FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
              INSERT INTO TBL_INTEG
                    (integid,refid,studyid,sipstudyid,studyname,siteid,sipsiteid,sitename,
                     labtype,labname,effectivestartdate,effectiveenddate,externalcentrallabid,
                     facilityid,facilityname,irfacilityid,masterfacilitytypecode,isdepartment,departmentid,
                     departmentname,departmenttypeid,irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,
                     fac_address1,fac_address2,fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,
                     fac_countrycd,fac_postalcode,fac_phone1,fac_phone1ext,fac_fax,fac_email,
                     orgid,orgcode,isactive,sipeventid,createdby,createddt,modifiedby,modifieddt)
              VALUES(seq_integ.NEXTVAL,v_cur_rec(i).refid,v_cur_rec(i).studyid,v_cur_rec(i).sipstudyid,v_cur_rec(i).studyname,v_cur_rec(i).siteid,v_cur_rec(i).sipsiteid,v_cur_rec(i).sitename,
                     v_cur_rec(i).labtype,v_cur_rec(i).labname,v_cur_rec(i).effectivestartdate,v_cur_rec(i).effectiveenddate,v_cur_rec(i).externalcentrallabid,
                     v_cur_rec(i).facilityid,v_cur_rec(i).facilityname,v_cur_rec(i).irfacilityid,v_cur_rec(i).masterfacilitytypecode,v_cur_rec(i).isdepartment,v_cur_rec(i).departmentid,
                     v_cur_rec(i).departmentname,v_cur_rec(i).departmenttypeid,v_cur_rec(i).irdepartmentid,v_cur_rec(i).fac_contactid,v_cur_rec(i).fac_contacttype,v_cur_rec(i).fac_addresstype,
                     v_cur_rec(i).fac_address1,v_cur_rec(i).fac_address2,v_cur_rec(i).fac_address3,v_cur_rec(i).fac_city,v_cur_rec(i).fac_statename,v_cur_rec(i).fac_statecd,v_cur_rec(i).fac_countryname,
                     v_cur_rec(i).fac_countrycd,v_cur_rec(i).fac_postalcode,v_cur_rec(i).fac_phone1,v_cur_rec(i).fac_phone1ext,v_cur_rec(i).fac_fax,v_cur_rec(i).fac_email,
                     v_cur_rec(i).orgid,v_cur_rec(i).orgcode,v_cur_rec(i).isactive,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
              RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;
    
              FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
                  SP_INTEG(v_integidlist(j),ip_sitelabid,v_orgidlist(j),ip_sipeventid,gv_eventtype_sitelab);
                  --Populate LAB Accreditation for Integ ID
                  SP_SET_INTEG_MULTIVALUE(v_integidlist(j),ip_sitelabid,NULL,gv_keytype_accreditation);
              END LOOP;
    
      END LOOP;
      CLOSE cur_rec;
  ELSE
     OPEN cur_loclab;
      LOOP
          FETCH cur_loclab BULK COLLECT INTO v_cur_loclab LIMIT gv_rec_limit;
          EXIT WHEN v_cur_loclab.COUNT = 0;
    
          FORALL i IN v_cur_loclab.FIRST..v_cur_loclab.LAST
              INSERT INTO TBL_INTEG
                    (integid,refid,studyid,sipstudyid,studyname,siteid,sipsiteid,sitename,
                     labtype,labname,effectivestartdate,effectiveenddate,externalcentrallabid,
                     facilityid,facilityname,irfacilityid,masterfacilitytypecode,isdepartment,departmentid,
                     departmentname,departmenttypeid,irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,
                     fac_address1,fac_address2,fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,
                     fac_countrycd,fac_postalcode,fac_phone1,fac_phone1ext,fac_fax,fac_email,
                     orgid,orgcode,isactive,sipeventid,createdby,createddt,modifiedby,modifieddt)
              VALUES(seq_integ.NEXTVAL,v_cur_loclab(i).refid,v_cur_loclab(i).studyid,v_cur_loclab(i).sipstudyid,v_cur_loclab(i).studyname,v_cur_loclab(i).siteid,v_cur_loclab(i).sipsiteid,v_cur_loclab(i).sitename,
                     v_cur_loclab(i).labtype,v_cur_loclab(i).labname,v_cur_loclab(i).effectivestartdate,v_cur_loclab(i).effectiveenddate,v_cur_loclab(i).externalcentrallabid,
                     v_cur_loclab(i).facilityid,v_cur_loclab(i).facilityname,v_cur_loclab(i).irfacilityid,v_cur_loclab(i).masterfacilitytypecode,v_cur_loclab(i).isdepartment,v_cur_loclab(i).departmentid,
                     v_cur_loclab(i).departmentname,v_cur_loclab(i).departmenttypeid,v_cur_loclab(i).irdepartmentid,v_cur_loclab(i).fac_contactid,v_cur_loclab(i).fac_contacttype,v_cur_loclab(i).fac_addresstype,
                     v_cur_loclab(i).fac_address1,v_cur_loclab(i).fac_address2,v_cur_loclab(i).fac_address3,v_cur_loclab(i).fac_city,v_cur_loclab(i).fac_statename,v_cur_loclab(i).fac_statecd,v_cur_loclab(i).fac_countryname,
                     v_cur_loclab(i).fac_countrycd,v_cur_loclab(i).fac_postalcode,v_cur_loclab(i).fac_phone1,v_cur_loclab(i).fac_phone1ext,v_cur_loclab(i).fac_fax,v_cur_loclab(i).fac_email,
                     v_cur_loclab(i).orgid,v_cur_loclab(i).orgcode,v_cur_loclab(i).isactive,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
              RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;
    
              FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
                  SP_INTEG(v_integidlist(j),ip_sitelabid,v_orgidlist(j),ip_sipeventid,gv_eventtype_sitelab);
                  --Populate LAB Accreditation for Integ ID
                  SP_SET_INTEG_MULTIVALUE(v_integidlist(j),ip_sitelabid,NULL,gv_keytype_accreditation);
              END LOOP;
    
      END LOOP;
      CLOSE cur_loclab;
  END IF;

  OPEN op_sitelab FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));

END SP_SET_SITELAB_INT;

PROCEDURE SP_SET_FACILITY_INT
(
ip_facilityid    IN TBL_FACILITIES.facilityid%TYPE,
ip_sipeventid    IN TBL_SIP_EVENT.sipeventid%TYPE,
op_facility      OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT DISTINCT ts.sipstudyid,tsi.sipsiteid,
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
             CASE 
                 WHEN tf.isdepartment = 'Y' THEN
                      tpf.sqtfacilitiestype 
                 ELSE tf.sqtfacilitiestype     
             END sqtfacilitiestype,
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
             tor.orgid,tor.orgcd orgcode
          FROM TBL_FACILITIES tf,
               TBL_CONTACT tcf,
               TBL_FACILITIES tpf, 
               TBL_CONTACT tcd,
               TBL_SITE tsi,
               TBL_STUDY ts,
               TBL_ORGANIZATION tor
          WHERE tf.contactid = tcf.contactid(+)
          AND tf.facilityfordept = tpf.facilityid(+)
          AND tpf.contactid = tcd.contactid(+)
          AND tf.facilityid = tsi.principalfacilityid
          AND tsi.studyid = ts.studyid
          AND ts.orgid = tor.orgid
          AND tf.facilityid = ip_facilityid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

BEGIN
    
  --Facility Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEG
                (integid,sipstudyid,sipsiteid,facilityid,facilityname,irfacilityid,masterfacilitytypecode,sqtfacilitiestype,isdepartment,departmentid,
                 departmentname,departmenttypeid,irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,
                 fac_address1,fac_address2,fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,
                 fac_countrycd,fac_postalcode,fac_phone1,fac_phone1ext,fac_fax,fac_email,dept_contactid,
                 dept_contacttype,dept_addresstype,dept_address1,dept_address2,dept_address3,dept_city,dept_statename,
                 dept_statecd,dept_countryname,dept_countrycd,dept_postalcode,dept_phone1,dept_phone1ext,dept_fax,dept_email,
                 orgid,orgcode,sipeventid,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integ.NEXTVAL,v_cur_rec(i).sipstudyid,v_cur_rec(i).sipsiteid,v_cur_rec(i).facilityid,v_cur_rec(i).facilityname,v_cur_rec(i).irfacilityid,v_cur_rec(i).masterfacilitytypecode,v_cur_rec(i).sqtfacilitiestype,v_cur_rec(i).isdepartment,v_cur_rec(i).departmentid,
                 v_cur_rec(i).departmentname,v_cur_rec(i).departmenttypeid,v_cur_rec(i).irdepartmentid,v_cur_rec(i).fac_contactid,v_cur_rec(i).fac_contacttype,v_cur_rec(i).fac_addresstype,
                 v_cur_rec(i).fac_address1,v_cur_rec(i).fac_address2,v_cur_rec(i).fac_address3,v_cur_rec(i).fac_city,v_cur_rec(i).fac_statename,v_cur_rec(i).fac_statecd,v_cur_rec(i).fac_countryname,
                 v_cur_rec(i).fac_countrycd,v_cur_rec(i).fac_postalcode,v_cur_rec(i).fac_phone1,v_cur_rec(i).fac_phone1ext,v_cur_rec(i).fac_fax,v_cur_rec(i).fac_email,v_cur_rec(i).dept_contactid,
                 v_cur_rec(i).dept_contacttype,v_cur_rec(i).dept_addresstype,v_cur_rec(i).dept_address1,v_cur_rec(i).dept_address2,v_cur_rec(i).dept_address3,v_cur_rec(i).dept_city,v_cur_rec(i).dept_statename,
                 v_cur_rec(i).dept_statecd,v_cur_rec(i).dept_countryname,v_cur_rec(i).dept_countrycd,v_cur_rec(i).dept_postalcode,v_cur_rec(i).dept_phone1,v_cur_rec(i).dept_phone1ext,v_cur_rec(i).dept_fax,v_cur_rec(i).dept_email,
                 v_cur_rec(i).orgid,v_cur_rec(i).orgcode,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_facilityid,v_orgidlist(j),ip_sipeventid,gv_eventtype_facility);
          END LOOP;

  END LOOP;
  CLOSE cur_rec;
  
  OPEN op_facility FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));

END SP_SET_FACILITY_INT;

PROCEDURE SP_SET_PISTATUS_INT
(
ip_potentialinvfacid    IN TBL_POTENTIALINVFACMAP.potentialinvfacid%TYPE,
ip_sipeventid           IN TBL_SIP_EVENT.sipeventid%TYPE,
op_pistatus             OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT DISTINCT ts.studyid,ts.sipstudyid,ts.studyname,tpifm.preselectsitename sitename,tu.isactive,tiru.irid useririd,tu.userid,tu.transcelerateuserid,tu.sipuserid,
             tu.prefix,tu.title,tu.firstname,tu.middlename,tu.lastname,tu.suffix,tu.initials,tu.timezoneid,
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
                 CASE 
                     WHEN tf.isdepartment = 'Y' THEN
                          tpf.sqtfacilitiestype 
                     ELSE tf.sqtfacilitiestype     
                 END sqtfacilitiestype,
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
                 tc.codevalue record_status,tpifm.zscore,
                 tor.orgid,tor.orgcd orgcode
            FROM TBL_POTENTIALINVFACMAP tpifm,
                 TBL_POTENTIALINVESTIGATOR tpi,
                 TBL_POTENTIALINVTITLES tpt,
                 TBL_USERPROFILES tu,
                 TBL_IRUSERMAP tiru,
                 TBL_CODE tc,
                 TBL_CONTACT tcu,
                 TBL_FACILITIES tf,
                 TBL_CONTACT tcf,
                 TBL_FACILITIES tpf, 
                 TBL_CONTACT tcd,
                 TBL_STUDY ts,
                 TBL_ORGANIZATION tor
            WHERE tpifm.potentialinvuserid = tpi.potentialinvuserid
            AND tpi.titleid = tpt.titleid
            AND tpt.studyid = ts.studyid
            AND tpifm.facilityid = tf.facilityid
            AND tpi.transcelerateuserid = tu.transcelerateuserid
            AND tu.contactid = tcu.contactid(+)
            AND tu.transcelerateuserid = tiru.transcelerateuserid(+)
            AND tpifm.statuscd = tc.codename(+)
            AND tf.contactid = tcf.contactid(+)
            AND tf.facilityfordept = tpf.facilityid(+)
            AND tpf.contactid = tcd.contactid(+)
            AND ts.orgid = tor.orgid
            AND tpifm.potentialinvfacid = ip_potentialinvfacid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

BEGIN
  --PI Status Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEG
                (integid,studyid,sipstudyid,studyname,sitename,isactive,userid,transcelerateuserid,
                 sipuserid,prefix,title,firstname,middlename,lastname,suffix,initials,
                 timezoneid,user_contactid,user_contacttype,user_addresstype,user_address1,user_address2,
                 user_address3,user_city,user_statename,user_statecd,user_countryname,user_countrycd,
                 user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,facilityid,facilityname,
                 irfacilityid,masterfacilitytypecode,sqtfacilitiestype,isdepartment,departmentid,departmentname,departmenttypeid,
                 irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,fac_address1,fac_address2,
                 fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,fac_countrycd,fac_postalcode,
                 fac_phone1,fac_phone1ext,fac_fax,fac_email,dept_contactid,dept_contacttype,dept_addresstype,
                 dept_address1,dept_address2,dept_address3,dept_city,dept_statename,dept_statecd,dept_countryname,
                 dept_countrycd,dept_postalcode,dept_phone1,dept_phone1ext,dept_fax,dept_email,record_status,zscore,
                 orgid,orgcode,sipeventid,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integ.NEXTVAL,v_cur_rec(i).studyid,v_cur_rec(i).sipstudyid,v_cur_rec(i).studyname,v_cur_rec(i).sitename,v_cur_rec(i).isactive,v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).sipuserid,
                 v_cur_rec(i).prefix,v_cur_rec(i).title,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,v_cur_rec(i).suffix,v_cur_rec(i).initials,
                 v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,
                 v_cur_rec(i).user_address3,v_cur_rec(i).user_city,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,v_cur_rec(i).user_countrycd,
                 v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,v_cur_rec(i).user_email,v_cur_rec(i).facilityid,v_cur_rec(i).facilityname,
                 v_cur_rec(i).irfacilityid,v_cur_rec(i).masterfacilitytypecode,v_cur_rec(i).sqtfacilitiestype,v_cur_rec(i).isdepartment,v_cur_rec(i).departmentid,v_cur_rec(i).departmentname,v_cur_rec(i).departmenttypeid,
                 v_cur_rec(i).irdepartmentid,v_cur_rec(i).fac_contactid,v_cur_rec(i).fac_contacttype,v_cur_rec(i).fac_addresstype,v_cur_rec(i).fac_address1,v_cur_rec(i).fac_address2,
                 v_cur_rec(i).fac_address3,v_cur_rec(i).fac_city,v_cur_rec(i).fac_statename,v_cur_rec(i).fac_statecd,v_cur_rec(i).fac_countryname,v_cur_rec(i).fac_countrycd,v_cur_rec(i).fac_postalcode,
                 v_cur_rec(i).fac_phone1,v_cur_rec(i).fac_phone1ext,v_cur_rec(i).fac_fax,v_cur_rec(i).fac_email,v_cur_rec(i).dept_contactid,v_cur_rec(i).dept_contacttype,v_cur_rec(i).dept_addresstype,
                 v_cur_rec(i).dept_address1,v_cur_rec(i).dept_address2,v_cur_rec(i).dept_address3,v_cur_rec(i).dept_city,v_cur_rec(i).dept_statename,v_cur_rec(i).dept_statecd,v_cur_rec(i).dept_countryname,
                 v_cur_rec(i).dept_countrycd,v_cur_rec(i).dept_postalcode,v_cur_rec(i).dept_phone1,v_cur_rec(i).dept_phone1ext,v_cur_rec(i).dept_fax,v_cur_rec(i).dept_email,v_cur_rec(i).record_status,v_cur_rec(i).zscore,
                 v_cur_rec(i).orgid,v_cur_rec(i).orgcode,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_potentialinvfacid,v_orgidlist(j),ip_sipeventid,gv_eventtype_pistatus);
          END LOOP;

  END LOOP;
  CLOSE cur_rec;

  OPEN op_pistatus FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));

END SP_SET_PISTATUS_INT;

PROCEDURE SP_SET_USERDEACT_INT
(
ip_userdeactivationid   IN TBL_USERDEACTIVATIONLOG.userdeactivationid%TYPE,
ip_sipeventid           IN TBL_SIP_EVENT.sipeventid%TYPE,
op_userdeact            OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT tudl.requesterid,
            (SELECT tium.irid 
             FROM TBL_IRUSERMAP tium, TBL_USERPROFILES tup 
             WHERE tium.transcelerateuserid = tup.transcelerateuserid
             AND tup.userid = tudl.requesterid) requester_irid,
             tudl.affectorid userid,
             (SELECT tium.irid 
             FROM TBL_IRUSERMAP tium, TBL_USERPROFILES tup 
             WHERE tium.transcelerateuserid = tup.transcelerateuserid
             AND tup.userid = tudl.affectorid) useririd,
             tudl.effectivedate effectiveenddate,tudl.isforcause,
            (SELECT tj.justificationdesc
             FROM TBL_JUSTIFICATIOn tj
             WHERE tudl.justificationid = tj.justificationid) record_status,
             tsd.studyid,tsd.sipstudyid,tsd.studyname,ts.siteid,ts.sipsiteid,ts.sitename,
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
             tu.transcelerateuserid,tu.sipuserid,
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
             tor.orgid,tor.orgcd orgcode,tc.compoundid,tc.compoundname,tc.membercompoundcd
      FROM TBL_USERDEACTIVATIONLOG tudl,
           TBL_STUDY tsd,
           TBL_PROGRAM tp,
           TBL_ORGANIZATION tor,
           TBL_COMPOUND tc, 
           TBL_SITE ts,
           TBL_USERPROFILES tu,
           TBL_CONTACT tcu,
           TBL_FACILITIES tf,  
           TBL_CONTACT tcf,
           TBL_FACILITIES tpf, 
           TBL_CONTACT tcd
      WHERE tudl.studyid = tsd.studyid
      AND tsd.progid = tp.progid
      AND tp.orgid = tor.orgid
      AND tsd.compoundid = tc.compoundid
      AND tudl.siteid = ts.siteid(+)
      AND tudl.affectorid = tu.userid
      AND tu.contactid = tcu.contactid(+)
      AND ts.principalfacilityid = tf.facilityid(+)
      AND tf.contactid = tcf.contactid(+)
      AND tf.facilityfordept = tpf.facilityid(+)
      AND tpf.contactid = tcd.contactid(+)
      AND tudl.userdeactivationid = ip_userdeactivationid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

BEGIN
    --User User Deactivation Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEG
                (integid,requesterid,requester_irid,useririd,effectiveenddate,isforcause,record_status,
                 studyid,sipstudyid,studyname,siteid,sipsiteid,sitename,study_countrycd,study_countryname,
                 userid,transcelerateuserid,sipuserid,prefix,title,firstname,middlename,lastname,suffix,initials,isactive,
                 timezoneid,user_contactid,user_contacttype,user_addresstype,user_address1,user_address2,
                 user_address3,user_city,user_statename,user_statecd,user_countryname,user_countrycd,
                 user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,facilityid,facilityname,
                 irfacilityid,masterfacilitytypecode,isdepartment,departmentid,departmentname,departmenttypeid,
                 irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,fac_address1,fac_address2,
                 fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,fac_countrycd,fac_postalcode,
                 fac_phone1,fac_phone1ext,fac_fax,fac_email,dept_contactid,dept_contacttype,dept_addresstype,
                 dept_address1,dept_address2,dept_address3,dept_city,dept_statename,dept_statecd,dept_countryname,
                 dept_countrycd,dept_postalcode,dept_phone1,dept_phone1ext,dept_fax,dept_email,orgid,orgcode,
                 compoundid,compoundname,membercompoundcd,sipeventid,createdby,createddt,modifiedby,modifieddt)
         VALUES(seq_integ.NEXTVAL,v_cur_rec(i).requesterid,v_cur_rec(i).requester_irid,v_cur_rec(i).useririd,v_cur_rec(i).effectiveenddate,v_cur_rec(i).isforcause,v_cur_rec(i).record_status,
                v_cur_rec(i).studyid,v_cur_rec(i).sipstudyid,v_cur_rec(i).studyname,v_cur_rec(i).siteid,v_cur_rec(i).sipsiteid,v_cur_rec(i).sitename,v_cur_rec(i).study_countrycd,v_cur_rec(i).study_countryname,v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).sipuserid,
                v_cur_rec(i).prefix,v_cur_rec(i).title,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,v_cur_rec(i).suffix,v_cur_rec(i).initials,v_cur_rec(i).isactive,
                v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,
                v_cur_rec(i).user_address3,v_cur_rec(i).user_city,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,v_cur_rec(i).user_countrycd,
                v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,v_cur_rec(i).user_email,v_cur_rec(i).facilityid,v_cur_rec(i).facilityname,
                v_cur_rec(i).irfacilityid,v_cur_rec(i).masterfacilitytypecode,v_cur_rec(i).isdepartment,v_cur_rec(i).departmentid,v_cur_rec(i).departmentname,v_cur_rec(i).departmenttypeid,
                v_cur_rec(i).irdepartmentid,v_cur_rec(i).fac_contactid,v_cur_rec(i).fac_contacttype,v_cur_rec(i).fac_addresstype,v_cur_rec(i).fac_address1,v_cur_rec(i).fac_address2,
                v_cur_rec(i).fac_address3,v_cur_rec(i).fac_city,v_cur_rec(i).fac_statename,v_cur_rec(i).fac_statecd,v_cur_rec(i).fac_countryname,v_cur_rec(i).fac_countrycd,v_cur_rec(i).fac_postalcode,
                v_cur_rec(i).fac_phone1,v_cur_rec(i).fac_phone1ext,v_cur_rec(i).fac_fax,v_cur_rec(i).fac_email,v_cur_rec(i).dept_contactid,v_cur_rec(i).dept_contacttype,v_cur_rec(i).dept_addresstype,
                v_cur_rec(i).dept_address1,v_cur_rec(i).dept_address2,v_cur_rec(i).dept_address3,v_cur_rec(i).dept_city,v_cur_rec(i).dept_statename,v_cur_rec(i).dept_statecd,v_cur_rec(i).dept_countryname,
                v_cur_rec(i).dept_countrycd,v_cur_rec(i).dept_postalcode,v_cur_rec(i).dept_phone1,v_cur_rec(i).dept_phone1ext,v_cur_rec(i).dept_fax,v_cur_rec(i).dept_email,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,
                v_cur_rec(i).compoundid,v_cur_rec(i).compoundname,v_cur_rec(i).membercompoundcd,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_userdeactivationid,v_orgidlist(j),ip_sipeventid,gv_eventtype_userdeact);
          END LOOP;

  END LOOP;
  CLOSE cur_rec;
    
  OPEN op_userdeact FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));
         
END SP_SET_USERDEACT_INT;

PROCEDURE SP_SET_ACCESSMOD_INT
(
ip_acessmodreqid        IN TBL_ACESSMODIFICATIONREQUEST.acessmodreqid%TYPE,
ip_sipeventid           IN TBL_SIP_EVENT.sipeventid%TYPE,
op_accessmod            OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT tamr.requestorid requesterid,
            (SELECT tium.irid 
             FROM TBL_IRUSERMAP tium, TBL_USERPROFILES tup 
             WHERE tium.transcelerateuserid = tup.transcelerateuserid
             AND tup.userid = tamr.requestorid) requester_irid,
             tamr.requestedforid userid,
            (SELECT tium.irid 
             FROM TBL_IRUSERMAP tium, TBL_USERPROFILES tup 
             WHERE tium.transcelerateuserid = tup.transcelerateuserid
             AND tup.userid = tamr.requestedforid) useririd,
             tamr.effectivedate effectiveenddate,tamr.requestorcomments otherdescription,tamr.requestedroles,tamr.newroles,
             tsd.studyid,tsd.sipstudyid,tsd.studyname,ts.siteid,ts.sipsiteid,ts.sitename,
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
             tu.transcelerateuserid,tu.sipuserid,
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
             tor.orgid,tor.orgcd orgcode,tc.compoundid,tc.compoundname,tc.membercompoundcd
      FROM TBL_ACESSMODIFICATIONREQUEST tamr,
           TBL_STUDY tsd,
           TBL_PROGRAM tp,
           TBL_ORGANIZATION tor,
           TBL_COMPOUND tc, 
           TBL_SITE ts,
           TBL_USERPROFILES tu,
           TBL_CONTACT tcu,
           TBL_FACILITIES tf,  
           TBL_CONTACT tcf,
           TBL_FACILITIES tpf, 
           TBL_CONTACT tcd
      WHERE tamr.studyid = tsd.studyid
      AND tsd.progid = tp.progid
      AND tp.orgid = tor.orgid
      AND tsd.compoundid = tc.compoundid
      AND tamr.siteid = ts.siteid(+)
      AND tamr.requestedforid = tu.userid
      AND tu.contactid = tcu.contactid(+)
      AND ts.principalfacilityid = tf.facilityid(+)
      AND tf.contactid = tcf.contactid(+)
      AND tf.facilityfordept = tpf.facilityid(+)
      AND tpf.contactid = tcd.contactid(+)
      AND tamr.acessmodreqid = ip_acessmodreqid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;       
       
BEGIN
  --User Access Modification Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEG
                (integid,requesterid,requester_irid,useririd,effectiveenddate,otherdescription,requestedroles,newroles,
                 studyid,sipstudyid,studyname,siteid,sipsiteid,sitename,study_countrycd,study_countryname,
                 userid,transcelerateuserid,sipuserid,prefix,title,firstname,middlename,lastname,suffix,initials,isactive,
                 timezoneid,user_contactid,user_contacttype,user_addresstype,user_address1,user_address2,
                 user_address3,user_city,user_statename,user_statecd,user_countryname,user_countrycd,
                 user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,facilityid,facilityname,
                 irfacilityid,masterfacilitytypecode,isdepartment,departmentid,departmentname,departmenttypeid,
                 irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,fac_address1,fac_address2,
                 fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,fac_countrycd,fac_postalcode,
                 fac_phone1,fac_phone1ext,fac_fax,fac_email,dept_contactid,dept_contacttype,dept_addresstype,
                 dept_address1,dept_address2,dept_address3,dept_city,dept_statename,dept_statecd,dept_countryname,
                 dept_countrycd,dept_postalcode,dept_phone1,dept_phone1ext,dept_fax,dept_email,orgid,orgcode,
                 compoundid,compoundname,membercompoundcd,sipeventid,createdby,createddt,modifiedby,modifieddt)
          VALUES(seq_integ.NEXTVAL,v_cur_rec(i).requesterid,v_cur_rec(i).requester_irid,v_cur_rec(i).useririd,v_cur_rec(i).effectiveenddate,v_cur_rec(i).otherdescription,v_cur_rec(i).requestedroles,v_cur_rec(i).newroles,
                 v_cur_rec(i).studyid,v_cur_rec(i).sipstudyid,v_cur_rec(i).studyname,v_cur_rec(i).siteid,v_cur_rec(i).sipsiteid,v_cur_rec(i).sitename,v_cur_rec(i).study_countrycd,v_cur_rec(i).study_countryname,v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).sipuserid,
                 v_cur_rec(i).prefix,v_cur_rec(i).title,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,v_cur_rec(i).suffix,v_cur_rec(i).initials,v_cur_rec(i).isactive,
                 v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,
                 v_cur_rec(i).user_address3,v_cur_rec(i).user_city,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,v_cur_rec(i).user_countrycd,
                 v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,v_cur_rec(i).user_email,v_cur_rec(i).facilityid,v_cur_rec(i).facilityname,
                 v_cur_rec(i).irfacilityid,v_cur_rec(i).masterfacilitytypecode,v_cur_rec(i).isdepartment,v_cur_rec(i).departmentid,v_cur_rec(i).departmentname,v_cur_rec(i).departmenttypeid,
                 v_cur_rec(i).irdepartmentid,v_cur_rec(i).fac_contactid,v_cur_rec(i).fac_contacttype,v_cur_rec(i).fac_addresstype,v_cur_rec(i).fac_address1,v_cur_rec(i).fac_address2,
                 v_cur_rec(i).fac_address3,v_cur_rec(i).fac_city,v_cur_rec(i).fac_statename,v_cur_rec(i).fac_statecd,v_cur_rec(i).fac_countryname,v_cur_rec(i).fac_countrycd,v_cur_rec(i).fac_postalcode,
                 v_cur_rec(i).fac_phone1,v_cur_rec(i).fac_phone1ext,v_cur_rec(i).fac_fax,v_cur_rec(i).fac_email,v_cur_rec(i).dept_contactid,v_cur_rec(i).dept_contacttype,v_cur_rec(i).dept_addresstype,
                 v_cur_rec(i).dept_address1,v_cur_rec(i).dept_address2,v_cur_rec(i).dept_address3,v_cur_rec(i).dept_city,v_cur_rec(i).dept_statename,v_cur_rec(i).dept_statecd,v_cur_rec(i).dept_countryname,
                 v_cur_rec(i).dept_countrycd,v_cur_rec(i).dept_postalcode,v_cur_rec(i).dept_phone1,v_cur_rec(i).dept_phone1ext,v_cur_rec(i).dept_fax,v_cur_rec(i).dept_email,v_cur_rec(i).orgid,v_cur_rec(i).orgcode,
                 v_cur_rec(i).compoundid,v_cur_rec(i).compoundname,v_cur_rec(i).membercompoundcd,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_acessmodreqid,v_orgidlist(j),ip_sipeventid,gv_eventtype_accessmod);
          END LOOP;

  END LOOP;
  CLOSE cur_rec;
    
  OPEN op_accessmod FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));    

END SP_SET_ACCESSMOD_INT;

PROCEDURE SP_SET_ADDSITELOC_INT
(
ip_sitelocationid       IN TBL_ADDLSITELOCATION.sitelocationid%TYPE,
ip_sipeventid           IN TBL_SIP_EVENT.sipeventid%TYPE,
op_addsiteloc           OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT DISTINCT ts.studyid,ts.sipstudyid,ts.studyname,tsi.siteid,tsi.sipsiteid,tsi.sitename,
             tasl.startdate effectivestartdate,tasl.enddate effectiveenddate,
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
             tcf.contactid fac_contactid,
             tcf.contacttype fac_contacttype,
             tcf.addresstype fac_addresstype,
             tcf.address1 fac_address1,
             tcf.address2 fac_address2,
             tcf.address3 fac_address3,
             tcf.city fac_city,
            (SELECT tst.statename
             FROM TBL_STATES tst, TBL_COUNTRIES tcnt
             WHERE tst.countryid = tcnt.countryid
             AND tcnt.countrycd = tcf.countrycd
             AND tst.statecd = tcf.state) fac_statename,
             tcf.state fac_statecd,
            (SELECT tcnt.countryname 
             FROM TBL_COUNTRIES tcnt
             WHERE tcnt.countrycd = tcf.countrycd) fac_countryname,
             tcf.countrycd fac_countrycd,
             tcf.postalcode fac_postalcode,
             tcf.phone1 fac_phone1,
             tcf.phone1ext fac_phone1ext,
             tcf.fax fac_fax,
             tcf.email fac_email,
             tor.orgid,tor.orgcd orgcode
          FROM TBL_ADDLSITELOCATION tasl,
               TBL_SITE tsi,
               TBL_STUDY ts, 
               TBL_FACILITIES tf,
               TBL_CONTACT tcf,
               TBL_FACILITIES tpf, 
               TBL_ORGANIZATION tor
          WHERE tasl.siteid = tsi.siteid
          AND tsi.studyid = ts.studyid
          AND tasl.facilityid = tf.facilityid(+)
          AND tasl.contactid = tcf.contactid(+)
          AND tf.facilityfordept = tpf.facilityid(+)
          AND ts.orgid = tor.orgid
          AND tasl.sitelocationid = ip_sitelocationid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

--Local Facility
CURSOR cur_locfac IS
       SELECT DISTINCT ts.studyid,ts.sipstudyid,ts.studyname,tsi.siteid,tsi.sipsiteid,tsi.sitename,
             tasl.startdate effectivestartdate,tasl.enddate effectiveenddate,
             tasl.facilityid,
             tasl.facilityname,
             NULL irfacilityid,
             NULL masterfacilitytypecode,
             tasl.isdepartment,
             NULL departmentid,
             tasl.departmentname,
             NULL departmenttypeid,
             NULL irdepartmentid,
             tcf.contactid fac_contactid,
             tcf.contacttype fac_contacttype,
             tcf.addresstype fac_addresstype,
             tcf.address1 fac_address1,
             tcf.address2 fac_address2,
             tcf.address3 fac_address3,
             tcf.city fac_city,
             (SELECT tst.statename
              FROM TBL_STATES tst, TBL_COUNTRIES tcnt
              WHERE tst.countryid = tcnt.countryid
              AND tcnt.countrycd = tcf.countrycd
              AND tst.statecd = tcf.state) fac_statename,
             tcf.state fac_statecd,
             (SELECT tcnt.countryname 
              FROM TBL_COUNTRIES tcnt
              WHERE tcnt.countrycd = tcf.countrycd) fac_countryname,
             tcf.countrycd fac_countrycd,
             tcf.postalcode fac_postalcode,
             tcf.phone1 fac_phone1,
             tcf.phone1ext fac_phone1ext,
             tcf.fax fac_fax,
             tcf.email fac_email,
             tor.orgid,tor.orgcd orgcode
          FROM TBL_ADDLSITELOCATION tasl,
               TBL_SITE tsi,
               TBL_STUDY ts, 
               TBL_CONTACT tcf,
               TBL_ORGANIZATION tor
          WHERE tasl.siteid = tsi.siteid
          AND tsi.studyid = ts.studyid
          AND tasl.contactid = tcf.contactid(+)
          AND ts.orgid = tor.orgid
          AND tasl.sitelocationid = ip_sitelocationid;

TYPE typ_cur_locfac IS TABLE OF cur_locfac%ROWTYPE;
v_cur_locfac typ_cur_locfac;

v_locfac PLS_INTEGER:=0;

BEGIN
  --Check if it is for Local Facility
  SELECT COUNT(1) INTO v_locfac FROM TBL_ADDLSITELOCATION tasl WHERE tasl.sitelocationid = ip_sitelocationid AND tasl.facilityid IS NOT NULL;
  IF v_locfac <> 0 THEN
  --Additional Site Location Integration
      OPEN cur_rec;
      LOOP
          FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
          EXIT WHEN v_cur_rec.COUNT = 0;
    
          FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
              INSERT INTO TBL_INTEG
                   (integid,studyid,sipstudyid,studyname,siteid,sipsiteid,sitename,effectivestartdate,effectiveenddate,
                    facilityid,facilityname,irfacilityid,masterfacilitytypecode,isdepartment,departmentid,
                    departmentname,departmenttypeid,irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,
                    fac_address1,fac_address2,fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,
                    fac_countrycd,fac_postalcode,fac_phone1,fac_phone1ext,fac_fax,fac_email,
                    orgid,orgcode,sipeventid,createdby,createddt,modifiedby,modifieddt)
             VALUES(seq_integ.NEXTVAL,v_cur_rec(i).studyid,v_cur_rec(i).sipstudyid,v_cur_rec(i).studyname,v_cur_rec(i).siteid,v_cur_rec(i).sipsiteid,v_cur_rec(i).sitename,v_cur_rec(i).effectivestartdate,v_cur_rec(i).effectiveenddate,
                    v_cur_rec(i).facilityid,v_cur_rec(i).facilityname,v_cur_rec(i).irfacilityid,v_cur_rec(i).masterfacilitytypecode,v_cur_rec(i).isdepartment,v_cur_rec(i).departmentid,
                    v_cur_rec(i).departmentname,v_cur_rec(i).departmenttypeid,v_cur_rec(i).irdepartmentid,v_cur_rec(i).fac_contactid,v_cur_rec(i).fac_contacttype,v_cur_rec(i).fac_addresstype,
                    v_cur_rec(i).fac_address1,v_cur_rec(i).fac_address2,v_cur_rec(i).fac_address3,v_cur_rec(i).fac_city,v_cur_rec(i).fac_statename,v_cur_rec(i).fac_statecd,v_cur_rec(i).fac_countryname,
                    v_cur_rec(i).fac_countrycd,v_cur_rec(i).fac_postalcode,v_cur_rec(i).fac_phone1,v_cur_rec(i).fac_phone1ext,v_cur_rec(i).fac_fax,v_cur_rec(i).fac_email,
                    v_cur_rec(i).orgid,v_cur_rec(i).orgcode,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
              RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;
    
              FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
                  SP_INTEG(v_integidlist(j),ip_sitelocationid,v_orgidlist(j),ip_sipeventid,gv_eventtype_addsiteloc);
              END LOOP;
    
      END LOOP;
      CLOSE cur_rec;
  ELSE
      OPEN cur_locfac;
      LOOP
          FETCH cur_locfac BULK COLLECT INTO v_cur_locfac LIMIT gv_rec_limit;
          EXIT WHEN v_cur_locfac.COUNT = 0;
    
          FORALL i IN v_cur_locfac.FIRST..v_cur_locfac.LAST
              INSERT INTO TBL_INTEG
                   (integid,studyid,sipstudyid,studyname,siteid,sipsiteid,sitename,effectivestartdate,effectiveenddate,
                    facilityid,facilityname,irfacilityid,masterfacilitytypecode,isdepartment,departmentid,
                    departmentname,departmenttypeid,irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,
                    fac_address1,fac_address2,fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,
                    fac_countrycd,fac_postalcode,fac_phone1,fac_phone1ext,fac_fax,fac_email,
                    orgid,orgcode,sipeventid,createdby,createddt,modifiedby,modifieddt)
             VALUES(seq_integ.NEXTVAL,v_cur_locfac(i).studyid,v_cur_locfac(i).sipstudyid,v_cur_locfac(i).studyname,v_cur_locfac(i).siteid,v_cur_locfac(i).sipsiteid,v_cur_locfac(i).sitename,v_cur_locfac(i).effectivestartdate,v_cur_locfac(i).effectiveenddate,
                    v_cur_locfac(i).facilityid,v_cur_locfac(i).facilityname,v_cur_locfac(i).irfacilityid,v_cur_locfac(i).masterfacilitytypecode,v_cur_locfac(i).isdepartment,v_cur_locfac(i).departmentid,
                    v_cur_locfac(i).departmentname,v_cur_locfac(i).departmenttypeid,v_cur_locfac(i).irdepartmentid,v_cur_locfac(i).fac_contactid,v_cur_locfac(i).fac_contacttype,v_cur_locfac(i).fac_addresstype,
                    v_cur_locfac(i).fac_address1,v_cur_locfac(i).fac_address2,v_cur_locfac(i).fac_address3,v_cur_locfac(i).fac_city,v_cur_locfac(i).fac_statename,v_cur_locfac(i).fac_statecd,v_cur_locfac(i).fac_countryname,
                    v_cur_locfac(i).fac_countrycd,v_cur_locfac(i).fac_postalcode,v_cur_locfac(i).fac_phone1,v_cur_locfac(i).fac_phone1ext,v_cur_locfac(i).fac_fax,v_cur_locfac(i).fac_email,
                    v_cur_locfac(i).orgid,v_cur_locfac(i).orgcode,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
              RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;
    
              FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
                  SP_INTEG(v_integidlist(j),ip_sitelocationid,v_orgidlist(j),ip_sipeventid,gv_eventtype_addsiteloc);
              END LOOP;
    
      END LOOP;
      CLOSE cur_locfac;  
  END IF;
  
  OPEN op_addsiteloc FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));   
END SP_SET_ADDSITELOC_INT;

PROCEDURE SP_SET_TRNGCREDIT_INT
(
ip_requestid       IN TBL_TRNGCREDITS.requestid%TYPE,
ip_sipeventid      IN TBL_SIP_EVENT.sipeventid%TYPE,
op_trngcredit      OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT DISTINCT tcr.requestid,tcr.coursetitle,tcr.courseid,tcr.trngcatname,tcr.trngprovidername,
             tcr.requestedfor,tcr.trng_status_id,tcr.requesteddt,tcr.completiondt,tcr.expirydate,
             tcr.trngtype,tcr.rejectionid,tcr.rejectioncomments,tcr.comments,tcr.actiondt,tcr.ismrt,tcr.trng_sponsor,
             tcr.userid,turf.transcelerateuserid,tiru.irid useririd,turf.sipuserid,tcr.userid requesterid,turb.transcelerateuserid requestedbytransid,tirub.irid requester_irid,turb.sipuserid requestedbysipuserid,
             turf.prefix,turf.title,turf.firstname,turf.middlename,turf.lastname,turf.suffix,
             turf.initials,turf.isactive,turf.timezoneid,tcu.contactid user_contactid,tcu.contacttype user_contacttype,tcu.addresstype user_addresstype,
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
             tor.orgid,tor.orgcd orgcode
      FROM TBL_TRNGCREDITS tcr,
           TBL_USERROLEMAP turm,
           TBL_STUDY tsd,
           TBL_PROGRAM tp,
           TBL_ORGANIZATION tor,
           TBL_USERPROFILES turf,
           TBL_IRUSERMAP tiru,
           TBL_USERPROFILES turb,
           TBL_IRUSERMAP tirub,
           TBL_CONTACT tcu
      WHERE tcr.userid = turm.userid
      AND turm.studyid = tsd.studyid
      AND tsd.progid = tp.progid
      AND tp.orgid = tor.orgid
      AND tcr.requestedfor = turf.userid
      AND turf.transcelerateuserid = tiru.transcelerateuserid(+)
      AND tcr.userid = turb.userid
      AND turb.transcelerateuserid = tirub.transcelerateuserid(+)
      AND turf.contactid = tcu.contactid(+)
      AND tcr.requestid = ip_requestid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

BEGIN
  --Training Credit Integration
  OPEN cur_rec;
  LOOP
      FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
      EXIT WHEN v_cur_rec.COUNT = 0;

      FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
          INSERT INTO TBL_INTEG
                (integid,requestid,coursetitle,courseid,trngcatname,trngprovidername,
                 requestedfor,trng_status_id,requesteddt,completiondt,expirydate,
                 trngtype,rejectionid,rejectioncomments,comments,actiondt,ismrt,trng_sponsor,
                 userid,transcelerateuserid,sipuserid,requesterid,requestedbytransid,requester_irid,requestedbysipuserid,
                 prefix,title,firstname,middlename,lastname,suffix,initials,isactive,
                 timezoneid,user_contactid,user_contacttype,user_addresstype,user_address1,user_address2,
                 user_address3,user_city,user_statename,user_statecd,user_countryname,user_countrycd,
                 user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,
                 orgid,orgcode,sipeventid,createdby,createddt,modifiedby,modifieddt)
         VALUES(seq_integ.NEXTVAL,v_cur_rec(i).requestid,v_cur_rec(i).coursetitle,v_cur_rec(i).courseid,v_cur_rec(i).trngcatname,v_cur_rec(i).trngprovidername,
                v_cur_rec(i).requestedfor,v_cur_rec(i).trng_status_id,v_cur_rec(i).requesteddt,v_cur_rec(i).completiondt,v_cur_rec(i).expirydate,
                v_cur_rec(i).trngtype,v_cur_rec(i).rejectionid,v_cur_rec(i).rejectioncomments,v_cur_rec(i).comments,v_cur_rec(i).actiondt,v_cur_rec(i).ismrt,v_cur_rec(i).trng_sponsor,
                v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).sipuserid,v_cur_rec(i).requesterid,v_cur_rec(i).requestedbytransid,v_cur_rec(i).requester_irid,v_cur_rec(i).requestedbysipuserid,
                v_cur_rec(i).prefix,v_cur_rec(i).title,v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,v_cur_rec(i).suffix,v_cur_rec(i).initials,v_cur_rec(i).isactive,
                v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,
                v_cur_rec(i).user_address3,v_cur_rec(i).user_city,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,v_cur_rec(i).user_countrycd,
                v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,v_cur_rec(i).user_email,
                v_cur_rec(i).orgid,v_cur_rec(i).orgcode,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
          RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;

          FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
              SP_INTEG(v_integidlist(j),ip_requestid,v_orgidlist(j),ip_sipeventid,gv_eventtype_trngcredit);
          END LOOP;

  END LOOP;
  CLOSE cur_rec;

  OPEN op_trngcredit FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));    

END SP_SET_TRNGCREDIT_INT;

PROCEDURE SP_SET_SURVEY_RESPONSE_INT
(
ip_surveyid             IN TBL_SURVEY.surveyid%TYPE,
ip_transcelerateuserid  IN TBL_USERPROFILES.transcelerateuserid%TYPE,
ip_sipeventid           IN TBL_SIP_EVENT.sipeventid%TYPE,
op_surveyresponse       OUT SYS_REFCURSOR
)
IS
v_integidlist       NUM_ARRAY := NUM_ARRAY();
v_orgidlist         NUM_ARRAY := NUM_ARRAY();
v_createddt         DATE:= SYSDATE;

CURSOR cur_rec IS
       SELECT DISTINCT tsv.surveyid,tsv.parentsurveyid,tsv.surveytitle,tsvp.surveytitle parentsurveytitle,
               CASE 
                WHEN (SELECT tsmd.metadatavalue
                      FROM TBL_SURVEYMETADATA tsmd
                      WHERE tsmd.surveymetadataid = tsv.surveysubtype) <> 'Other' THEN
                   (SELECT tsmd.metadatavalue
                    FROM TBL_SURVEYMETADATA tsmd
                    WHERE tsmd.surveymetadataid = tsv.surveysubtype)  
                ELSE
                    tsv.othersurveytypetext
               END surveytype,
              (SELECT tsmd.metadatavalue
               FROM TBL_SURVEYMETADATA tsmd
               WHERE tsmd.surveymetadataid = tsv.surveytypeid) surveyrecipient,
              (SELECT tsmd.metadatavalue
               FROM TBL_SURVEYMETADATA tsmd
               WHERE tsmd.surveymetadataid = tsu.surveystatus) surveystatus,
               (SELECT tsmd.metadatavalue
               FROM TBL_SURVEYMETADATA tsmd
               WHERE tsmd.surveymetadataid = tsu.recipientstatus) surveyrecipientstatus,tsu.createdby surveyaddedby,
               tsu.surveyduedate,tsu.surveysentdate,tsu.lastreminderdate surveylastreminderdate,
               tsu.tranecelerateid pitransid, 
              (SELECT tupi.sipuserid
               FROM TBL_USERPROFILES tupi
               WHERE tupi.transcelerateuserid = tsu.tranecelerateid) pisipuserid,
              (SELECT tiupi.irid
               FROM TBL_IRUSERMAP tiupi
               WHERE tiupi.transcelerateuserid = tsu.tranecelerateid) piiruserid,
               tsu.submitteddate surveyresponsedate,tsu.referencecode,
               tsd.studyid,tsd.sipstudyid,tsd.studyname,
               tu.userid,tu.transcelerateuserid,tu.sipuserid,tiru.irid useririd,
               tu.prefix,tu.title,tu.firstname,tu.middlename,tu.lastname,tu.suffix,
               tu.initials,tu.isactive,tu.timezoneid,tcu.contactid user_contactid,tcu.contacttype user_contacttype,
               tcu.addresstype user_addresstype,tcu.address1 user_address1,tcu.address2 user_address2,
               tcu.address3 user_address3,tcu.city user_city,
               (SELECT tst.statename
               FROM TBL_STATES tst, TBL_COUNTRIES tcnt
               WHERE tst.countryid = tcnt.countryid
               AND tcnt.countrycd = tcu.countrycd
               AND tst.statecd = tcu.state) user_statename,
               tcu.state user_statecd,
               (SELECT tcnt.countryname 
               FROM TBL_COUNTRIES tcnt
               WHERE tcnt.countrycd = tcu.countrycd) user_countryname,
               tcu.countrycd user_countrycd,tcu.postalcode user_postalcode,tcu.phone1 user_phone1,tcu.phone1ext user_phone1ext,
               tcu.fax user_fax,tcu.email user_email,
               tf.facilityid facilityid,
               tf.facilityname facilityname,
               tf.irfacilityid irfacilityid,
               tf.masterfacilitytypecode masterfacilitytypecode,
               tf.isdepartment,
               tfd.facilityid departmentid,
               tfd.departmentname,
               tfd.departmenttypeid,
               tfd.irfacilityid irdepartmentid,
               tcf.contactid fac_contactid,
               tcf.contacttype fac_contacttype,
               tcf.addresstype fac_addresstype,
               tcf.address1 fac_address1,
               tcf.address2 fac_address2,
               tcf.address3 fac_address3,
               tcf.city fac_city,
              (SELECT tst.statename
               FROM TBL_STATES tst, TBL_COUNTRIES tcnt
               WHERE tst.countryid = tcnt.countryid
               AND tcnt.countrycd = tcf.countrycd
               AND tst.statecd = tcf.state) fac_statename,
               tcf.state fac_statecd,
              (SELECT tcnt.countryname 
               FROM TBL_COUNTRIES tcnt
               WHERE tcnt.countrycd = tcf.countrycd) fac_countryname,
               tcf.countrycd fac_countrycd,
               tcf.postalcode fac_postalcode,
               tcf.phone1 fac_phone1,
               tcf.phone1ext fac_phone1ext,
               tcf.fax fac_fax,
               tcf.email fac_email,
               tcd.contactid dept_contactid,
               tcd.contacttype dept_contacttype,
               tcd.addresstype dept_addresstype,
               tcd.address1 dept_address1,
               tcd.address2 dept_address2,
               tcd.address3 dept_address3,
               tcd.city dept_city,
              (SELECT tst.statename
               FROM TBL_STATES tst, TBL_COUNTRIES tcnt
               WHERE tst.countryid = tcnt.countryid
               AND tcnt.countrycd = tcd.countrycd
               AND tst.statecd = tcd.state) dept_statename,
               tcd.state dept_statecd,
              (SELECT tcnt.countryname 
               FROM TBL_COUNTRIES tcnt
               WHERE tcnt.countrycd = tcd.countrycd) dept_countryname,
               tcd.countrycd dept_countrycd,
               tcd.postalcode dept_postalcode,
               tcd.phone1 dept_phone1,
               tcd.phone1ext dept_phone1ext,
               tcd.fax dept_fax,
               tcd.email dept_email,
               tor.orgid,tor.orgcd orgcode
        FROM TBL_SURVEY tsv
             JOIN TBL_SURVEYSIPASSOCIATION tssa
             ON (tsv.surveyid = tssa.belongto)
             LEFT JOIN TBL_SURVEY tsvp
             ON (tsv.parentsurveyid = tsvp.surveyid)
             LEFT JOIN TBL_SURVEYFACILITYMAP tsf
             ON (tsv.surveyid = tsf.surveyid)
             JOIN TBL_SURVEYUSERMAP tsu
             ON (tsv.surveyid = tsu.belongto
             AND tsf.surveyuserid = tsu.surveyuserid)
             LEFT JOIN TBL_STUDY tsd
             ON (tssa.studyid = tsd.studyid)
             LEFT JOIN TBL_USERPROFILES tu
             ON (tsu.tranecelerateid = tu.transcelerateuserid)
             LEFT JOIN TBL_IRUSERMAP tiru
             ON (tu.transcelerateuserid = tiru.transcelerateuserid)
             LEFT JOIN TBL_CONTACT tcu
             ON (tu.contactid = tcu.contactid)
             LEFT JOIN TBL_FACILITIES tf
             ON (tsf.facilityid = tf.facilityid)
             LEFT JOIN TBL_CONTACT tcf
             ON (tf.contactid = tcf.contactid)
             LEFT JOIN TBL_FACILITIES tfd
             ON (tsf.departmentid = tfd.facilityid)
             LEFT JOIN TBL_CONTACT tcd
             ON (tfd.contactid = tcd.contactid)
             LEFT JOIN TBL_ORGANIZATION tor
             ON (tssa.sponsororganizaionid  = tor.orgid)
        WHERE tsv.surveyid = ip_surveyid
        AND tsu.tranecelerateid = ip_transcelerateuserid;

TYPE typ_cur_rec IS TABLE OF cur_rec%ROWTYPE;
v_cur_rec typ_cur_rec;

CURSOR cur_rec1 IS
       SELECT DISTINCT tsv.surveyid,tsv.parentsurveyid,tsv.surveytitle,tsvp.surveytitle parentsurveytitle,
               CASE 
                WHEN (SELECT tsmd.metadatavalue
                      FROM TBL_SURVEYMETADATA tsmd
                      WHERE tsmd.surveymetadataid = tsv.surveysubtype) <> 'Other' THEN
                   (SELECT tsmd.metadatavalue
                    FROM TBL_SURVEYMETADATA tsmd
                    WHERE tsmd.surveymetadataid = tsv.surveysubtype)  
                ELSE
                    tsv.othersurveytypetext
               END surveytype,
              (SELECT tsmd.metadatavalue
               FROM TBL_SURVEYMETADATA tsmd
               WHERE tsmd.surveymetadataid = tsv.surveytypeid) surveyrecipient,
              (SELECT tsmd.metadatavalue
               FROM TBL_SURVEYMETADATA tsmd
               WHERE tsmd.surveymetadataid = tsu.surveystatus) surveystatus,
               (SELECT tsmd.metadatavalue
               FROM TBL_SURVEYMETADATA tsmd
               WHERE tsmd.surveymetadataid = tsu.recipientstatus) surveyrecipientstatus,tsu.createdby surveyaddedby,
               tsu.surveyduedate,tsu.surveysentdate,tsu.lastreminderdate surveylastreminderdate,
               tsu.tranecelerateid pitransid, 
              (SELECT tupi.sipuserid
               FROM TBL_USERPROFILES tupi
               WHERE tupi.transcelerateuserid = tsu.tranecelerateid) pisipuserid,
              (SELECT tiupi.irid
               FROM TBL_IRUSERMAP tiupi
               WHERE tiupi.transcelerateuserid = tsu.tranecelerateid) piiruserid,
               tsu.submitteddate surveyresponsedate,tsu.referencecode,
               tsd.studyid,tsd.sipstudyid,tsd.studyname,
               tu.userid,tu.transcelerateuserid,tu.sipuserid,tiru.irid useririd,
               tu.prefix,tu.title,tu.firstname,tu.middlename,tu.lastname,tu.suffix,
               tu.initials,tu.isactive,tu.timezoneid,tcu.contactid user_contactid,tcu.contacttype user_contacttype,
               tcu.addresstype user_addresstype,tcu.address1 user_address1,tcu.address2 user_address2,
               tcu.address3 user_address3,tcu.city user_city,
               (SELECT tst.statename
               FROM TBL_STATES tst, TBL_COUNTRIES tcnt
               WHERE tst.countryid = tcnt.countryid
               AND tcnt.countrycd = tcu.countrycd
               AND tst.statecd = tcu.state) user_statename,
               tcu.state user_statecd,
               (SELECT tcnt.countryname 
               FROM TBL_COUNTRIES tcnt
               WHERE tcnt.countrycd = tcu.countrycd) user_countryname,
               tcu.countrycd user_countrycd,tcu.postalcode user_postalcode,tcu.phone1 user_phone1,tcu.phone1ext user_phone1ext,
               tcu.fax user_fax,tcu.email user_email,
               tf.facilityid facilityid,
               tf.facilityname facilityname,
               tf.irfacilityid irfacilityid,
               tf.masterfacilitytypecode masterfacilitytypecode,
               tf.isdepartment,
               tfd.facilityid departmentid,
               tfd.departmentname,
               tfd.departmenttypeid,
               tfd.irfacilityid irdepartmentid,
               tcf.contactid fac_contactid,
               tcf.contacttype fac_contacttype,
               tcf.addresstype fac_addresstype,
               tcf.address1 fac_address1,
               tcf.address2 fac_address2,
               tcf.address3 fac_address3,
               tcf.city fac_city,
              (SELECT tst.statename
               FROM TBL_STATES tst, TBL_COUNTRIES tcnt
               WHERE tst.countryid = tcnt.countryid
               AND tcnt.countrycd = tcf.countrycd
               AND tst.statecd = tcf.state) fac_statename,
               tcf.state fac_statecd,
              (SELECT tcnt.countryname 
               FROM TBL_COUNTRIES tcnt
               WHERE tcnt.countrycd = tcf.countrycd) fac_countryname,
               tcf.countrycd fac_countrycd,
               tcf.postalcode fac_postalcode,
               tcf.phone1 fac_phone1,
               tcf.phone1ext fac_phone1ext,
               tcf.fax fac_fax,
               tcf.email fac_email,
               tcd.contactid dept_contactid,
               tcd.contacttype dept_contacttype,
               tcd.addresstype dept_addresstype,
               tcd.address1 dept_address1,
               tcd.address2 dept_address2,
               tcd.address3 dept_address3,
               tcd.city dept_city,
              (SELECT tst.statename
               FROM TBL_STATES tst, TBL_COUNTRIES tcnt
               WHERE tst.countryid = tcnt.countryid
               AND tcnt.countrycd = tcd.countrycd
               AND tst.statecd = tcd.state) dept_statename,
               tcd.state dept_statecd,
              (SELECT tcnt.countryname 
               FROM TBL_COUNTRIES tcnt
               WHERE tcnt.countrycd = tcd.countrycd) dept_countryname,
               tcd.countrycd dept_countrycd,
               tcd.postalcode dept_postalcode,
               tcd.phone1 dept_phone1,
               tcd.phone1ext dept_phone1ext,
               tcd.fax dept_fax,
               tcd.email dept_email,
               tor.orgid,tor.orgcd orgcode
        FROM TBL_SURVEY tsv
             JOIN TBL_SURVEYSIPASSOCIATION tssa
             ON (tsv.surveyid = tssa.belongto)
             LEFT JOIN TBL_SURVEY tsvp
             ON (tsv.parentsurveyid = tsvp.surveyid)
             LEFT JOIN TBL_SURVEYFACILITYMAP tsf
             ON (tsv.surveyid = tsf.surveyid)
             JOIN TBL_SURVEYUSERMAP tsu
             ON (tsv.surveyid = tsu.belongto
             AND tsf.surveyuserid = tsu.surveyuserid)
             LEFT JOIN TBL_STUDY tsd
             ON (tssa.studyid = tsd.studyid)
             LEFT JOIN TBL_USERPROFILES tu
             ON (tsu.delegatetransid = tu.transcelerateuserid)
             LEFT JOIN TBL_IRUSERMAP tiru
             ON (tu.transcelerateuserid = tiru.transcelerateuserid)
             LEFT JOIN TBL_CONTACT tcu
             ON (tu.contactid = tcu.contactid)
             LEFT JOIN TBL_FACILITIES tf
             ON (tsf.facilityid = tf.facilityid)
             LEFT JOIN TBL_CONTACT tcf
             ON (tf.contactid = tcf.contactid)
             LEFT JOIN TBL_FACILITIES tfd
             ON (tsf.departmentid = tfd.facilityid)
             LEFT JOIN TBL_CONTACT tcd
             ON (tfd.contactid = tcd.contactid)
             LEFT JOIN TBL_ORGANIZATION tor
             ON (tssa.sponsororganizaionid  = tor.orgid)
        WHERE tsv.surveyid = ip_surveyid
        AND tsu.delegatetransid = ip_transcelerateuserid;

TYPE typ_cur_rec1 IS TABLE OF cur_rec1%ROWTYPE;
v_cur_rec1 typ_cur_rec1;

v_isdelegated   PLS_INTEGER:= 0;

BEGIN

  --Survey Response Integration
  --Check if Survey is Delegated
  SELECT COUNT(1) INTO v_isdelegated FROM TBL_SURVEYUSERMAP tsu WHERE tsu.belongto = ip_surveyid AND tsu.delegatetransid = ip_transcelerateuserid;
  IF v_isdelegated = 0 THEN
      OPEN cur_rec;
      LOOP
          FETCH cur_rec BULK COLLECT INTO v_cur_rec LIMIT gv_rec_limit;
          EXIT WHEN v_cur_rec.COUNT = 0;
    
          FORALL i IN v_cur_rec.FIRST..v_cur_rec.LAST
              INSERT INTO TBL_INTEG
                    (integid,surveyid,parentsurveyid,surveytitle,parentsurveytitle,surveytype,surveyrecipient,
                     surveystatus,surveyrecipientstatus,surveyaddedby,surveyduedate,
                     surveysentdate,surveylastreminderdate,pitransid,pisipuserid,piiruserid,
                     surveyresponsedate,referencecode,studyid,sipstudyid,studyname,
                     userid,transcelerateuserid,sipuserid,useririd,prefix,title,firstname,middlename,lastname,suffix,initials,isactive,
                     timezoneid,user_contactid,user_contacttype,user_addresstype,user_address1,user_address2,
                     user_address3,user_city,user_statename,user_statecd,user_countryname,user_countrycd,
                     user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,facilityid,facilityname,
                     irfacilityid,masterfacilitytypecode,isdepartment,departmentid,departmentname,departmenttypeid,
                     irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,fac_address1,fac_address2,
                     fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,fac_countrycd,fac_postalcode,
                     fac_phone1,fac_phone1ext,fac_fax,fac_email,dept_contactid,dept_contacttype,dept_addresstype,
                     dept_address1,dept_address2,dept_address3,dept_city,dept_statename,dept_statecd,dept_countryname,
                     dept_countrycd,dept_postalcode,dept_phone1,dept_phone1ext,dept_fax,dept_email,
                     orgid,orgcode,sipeventid,createdby,createddt,modifiedby,modifieddt)
              VALUES(seq_integ.NEXTVAL,v_cur_rec(i).surveyid,v_cur_rec(i).parentsurveyid,v_cur_rec(i).surveytitle,v_cur_rec(i).parentsurveytitle,v_cur_rec(i).surveytype,v_cur_rec(i).surveyrecipient,
                     v_cur_rec(i).surveystatus,v_cur_rec(i).surveyrecipientstatus,v_cur_rec(i).surveyaddedby,v_cur_rec(i).surveyduedate,
                     v_cur_rec(i).surveysentdate,v_cur_rec(i).surveylastreminderdate,v_cur_rec(i).pitransid,v_cur_rec(i).pisipuserid,v_cur_rec(i).piiruserid,
                     v_cur_rec(i).surveyresponsedate,v_cur_rec(i).referencecode,v_cur_rec(i).studyid,v_cur_rec(i).sipstudyid,v_cur_rec(i).studyname,
                     v_cur_rec(i).userid,v_cur_rec(i).transcelerateuserid,v_cur_rec(i).sipuserid,v_cur_rec(i).useririd,v_cur_rec(i).prefix,v_cur_rec(i).title,
                     v_cur_rec(i).firstname,v_cur_rec(i).middlename,v_cur_rec(i).lastname,v_cur_rec(i).suffix,v_cur_rec(i).initials,v_cur_rec(i).isactive,
                     v_cur_rec(i).timezoneid,v_cur_rec(i).user_contactid,v_cur_rec(i).user_contacttype,v_cur_rec(i).user_addresstype,v_cur_rec(i).user_address1,v_cur_rec(i).user_address2,
                     v_cur_rec(i).user_address3,v_cur_rec(i).user_city,v_cur_rec(i).user_statename,v_cur_rec(i).user_statecd,v_cur_rec(i).user_countryname,v_cur_rec(i).user_countrycd,
                     v_cur_rec(i).user_postalcode,v_cur_rec(i).user_phone1,v_cur_rec(i).user_phone1ext,v_cur_rec(i).user_fax,v_cur_rec(i).user_email,v_cur_rec(i).facilityid,v_cur_rec(i).facilityname,
                     v_cur_rec(i).irfacilityid,v_cur_rec(i).masterfacilitytypecode,v_cur_rec(i).isdepartment,v_cur_rec(i).departmentid,v_cur_rec(i).departmentname,v_cur_rec(i).departmenttypeid,
                     v_cur_rec(i).irdepartmentid,v_cur_rec(i).fac_contactid,v_cur_rec(i).fac_contacttype,v_cur_rec(i).fac_addresstype,v_cur_rec(i).fac_address1,v_cur_rec(i).fac_address2,
                     v_cur_rec(i).fac_address3,v_cur_rec(i).fac_city,v_cur_rec(i).fac_statename,v_cur_rec(i).fac_statecd,v_cur_rec(i).fac_countryname,v_cur_rec(i).fac_countrycd,v_cur_rec(i).fac_postalcode,
                     v_cur_rec(i).fac_phone1,v_cur_rec(i).fac_phone1ext,v_cur_rec(i).fac_fax,v_cur_rec(i).fac_email,v_cur_rec(i).dept_contactid,v_cur_rec(i).dept_contacttype,v_cur_rec(i).dept_addresstype,
                     v_cur_rec(i).dept_address1,v_cur_rec(i).dept_address2,v_cur_rec(i).dept_address3,v_cur_rec(i).dept_city,v_cur_rec(i).dept_statename,v_cur_rec(i).dept_statecd,v_cur_rec(i).dept_countryname,
                     v_cur_rec(i).dept_countrycd,v_cur_rec(i).dept_postalcode,v_cur_rec(i).dept_phone1,v_cur_rec(i).dept_phone1ext,v_cur_rec(i).dept_fax,v_cur_rec(i).dept_email,
                     v_cur_rec(i).orgid,v_cur_rec(i).orgcode,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
              RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;
    
              FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
                  SP_INTEG(v_integidlist(j),ip_surveyid,v_orgidlist(j),ip_sipeventid,gv_eventtype_surveyresponse);
                  
                  --Populate Survey Response details for Integration ID
                  SP_SET_INTEG_MULTIVALUE(v_integidlist(j),ip_surveyid,ip_transcelerateuserid,gv_keytype_surveyquesans);
                  
              END LOOP;
    
      END LOOP;
      CLOSE cur_rec;
  ELSE
      OPEN cur_rec1;
      LOOP
          FETCH cur_rec1 BULK COLLECT INTO v_cur_rec1 LIMIT gv_rec_limit;
          EXIT WHEN v_cur_rec1.COUNT = 0;
    
          FORALL i IN v_cur_rec1.FIRST..v_cur_rec1.LAST
              INSERT INTO TBL_INTEG
                    (integid,surveyid,parentsurveyid,surveytitle,parentsurveytitle,surveytype,surveyrecipient,
                     surveystatus,surveyrecipientstatus,surveyaddedby,surveyduedate,
                     surveysentdate,surveylastreminderdate,pitransid,pisipuserid,piiruserid,
                     surveyresponsedate,referencecode,studyid,sipstudyid,studyname,
                     userid,transcelerateuserid,sipuserid,useririd,prefix,title,firstname,middlename,lastname,suffix,initials,isactive,
                     timezoneid,user_contactid,user_contacttype,user_addresstype,user_address1,user_address2,
                     user_address3,user_city,user_statename,user_statecd,user_countryname,user_countrycd,
                     user_postalcode,user_phone1,user_phone1ext,user_fax,user_email,facilityid,facilityname,
                     irfacilityid,masterfacilitytypecode,isdepartment,departmentid,departmentname,departmenttypeid,
                     irdepartmentid,fac_contactid,fac_contacttype,fac_addresstype,fac_address1,fac_address2,
                     fac_address3,fac_city,fac_statename,fac_statecd,fac_countryname,fac_countrycd,fac_postalcode,
                     fac_phone1,fac_phone1ext,fac_fax,fac_email,dept_contactid,dept_contacttype,dept_addresstype,
                     dept_address1,dept_address2,dept_address3,dept_city,dept_statename,dept_statecd,dept_countryname,
                     dept_countrycd,dept_postalcode,dept_phone1,dept_phone1ext,dept_fax,dept_email,
                     orgid,orgcode,sipeventid,createdby,createddt,modifiedby,modifieddt)
              VALUES(seq_integ.NEXTVAL,v_cur_rec1(i).surveyid,v_cur_rec1(i).parentsurveyid,v_cur_rec1(i).surveytitle,v_cur_rec1(i).parentsurveytitle,v_cur_rec1(i).surveytype,v_cur_rec1(i).surveyrecipient,
                     v_cur_rec1(i).surveystatus,v_cur_rec1(i).surveyrecipientstatus,v_cur_rec1(i).surveyaddedby,v_cur_rec1(i).surveyduedate,
                     v_cur_rec1(i).surveysentdate,v_cur_rec1(i).surveylastreminderdate,v_cur_rec1(i).pitransid,v_cur_rec1(i).pisipuserid,v_cur_rec1(i).piiruserid,
                     v_cur_rec1(i).surveyresponsedate,v_cur_rec1(i).referencecode,v_cur_rec1(i).studyid,v_cur_rec1(i).sipstudyid,v_cur_rec1(i).studyname,
                     v_cur_rec1(i).userid,v_cur_rec1(i).transcelerateuserid,v_cur_rec1(i).sipuserid,v_cur_rec1(i).useririd,v_cur_rec1(i).prefix,v_cur_rec1(i).title,
                     v_cur_rec1(i).firstname,v_cur_rec1(i).middlename,v_cur_rec1(i).lastname,v_cur_rec1(i).suffix,v_cur_rec1(i).initials,v_cur_rec1(i).isactive,
                     v_cur_rec1(i).timezoneid,v_cur_rec1(i).user_contactid,v_cur_rec1(i).user_contacttype,v_cur_rec1(i).user_addresstype,v_cur_rec1(i).user_address1,v_cur_rec1(i).user_address2,
                     v_cur_rec1(i).user_address3,v_cur_rec1(i).user_city,v_cur_rec1(i).user_statename,v_cur_rec1(i).user_statecd,v_cur_rec1(i).user_countryname,v_cur_rec1(i).user_countrycd,
                     v_cur_rec1(i).user_postalcode,v_cur_rec1(i).user_phone1,v_cur_rec1(i).user_phone1ext,v_cur_rec1(i).user_fax,v_cur_rec1(i).user_email,v_cur_rec1(i).facilityid,v_cur_rec1(i).facilityname,
                     v_cur_rec1(i).irfacilityid,v_cur_rec1(i).masterfacilitytypecode,v_cur_rec1(i).isdepartment,v_cur_rec1(i).departmentid,v_cur_rec1(i).departmentname,v_cur_rec1(i).departmenttypeid,
                     v_cur_rec1(i).irdepartmentid,v_cur_rec1(i).fac_contactid,v_cur_rec1(i).fac_contacttype,v_cur_rec1(i).fac_addresstype,v_cur_rec1(i).fac_address1,v_cur_rec1(i).fac_address2,
                     v_cur_rec1(i).fac_address3,v_cur_rec1(i).fac_city,v_cur_rec1(i).fac_statename,v_cur_rec1(i).fac_statecd,v_cur_rec1(i).fac_countryname,v_cur_rec1(i).fac_countrycd,v_cur_rec1(i).fac_postalcode,
                     v_cur_rec1(i).fac_phone1,v_cur_rec1(i).fac_phone1ext,v_cur_rec1(i).fac_fax,v_cur_rec1(i).fac_email,v_cur_rec1(i).dept_contactid,v_cur_rec1(i).dept_contacttype,v_cur_rec1(i).dept_addresstype,
                     v_cur_rec1(i).dept_address1,v_cur_rec1(i).dept_address2,v_cur_rec1(i).dept_address3,v_cur_rec1(i).dept_city,v_cur_rec1(i).dept_statename,v_cur_rec1(i).dept_statecd,v_cur_rec1(i).dept_countryname,
                     v_cur_rec1(i).dept_countrycd,v_cur_rec1(i).dept_postalcode,v_cur_rec1(i).dept_phone1,v_cur_rec1(i).dept_phone1ext,v_cur_rec1(i).dept_fax,v_cur_rec1(i).dept_email,
                     v_cur_rec1(i).orgid,v_cur_rec1(i).orgcode,ip_sipeventid,gv_createdby,v_createddt,NULL,NULL)
              RETURNING integid,orgid BULK COLLECT INTO v_integidlist,v_orgidlist;
    
              FOR j IN v_integidlist.FIRST..v_integidlist.LAST LOOP
                  SP_INTEG(v_integidlist(j),ip_surveyid,v_orgidlist(j),ip_sipeventid,gv_eventtype_surveyresponse);
                  
                  --Populate Survey Response details for Integration ID
                  SP_SET_INTEG_MULTIVALUE(v_integidlist(j),ip_surveyid,ip_transcelerateuserid,gv_keytype_surveyquesans);
                  
              END LOOP;
    
      END LOOP;
      CLOSE cur_rec1;
  END IF;
  
  OPEN op_surveyresponse FOR
       SELECT * FROM TBL_INTEG
       WHERE integid IN (SELECT * FROM TABLE(v_integidlist));
END SP_SET_SURVEY_RESPONSE_INT;

PROCEDURE SP_VEEVA_INTEG
(
ip_veeva_integ  IN gtyp_veeva_integ
)
IS
v_createddt         DATE:= SYSDATE;
BEGIN
    --Populate Veeva Integration Attributes
    FOR i IN ip_veeva_integ.FIRST..ip_veeva_integ.LAST LOOP
        INSERT INTO TBL_INTEG_VEEVA_MAP 
              (integveevamapid,integid,orgid,externalsystemid,orgextsyseventmapid,
               extsysstudyid,extsysstudycountryid,extsyscompoundid,
               extsyssiteid,extsysuserroleid,extsysuserid,extsyspersonid,
               extsyscommonvaultuserid,createdby,createddt,modifiedby,modifieddt)
        VALUES(SEQ_INTEG_VEEVA_MAP.NEXTVAL,ip_veeva_integ(i).integid,ip_veeva_integ(i).orgid,
               ip_veeva_integ(i).externalsystemid,ip_veeva_integ(i).orgextsyseventmapid,ip_veeva_integ(i).extsysstudyid,
               ip_veeva_integ(i).extsysstudycountryid,ip_veeva_integ(i).extsyscompoundid,ip_veeva_integ(i).extsyssiteid,
               ip_veeva_integ(i).extsysuserroleid,ip_veeva_integ(i).extsysuserid,ip_veeva_integ(i).extsyspersonid,
               ip_veeva_integ(i).extsyscommonvaultuserid,gv_createdby,v_createddt,NULL,NULL);
    END LOOP;
    
END SP_VEEVA_INTEG;

PROCEDURE SP_SAFED_INTEG
(
ip_safed_integ  IN gtyp_safed_integ
)
IS
v_createddt         DATE:= SYSDATE;
BEGIN
    --Populate SafeD Integration Attributes
    FOR i IN ip_safed_integ.FIRST..ip_safed_integ.LAST LOOP
        INSERT INTO TBL_INTEG_SAFED_MAP 
              (integsafedmapid,integid,orgid,externalsystemid,orgextsyseventmapid,
               createdby,createddt,modifiedby,modifieddt)
        VALUES(SEQ_INTEG_SAFED_MAP.NEXTVAL,ip_safed_integ(i).integid,ip_safed_integ(i).orgid,
               ip_safed_integ(i).externalsystemid,ip_safed_integ(i).orgextsyseventmapid,
               gv_createdby,v_createddt,NULL,NULL);
    END LOOP;
END SP_SAFED_INTEG;

PROCEDURE SP_GOBALTO_INTEG
(
ip_gobalto_integ  IN gtyp_gobalto_integ
)
IS
v_createddt         DATE:= SYSDATE;
BEGIN
    --Populate GobalTO Integration Attributes    
    FOR i IN ip_gobalto_integ.FIRST..ip_gobalto_integ.LAST LOOP
        INSERT INTO TBL_INTEG_GOBALTO_MAP 
              (integgobaltomapid,integid,orgid,externalsystemid,orgextsyseventmapid,
               createdby,createddt,modifiedby,modifieddt)
        VALUES(SEQ_INTEG_GOBALTO_MAP.NEXTVAL,ip_gobalto_integ(i).integid,ip_gobalto_integ(i).orgid,
               ip_gobalto_integ(i).externalsystemid,ip_gobalto_integ(i).orgextsyseventmapid,
               gv_createdby,v_createddt,NULL,NULL);
    END LOOP;
END SP_GOBALTO_INTEG;

PROCEDURE SP_CTMS_INTEG
(
ip_ctms_integ  IN gtyp_ctms_integ
)
IS
v_createddt         DATE:= SYSDATE;
BEGIN
    --Populate CTMS Integration Attributes
    FOR i IN ip_ctms_integ.FIRST..ip_ctms_integ.LAST LOOP
        INSERT INTO TBL_INTEG_CTMS_MAP 
              (integctmsmapid,integid,orgid,externalsystemid,orgextsyseventmapid,
               createdby,createddt,modifiedby,modifieddt)
        VALUES(SEQ_INTEG_CTMS_MAP.NEXTVAL,ip_ctms_integ(i).integid,ip_ctms_integ(i).orgid,
               ip_ctms_integ(i).externalsystemid,ip_ctms_integ(i).orgextsyseventmapid,
               gv_createdby,v_createddt,NULL,NULL);
    END LOOP;
END SP_CTMS_INTEG;

PROCEDURE SP_INTEG
(
ip_integid      IN TBL_INTEG.integid%TYPE,
ip_pkid         IN VARCHAR2,
ip_orgid        IN TBL_ORGANIZATION.orgid%TYPE,
ip_sipeventid   IN TBL_SIP_EVENT.sipeventid%TYPE,
ip_eventtype    IN VARCHAR2
)
IS
v_veeva_integ               gtyp_veeva_integ := gtyp_veeva_integ();
v_safed_integ               gtyp_safed_integ := gtyp_safed_integ();
v_gobalto_integ             gtyp_gobalto_integ := gtyp_gobalto_integ();
v_ctms_integ                gtyp_ctms_integ := gtyp_ctms_integ();
v_extsysstudyid             TBL_INTEG_VEEVA_MAP.extsysstudyid%TYPE;
v_extsysstudycountryid      TBL_INTEG_VEEVA_MAP.extsysstudycountryid%TYPE;
v_extsyscompoundid          TBL_INTEG_VEEVA_MAP.extsyscompoundid%TYPE;
v_extsyssiteid              TBL_INTEG_VEEVA_MAP.extsyssiteid%TYPE;
v_extsysuserroleid          TBL_INTEG_VEEVA_MAP.extsysuserroleid%TYPE;
v_extsysuserid              TBL_INTEG_VEEVA_MAP.extsysuserid%TYPE;
v_extsyspersonid            TBL_INTEG_VEEVA_MAP.extsyspersonid%TYPE;
v_extsyscommonvaultuserid   TBL_INTEG_VEEVA_MAP.extsyscommonvaultuserid%TYPE;
v_userid                    TBL_USERPROFILES.userid%TYPE;
v_studyid                   TBL_STUDY.studyid%TYPE;
v_compoundid                TBL_STUDY.compoundid%TYPE;
v_siteid                    TBL_SITE.siteid%TYPE;
v_studycountryid            TBL_STUDYCOUNTRYMILESTONE.studycountryid%TYPE;
v_userroleid                TBL_USERROLEMAP.userroleid%TYPE;
v_createddt         DATE:= SYSDATE;
BEGIN
    v_veeva_integ.DELETE;
    v_safed_integ.DELETE;
    v_gobalto_integ.DELETE;
    v_ctms_integ.DELETE;
    --Get External System Integration Attributes
    FOR i IN (SELECT tes.externalsystemid,tes.external_system_code extsys,toeem.orgextsyseventmapid
              FROM TBL_EXTERNAL_SYSTEM tes,TBL_ORG_EXTSYS_MAP toem, TBL_ORG_EXTSYS_EVENT_MAP toeem
              WHERE tes.externalsystemid = toem.externalsystemid
              AND toem.orgextsysmapid = toeem.orgextsysmapid
              AND toem.orgid = ip_orgid
              AND toeem.sipeventid = ip_sipeventid) LOOP
              
          --Check Event Type to get External System Attributes
          IF ip_eventtype = gv_eventtype_study THEN
             --Get Study ID
             v_studyid := ip_pkid;
             --Get Compound ID
             BEGIN
                SELECT ts.compoundid INTO v_compoundid FROM TBL_STUDY ts WHERE ts.studyid = ip_pkid; 
             EXCEPTION
                WHEN OTHERS THEN
                     v_compoundid := NULL;
             END;
             --Get Site ID
             v_siteid := NULL;
             --Get Study Country ID
             v_studycountryid := NULL;
             --Get User ID
             v_userid := NULL;
             --Get User Role ID
             v_userroleid := NULL;
          ELSIF ip_eventtype = gv_eventtype_site OR
                ip_eventtype = gv_eventtype_updatesite THEN
             --Get Study ID   
             BEGIN
                SELECT tsi.studyid INTO v_studyid FROM TBL_SITE tsi WHERE tsi.siteid = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_studyid := NULL;
             END;
             --Get Compound ID
             BEGIN
                SELECT ts.compoundid INTO v_compoundid FROM TBL_SITE tsi, TBL_STUDY ts WHERE tsi.studyid = ts.studyid AND tsi.siteid = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_compoundid := NULL;
             END;
             --Get Site ID
             v_siteid := ip_pkid;
             --Get Study Country ID
             v_studycountryid := NULL;
             --Get User ID
             BEGIN
                SELECT tsi.piid INTO v_userid FROM TBL_SITE tsi WHERE tsi.siteid = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_userid := NULL;
             END;
             --Get User Role ID
             v_userroleid := NULL;
          ELSIF ip_eventtype = gv_eventtype_studycountry  THEN
             --Get Study ID 
             BEGIN
                SELECT tscm.studyid INTO v_studyid FROM TBL_STUDYCOUNTRYMILESTONE tscm WHERE tscm.studycountryid = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_studyid := NULL;
             END;
             --Get Compound ID
             BEGIN
                SELECT ts.compoundid INTO v_compoundid FROM TBL_STUDYCOUNTRYMILESTONE tscm, TBL_STUDY ts WHERE tscm.studyid = ts.studyid AND tscm.studycountryid = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_compoundid := NULL;
             END;
             --Get Site ID
             v_siteid := NULL;
             --Get Study Country ID
             v_studycountryid := ip_pkid;
             --Get User ID
             v_userid := NULL;
             --Get User Role ID
             v_userroleid := NULL;
          ELSIF ip_eventtype = gv_eventtype_staffrole OR
                ip_eventtype = gv_eventtype_useraccess OR 
                ip_eventtype = gv_eventtype_sponsoraccess OR
                ip_eventtype = gv_eventtype_usercv THEN
             --Get Study ID 
             BEGIN
                SELECT turm.studyid INTO v_studyid FROM TBL_USERROLEMAP turm WHERE turm.userroleid = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_studyid := NULL;
             END;
             --Get Compound ID
             BEGIN
                SELECT ts.compoundid INTO v_compoundid FROM TBL_USERROLEMAP turm, TBL_STUDY ts WHERE turm.studyid = ts.studyid AND turm.userroleid = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_compoundid := NULL;
             END;
             --Get Site ID
             BEGIN
                SELECT turm.siteid INTO v_siteid FROM TBL_USERROLEMAP turm WHERE turm.userroleid = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_siteid := NULL;
             END;
             --Get Study Country ID
             v_studycountryid := NULL;
             --Get User ID
             BEGIN
                SELECT turm.userid INTO v_userid FROM TBL_USERROLEMAP turm WHERE turm.userroleid = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_userid := NULL;
             END;
             --Get User Role ID
             v_userroleid := ip_pkid;
          ELSIF ip_eventtype = gv_eventtype_userdoc OR 
                ip_eventtype = gv_eventtype_1572 THEN
             --Get Study ID 
             BEGIN
                SELECT td.studyid INTO v_studyid FROM TBL_DOCUMENTS td WHERE td.documentid = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_studyid := NULL;
             END;
             --Get Compound ID
             v_compoundid := NULL;
             --Get Site ID
             BEGIN
                SELECT td.siteid INTO v_siteid FROM TBL_DOCUMENTS td WHERE td.documentid = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_siteid := NULL;
             END;
             --Get Study Country ID
             v_studycountryid := NULL;
             --Get User ID
             BEGIN
                SELECT td.docuserid INTO v_userid FROM TBL_DOCUMENTS td WHERE td.documentid = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_userid := NULL;
             END;
             --Get User Role ID
             v_userroleid := NULL;
          ELSIF ip_eventtype = gv_eventtype_sponsordeact THEN
             --Get Study ID
             v_studyid := SUBSTR(ip_pkid,INSTR(ip_pkid,gv_delimiter_attherate)+1,INSTR(ip_pkid,gv_delimiter_attherate,1,2)-(INSTR(ip_pkid,gv_delimiter_attherate)+1));
             --Get Compound ID
             v_compoundid := NULL;
             --Get Site ID
             v_siteid := SUBSTR(ip_pkid,INSTR(ip_pkid,gv_delimiter_attherate,1,2)+1);
             --Get Study Country ID
             v_studycountryid := NULL;
             --Get User ID
             v_userid := SUBSTR(ip_pkid,1,INSTR(ip_pkid,gv_delimiter_attherate)-1);
             --Get User Role ID
             v_userroleid := NULL;
          ELSIF ip_eventtype = gv_eventtype_usertrng THEN
             --Get Study ID 
             BEGIN
                SELECT tuts.study_id INTO v_studyid FROM TBL_USER_TRAINING_STATUS tuts WHERE tuts.id = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_studyid := NULL;
             END;
             --Get Compound ID
             v_compoundid := NULL;
             --Get Site ID
             BEGIN
                SELECT tuts.site_id INTO v_siteid FROM TBL_USER_TRAINING_STATUS tuts WHERE tuts.id = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_siteid := NULL;
             END;
             --Get Study Country ID
             v_studycountryid := NULL;
             --Get User ID
             BEGIN
                SELECT tuts.user_id INTO v_userid FROM TBL_USER_TRAINING_STATUS tuts WHERE tuts.id = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_userid := NULL;
             END;
             --Get User Role ID
             v_userroleid := NULL;
          ELSIF ip_eventtype = gv_eventtype_userdeact THEN
             --Get Study ID 
             BEGIN
                SELECT tudl.studyid INTO v_studyid FROM TBL_USERDEACTIVATIONLOG tudl WHERE tudl.userdeactivationid = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_studyid := NULL;
             END;
             --Get Compound ID
             v_compoundid := NULL;
             --Get Site ID
             BEGIN
                SELECT tudl.siteid INTO v_siteid FROM TBL_USERDEACTIVATIONLOG tudl WHERE tudl.userdeactivationid = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_siteid := NULL;
             END;
             --Get Study Country ID
             v_studycountryid := NULL;
             --Get User ID
             v_userid := NULL;
             --Get User Role ID
             v_userroleid := NULL;
          ELSIF ip_eventtype = gv_eventtype_accessmod THEN
             --Get Study ID 
             BEGIN
                SELECT tamr.studyid INTO v_studyid FROM TBL_ACESSMODIFICATIONREQUEST tamr WHERE tamr.acessmodreqid = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_studyid := NULL;
             END;
             --Get Compound ID
             v_compoundid := NULL;
             --Get Site ID
             BEGIN
                SELECT tamr.siteid INTO v_siteid FROM TBL_ACESSMODIFICATIONREQUEST tamr WHERE tamr.acessmodreqid = ip_pkid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_siteid := NULL;
             END;
             --Get Study Country ID
             v_studycountryid := NULL;
             --Get User ID
             v_userid := NULL;
             --Get User Role ID
             v_userroleid := NULL;
          END IF;
          
          --Get External System Study ID
          IF v_studyid IS NOT NULL THEN
             BEGIN
                  SELECT tsem.extsysstudyid 
                  INTO v_extsysstudyid
                  FROM TBL_STUDY_EXTSYS_MAP tsem
                  WHERE tsem.externalsystemid = i.externalsystemid
                  AND tsem.orgid = ip_orgid
                  AND tsem.studyid = v_studyid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_extsysstudyid := NULL;
             END;
          END IF;
          
          --Get External System Compound ID
          IF v_compoundid IS NOT NULL THEN
             BEGIN
                  SELECT tcem.extsyscompoundid
                  INTO v_extsyscompoundid
                  FROM TBL_COMPOUND_EXTSYS_MAP tcem
                  WHERE tcem.externalsystemid = i.externalsystemid
                  AND tcem.compoundid = v_compoundid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_extsyscompoundid := NULL;
             END;
          END IF;
          
          --Get External System Study Country ID
          IF v_studyid IS NOT NULL AND v_studycountryid IS NOT NULL THEN
             BEGIN
                 SELECT tscem.extsysstudycountryid
                 INTO v_extsysstudycountryid
                 FROM TBL_STUDYCOUNTRYMILESTONE tscm,TBL_STUDYCOUNTRY_EXTSYS_MAP tscem,TBL_COUNTRIES tcnt
                 WHERE tscm.studycountryid = tscem.studycountryid(+)
                 AND tscem.externalsystemid = i.externalsystemid
                 AND tscm.countryid = tcnt.countryid
                 AND tscm.studyid = v_studyid
                 AND tcnt.countrycd = (SELECT tc.countrycd
                                       FROM TBL_STUDY ts, 
                                            TBL_STUDYCOUNTRYMILESTONE tscm,
                                            TBL_COUNTRIES tc
                                       WHERE ts.studyid = tscm.studyid
                                       AND tscm.countryid = tc.countryid
                                       AND tscm.studycountryid = v_studycountryid)
                 AND tscm.isactive = 'Y';
             EXCEPTION
                WHEN OTHERS THEN
                     v_extsysstudycountryid := NULL;        
             END;
          END IF;
          
          --Get External System Site ID
          IF v_siteid IS NOT NULL THEN
             BEGIN
                  SELECT tsem.extsyssiteid 
                  INTO v_extsyssiteid
                  FROM TBL_SITE_EXTSYS_MAP tsem
                  WHERE tsem.externalsystemid = i.externalsystemid
                  AND tsem.orgid = ip_orgid
                  AND tsem.siteid = v_siteid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_extsyssiteid := NULL;
             END;
          END IF;
          
          --Get External System User ID, Person ID and Common Vault User ID
          IF v_userid IS NOT NULL THEN
             BEGIN
                  SELECT tuem.extsysuserid,tuem.extsyspersonid,tuem.extsyscommonvaultuserid
                  INTO v_extsysuserid,v_extsyspersonid,v_extsyscommonvaultuserid
                  FROM TBL_USER_EXTSYS_MAP tuem
                  WHERE tuem.externalsystemid = i.externalsystemid
                  AND tuem.orgid = ip_orgid
                  AND tuem.userid = v_userid;
             EXCEPTION
                WHEN OTHERS THEN
                     v_extsysuserid := NULL;
                     v_extsyspersonid := NULL;
                     v_extsyscommonvaultuserid := NULL;
             END;
          END IF;
          
          --Get External System User Role ID
          IF v_userroleid IS NOT NULL THEN
             BEGIN
                  SELECT turesm.extsysuserroleid
                  INTO v_extsysuserroleid
                  FROM TBL_USERROLE_EXTSYS_MAP turesm
                  WHERE turesm.externalsystemid = i.externalsystemid
                  AND turesm.orgid = ip_orgid
                  AND turesm.userroleid = v_userroleid;
             EXCEPTION
                 WHEN OTHERS THEN
                      v_extsysuserroleid := NULL;
             END;
          END IF;
          
          --Veeva Attributes     
          IF i.extsys = gv_extsys_veeva THEN      
             v_veeva_integ.EXTEND;
             v_veeva_integ(v_veeva_integ.COUNT).integid := ip_integid;
             v_veeva_integ(v_veeva_integ.COUNT).orgid := ip_orgid;
             v_veeva_integ(v_veeva_integ.COUNT).externalsystemid := i.externalsystemid;
             v_veeva_integ(v_veeva_integ.COUNT).orgextsyseventmapid := i.orgextsyseventmapid;
             v_veeva_integ(v_veeva_integ.COUNT).extsysstudyid := v_extsysstudyid;
             v_veeva_integ(v_veeva_integ.COUNT).extsyscompoundid := v_extsyscompoundid;
             v_veeva_integ(v_veeva_integ.COUNT).extsysstudycountryid := v_extsysstudycountryid;
             v_veeva_integ(v_veeva_integ.COUNT).extsyssiteid := v_extsyssiteid;                 
             v_veeva_integ(v_veeva_integ.COUNT).extsysuserroleid := v_extsysuserroleid;              
             v_veeva_integ(v_veeva_integ.COUNT).extsysuserid := v_extsysuserid;                
             v_veeva_integ(v_veeva_integ.COUNT).extsyspersonid := v_extsyspersonid;              
             v_veeva_integ(v_veeva_integ.COUNT).extsyscommonvaultuserid := v_extsyscommonvaultuserid; 
          --SafeD Attributes 
          ELSIF i.extsys = gv_extsys_safed THEN  
             v_safed_integ.EXTEND;
             v_safed_integ(v_safed_integ.COUNT).integid := ip_integid;
             v_safed_integ(v_safed_integ.COUNT).orgid := ip_orgid;
             v_safed_integ(v_safed_integ.COUNT).externalsystemid := i.externalsystemid;
             v_safed_integ(v_safed_integ.COUNT).orgextsyseventmapid := i.orgextsyseventmapid;
          ELSIF i.extsys = gv_extsys_gobalto THEN  
             v_gobalto_integ.EXTEND;
             v_gobalto_integ(v_gobalto_integ.COUNT).integid := ip_integid;
             v_gobalto_integ(v_gobalto_integ.COUNT).orgid := ip_orgid;
             v_gobalto_integ(v_gobalto_integ.COUNT).externalsystemid := i.externalsystemid;
             v_gobalto_integ(v_gobalto_integ.COUNT).orgextsyseventmapid := i.orgextsyseventmapid;
          ELSIF i.extsys = gv_extsys_ctms THEN  
             v_ctms_integ.EXTEND;
             v_ctms_integ(v_ctms_integ.COUNT).integid := ip_integid;
             v_ctms_integ(v_ctms_integ.COUNT).orgid := ip_orgid;
             v_ctms_integ(v_ctms_integ.COUNT).externalsystemid := i.externalsystemid;
             v_ctms_integ(v_ctms_integ.COUNT).orgextsyseventmapid := i.orgextsyseventmapid;
          END IF;
          
    END LOOP;
    
    --Set Veeva Integration
    IF v_veeva_integ.COUNT <> 0 THEN
       SP_VEEVA_INTEG(v_veeva_integ);
    END IF;

    --Set SafeD Integration
    IF v_safed_integ.COUNT <> 0 THEN
       SP_SAFED_INTEG(v_safed_integ);
    END IF;

    --Set GobalTO Integration
    IF v_gobalto_integ.COUNT <> 0 THEN
       SP_GOBALTO_INTEG(v_gobalto_integ);
    END IF;

    --Set CTMS Integration
    IF v_ctms_integ.COUNT <> 0 THEN
       SP_CTMS_INTEG(v_ctms_integ);
    END IF;
    
END SP_INTEG;

PROCEDURE SP_USERROLE_EXTSYS
(
ip_userroleid       IN TBL_USERROLEMAP.userroleid%TYPE,
ip_sipeventid       IN TBL_SIP_EVENT.sipeventid%TYPE
)
IS
v_createddt         DATE:= SYSDATE;
BEGIN

    --Make entry into TBL_USERROLE_EXTSYS_MAP for each External System mapped to Study Organization
    INSERT INTO TBL_USERROLE_EXTSYS_MAP
           (userroleextsysmapid,userroleid,orgid,externalsystemid,extsysuserroleid,createdby,createddt,modifiedby,modifieddt)
    SELECT SEQ_USERROLE_EXTSYS_MAP.NEXTVAL,turm.userroleid,toem.orgid,tes.externalsystemid,NULL,gv_createdby,v_createddt,NULL,NULL
    FROM TBL_EXTERNAL_SYSTEM tes,
         TBL_ORG_EXTSYS_MAP toem, 
         TBL_ORG_EXTSYS_EVENT_MAP toeem, 
         TBL_USERROLEMAP turm, 
         TBL_STUDY ts
    WHERE tes.externalsystemid = toem.externalsystemid
    AND toem.orgextsysmapid = toeem.orgextsysmapid
    AND turm.studyid = ts.studyid
    AND ts.orgid = toem.orgid
    AND turm.userroleid = ip_userroleid
    AND toeem.sipeventid = ip_sipeventid
    AND NOT EXISTS (SELECT 1
                    FROM TBL_USERROLE_EXTSYS_MAP turem
                    WHERE turem.userroleid = turm.userroleid
                    AND turem.orgid = toem.orgid
                    AND turem.externalsystemid = tes.externalsystemid);
    
END SP_USERROLE_EXTSYS;

PROCEDURE SP_SET_INTEG_MULTIVALUE
(
ip_integid   IN TBL_INTEG.integid%TYPE,
ip_pk1       IN NUMBER,
ip_pk2       IN VARCHAR2,
ip_keytype   IN TBL_INTEG_MULTIVALUE.keytype%TYPE 
)
IS
v_createddt         DATE:= SYSDATE;
BEGIN
    --Populate Multiple Value Attributes for Integration
    IF ip_keytype = gv_keytype_systemaccess THEN
       --System Access Request
       INSERT INTO TBL_INTEG_MULTIVALUE (multivalueid,integid,keytype,attributekey,attributevalue,otherattributevalue,createdby,createddt,modifiedby,modifieddt)
       SELECT SEQ_INTEG_MULTIVALUE.NEXTVAL,ip_integid,ip_keytype,tosa.systemname,tosa.accesstype,NULL,gv_createdby,v_createddt,NULL,NULL
       FROM TBL_USERROLEMAP turm,
            TBL_SITESYSTEMACCESS tssa,
            TBL_ORGSYSTEMACCESS tosa
       WHERE turm.userid = tssa.userid
       AND turm.siteid = tssa.siteid
       AND tosa.orgsystemid = tssa.systemid
       AND turm.userroleid = ip_pk1;
    ELSIF ip_keytype = gv_keytype_regnumbody THEN
       --Registration Number and Body
       INSERT INTO TBL_INTEG_MULTIVALUE (multivalueid,integid,keytype,attributekey,attributevalue,otherattributevalue,createdby,createddt,modifiedby,modifieddt)
       SELECT SEQ_INTEG_MULTIVALUE.NEXTVAL,ip_integid,ip_keytype,tsr.registrationnumber,tsr.registerintbody,NULL,gv_createdby,v_createddt,NULL,NULL
       FROM TBL_SITEIRBREGISTRATION tsr
       WHERE siteirbid = ip_pk1;
    ELSIF ip_keytype = gv_keytype_accreditation THEN
       --LAB Accreditation
       INSERT INTO TBL_INTEG_MULTIVALUE (multivalueid,integid,keytype,attributekey,attributevalue,otherattributevalue,createdby,createddt,modifiedby,modifieddt)
       SELECT SEQ_INTEG_MULTIVALUE.NEXTVAL,ip_integid,ip_keytype,tla.labaccreditationid,tla.labaccreditationname,tsla.otherlabaccreditation,gv_createdby,v_createddt,NULL,NULL
       FROM TBL_SITELABMAP tsl, 
            TBL_SITELABACCREDITATION tsla,
            TBL_LABACCREDITATION tla
       WHERE tsl.sitelabid = tsla.sitelabid
       AND tsla.labaccreditationid = tla.labaccreditationid
       AND tsl.sitelabid = ip_pk1;
    ELSIF ip_keytype = gv_keytype_surveyquesans THEN
       --Survey Question Answer
       INSERT INTO TBL_INTEG_MULTIVALUE (multivalueid,integid,keytype,attributekey,attributevalue,otherattributevalue,createdby,createddt,modifiedby,modifieddt)
       SELECT SEQ_INTEG_MULTIVALUE.NEXTVAL,ip_integid,ip_keytype,surveyquestitle,surveyanstitle,rank,gv_createdby,v_createddt,NULL,NULL
       FROM (
       SELECT DISTINCT tsv.surveyid,tsq.surveyquestitle,
              CASE 
                WHEN tsra.surveyansid = 0 AND tsra.isfreetext = 1 THEN
                     tsra.freetext
                ELSE
                     tsa.surveyanstitle
              END surveyanstitle,
              tsra.rank 
       FROM TBL_SURVEY tsv
            JOIN TBL_SURVEYUSERMAP tsu
            ON (tsv.surveyid = tsu.belongto)
            LEFT JOIN TBL_SURVEYRESPONSELIST tsrl
            ON (tsv.surveyid = tsrl.surveyid)
            LEFT JOIN TBL_SURVEYRESPONSE tsr
            ON (tsr.responselistid = tsrl.responselistid
            AND tsr.belongto = tsu.surveyusermapid)
            JOIN TBL_SURVEYRESPONSEANSWER tsra
            ON (tsra.surveyresponseid = tsr.surveyresponseid)
            LEFT JOIN TBL_SURVEYQUESTION tsq
            ON (tsq.surveyquesid = tsra.surveyquesid)
            LEFT JOIN TBL_SURVEYANSWER tsa
            ON (tsa.surveyansid = tsra.surveyansid)
       WHERE tsv.surveystatus IN (SELECT tsmd.surveymetadataid 
                                  FROM TBL_SURVEYMETADATA tsmd 
                                  WHERE tsmd.metadataname IN(gv_survey_status_received,gv_survey_status_submitted))
       AND tsv.surveyid = ip_pk1
       AND tsu.tranecelerateid = ip_pk2);
    END IF;
END SP_SET_INTEG_MULTIVALUE;

END PKG_INTEG;
/