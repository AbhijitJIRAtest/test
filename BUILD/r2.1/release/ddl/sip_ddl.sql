CREATE TABLE TBL_SPONSOR_BUSINESSUNIT 
(BUSINESSUNITID     	NUMBER(38,0) NOT NULL,
BUSINESSUNITNAME	VARCHAR2(500 CHAR),
ORGID             	NUMBER(38,0) NOT NULL,
MEMBUSSINESSCD		VARCHAR2(100 CHAR),
CREATEDDT	DATE     NOT NULL,
CREATEDBY	VARCHAR2(100 CHAR)	NOT NULL,
MODIFIEDDT	DATE,
MODIFIEDBY	VARCHAR2(100 CHAR)
);
ALTER TABLE TBL_SPONSOR_BUSINESSUNIT ADD CONSTRAINT TBL_SPONSOR_BUSINESSUNIT_PK PRIMARY KEY (BUSINESSUNITID);
ALTER TABLE TBL_SPONSOR_BUSINESSUNIT ADD CONSTRAINT TBL_SPONSOR_BUSINESSUNIT_FK FOREIGN KEY ( ORGID ) REFERENCES TBL_ORGANIZATION ( ORGID );

CREATE SEQUENCE SEQ_SPONSOR_BUSINESSUNIT MINVALUE 1 MAXVALUE 999999999999999999999999999 START WITH 1 INCREMENT BY 1 NOCACHE;

COMMENT ON TABLE TBL_SPONSOR_BUSINESSUNIT IS 'To accomodate Onboarding Sponsor user with Future Onboarding Date';
COMMENT ON COLUMN TBL_SPONSOR_BUSINESSUNIT.BUSINESSUNITID IS 'Business Unit Id sequence generated primary key';
COMMENT ON COLUMN TBL_SPONSOR_BUSINESSUNIT.BUSINESSUNITNAME IS 'Business Unit Name';
COMMENT ON COLUMN TBL_SPONSOR_BUSINESSUNIT.ORGID IS 'Organization id'; 
COMMENT ON COLUMN TBL_SPONSOR_BUSINESSUNIT.MEMBUSSINESSCD IS 'Member Business code'; 
COMMENT ON COLUMN TBL_SPONSOR_BUSINESSUNIT.CREATEDDT IS 'Created date'; 
COMMENT ON COLUMN TBL_SPONSOR_BUSINESSUNIT.CREATEDBY IS 'Created by'; 
COMMENT ON COLUMN TBL_SPONSOR_BUSINESSUNIT.MODIFIEDDT IS 'Modified date'; 
COMMENT ON COLUMN TBL_SPONSOR_BUSINESSUNIT.MODIFIEDBY IS 'Modified by'; 
-----------------------------------------------------------------------------------------------------------------------------------------------


ALTER TABLE TBL_USERPROFILES ADD BUSINESSUNITID   NUMBER (38,0);

ALTER TABLE TBL_USERPROFILES ADD CONSTRAINT TBL_USERPROFILES_SB FOREIGN KEY ( BUSINESSUNITID ) REFERENCES TBL_SPONSOR_BUSINESSUNIT ( BUSINESSUNITID );

------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE TBL_FUTURESPONSORONBOARDING  
(FUTSPONONBOARDID		NUMBER(38,0) NOT NULL,
TRANSCELERATEUSERID     VARCHAR2(100 CHAR),
BUSINESSUNITID			NUMBER(38,0),
TITLE					VARCHAR2(500 CHAR),
FIRSTNAME				VARCHAR2(400 CHAR),
MIDDLENAME 				VARCHAR2(400 CHAR),
LASTNAME                VARCHAR2(400 CHAR),
SUFFIX                  VARCHAR2(100 CHAR),
ADDRESS1                VARCHAR2(1000 CHAR),
ADDRESS2                VARCHAR2(1000 CHAR),
ADDRESS3                VARCHAR2(1000 CHAR),
CITY                    VARCHAR2(100 CHAR),  
STATEID                 NUMBER(38,0),  
COUNTRYID               NUMBER(38,0),
POSTALCODE              VARCHAR2(200 CHAR),
PHONE1                  VARCHAR2(200 CHAR),
EMAIL                   VARCHAR2(500 CHAR),
ROLEID                  VARCHAR2(500 CHAR),
TIMEZONEID              NUMBER(38,0) NOT NULL,
ACTIVATIONSTARTDT       DATE,   
ORGID                   NUMBER(38,0), 
ACTUALTRANSCELERATEUSERID   VARCHAR2(500 CHAR),
ISACTIVE                VARCHAR2(1 CHAR),
ISPROCESSED             VARCHAR2(1 CHAR),
CREATEDDT				DATE     NOT NULL,
CREATEDBY				VARCHAR2(100 CHAR)	NOT NULL,
MODIFIEDDT				DATE,
MODIFIEDBY				VARCHAR2(100 CHAR)
);


ALTER TABLE TBL_FUTURESPONSORONBOARDING ADD CONSTRAINT TBL_FUTURESPONSORONBOARDING_PK PRIMARY KEY (FUTSPONONBOARDID);
ALTER TABLE TBL_FUTURESPONSORONBOARDING ADD CONSTRAINT TBL_FUTURESPONSORONBOARDING_FK FOREIGN KEY ( BUSINESSUNITID ) REFERENCES TBL_SPONSOR_BUSINESSUNIT ( BUSINESSUNITID );

CREATE SEQUENCE SEQ_FUTURESPONSORONBOARDING MINVALUE 1 MAXVALUE 999999999999999999999999999 START WITH 1 INCREMENT BY 1 NOCACHE;

COMMENT ON TABLE TBL_FUTURESPONSORONBOARDING IS 'To accomodate Onboarding Sponsor user with Future Onboarding Date';
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.FUTSPONONBOARDID IS 'Future Sponsor Onboard Id sequence generated primary key';
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.TRANSCELERATEUSERID IS 'Transcelerate User id';
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.BUSINESSUNITID IS 'Business Unit id'; 
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.TITLE IS 'Title'; 
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.FIRSTNAME IS 'Firstname';
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.MIDDLENAME IS 'Middlename';
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.LASTNAME IS 'Lastname'; 
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.SUFFIX IS 'Suffix'; 
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.ADDRESS1 IS 'Address Line 1';
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.ADDRESS2 IS 'Address Line 2';
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.ADDRESS3 IS 'Address Line 3'; 
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.CITY IS 'City'; 
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.POSTALCODE IS 'Postal Code';
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.PHONE1 IS 'Phone number';
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.EMAIL IS 'Email id'; 
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.ROLEID IS 'Role id'; 
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.TIMEZONEID IS 'Timezone id';
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.ACTIVATIONSTARTDT IS 'Activation start date';
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.ORGID IS 'Organization id'; 
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.ACTUALTRANSCELERATEUSERID IS 'Actual transcelerate user id'; 
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.ISACTIVE IS 'Is active flag'; 
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.ISPROCESSED IS 'Is processed flag'; 
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.STATEID IS 'Stateid'; 
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.COUNTRYID IS 'Countryid'; 
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.CREATEDDT IS 'Created date'; 
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.CREATEDBY IS 'Created by'; 
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.MODIFIEDDT IS 'Modified date'; 
COMMENT ON COLUMN TBL_FUTURESPONSORONBOARDING.MODIFIEDBY IS 'Modified by'; 

------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE TBL_ALERTSANDNOTIFICATIONS ADD EMAILLOGID NUMBER(38,0);
ALTER TABLE TBL_ALERTSANDNOTIFICATIONS ADD CONSTRAINT TBL_ALERTSANNOT_EMAILOG_FK FOREIGN KEY ( EMAILLOGID ) REFERENCES TBL_EMAILLOG ( EMAILLOGID );

-------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE TBL_JUSTIFICATION ADD ( ISACTIVE VARCHAR2(1 CHAR),USERTYPE  VARCHAR2(500 CHAR));
COMMENT ON COLUMN TBL_JUSTIFICATION.ISACTIVE IS 'Active Flag'; 
COMMENT ON COLUMN TBL_JUSTIFICATION.USERTYPE IS 'User type'; 


ALTER TABLE TBL_USERPROFILES ADD DEACTIVATIONENDREASON VARCHAR2(500 CHAR);
COMMENT ON COLUMN TBL_USERPROFILES.DEACTIVATIONENDREASON IS 'Deactivation reason'; 


ALTER TABLE TBL_USERDEACTIVATIONLOG RENAME COLUMN STATUS TO ISPROCESSED ;
ALTER TABLE TBL_USERDEACTIVATIONLOG MODIFY ISPROCESSED VARCHAR2(1 CHAR) ;
ALTER TABLE TBL_USERDEACTIVATIONLOG ADD ISACTIVE VARCHAR2(1 CHAR);
ALTER TABLE TBL_USERDEACTIVATIONLOG ADD USERROLEID NUMBER(38);
COMMENT ON COLUMN TBL_USERDEACTIVATIONLOG.ISACTIVE IS 'Active Flag'; 
COMMENT ON COLUMN TBL_USERDEACTIVATIONLOG.ISPROCESSED IS 'Processed Flag'; 
COMMENT ON COLUMN TBL_USERDEACTIVATIONLOG.USERROLEID IS 'User Role id Mapping';
--------------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE TBL_ALERTANDNOTIFICATIONTYPE ADD ISFORSITEUSR  VARCHAR2(1 CHAR) DEFAULT 'Y' NOT NULL;
COMMENT ON COLUMN TBL_ALERTANDNOTIFICATIONTYPE.ISFORSITEUSR IS 'Site user flag';
ALTER TABLE TBL_ALERTANDNOTIFICATIONTYPE ADD ISFORSPONSORUSR  VARCHAR2(1 CHAR) DEFAULT 'Y' NOT NULL;
COMMENT ON COLUMN TBL_ALERTANDNOTIFICATIONTYPE.ISFORSPONSORUSR IS 'Sponsor user flag'

CREATE TABLE TBL_TASKTYPES(
TASKTYPEID  NUMBER(38,0)  NOT NULL ,
TASKDESC  VARCHAR2(100 CHAR)  NOT NULL,
ISFORSITEUSER  VARCHAR2(1 CHAR)  NOT NULL,
ISFORSPONSORUSER  VARCHAR2(1 CHAR)  NOT NULL,
CREATEDDT  DATE  NOT NULL,
CREATEDBY  VARCHAR2(100 CHAR)  NOT NULL,
MODIFIEDDT  DATE,
MODIFIEDBY  VARCHAR2(100 CHAR)
);

ALTER TABLE TBL_TASKTYPES ADD CONSTRAINT TBL_TASKTYPES_PK PRIMARY KEY (TASKTYPEID);
CREATE SEQUENCE SEQ_TASKTYPES MINVALUE 1 MAXVALUE 999999999999999999999999999 START WITH 1 INCREMENT BY 1 NOCACHE;

COMMENT ON TABLE TBL_TASKTYPES IS 'To accomodate task description for site and sponsor user';
COMMENT ON COLUMN TBL_TASKTYPES.TASKTYPEID IS 'sequence generated primary key';
COMMENT ON COLUMN TBL_TASKTYPES.TASKDESC IS 'task description';
COMMENT ON COLUMN TBL_TASKTYPES.ISFORSITEUSER IS 'Site user flag'; 
COMMENT ON COLUMN TBL_TASKTYPES.ISFORSPONSORUSER IS 'Sponsor user flag'; 
COMMENT ON COLUMN TBL_TASKTYPES.CREATEDDT IS 'Created date'; 
COMMENT ON COLUMN TBL_TASKTYPES.CREATEDBY IS 'Created by'; 
COMMENT ON COLUMN TBL_TASKTYPES.MODIFIEDDT IS 'Modified date'; 
COMMENT ON COLUMN TBL_TASKTYPES.MODIFIEDBY IS 'Modified by'; 

ALTER TABLE TBL_TASK ADD TASKTYPEID NUMBER(38);
ALTER TABLE TBL_TASK ADD CONSTRAINT TBL_TASK_TASKTYPE_FK FOREIGN KEY ( TASKTYPEID ) REFERENCES TBL_TASKTYPES ( TASKTYPEID );
COMMENT ON COLUMN TBL_TASK.TASKTYPEID IS 'Task type ID';
ALTER TABLE TBL_TASK ADD REASON VARCHAR2(100 CHAR);
COMMENT ON COLUMN TBL_TASK.REASON IS 'Reason';
ALTER TABLE TBL_TASK ADD COMMENTS VARCHAR2(100 CHAR);
COMMENT ON COLUMN TBL_TASK.COMMENTS IS 'Comment';

ALTER TABLE TBL_STUDY DROP CONSTRAINT TBL_STUDY_UN;


----------------------------------------------------------------------------------------------------------------------------------------------------------


ALTER TABLE TBL_USERROLEMAP ADD COUNTRYID NUMBER (38,0) ; 
ALTER TABLE TBL_USERDEACTIVATIONLOG  ADD COUNTRYID NUMBER (38,0) ; 
ALTER TABLE TBL_USERDEACTIVATIONLOG  ADD ROLEID NUMBER (38,0) ; 
ALTER TABLE TBL_USERDEACTIVATIONLOG ADD CONSTRAINT TBL_USERDEACTIVATIONLOG_FKROL FOREIGN KEY ( ROLEID ) REFERENCES TBL_ROLES ( ROLEID );


COMMENT ON COLUMN TBL_USERROLEMAP.COUNTRYID IS 'Country id'; 
COMMENT ON COLUMN TBL_USERDEACTIVATIONLOG.COUNTRYID IS 'Country id'; 
COMMENT ON COLUMN TBL_USERDEACTIVATIONLOG.ROLEID IS 'Foreign key for TBL_ROLES'; 

-------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE TBL_SPONSORACCESSMGT 
(ACCESSMGTID     	NUMBER(38,0) NOT NULL,
USERID				NUMBER(38,0) NOT NULL,
STARTDT				DATE NOT NULL,
ENDDT				DATE,
COUNTRYID             	NUMBER(38,0) ,
ROLEID             	NUMBER(38,0) NOT NULL,
ORGID             	NUMBER(38,0) NOT NULL,
ISEXISTINGSTUDY		VARCHAR2(1 CHAR),
ISEXISTINGSITE		VARCHAR2(1 CHAR),
ISFUTURESTUDY		VARCHAR2(1 CHAR),
ISFUTURESITE		VARCHAR2(1 CHAR),
STUDYID             NUMBER(38,0),
NOOFASSIGNMENTS     NUMBER(38,0),
CREATEDDT	DATE     NOT NULL,
CREATEDBY	VARCHAR2(100 CHAR)	NOT NULL,
MODIFIEDDT	DATE,
MODIFIEDBY	VARCHAR2(100 CHAR)
);
ALTER TABLE TBL_SPONSORACCESSMGT ADD CONSTRAINT TBL_SPONSORACCESSMGT_PK PRIMARY KEY (ACCESSMGTID);

CREATE SEQUENCE SEQ_SPONSORACCESSMGT MINVALUE 1 MAXVALUE 999999999999999999999999999 START WITH 1 INCREMENT BY 1 NOCACHE;

COMMENT ON TABLE TBL_SPONSORACCESSMGT IS 'Table for Scheduler Functionality for Access Management ';
COMMENT ON COLUMN TBL_SPONSORACCESSMGT.ACCESSMGTID IS 'Access Management Id sequence generated primary key';
COMMENT ON COLUMN TBL_SPONSORACCESSMGT.USERID IS 'User id';
COMMENT ON COLUMN TBL_SPONSORACCESSMGT.STARTDT IS 'Start date'; 
COMMENT ON COLUMN TBL_SPONSORACCESSMGT.ENDDT IS 'End date'; 
COMMENT ON COLUMN TBL_SPONSORACCESSMGT.COUNTRYID IS 'Country id';
COMMENT ON COLUMN TBL_SPONSORACCESSMGT.ROLEID IS 'Role id'; 
COMMENT ON COLUMN TBL_SPONSORACCESSMGT.ORGID IS 'Org id'; 
COMMENT ON COLUMN TBL_SPONSORACCESSMGT.ISEXISTINGSTUDY IS 'Flag for Existing study'; 
COMMENT ON COLUMN TBL_SPONSORACCESSMGT.ISEXISTINGSITE IS 'Flag for Existing site';
COMMENT ON COLUMN TBL_SPONSORACCESSMGT.ISFUTURESTUDY IS 'Flag for Future Study'; 
COMMENT ON COLUMN TBL_SPONSORACCESSMGT.ISFUTURESITE IS 'Flag for Future Site'; 
COMMENT ON COLUMN TBL_SPONSORACCESSMGT.STUDYID IS 'Study id'; 
COMMENT ON COLUMN TBL_SPONSORACCESSMGT.NOOFASSIGNMENTS IS 'No. of assignments'; 
COMMENT ON COLUMN TBL_SPONSORACCESSMGT.CREATEDDT IS 'Created date'; 
COMMENT ON COLUMN TBL_SPONSORACCESSMGT.CREATEDBY IS 'Created by'; 
COMMENT ON COLUMN TBL_SPONSORACCESSMGT.MODIFIEDDT IS 'Modified date'; 
COMMENT ON COLUMN TBL_SPONSORACCESSMGT.MODIFIEDBY IS 'Modified by'; 

-------------------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE TBL_DOCEXSYSTEM ADD(TOKENCODE VARCHAR2(50 CHAR));
COMMENT ON COLUMN TBL_DOCEXSYSTEM.TOKENCODE IS 'Token Code'; 

ALTER TABLE TBL_DOCEXCHANGE ADD(DOCEXSYSTEMID  NUMBER(38,0));
COMMENT ON COLUMN TBL_DOCEXCHANGE.DOCEXSYSTEMID  IS 'Foreign Key to table TBL_DOCEXSYSTEM'; 

ALTER TABLE TBL_DOCEXCHANGE ADD CONSTRAINT TBL_DOCEXCHANGE_FK1 FOREIGN KEY (DOCEXSYSTEMID) REFERENCES TBL_DOCEXSYSTEM (DOCEXSYSTEMID);

--------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE TBL_TASKCATEGORY 
(TASKCATEGORYID     	NUMBER(38,0) NOT NULL,
TASKTYPEID	NUMBER(38,0) NOT NULL,
CATEGORYCD             	VARCHAR2(100 CHAR) NOT NULL,
CREATEDDT	DATE     NOT NULL,
CREATEDBY	VARCHAR2(100 CHAR)	NOT NULL,
MODIFIEDDT	DATE,
MODIFIEDBY	VARCHAR2(100 CHAR)
);
ALTER TABLE TBL_TASKCATEGORY ADD CONSTRAINT TBL_TASKCATEGORY_PK PRIMARY KEY (TASKCATEGORYID);
ALTER TABLE TBL_TASKCATEGORY ADD CONSTRAINT TBL_TASKCATEGORY_FK FOREIGN KEY ( TASKTYPEID ) REFERENCES TBL_TASKTYPES ( TASKTYPEID );

CREATE SEQUENCE SEQ_TASKCATEGORY MINVALUE 1 MAXVALUE 999999999999999999999999999 START WITH 1 INCREMENT BY 1 NOCACHE;

COMMENT ON TABLE TBL_TASKCATEGORY IS 'To store mapping between task types and task category code';
COMMENT ON COLUMN TBL_TASKCATEGORY.TASKCATEGORYID IS 'Sequence generated primary key';
COMMENT ON COLUMN TBL_TASKCATEGORY.TASKTYPEID IS 'Foreign key to TBL_TASK';
COMMENT ON COLUMN TBL_TASKCATEGORY.CATEGORYCD IS 'Category code'; 
COMMENT ON COLUMN TBL_TASKCATEGORY.CREATEDDT IS 'Created date'; 
COMMENT ON COLUMN TBL_TASKCATEGORY.CREATEDBY IS 'Created by'; 
COMMENT ON COLUMN TBL_TASKCATEGORY.MODIFIEDDT IS 'Modified date'; 
COMMENT ON COLUMN TBL_TASKCATEGORY.MODIFIEDBY IS 'Modified by'; 

ALTER TABLE TBL_USER_TRAINING_STATUS ADD ISACTIVE VARCHAR2(1 CHAR);
COMMENT ON COLUMN TBL_USER_TRAINING_STATUS.ISACTIVE IS 'Active Flag'; 


---------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE TABLE TBL_CURATIONENTITYTYPE
  (
    CURENTITYID INTEGER NOT NULL ,
                ENTITYNAME         VARCHAR2 (100 CHAR) NOT NULL,
    ISACTIVE           VARCHAR2 (1 CHAR) DEFAULT 'Y' NOT NULL ,
    CREATEDBY          VARCHAR2 (100 CHAR) NOT NULL ,
    CREATEDDT          DATE NOT NULL ,
    MODIFIEDBY         VARCHAR2 (100 CHAR) ,
    MODIFIEDDT         DATE
  );
  
ALTER TABLE TBL_CURATIONENTITYTYPE ADD CONSTRAINT TBL_CURATIONENTITYTYPE_PK PRIMARY KEY ( CURENTITYID );
CREATE SEQUENCE SEQ_CURATIONENTITYTYPE MINVALUE 1 MAXVALUE 999999999999999999999999999 START WITH 1 INCREMENT BY 1 NOCACHE;

COMMENT ON COLUMN TBL_CURATIONENTITYTYPE.CURENTITYID IS 'PRIMARY key of the table';     
COMMENT ON COLUMN TBL_CURATIONENTITYTYPE.ENTITYNAME IS 'ENTITYNAME that has been curated';  
COMMENT ON COLUMN TBL_CURATIONENTITYTYPE.CREATEDBY IS 'Created By';
COMMENT ON COLUMN TBL_CURATIONENTITYTYPE.CREATEDDT IS 'Created Date';
COMMENT ON COLUMN TBL_CURATIONENTITYTYPE.MODIFIEDBY IS 'Modified By';
COMMENT ON COLUMN TBL_CURATIONENTITYTYPE.MODIFIEDDT IS 'Modified Date';
COMMENT ON COLUMN TBL_CURATIONENTITYTYPE.ISACTIVE IS 'Active flag with default value Y';




CREATE TABLE TBL_IRCURATION
  (
    IRCURATIONID INTEGER NOT NULL ,
    OLDVALUE           VARCHAR2 (100 CHAR),
    NEWVALUE           VARCHAR2 (100 CHAR),
    ENTITYTYPEID       INTEGER NOT NULL, 
    ISPROCESSED        VARCHAR2 (1 CHAR) DEFAULT 'N' NOT NULL ,
    ISACTIVE           VARCHAR2 (1 CHAR) DEFAULT 'Y' NOT NULL  ,
    CREATEDBY          VARCHAR2 (100 CHAR) NOT NULL ,
    CREATEDDT          DATE NOT NULL ,
    MODIFIEDBY         VARCHAR2 (100 CHAR) ,
    MODIFIEDDT         DATE
  );
  
ALTER TABLE TBL_IRCURATION ADD CONSTRAINT TBL_IRCURATION_PK PRIMARY KEY ( IRCURATIONID );
ALTER TABLE TBL_IRCURATION ADD CONSTRAINT TBL_IRCURATION_FK FOREIGN KEY ( ENTITYTYPEID ) REFERENCES TBL_CURATIONENTITYTYPE ( CURENTITYID );
CREATE SEQUENCE SEQ_IRCURATION MINVALUE 1 MAXVALUE 999999999999999999999999999 START WITH 1 INCREMENT BY 1 NOCACHE;

COMMENT ON COLUMN TBL_IRCURATION.IRCURATIONID IS 'PRIMARY key of the table';    
COMMENT ON COLUMN TBL_IRCURATION.OLDVALUE IS 'Old IR ID';    
COMMENT ON COLUMN TBL_IRCURATION.NEWVALUE IS 'Curated IR ID';    
COMMENT ON COLUMN TBL_IRCURATION.ENTITYTYPEID IS 'ENTITYNAME that has been curated';  
COMMENT ON COLUMN TBL_IRCURATION.CREATEDBY IS 'Created By';
COMMENT ON COLUMN TBL_IRCURATION.CREATEDDT IS 'Created Date';
COMMENT ON COLUMN TBL_IRCURATION.MODIFIEDBY IS 'Modified By';
COMMENT ON COLUMN TBL_IRCURATION.MODIFIEDDT IS 'Modified Date';
COMMENT ON COLUMN TBL_IRCURATION.ISPROCESSED IS 'Process flag with deafult value N';
COMMENT ON COLUMN TBL_IRCURATION.ISACTIVE IS 'Active flag with default value Y';

drop index TBL_STUDY_UN;
create index TBL_STUDY_UN on TBL_STUDY (STUDYNAME);

ALTER TABLE TBL_USER_TRAINING_STATUS 
ADD(ASSIGNEDDATE  DATE);
COMMENT ON COLUMN TBL_USER_TRAINING_STATUS.ASSIGNEDDATE IS 'Course Assignment Date';

ALTER TABLE TBL_USER_TRAINING_STATUS 
ADD(EXPIRYDATE  DATE);
COMMENT ON COLUMN TBL_USER_TRAINING_STATUS.EXPIRYDATE IS 'Course Expiry Date';

--BLOB to CLOB Conversion for TBL_TASK.TASKDATA column
ALTER TABLE TBL_TASK ADD(TASKDATA_NEW CLOB);

DECLARE
v_clob CLOB;
v_blob_length   PLS_INTEGER:=0;
BEGIN

    FOR i IN (SELECT taskid,taskdata FROM TBL_TASK ORDER BY taskid) LOOP
        v_blob_length:= DBMS_LOB.GETLENGTH(i.taskdata);
        v_clob := EMPTY_CLOB();
        /*IF v_blob_length > 2000 THEN
           DBMS_OUTPUT.PUT_LINE(i.taskid || ':' || v_blob_length);
        END IF;*/
        IF v_blob_length <= 2000 THEN 
           v_clob := UTL_RAW.CAST_TO_VARCHAR2(i.taskdata); 
        ELSE
           v_clob := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(i.taskdata,2000,1)) || 
                     UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(i.taskdata,2000,2001)) ||
                     UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(i.taskdata,2000,4001)); 
        END IF;
        
        UPDATE TBL_TASK
        SET taskdata_new = v_clob
        WHERE taskid = i.taskid;
        
    END LOOP;
END;
/

ALTER TABLE TBL_TASK DROP(TASKDATA);
ALTER TABLE TBL_TASK RENAME COLUMN TASKDATA_NEW TO TASKDATA;
