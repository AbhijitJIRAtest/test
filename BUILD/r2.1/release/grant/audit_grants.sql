--Grants
GRANT SELECT,INSERT ON TBL_AUDIT TO TCSIP_CPORTAL;
GRANT SELECT,INSERT ON TBL_STUDYAUDITREPORTMAP TO TCSIP_CPORTAL;
GRANT SELECT,INSERT, UPDATE, DELETE ON TBL_SURVEYAUDITREPORTMAP TO TCSIP_CPORTAL;
GRANT SELECT,INSERT ON TBL_TRNGCREDITSAUDITREPORTMAP TO TCSIP_CPORTAL;
GRANT SELECT,INSERT ON TBL_DOCAUDITREPORTMAP TO TCSIP_CPORTAL;
GRANT SELECT,INSERT ON TBL_USERPROFILES TO TCSIP_CPORTAL;


GRANT EXECUTE ON PKG_AUDIT TO TCSIP_CPORTAL;