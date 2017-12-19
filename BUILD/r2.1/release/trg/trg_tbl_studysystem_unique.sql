CREATE OR REPLACE TRIGGER trg_tbl_studysystem_unique
BEFORE INSERT ON TBL_STUDYSYSTEMMAP
FOR EACH ROW
DECLARE
BEGIN

  :NEW.SIPSTUDYSYSTEMID := 'SS' || TO_CHAR(SYSDATE,'MMDDYYYYHH24MISS') || LPAD(SEQ_SIPSTUDYSYSTEMID.NEXTVAL,4,0);

END trg_tbl_studysystem_unique;
/