CREATE OR REPLACE
PACKAGE BODY UTL$ERROR
IS

    /**
    * ============================================================================
    *                           History of changes
    * ============================================================================
    *  Date (DD/MM/YYYY) Who               Description
    * ----------------- ----------------- --------------------------------
    *  11/06/2012        Martin Mareš      Create package
    *  11/06/2012        Martin Mareš      GitHub distribution
    * ============================================================================
    */
    PROCEDURE call_raise(err_number_in  IN T_BIG_INTEGER
                        ,schema_name_in IN T_MAX_STRING  DEFAULT g_schema_name
                        ,scope_name_in  IN T_MAX_STRING  DEFAULT g_scope_name)
    IS

    BEGIN
        call_raise(instance_id_in => NULL, err_number_in => err_number_in, schema_name_in => schema_name_in, scope_name_in => scope_name_in);
    END call_raise;

    PROCEDURE call_raise(instance_id_in IN T_BIG_INTEGER
                        ,err_number_in  IN T_BIG_INTEGER
                        ,schema_name_in IN T_MAX_STRING  DEFAULT g_schema_name
                        ,scope_name_in  IN T_MAX_STRING  DEFAULT g_scope_name)
    IS
        l_err_text    UTL$ERROR_CODES.ERR_TEXT%TYPE;
        l_instance_id UTL$ERROR_INSTANCE.ID%TYPE;

    BEGIN
        l_instance_id := instance_id_in;
        l_err_text := get_err_text(err_number_in => err_number_in, schema_name_in => schema_name_in, scope_name_in => scope_name_in);

        IF (l_instance_id IS NULL) THEN
            l_instance_id := init_instance(err_number_in => err_number_in, schema_name_in => schema_name_in, scope_name_in => scope_name_in);
            set_instance(instance_id_in => l_instance_id, system_err_code_in => err_number_in, system_err_message_in => l_err_text);
        END IF;

        IF err_number_in BETWEEN - 20999 AND - 20000 THEN
            RAISE_APPLICATION_ERROR (err_number_in, l_err_text);
        ELSIF err_number_in IN(100, - 1403) THEN
            RAISE NO_DATA_FOUND;
        ELSE
            EXECUTE IMMEDIATE 'DECLARE myexc EXCEPTION; ' || ' PRAGMA EXCEPTION_INIT (myexc, ' || err_number_in || ');' || ' BEGIN RAISE myexc; END;' ;
        END IF;

    END call_raise;

    FUNCTION init_instance(err_number_in  IN T_BIG_INTEGER
                          ,schema_name_in IN T_MAX_STRING  DEFAULT g_schema_name
                          ,scope_name_in  IN T_MAX_STRING  DEFAULT g_scope_name) RETURN T_BIG_INTEGER
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;

        l_err_code_id UTL$ERROR_CODES.ID%TYPE;
        l_instance_id UTL$ERROR_INSTANCE.ID%TYPE;
        l_err_text    UTL$ERROR_CODES.ERR_TEXT%TYPE;

    BEGIN
        l_err_text := get_err_text(err_number_in => err_number_in, schema_name_in => schema_name_in, scope_name_in => scope_name_in);

        BEGIN

            SELECT ID
              INTO l_err_code_id
              FROM UTL$ERROR_CODES
             WHERE SCHEMA_NAME = schema_name_in
               AND SCOPE_NAME = scope_name_in
               AND ERR_NUMBER = err_number_in;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN

                    SELECT ID
                      INTO l_err_code_id
                      FROM UTL$ERROR_CODES
                     WHERE SCHEMA_NAME = g_schema_name
                       AND SCOPE_NAME = g_scope_name
                       AND ERR_NUMBER = g_err_number;

        END;

        INSERT INTO UTL$ERROR_INSTANCE
            (ID,
             ID_ERR_CODE,
             SYSTEM_ERR_CODE,
             SYSTEM_ERR_MESSAGE)
     VALUES(NULL, l_err_code_id, err_number_in, l_err_text)
          RETURNING ID
               INTO l_instance_id;

        COMMIT;
        RETURN l_instance_id;
    END init_instance;

    PROCEDURE set_instance(instance_id_in        IN T_BIG_INTEGER
                          ,system_err_code_in    IN T_BIG_INTEGER DEFAULT NULL
                          ,system_err_message_in IN T_MAX_STRING  DEFAULT NULL
                          ,callstack_in          IN T_MAX_STRING  DEFAULT NULL)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;

        l_system_err_code    PLS_INTEGER;
        l_system_err_message T_BIG_STRING;
        l_call_stack         T_BIG_STRING;

    BEGIN
        l_system_err_code := SQLCODE;
        l_system_err_message := COALESCE(DBMS_UTILITY.format_error_stack(), SQLERRM);
        l_call_stack := DBMS_UTILITY.format_call_stack();

        UPDATE UTL$ERROR_INSTANCE
           SET SYSTEM_ERR_CODE = COALESCE(SYSTEM_ERR_CODE, system_err_code_in, l_system_err_code)
              ,SYSTEM_ERR_MESSAGE = COALESCE(SYSTEM_ERR_MESSAGE, system_err_message_in, l_system_err_message)
              ,CALLSTACK = COALESCE(CALLSTACK, callstack_in, l_call_stack)
         WHERE id = instance_id_in;

        COMMIT;
    END set_instance;

    PROCEDURE set_context(instance_id_in IN T_BIG_INTEGER
                         ,name_in        IN T_MAX_STRING  DEFAULT NULL
                         ,value_in       IN T_MAX_STRING  DEFAULT NULL)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;

    BEGIN

        INSERT INTO UTL$ERROR_CONTEXT
            (ID,
             ID_ERR_INSTANCE,
             PAR_NAME,
             PAR_VALUE)
     VALUES(NULL, instance_id_in, name_in, value_in);

        COMMIT;
    END set_context;

    FUNCTION get_err_text(err_number_in  IN T_BIG_INTEGER
                         ,schema_name_in IN T_MAX_STRING  DEFAULT g_schema_name
                         ,scope_name_in  IN T_MAX_STRING  DEFAULT g_scope_name) RETURN T_MAX_STRING
    IS
        l_err_text UTL$ERROR_CODES.ERR_TEXT%TYPE;

    BEGIN

        <<user_defined_exc>>

        BEGIN

            SELECT '[ERROR][' || TO_CHAR(err_number_in) || '][' || schema_name_in || '][' || scope_name_in || '] - ' || ERR_TEXT
              INTO l_err_text
              FROM UTL$ERROR_CODES
             WHERE SCHEMA_NAME = schema_name_in
               AND SCOPE_NAME = scope_name_in
               AND ERR_NUMBER = err_number_in;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN

                    <<predefined_oracle_exc>>

                    BEGIN

                        SELECT '[ERROR][' || TO_CHAR(err_number_in) || '][' || schema_name_in || '][' || scope_name_in || '] - ' || ERR_TEXT
                          INTO l_err_text
                          FROM UTL$ERROR_CODES
                         WHERE SCHEMA_NAME = g_schema_name
                           AND SCOPE_NAME = g_scope_name
                           AND ERR_NUMBER = err_number_in;

                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                l_err_text := '[ERROR][' ||
                                              TO_CHAR(err_number_in) ||
                                              '][' ||
                                              schema_name_in ||
                                              '][' ||
                                              scope_name_in ||
                                              '] - (bez popisu) ';
                    END predefined_oracle_exc;
        END user_defined_exc;
        RETURN l_err_text;
    END get_err_text;

    PROCEDURE call_register(schema_name_in  IN T_MAX_STRING  DEFAULT g_schema_name
                           ,scope_name_in   IN T_MAX_STRING  DEFAULT g_scope_name
                           ,err_number_in   IN T_BIG_INTEGER
                           ,err_declare_in  IN T_MAX_STRING
                           ,err_text_in     IN T_MAX_STRING
                           ,log_instance_in IN T_MAX_STRING  DEFAULT c_NO_CHAR
                           ,log_context_in  IN T_MAX_STRING  DEFAULT c_NO_CHAR)
    IS

    BEGIN

        INSERT INTO UTL$ERROR_CODES
            (SCHEMA_NAME,
             SCOPE_NAME,
             ERR_NUMBER,
             ERR_DECLARE,
             ERR_TEXT,
             LOG_INSTANCE,
             LOG_CONTEXT)
     VALUES(schema_name_in, scope_name_in, err_number_in, err_declare_in, err_text_in, log_instance_in, log_context_in);

    END call_register;

    PROCEDURE call_generate_packages(schema_name_in IN T_MAX_STRING DEFAULT NULL
                                    ,scope_name_in  IN T_MAX_STRING DEFAULT NULL
                                    ,debug_in       IN T_MAX_STRING DEFAULT NULL)
    IS
        l_plsql_str        T_BIG_STRING_LIST;
        l_dyn_cursor       T_PLS_INTEGER;
        dyn_execute_return T_SMALL_INTEGER;

        PROCEDURE set_plsql_str(line_in IN T_MAX_STRING)
        IS

        BEGIN
            l_plsql_str(l_plsql_str.COUNT) := line_in ||
                                              CHR(10);
        END set_plsql_str;

    BEGIN

        <<for_all_scopes>>
        FOR cur_scopes IN  (SELECT DISTINCT SCHEMA_NAME
                                           ,SCOPE_NAME
                                       FROM UTL$ERROR_CODES
                                      WHERE SCHEMA_NAME NOT IN(g_schema_name)
                                        AND SCHEMA_NAME = COALESCE(schema_name_in
                                                                  ,SCHEMA_NAME)
                                        AND SCOPE_NAME = COALESCE(scope_name_in
                                                                 ,SCOPE_NAME) ) LOOP
            l_plsql_str.DELETE;
            set_plsql_str('CREATE OR REPLACE');
            set_plsql_str('PACKAGE ' ||
                          cur_scopes.SCHEMA_NAME ||
                          '.' ||
                          cur_scopes.SCOPE_NAME ||
                          g_package_suffix);
            set_plsql_str('IS');
            set_plsql_str(' ');
            set_plsql_str('    /**');
            set_plsql_str('    * ======================================================================');
            set_plsql_str('    *                               ANNOTATION');
            set_plsql_str('    * ======================================================================');
            set_plsql_str('    * Basic package to handle Oracle exceptions (ORA-20xxx errors).');
            set_plsql_str('    * For package "' ||
                          cur_scopes.SCHEMA_NAME ||
                          '.' ||
                          cur_scopes.SCOPE_NAME ||
                          '"');
            set_plsql_str('    * ----------------------------------------------------------------------');
            set_plsql_str('    *');
            set_plsql_str('    * Dynamically generated package as defined in the table ' ||
                          c_BASE_SCHEMA ||
                          '.UTL$ERROR_CODES');
            set_plsql_str('    * Generated: ' ||
                          TO_CHAR(SYSDATE,('DD/MM/YYYY HH24:MI:SS')));
            set_plsql_str('    * ======================================================================');
            set_plsql_str('    */');
            set_plsql_str(' ');
            set_plsql_str('    -- Basic data types inherited from UTL$DATA_TYPES ("T" is synonym) package');
            set_plsql_str('    SUBTYPE T_SMALL_INTEGER      IS T.T_SMALL_INTEGER;');
            set_plsql_str('    SUBTYPE T_BIG_INTEGER        IS T.T_BIG_INTEGER;');
            set_plsql_str('    SUBTYPE T_SMALL_STRING       IS T.T_SMALL_STRING;');
            set_plsql_str('    SUBTYPE T_BIG_STRING         IS T.T_BIG_STRING;');
            set_plsql_str('    SUBTYPE T_MAX_STRING         IS T.T_MAX_STRING;');
            set_plsql_str('    SUBTYPE T_USER_MESSAGE       IS T.T_USER_MESSAGE;');
            set_plsql_str('    SUBTYPE T_DATE               IS T.T_DATE;');
            set_plsql_str('    SUBTYPE T_BOOLEAN            IS T.T_BOOLEAN;');
            set_plsql_str('    SUBTYPE T_NUMBER             IS T.T_NUMBER;');
            set_plsql_str('    SUBTYPE T_BINARY_INTEGER     IS T.T_BINARY_INTEGER;');
            set_plsql_str('    SUBTYPE T_DB_BOOLEAN         IS T.T_DB_BOOLEAN;');
            set_plsql_str('    SUBTYPE T_PLS_INTEGER        IS T.T_PLS_INTEGER;');
            set_plsql_str(' ');

            <<get_all_exceptions>>
            FOR cur_all_exceptions IN  (  SELECT ERR_NUMBER
                                                ,ERR_DECLARE
                                                ,ERR_TEXT
                                            FROM UTL$ERROR_CODES
                                           WHERE SCHEMA_NAME = cur_scopes.SCHEMA_NAME
                                             AND SCOPE_NAME = cur_scopes.SCOPE_NAME
                                        ORDER BY ERR_NUMBER DESC ) LOOP
                set_plsql_str('    -- ' ||
                              cur_all_exceptions.ERR_TEXT);
                set_plsql_str('    ' ||
                              g_constant_prefix ||
                              cur_all_exceptions.ERR_DECLARE ||
                              ' CONSTANT T_SMALL_INTEGER := ' ||
                              cur_all_exceptions.ERR_NUMBER ||
                              ';');
                set_plsql_str('    ' ||
                              cur_all_exceptions.ERR_DECLARE ||
                              ' EXCEPTION;');
                set_plsql_str('    ' ||
                              'PRAGMA EXCEPTION_INIT (' ||
                              cur_all_exceptions.ERR_DECLARE ||
                              ', ' ||
                              cur_all_exceptions.ERR_NUMBER ||
                              ');');
                set_plsql_str(' ');
            END LOOP get_all_exceptions;
            set_plsql_str('    PROCEDURE call_raise(err_number_in IN  T_BIG_INTEGER);');
            set_plsql_str(' ');
            set_plsql_str('    PROCEDURE call_raise(instance_id_in IN T_BIG_INTEGER');
            set_plsql_str('                        ,err_number_in  IN T_BIG_INTEGER);');
            set_plsql_str(' ');
            set_plsql_str('    FUNCTION get_instance(err_number_in  IN T_BIG_INTEGER) RETURN T_BIG_INTEGER;');
            set_plsql_str(' ');
            set_plsql_str('    FUNCTION init_instance(err_number_in IN T_BIG_INTEGER) RETURN T_BIG_INTEGER;');
            set_plsql_str(' ');
            set_plsql_str('    PROCEDURE set_instance(instance_id_in        IN T_BIG_INTEGER');
            set_plsql_str('                          ,system_err_code_in    IN T_BIG_INTEGER   DEFAULT NULL');
            set_plsql_str('                          ,system_err_message_in IN T_MAX_STRING DEFAULT NULL');
            set_plsql_str('                          ,callstack_in          IN T_MAX_STRING DEFAULT NULL);');
            set_plsql_str(' ');
            set_plsql_str('    PROCEDURE set_context(instance_id_in IN T_BIG_INTEGER');
            set_plsql_str('                         ,name_in        IN T_MAX_STRING DEFAULT NULL');
            set_plsql_str('                         ,value_in       IN T_MAX_STRING DEFAULT NULL);');
            set_plsql_str(' ');
            set_plsql_str('END ' ||
                          cur_scopes.SCOPE_NAME ||
                          g_package_suffix ||
                          ';');

            IF (l_plsql_str.COUNT > 0) THEN

                /**
                * ----------------------------------------------------------------------
                * GENEROVÁNÍ SPECIFIKACE
                * ----------------------------------------------------------------------
                */

                IF (debug_in IN(c_YES_CHAR_CZ, c_YES_CZ, c_YES_CHAR, c_YES)) THEN
                    PUT_LINE('-- begin');

                    <<cur_sql_output>>
                    FOR cur_sql_output IN l_plsql_str.FIRST..l_plsql_str.LAST LOOP
                        PUT_LINE(l_plsql_str(cur_sql_output));
                    END LOOP cur_sql_output;
                    PUT_LINE('-- end');
                END IF;

                l_dyn_cursor := DBMS_SQL.open_cursor;
                DBMS_SQL.parse(l_dyn_cursor
                              ,l_plsql_str
                              ,l_plsql_str.FIRST
                              ,l_plsql_str.LAST
                              ,FALSE
                              ,DBMS_SQL.NATIVE);
                dyn_execute_return := DBMS_SQL.execute(l_dyn_cursor);
                PUT_LINE('Create PACKAGE "' ||
                         cur_scopes.SCHEMA_NAME ||
                         '.' ||
                         cur_scopes.SCOPE_NAME ||
                         '" with dbms_sql.execute return "' ||
                         dyn_execute_return ||
                         '"');
                DBMS_SQL.close_cursor (l_dyn_cursor);

                /**
                * ----------------------------------------------------------------------
                * GENEROVÁNÍ BODY
                * ----------------------------------------------------------------------
                */
                l_plsql_str.DELETE;
                set_plsql_str('CREATE OR REPLACE');
                set_plsql_str('PACKAGE BODY ' ||
                              cur_scopes.SCHEMA_NAME ||
                              '.' ||
                              cur_scopes.SCOPE_NAME ||
                              g_package_suffix);
                set_plsql_str('IS');
                set_plsql_str('    PROCEDURE call_raise(err_number_in IN T_BIG_INTEGER)');
                set_plsql_str('    IS');
                set_plsql_str('    BEGIN');
                set_plsql_str('        call_raise(INSTANCE_ID_IN => NULL, ERR_NUMBER_IN => err_number_in);');
                set_plsql_str('    END call_raise;');
                set_plsql_str(' ');
                set_plsql_str('    PROCEDURE call_raise(instance_id_in IN T_BIG_INTEGER');
                set_plsql_str('                        ,err_number_in  IN T_BIG_INTEGER)');
                set_plsql_str('    IS');
                set_plsql_str('        l_schema_name ' ||
                              c_BASE_SCHEMA ||
                              '.UTL$ERROR_CODES.SCHEMA_NAME%TYPE;');
                set_plsql_str('        l_scope_name  ' ||
                              c_BASE_SCHEMA ||
                              '.UTL$ERROR_CODES.SCOPE_NAME%TYPE;');
                set_plsql_str('    BEGIN');
                set_plsql_str('        l_schema_name := ''' ||
                              cur_scopes.SCHEMA_NAME ||
                              ''';');
                set_plsql_str('        l_scope_name := ''' ||
                              cur_scopes.SCOPE_NAME ||
                              ''';');
                set_plsql_str('        ' ||
                              c_BASE_SCHEMA ||
                              '.utl$error.call_raise(INSTANCE_ID_IN => instance_id_in, ERR_NUMBER_IN => err_number_in, SCHEMA_NAME_IN => l_schema_name, SCOPE_NAME_IN => l_scope_name);');
                set_plsql_str('    END call_raise;');
                set_plsql_str(' ');
                set_plsql_str('    FUNCTION get_instance(err_number_in IN T_BIG_INTEGER) RETURN T_BIG_INTEGER');
                set_plsql_str('    IS');
                set_plsql_str('        l_schema_name ' ||
                              c_BASE_SCHEMA ||
                              '.UTL$ERROR_CODES.SCHEMA_NAME%TYPE;');
                set_plsql_str('        l_scope_name  ' ||
                              c_BASE_SCHEMA ||
                              '.UTL$ERROR_CODES.SCOPE_NAME%TYPE;');
                set_plsql_str('        l_instance_id ' ||
                              c_BASE_SCHEMA ||
                              '.UTL$ERROR_INSTANCE.ID%TYPE;');
                set_plsql_str(' ');
                set_plsql_str('    BEGIN');
                set_plsql_str('        l_schema_name := ''' ||
                              cur_scopes.SCHEMA_NAME ||
                              ''';');
                set_plsql_str('        l_scope_name := ''' ||
                              cur_scopes.SCOPE_NAME ||
                              ''';');
                set_plsql_str('        l_instance_id := init_instance(ERR_NUMBER_IN => err_number_in);');
                set_plsql_str('        set_instance(INSTANCE_ID_IN => l_instance_id, SYSTEM_ERR_CODE_IN => NULL, SYSTEM_ERR_MESSAGE_IN => NULL, CALLSTACK_IN => NULL);');
                set_plsql_str('        RETURN l_instance_id;');
                set_plsql_str('    END get_instance;');
                set_plsql_str(' ');
                set_plsql_str('    FUNCTION init_instance(err_number_in IN T_BIG_INTEGER) RETURN T_BIG_INTEGER');
                set_plsql_str('    IS');
                set_plsql_str('        l_schema_name ' ||
                              c_BASE_SCHEMA ||
                              '.UTL$ERROR_CODES.SCHEMA_NAME%TYPE;');
                set_plsql_str('        l_scope_name  ' ||
                              c_BASE_SCHEMA ||
                              '.UTL$ERROR_CODES.SCOPE_NAME%TYPE;');
                set_plsql_str(' ');
                set_plsql_str('    BEGIN');
                set_plsql_str('        l_schema_name := ''' ||
                              cur_scopes.SCHEMA_NAME ||
                              ''';');
                set_plsql_str('        l_scope_name := ''' ||
                              cur_scopes.SCOPE_NAME ||
                              ''';');
                set_plsql_str('        RETURN ' ||
                              c_BASE_SCHEMA ||
                              '.utl$error.init_instance(ERR_NUMBER_IN => err_number_in, SCHEMA_NAME_IN => l_schema_name, SCOPE_NAME_IN => l_scope_name);');
                set_plsql_str('    END init_instance;');
                set_plsql_str(' ');
                set_plsql_str('    PROCEDURE set_instance(instance_id_in        IN T_BIG_INTEGER');
                set_plsql_str('                          ,system_err_code_in    IN T_BIG_INTEGER   DEFAULT NULL');
                set_plsql_str('                          ,system_err_message_in IN T_MAX_STRING DEFAULT NULL');
                set_plsql_str('                          ,callstack_in          IN T_MAX_STRING DEFAULT NULL)');
                set_plsql_str('    IS');
                set_plsql_str('    BEGIN');
                set_plsql_str('        ' ||
                              c_BASE_SCHEMA ||
                              '.utl$error.set_instance(INSTANCE_ID_IN => instance_id_in, SYSTEM_ERR_CODE_IN => system_err_code_in, SYSTEM_ERR_MESSAGE_IN => system_err_message_in, CALLSTACK_IN => callstack_in);');
                set_plsql_str('    END set_instance;');
                set_plsql_str(' ');
                set_plsql_str('    PROCEDURE set_context (instance_id_in IN T_BIG_INTEGER');
                set_plsql_str('                          ,name_in        IN T_MAX_STRING DEFAULT NULL');
                set_plsql_str('                          ,value_in       IN T_MAX_STRING DEFAULT NULL)');
                set_plsql_str('    IS');
                set_plsql_str('    BEGIN');
                set_plsql_str('        ' ||
                              c_BASE_SCHEMA ||
                              '.utl$error.set_context(INSTANCE_ID_IN => instance_id_in, NAME_IN => name_in, VALUE_IN => value_in);');
                set_plsql_str('    END set_context;');
                set_plsql_str(' ');
                set_plsql_str('END ' ||
                              cur_scopes.SCOPE_NAME ||
                              g_package_suffix ||
                              ';');
                set_plsql_str(' ');

                <<cur_sql_output_body>>
                IF (debug_in IN(c_YES_CHAR_CZ, c_YES_CZ, c_YES_CHAR, c_YES)) THEN
                    PUT_LINE('-- begin body');
                    FOR cur_sql_output IN l_plsql_str.FIRST..l_plsql_str.LAST LOOP
                        PUT_LINE(l_plsql_str(cur_sql_output));
                    END LOOP cur_sql_output_body;
                    PUT_LINE('-- end body');
                END IF;

                l_dyn_cursor := DBMS_SQL.open_cursor;
                DBMS_SQL.parse(l_dyn_cursor
                              ,l_plsql_str
                              ,l_plsql_str.FIRST
                              ,l_plsql_str.LAST
                              ,FALSE
                              ,DBMS_SQL.NATIVE);
                dyn_execute_return := DBMS_SQL.execute(l_dyn_cursor);
                PUT_LINE('Create PACKAGE BODY "' ||
                         cur_scopes.SCHEMA_NAME ||
                         '.' ||
                         cur_scopes.SCOPE_NAME ||
                         '" with dbms_sql.execute return "' ||
                         dyn_execute_return ||
                         '"');
                DBMS_SQL.close_cursor (l_dyn_cursor);
            END IF;

        END LOOP for_all_scopes;

    END call_generate_packages;

    PROCEDURE print_insert_script(script_type_in      IN T_MAX_STRING DEFAULT c_DEFAULT_SCRIPT_TYPE
                                 ,append_exception_in IN T_MAX_STRING DEFAULT c_NO_CHAR
                                 ,schema_name_in      IN T_MAX_STRING DEFAULT NULL
                                 ,scope_name_in       IN T_MAX_STRING DEFAULT NULL)  -- SQL or SQL_PLUS
    IS
        l_script_prefix    T_SMALL_STRING;
        l_script_suffix    T_SMALL_STRING;
        l_append_exception T_SMALL_STRING;

    BEGIN

        <<for_all_scopes>>
        FOR cur_scopes IN  (SELECT DISTINCT SCHEMA_NAME
                                           ,SCOPE_NAME
                                           ,ERR_NUMBER
                                           ,ERR_DECLARE
                                           ,ERR_TEXT
                                           ,LOG_INSTANCE
                                           ,LOG_CONTEXT
                                       FROM UTL$ERROR_CODES
                                      WHERE SCHEMA_NAME = COALESCE(schema_name_in
                                                                  ,SCHEMA_NAME)
                                        AND SCOPE_NAME = COALESCE(scope_name_in
                                                                 ,SCOPE_NAME) ) LOOP

            IF (script_type_in = c_DEFAULT_SCRIPT_TYPE) THEN
                l_script_prefix := 'BEGIN' ||
                                   CHR(10);
                l_script_suffix := CHR(10) ||
                                   'END;' ||
                                   CHR(10) ||
                                   '/';
            ELSIF (script_type_in = 'SQL_PLUS') THEN
                l_script_prefix := 'EXEC ';
                l_script_suffix := NULL;
            END IF;

            IF (script_type_in = c_DEFAULT_SCRIPT_TYPE
                AND append_exception_in IN(c_YES_CHAR_CZ, c_YES_CZ, c_YES_CHAR, c_YES)) THEN
                l_append_exception := CHR(10) ||
                                      'EXCEPTION WHEN OTHERS THEN NULL;';
            END IF;

            put_long_line(l_script_prefix ||
                          c_BASE_SCHEMA ||
                          '.UTL$ERROR.CALL_REGISTER(''' ||
                          cur_scopes.SCHEMA_NAME ||
                          ''', ''' ||
                          cur_scopes.SCOPE_NAME ||
                          ''', ' ||
                          cur_scopes.ERR_NUMBER ||
                          ', ''' ||
                          cur_scopes.ERR_DECLARE ||
                          ''', ''' ||
                          cur_scopes.ERR_TEXT ||
                          ''', ''' ||
                          cur_scopes.LOG_INSTANCE ||
                          ''', ''' ||
                          cur_scopes.LOG_CONTEXT ||
                          ''');' ||
                          l_append_exception ||
                          l_script_suffix, 250);
        END LOOP for_all_scopes;

    END print_insert_script;

    FUNCTION get_default_schema_name RETURN T_SMALL_STRING
    IS

    BEGIN
        RETURN g_schema_name;
    END get_default_schema_name;

    FUNCTION get_default_scope_name RETURN T_SMALL_STRING
    IS

    BEGIN
        RETURN g_scope_name;
    END get_default_scope_name;

    FUNCTION get_default_err_number RETURN T_SMALL_STRING
    IS

    BEGIN
        RETURN g_err_number;
    END get_default_err_number;

END UTL$ERROR;
/
