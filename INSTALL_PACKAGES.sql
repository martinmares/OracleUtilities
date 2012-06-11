PROMPT Running...
SET SERVEROUTPUT ON
SET ECHO OFF
SET TIMING ON
SET DEFINE OFF
SET SQLBLANKLINES ON
SPOOL install_log.txt
PROMPT Exec UTL$BASE$ERR.package.sql
@UTL$BASE$ERR.package.sql
PROMPT Exec UTL$BASE$ERR.package_body.sql
@UTL$BASE$ERR.package_body.sql
PROMPT Exec UTL$BASE.package.sql
@UTL$BASE.package.sql
PROMPT Exec UTL$BASE.package_body.sql
@UTL$BASE.package_body.sql
PROMPT Exec UTL$DATA_TYPES.package.sql
@UTL$DATA_TYPES.package.sql
PROMPT Exec UTL$DB.package.sql
@UTL$DB.package.sql
PROMPT Exec UTL$DB.package_body.sql
@UTL$DB.package_body.sql
PROMPT Exec UTL$DESC.package.sql
@UTL$DESC.package.sql
PROMPT Exec UTL$DESC.package_body.sql
@UTL$DESC.package_body.sql
PROMPT Exec UTL$ERROR.package.sql
@UTL$ERROR.package.sql
PROMPT Exec UTL$ERROR.package_body.sql
@UTL$ERROR.package_body.sql
PROMPT Exec UTL$HTTP.package.sql
@UTL$HTTP.package.sql
PROMPT Exec UTL$HTTP.package_body.sql
@UTL$HTTP.package_body.sql
PROMPT Exec UTL$LOCALE.package.sql
@UTL$LOCALE.package.sql
PROMPT Exec UTL$LOCALE.package_body.sql
@UTL$LOCALE.package_body.sql
PROMPT Exec UTL$OUT.package.sql
@UTL$OUT.package.sql
PROMPT Exec UTL$OUT.package_body.sql
@UTL$OUT.package_body.sql
PROMPT Exec UTL$SECURE.package.sql
@UTL$SECURE.package.sql
PROMPT Exec UTL$SECURE.package_body.sql
@UTL$SECURE.package_body.sql
PROMPT Exec UTL$UNIT.package.sql
@UTL$UNIT.package.sql
PROMPT Exec UTL$UNIT.package_body.sql
@UTL$UNIT.package_body.sql
PROMPT Exec UTL$XML.package.sql
@UTL$XML.package.sql
PROMPT Exec UTL$XML.package_body.sql
@UTL$XML.package_body.sql
SPOOL OFF
SET TIMING OFF
COMMIT;
