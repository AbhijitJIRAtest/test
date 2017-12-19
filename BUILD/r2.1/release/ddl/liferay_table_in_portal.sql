CREATE TABLE TCSIP_CPORTAL.LNEWS 
(
  TYPEID NUMBER(30) NOT NULL 
, AUDIENCE VARCHAR2(75) 
, SUBJECT VARCHAR2(75) 
, DSPDATE TIMESTAMP 
, EXPDATE TIMESTAMP 
, URL VARCHAR2(75) 
, CREATDATE TIMESTAMP 
, SPONSORID NUMBER(30) 
, DESCRIPTION VARCHAR2(75) 
, CONTNTTYP VARCHAR2(75) 
);
CREATE SEQUENCE  TCSIP_CPORTAL.SEQ_LNEWS  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  NOORDER  NOCYCLE ;

CREATE TABLE TCSIP_CPORTAL.LnRoleNew 
(
  ROLETYPEID NUMBER(30) NOT NULL 
, ROLEID NUMBER(30)
, ROLETYPENAME VARCHAR2(75 CHAR)  
, TYPEID NUMBER(30)         
, SPONSORTYPEROLE VARCHAR2(100 CHAR) 
);
CREATE SEQUENCE  TCSIP_CPORTAL.SEQ_LnRoleNew  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  NOORDER  NOCYCLE ;

CREATE TABLE TCSIP_CPORTAL.CompoundLn 
(
  CMPNDTYPID NUMBER(30) NOT NULL 
, CMPNDID NUMBER(30)
, CMPNDNAME VARCHAR2(75 CHAR)  
, TYPEID NUMBER(30)         
);
CREATE SEQUENCE  TCSIP_CPORTAL.SEQ_CompoundLn  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  NOORDER  NOCYCLE ;

CREATE TABLE TCSIP_CPORTAL.ProgramLn 
(
  PRGMTYPID NUMBER(30) NOT NULL 
, PRGMID NUMBER(30)
, PRGMNAME VARCHAR2(75 CHAR)  
, TYPEID NUMBER(30)         
);
CREATE SEQUENCE  TCSIP_CPORTAL.SEQ_ProgramLn  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  NOORDER  NOCYCLE ;

CREATE TABLE TCSIP_CPORTAL.UserCountryLn 
(
  COUNTRYTYPEID NUMBER(30) NOT NULL 
, COUNTRYID  NUMBER(30)
, COUNTRYNAME VARCHAR2(75 CHAR)  
, TYPEID NUMBER(30)         
);
CREATE SEQUENCE  TCSIP_CPORTAL.SEQ_UserCountryLn  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  NOORDER  NOCYCLE ;

CREATE TABLE TCSIP_CPORTAL.UserStateLn 
(
  STATETYPEID NUMBER(30) NOT NULL 
, STATEID NUMBER(30)
, STATENAME VARCHAR2(75 CHAR)  
, TYPEID NUMBER(30)         
);
CREATE SEQUENCE  TCSIP_CPORTAL.SEQ_UserStateLn  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  NOORDER  NOCYCLE ;
CREATE TABLE TCSIP_CPORTAL.StudyLn 
(
  STUDYTYPEID NUMBER(30) NOT NULL 
, STUDYID NUMBER(30)
, STUDYNAME VARCHAR2(75 CHAR)  
, TYPEID NUMBER(30)         
);
CREATE SEQUENCE  TCSIP_CPORTAL.SEQ_StudyLn  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  NOORDER  NOCYCLE ;