CREATE OR REPLACE
PACKAGE UTL$ERROR
IS
    /**
    * ======================================================================
    *                               LICENSE and ANNOTATION
    * ======================================================================
    *
    * Basic Oracle utilities to handle exceptions (ORA-20xxx errors)
    *
    * ======================================================================
    * Distributed under "The GNU Lesser General Public License, version 3.0 (LGPLv3)"
    * ======================================================================
    *
    * UTL$ERROR
    *
    * Copyright (c) 2012, Martin Mareš <martin at sequel-code.cz>
    * All rights reserved.
    *
    * This library is free software; you can redistribute it and/or
    * modify it under the terms of the GNU Lesser General Public
    * License as published by the Free Software Foundation; either
    * version 3.0 of the License, or (at your option) any later version.
    *
    * This library is distributed in the hope that it will be useful,
    * but WITHOUT ANY WARRANTY; without even the implied warranty of
    * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    * Lesser General Public License for more details.
    *
    * You should have received a copy of the GNU Lesser General Public
    * License along with this library; if not, write to the Free Software
    * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
    *
    * ======================================================================
    */

    -- BASIC data types
    SUBTYPE T_DB_BOOLEAN IS UTL$DATA_TYPES.T_DB_BOOLEAN;
    SUBTYPE T_SMALL_INTEGER IS UTL$DATA_TYPES.T_SMALL_INTEGER;
    SUBTYPE T_BIG_INTEGER IS UTL$DATA_TYPES.T_BIG_INTEGER;
    SUBTYPE T_MAX_INTEGER IS UTL$DATA_TYPES.T_MAX_INTEGER;
    SUBTYPE T_SMALL_DOUBLE IS UTL$DATA_TYPES.T_SMALL_DOUBLE;
    SUBTYPE T_BIG_DOUBLE IS UTL$DATA_TYPES.T_BIG_DOUBLE;
    SUBTYPE T_MAX_DOUBLE IS UTL$DATA_TYPES.T_MAX_DOUBLE;
    SUBTYPE T_SMALL_STRING IS UTL$DATA_TYPES.T_SMALL_STRING;
    SUBTYPE T_BIG_STRING IS UTL$DATA_TYPES.T_BIG_STRING;
    SUBTYPE T_MAX_STRING IS UTL$DATA_TYPES.T_MAX_STRING;
    SUBTYPE T_SMALL_TIMESTAMP IS UTL$DATA_TYPES.T_SMALL_TIMESTAMP;
    SUBTYPE T_BIG_TIMESTAMP IS UTL$DATA_TYPES.T_BIG_TIMESTAMP;
    SUBTYPE T_MAX_TIMESTAMP IS UTL$DATA_TYPES.T_MAX_TIMESTAMP;
    SUBTYPE T_USER_MESSAGE IS UTL$DATA_TYPES.T_USER_MESSAGE;
    SUBTYPE T_DATE IS UTL$DATA_TYPES.T_DATE;
    SUBTYPE T_BOOLEAN IS UTL$DATA_TYPES.T_BOOLEAN;
    SUBTYPE T_NUMBER IS UTL$DATA_TYPES.T_NUMBER;
    SUBTYPE T_BINARY_INTEGER IS UTL$DATA_TYPES.T_BINARY_INTEGER;
    SUBTYPE T_PLS_INTEGER IS UTL$DATA_TYPES.T_PLS_INTEGER;
    SUBTYPE T_BIG_STRING_LIST IS UTL$DATA_TYPES.T_BIG_STRING_LIST;
    g_schema_name         CONSTANT UTL$ERROR_CODES.SCHEMA_NAME%TYPE := '_DEFAULT_';
    g_scope_name          CONSTANT UTL$ERROR_CODES.SCOPE_NAME%TYPE := '_ORACLE_EXCEPTION_';
    g_err_number          CONSTANT UTL$ERROR_CODES.ERR_NUMBER%TYPE := 0;
    g_package_suffix      CONSTANT T_SMALL_STRING := '$ERR';
    g_constant_prefix     CONSTANT T_SMALL_STRING := 'e_';
    c_BASE_SCHEMA         CONSTANT T_SMALL_STRING := 'NXT';
    c_DEFAULT_SCRIPT_TYPE CONSTANT T_SMALL_STRING := 'SQL';
    c_YES                 CONSTANT T_SMALL_STRING := 'YES';
    c_NO                  CONSTANT T_SMALL_STRING := 'NO';
    c_YES_CZ              CONSTANT T_SMALL_STRING := 'ANO';
    c_NO_CZ               CONSTANT T_SMALL_STRING := 'NE';
    c_YES_CHAR            CONSTANT T_DB_BOOLEAN := 'Y';
    c_NO_CHAR             CONSTANT T_DB_BOOLEAN := 'N';
    c_YES_CHAR_CZ         CONSTANT T_DB_BOOLEAN := 'A';
    c_NO_CHAR_CZ          CONSTANT T_DB_BOOLEAN := c_NO_CHAR;

    PROCEDURE call_raise(err_number_in  IN T_BIG_INTEGER
                        ,schema_name_in IN T_MAX_STRING  DEFAULT g_schema_name
                        ,scope_name_in  IN T_MAX_STRING  DEFAULT g_scope_name);

    PROCEDURE call_raise(instance_id_in IN T_BIG_INTEGER
                        ,err_number_in  IN T_BIG_INTEGER
                        ,schema_name_in IN T_MAX_STRING  DEFAULT g_schema_name
                        ,scope_name_in  IN T_MAX_STRING  DEFAULT g_scope_name);

    FUNCTION init_instance(err_number_in  IN T_BIG_INTEGER
                          ,schema_name_in IN T_MAX_STRING  DEFAULT g_schema_name
                          ,scope_name_in  IN T_MAX_STRING  DEFAULT g_scope_name) RETURN T_BIG_INTEGER;

    PROCEDURE set_instance(instance_id_in        IN T_BIG_INTEGER
                          ,system_err_code_in    IN T_BIG_INTEGER DEFAULT NULL
                          ,system_err_message_in IN T_MAX_STRING  DEFAULT NULL
                          ,callstack_in          IN T_MAX_STRING  DEFAULT NULL);

    PROCEDURE set_context(instance_id_in IN T_BIG_INTEGER
                         ,name_in        IN T_MAX_STRING  DEFAULT NULL
                         ,value_in       IN T_MAX_STRING  DEFAULT NULL);

    FUNCTION get_err_text(err_number_in  IN T_BIG_INTEGER
                         ,schema_name_in IN T_MAX_STRING  DEFAULT g_schema_name
                         ,scope_name_in  IN T_MAX_STRING  DEFAULT g_scope_name) RETURN T_MAX_STRING;

    PROCEDURE call_register(schema_name_in  IN T_MAX_STRING  DEFAULT g_schema_name
                           ,scope_name_in   IN T_MAX_STRING  DEFAULT g_scope_name
                           ,err_number_in   IN T_BIG_INTEGER
                           ,err_declare_in  IN T_MAX_STRING
                           ,err_text_in     IN T_MAX_STRING
                           ,log_instance_in IN T_MAX_STRING  DEFAULT c_NO_CHAR
                           ,log_context_in  IN T_MAX_STRING  DEFAULT c_NO_CHAR);

    PROCEDURE call_generate_packages(schema_name_in IN T_MAX_STRING DEFAULT NULL
                                    ,scope_name_in  IN T_MAX_STRING DEFAULT NULL
                                    ,debug_in       IN T_MAX_STRING DEFAULT NULL);

    PROCEDURE print_insert_script(script_type_in      IN T_MAX_STRING DEFAULT c_DEFAULT_SCRIPT_TYPE
                                 ,append_exception_in IN T_MAX_STRING DEFAULT c_NO_CHAR
                                 ,schema_name_in      IN T_MAX_STRING DEFAULT NULL
                                 ,scope_name_in       IN T_MAX_STRING DEFAULT NULL);

    FUNCTION get_default_schema_name RETURN T_SMALL_STRING;

    FUNCTION get_default_scope_name RETURN T_SMALL_STRING;

    FUNCTION get_default_err_number RETURN T_SMALL_STRING;

END UTL$ERROR;
/
