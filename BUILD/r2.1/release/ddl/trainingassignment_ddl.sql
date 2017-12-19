CREATE TABLE TBL_TRNG_COURSE_ASSIGN( 
COURSEASSIGNID          NUMBER(38,0) NOT NULL,
ACTIVITYID              NUMBER(38,0) NOT NULL,
COURSETITLE             VARCHAR2(3000 CHAR) NOT NULL,
COURSETYPE              VARCHAR2(1000 CHAR) NOT NULL,
ASSIGNLEVEL             NUMBER(2,0) NOT NULL,
REQUIREMENT             NUMBER(2,0) NOT NULL,
DUEDAYS                 NUMBER(38,0) NOT NULL,
ORGID					NUMBER(38,0) NOT NULL,
STUDYID                 NUMBER(38,0),
SITEID                  NUMBER(38,0),
COMPID                  NUMBER(38,0),
PROGID                  NUMBER(38,0),
USERID                  NUMBER(38,0),
LMSASSIGNMENTID         NUMBER(38,0),
ISACTIVE          	    VARCHAR2(1 CHAR) NOT NULL,
ISPROCESSED        		VARCHAR2(1 CHAR) NOT NULL,
ERROROCCURED       		VARCHAR2(1 CHAR),
COMMENTS			    VARCHAR2(3000 CHAR),
ROLESADDED				VARCHAR2(3000 CHAR),
ROLESREMOVED			VARCHAR2(3000 CHAR),
CREATEDBY               VARCHAR2(100 CHAR) NOT NULL,
CREATEDDT               DATE  NOT NULL ,     
MODIFIEDBY              VARCHAR2(100 CHAR),
MODIFIEDDT      	    DATE
);

ALTER TABLE TBL_TRNG_COURSE_ASSIGN ADD CONSTRAINT TBL_TRNG_COURSE_ASSIGN_PK PRIMARY KEY (COURSEASSIGNID);
CREATE SEQUENCE SEQ_TRNG_COURSE_ASSIGN MINVALUE 1 MAXVALUE 999999999999999999999999999 START WITH 1 INCREMENT BY 1 NOCACHE;


COMMENT ON TABLE TBL_TRNG_COURSE_ASSIGN IS 'Table to store all levels of course assignment which will be processed offline';
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.COURSEASSIGNID IS 'Sequence generated primary key';
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.ACTIVITYID IS 'Activity id is LMS course id ';
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.ASSIGNLEVEL IS 'What is the level of assignment whether its i compound, program, study, site, user etc'; 
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.REQUIREMENT IS 'Whether its required or recommended'; 
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.DUEDAYS IS 'Due days of course assigned'; 
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.ORGID IS 'Organization name in case of sponsor users referenced from Tbl_Organization'; 
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.ISPROCESSED IS 'Whether request got processed or not'; 
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.ERROROCCURED IS 'If error occurred during processing then this flag will be set'; 
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.COMMENTS IS 'Comments for updating the record'; 
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.ROLESADDED IS 'Users roles Added';
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.ROLESREMOVED IS 'Users roles removed';
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.ISACTIVE IS 'Active Flag'; 
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.CREATEDDT IS 'Created date'; 
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.CREATEDBY IS 'Created by'; 
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.MODIFIEDDT IS 'Modified date'; 
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.MODIFIEDBY IS 'Modified by'; 
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.COMPID IS 'If compound level assignment then compound id'; 
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.PROGID IS 'If program level assignment then program id'; 
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.STUDYID IS 'Foreign key for TBL_STUDY, STUDYID column'; 
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.SITEID IS 'Foreign key for TBL_STUDY, SITEID column'; 
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.USERID IS 'Foreign key for TBL_USER, USERID column'; 
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.LMSASSIGNMENTID IS 'ACTIVITYID of LMS after LMS sends response';
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.COURSETITLE IS 'Title of the course been assigned';
COMMENT ON COLUMN TBL_TRNG_COURSE_ASSIGN.COURSETYPE IS 'Type of Course whether its Sponsor MRT, SIP MRT, Study Training, Sponsor Training';