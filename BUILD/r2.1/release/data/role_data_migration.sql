--Migration (1)

--Update default role in tbl_userprofiles

select count(*) as BEFORE_COUNT from tbl_userprofiles where roleid=(SELECT ROLEID FROM TBL_ROLES where ROLENAME ='Sponsor');

UPDATE TBL_USERPROFILES SET ROLEID =(SELECT ROLEID FROM TBL_ROLES where ROLENAME ='Sponsor'),MODIFIEDDT = SYSDATE, 
MODIFIEDBY = 'SYSTEM' WHERE  ISACTIVE='Y' AND ISSPONSOR='Y';

Commit;

select count(*) as AFTER_COUNT from tbl_userprofiles where roleid=(SELECT ROLEID FROM TBL_ROLES where ROLENAME ='Sponsor');



--Insert entry in TBL_USERROLEMAP:

select count(*) as BEFORE_COUNT from tbl_userrolemap where roleid=(SELECT ROLEID FROM TBL_ROLES where ROLENAME ='Sponsor');

INSERT INTO TBL_USERROLEMAP 
       (userroleid,userid,roleid,studyid,siteid,effectivestartdate,effectiveenddate,createdby,createddt,act_isintegrated,deact_isintegrated,countryid)
SELECT SEQ_USERROLEMAP.NEXTVAL,up.userid,(SELECT tr.roleid FROM TBL_ROLES tr WHERE tr.rolename = 'Sponsor') roleid,
       NULL,NULL,SYSDATE,NULL,'SYSTEM',SYSDATE,'Y','Y',NULL
FROM TBL_USERPROFILES up
WHERE up.issponsor = 'Y' and up.isactive='Y' ;

Commit;

select count(*) as AFTER_COUNT from tbl_userrolemap where roleid=(SELECT ROLEID FROM TBL_ROLES where ROLENAME ='Sponsor');



--Migration (2)

select count(*) as BEFORE_COUNT from TBL_USERDEACTIVATIONLOG where isactive='Y';

Update TBL_USERDEACTIVATIONLOG set isactive='Y',MODIFIEDDT = SYSDATE, MODIFIEDBY = 'SYSTEM';

Commit;

select count(*) as AFTER_COUNT from TBL_USERDEACTIVATIONLOG where isactive='Y';



--Migration (3) 


--TBL_Roles: RoleType value update 2 to 1

select count(*) as BEFORE_COUNT  from tbl_roles where ROLETYPEID =1;

UPDATE TBL_ROLES SET ROLETYPEID =1,MODIFIEDDT = SYSDATE, MODIFIEDBY = 'SYSTEM' 
WHERE ROLENAME='Survey Creator';

Commit;

select count(*) as AFTER_COUNT  from tbl_roles where ROLETYPEID =1;



--TBL_USERROLEMAP: 

--->An entry should be created for each StudyID for the MC(No. of entries for every survey creator) will be equal to no of studies present for the MC)-> Start date will be conveyed 

select count(*) as BEFORE_COUNT from tbl_userrolemap where ROLEID in (select roleid from tbl_roles where rolename='Survey Creator');


BEGIN
  FOR i IN( SELECT UR.USERID,UR.ROLEID,S.STUDYID,UR.EFFECTIVESTARTDATE,UR.EFFECTIVEENDDATE FROM TBL_USERROLEMAP UR JOIN 		TBL_USERPROFILES U ON U.USERID=UR.USERID JOIN TBL_STUDY S ON S.ORGID=U.ORGID  AND U.ISACTIVE='Y' 
			AND UR.ROLEID IN (SELECT ROLEID FROM TBL_ROLES WHERE ROLENAME='Survey Creator') 
			AND ( UR.EFFECTIVEENDDATE IS NULL OR UR.EFFECTIVEENDDATE > SYSDATE ) AND UR.STUDYID IS NULL AND S.STUDYID 
			IN (SELECT STUDYID FROM TBL_STUDY ST JOIN TBL_USERPROFILES UP ON UP.ORGID=ST.ORGID AND ST.ISACTIVE='Y') ) LOOP
          
		 
   INSERT INTO TBL_USERROLEMAP (userroleid,userid,roleid,studyid,effectivestartdate,effectiveenddate,createdby,createddt,act_isintegrated,deact_isintegrated,countryid) 
   VALUES (SEQ_USERROLEMAP.NEXTVAL,i.USERID,i.roleid,i.studyid,i.EFFECTIVESTARTDATE,i.EFFECTIVEENDDATE,'SYSTEM',sysdate,'Y','Y',NULL) ;

          
  END LOOP;
END;
/

commit;


select count(*) as AFTER_COUNT from tbl_userrolemap where ROLEID in (select roleid from tbl_roles where rolename='Survey Creator');

--TBL_SPONSORACCESSMGT:
--->  New  Entry needs to be added (start date will be conveyed, isfuturestudy flag should be 'Y' all the other flags should be Null)

select count(*) as BEFORE_COUNT from TBL_SPONSORACCESSMGT;

INSERT INTO TBL_SPONSORACCESSMGT
(ACCESSMGTID,USERID,STARTDT,ENDDT,COUNTRYID,ROLEID,ORGID,ISEXISTINGSTUDY,ISEXISTINGSITE,ISFUTURESTUDY,ISFUTURESITE,
STUDYID,NOOFASSIGNMENTS,CREATEDDT,CREATEDBY,MODIFIEDDT,MODIFIEDBY)
select SEQ_SPONSORACCESSMGT.NextVal,up.userid,SYSDATE,NULL,NULL,ur.roleid,up.ORGID,
NULL,NULL,'Y','N',NULL,NULL,SYSDATE,'SYSTEM',NULL,NULL from tbl_userprofiles up join tbl_userrolemap ur on up.userid=ur.USERID
and ur.EFFECTIVESTARTDATE<sysdate+1 and (ur.EFFECTIVEENDDATE IS NULL or ur.EFFECTIVEENDDATE > sysdate) AND ur.STUDYID IS NULL 
and ur.roleid in (select roleid from tbl_roles where rolename ='Survey Creator');

Commit;

select count(*) as AFTER_COUNT from TBL_SPONSORACCESSMGT;

--Migration (4)


--Update script to End date the roles in TBL_USERROLEMAP:

select count(*) as BEFORE_COUNT from tbl_userrolemap urm,tbl_roles r 
where urm.roleid=r.roleid and urm.studyid is null  and urm.EFFECTIVESTARTDATE<sysdate+1 and (urm.EFFECTIVEENDDATE is null 
or urm.EFFECTIVEENDDATE>sysdate) and r.roletypeid=1 and r.rolename not in('Survey Creator') and r.rolename in ('Study - Edit and View','Study - View Only');

select count(*) as BEFORE_COUNT from tbl_userrolemap urm,tbl_roles r 
where urm.roleid=r.roleid and urm.siteid is null  and urm.EFFECTIVESTARTDATE<sysdate+1 and (urm.EFFECTIVEENDDATE is null 
or urm.EFFECTIVEENDDATE>sysdate) and r.roletypeid=1 and r.rolename not in('Survey Creator') and r.rolename in ('Monitor');



BEGIN
  FOR i IN( select urm.userroleid from tbl_userrolemap urm,tbl_roles r 
		    where urm.roleid=r.roleid and urm.studyid is null  and urm.EFFECTIVESTARTDATE<sysdate+1 and (urm.EFFECTIVEENDDATE is null or urm.EFFECTIVEENDDATE>sysdate) and r.roletypeid=1 and r.rolename not in('Survey Creator') and r.rolename 
		    in ('Study - Edit and View','Study - View Only') ) LOOP
			
				update tbl_userrolemap set EFFECTIVEENDDATE=sysdate, modifieddt=sysdate, modifiedby='SYSTEM'
				where userroleid=i.userroleid;
	
	end loop;
	
	FOR j IN( select urm.userroleid from tbl_userrolemap urm,tbl_roles r 
            where urm.roleid=r.roleid and urm.siteid is null  and urm.EFFECTIVESTARTDATE<sysdate+1 and (urm.EFFECTIVEENDDATE is null or urm.EFFECTIVEENDDATE>sysdate) and r.roletypeid=1 and r.rolename not in('Survey Creator') and r.rolename in ('Monitor') ) LOOP
			
			update tbl_userrolemap set EFFECTIVEENDDATE=sysdate, modifieddt=sysdate, modifiedby='SYSTEM'
			where userroleid=j.userroleid;
    
  END LOOP;
  
END;
/

commit;


select count(*) as AFTER_COUNT from tbl_userrolemap urm,tbl_roles r 
where urm.roleid=r.roleid and urm.studyid is null  and urm.EFFECTIVESTARTDATE<sysdate+1 and (urm.EFFECTIVEENDDATE is null 
or urm.EFFECTIVEENDDATE>sysdate) and r.roletypeid=1 and r.rolename not in('Survey Creator') and r.rolename in ('Study - Edit and View','Study - View Only');

select count(*) as AFTER_COUNT from tbl_userrolemap urm,tbl_roles r 
where urm.roleid=r.roleid and urm.siteid is null  and urm.EFFECTIVESTARTDATE<sysdate+1 and (urm.EFFECTIVEENDDATE is null 
or urm.EFFECTIVEENDDATE>sysdate) and r.roletypeid=1 and r.rolename not in('Survey Creator') and r.rolename in ('Monitor');
