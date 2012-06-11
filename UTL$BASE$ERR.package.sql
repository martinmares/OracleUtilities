CREATE OR REPLACE
PACKAGE UTL$BASE$ERR
IS
    /**
    * ======================================================================
    *                               ANNOTATION
    * ======================================================================
    * Basic package to handle Oracle exceptions (ORA-20xxx errors).
    * For package "UTL$BASE"
    * ----------------------------------------------------------------------
    *
    * Dynamically generated package as defined in the table UTL$ERROR_CODES
    * Generated: 11/06/2012 20:13:00
    *
    * ----------------------------------------------------------------------
    * Copyright (C) 2012 Martin Mareš <martin.mares at seznam.cz>, All rights reserved.
    * ======================================================================
    */
    -- Basic data types inerited from UTL$DATA_TYPES package
    SUBTYPE T_SMALL_INTEGER IS UTL$DATA_TYPES.T_SMALL_INTEGER;
    SUBTYPE T_BIG_INTEGER IS UTL$DATA_TYPES.T_BIG_INTEGER;
    SUBTYPE T_SMALL_STRING IS UTL$DATA_TYPES.T_SMALL_STRING;
    SUBTYPE T_BIG_STRING IS UTL$DATA_TYPES.T_BIG_STRING;
    SUBTYPE T_MAX_STRING IS UTL$DATA_TYPES.T_MAX_STRING;
    SUBTYPE T_USER_MESSAGE IS UTL$DATA_TYPES.T_USER_MESSAGE;
    SUBTYPE T_DATE IS UTL$DATA_TYPES.T_DATE;
    SUBTYPE T_BOOLEAN IS UTL$DATA_TYPES.T_BOOLEAN;
    SUBTYPE T_NUMBER IS UTL$DATA_TYPES.T_NUMBER;
    SUBTYPE T_BINARY_INTEGER IS UTL$DATA_TYPES.T_BINARY_INTEGER;
    SUBTYPE T_ONE_CHAR IS UTL$DATA_TYPES.T_DB_BOOLEAN;
    SUBTYPE T_PLS_INTEGER IS UTL$DATA_TYPES.T_PLS_INTEGER;

    -- Mapa s tímto jménem už existuje
    e_MAPA_S_TIMTO_JMENEM_EXISTUJE CONSTANT T_SMALL_INTEGER := - 20001;
    MAPA_S_TIMTO_JMENEM_EXISTUJE EXCEPTION;

    PRAGMA EXCEPTION_INIT(MAPA_S_TIMTO_JMENEM_EXISTUJE, - 20001);

    PROCEDURE call_raise(err_number_in IN T_BIG_INTEGER);

    PROCEDURE call_raise(instance_id_in IN T_BIG_INTEGER
                        ,err_number_in  IN T_BIG_INTEGER);

    FUNCTION get_instance(err_number_in IN T_BIG_INTEGER) RETURN T_BIG_INTEGER;

    FUNCTION init_instance(err_number_in IN T_BIG_INTEGER) RETURN T_BIG_INTEGER;

    PROCEDURE set_instance(instance_id_in        IN T_BIG_INTEGER
                          ,system_err_code_in    IN T_BIG_INTEGER DEFAULT NULL
                          ,system_err_message_in IN T_MAX_STRING  DEFAULT NULL
                          ,callstack_in          IN T_MAX_STRING  DEFAULT NULL);

    PROCEDURE set_context(instance_id_in IN T_BIG_INTEGER
                         ,name_in        IN T_MAX_STRING  DEFAULT NULL
                         ,value_in       IN T_MAX_STRING  DEFAULT NULL);

END UTL$BASE$ERR;
/
