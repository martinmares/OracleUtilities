CREATE OR REPLACE
PACKAGE BODY UTL$BASE$ERR
IS
    PROCEDURE call_raise(err_number_in IN T_BIG_INTEGER)
    IS

    BEGIN
        call_raise(INSTANCE_ID_IN => NULL, ERR_NUMBER_IN => err_number_in);
    END call_raise;

    PROCEDURE call_raise(instance_id_in IN T_BIG_INTEGER
                        ,err_number_in  IN T_BIG_INTEGER)
    IS
        l_schema_name UTL$ERROR_CODES.SCHEMA_NAME%TYPE;
        l_scope_name  UTL$ERROR_CODES.SCOPE_NAME%TYPE;

    BEGIN
        l_schema_name := 'NXT';
        l_scope_name := 'UTL$BASE';
        utl$error.call_raise(INSTANCE_ID_IN => instance_id_in, ERR_NUMBER_IN => err_number_in, SCHEMA_NAME_IN => l_schema_name, SCOPE_NAME_IN => l_scope_name);
    END call_raise;

    FUNCTION get_instance(err_number_in IN T_BIG_INTEGER) RETURN T_BIG_INTEGER
    IS
        l_schema_name UTL$ERROR_CODES.SCHEMA_NAME%TYPE;
        l_scope_name  UTL$ERROR_CODES.SCOPE_NAME%TYPE;
        l_instance_id UTL$ERROR_INSTANCE.ID%TYPE;

    BEGIN
        l_schema_name := 'NXT';
        l_scope_name := 'UTL$BASE';
        l_instance_id := init_instance(ERR_NUMBER_IN => err_number_in);
        set_instance(INSTANCE_ID_IN => l_instance_id, SYSTEM_ERR_CODE_IN => NULL, SYSTEM_ERR_MESSAGE_IN => NULL, CALLSTACK_IN => NULL);
        RETURN l_instance_id;
    END get_instance;

    FUNCTION init_instance(err_number_in IN T_BIG_INTEGER) RETURN T_BIG_INTEGER
    IS
        l_schema_name UTL$ERROR_CODES.SCHEMA_NAME%TYPE;
        l_scope_name  UTL$ERROR_CODES.SCOPE_NAME%TYPE;

    BEGIN
        l_schema_name := 'NXT';
        l_scope_name := 'UTL$BASE';
        RETURN utl$error.init_instance(ERR_NUMBER_IN => err_number_in, SCHEMA_NAME_IN => l_schema_name, SCOPE_NAME_IN => l_scope_name);
    END init_instance;

    PROCEDURE set_instance(instance_id_in        IN T_BIG_INTEGER
                          ,system_err_code_in    IN T_BIG_INTEGER DEFAULT NULL
                          ,system_err_message_in IN T_MAX_STRING  DEFAULT NULL
                          ,callstack_in          IN T_MAX_STRING  DEFAULT NULL)
    IS

    BEGIN
        utl$error.set_instance(INSTANCE_ID_IN => instance_id_in, SYSTEM_ERR_CODE_IN => system_err_code_in, SYSTEM_ERR_MESSAGE_IN => system_err_message_in,
                                   CALLSTACK_IN => callstack_in);
    END set_instance;

    PROCEDURE set_context(instance_id_in IN T_BIG_INTEGER
                         ,name_in        IN T_MAX_STRING  DEFAULT NULL
                         ,value_in       IN T_MAX_STRING  DEFAULT NULL)
    IS

    BEGIN
        utl$error.set_context(INSTANCE_ID_IN => instance_id_in, NAME_IN => name_in, VALUE_IN => value_in);
    END set_context;

END UTL$BASE$ERR;
/
