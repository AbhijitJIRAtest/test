insert into TBL_ROLES (ROLEID,ROLENAME,USERTYPE,ROLELEVEL,ROLETYPEID,CREATEDDT,CREATEDBY)
values (72,'Sponsor','Sponsor','Platform and StudySite',(select ROLETYPEID from TBL_ROLETYPE where ROLETYPE = 'Type 0'),SYSDATE,'SYSTEM') ;

insert into TBL_ROLES (ROLEID,ROLENAME,USERTYPE,ROLELEVEL,ROLETYPEID,CREATEDDT,CREATEDBY)
values (73,'General Safety User','Sponsor','Platform and StudySite',(select ROLETYPEID from TBL_ROLETYPE where ROLETYPE = 'Type I'),SYSDATE,'SYSTEM') ;

insert into TBL_ROLES (ROLEID,ROLENAME,USERTYPE,ROLELEVEL,ROLETYPEID,CREATEDDT,CREATEDBY)
values (74,'Local Safety Officer','Sponsor','Platform and StudySite',(select ROLETYPEID from TBL_ROLETYPE where ROLETYPE = 'Type I'),SYSDATE,'SYSTEM') ;

UPDATE TBL_ROLES SET ROLETYPEID=1 WHERE ROLENAME='Survey Creator';

commit;
UPDATE TBL_ROLES TR SET TR.ROLENAME='Safety Administrator' WHERE TR.ROLENAME='Safety Admin';
Commit;

UPDATE TBL_ROLES SET ROLENAME='SIP Training Administrator' WHERE ROLENAME='SIP Training Admin' ;
UPDATE TBL_ROLES SET ROLENAME='Sponsor Document Administrator' WHERE ROLENAME='Sponsor Document Admin' ;
UPDATE TBL_ROLES SET ROLENAME='SIP Document Administrator' WHERE ROLENAME='SIP Document Admin' ;

COMMIT;