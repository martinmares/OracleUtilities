CREATE OR REPLACE
PACKAGE BODY UTL$DB
IS
    /**
    * ============================================================================
    *                           History of changes
    * ============================================================================
    *  Date (DD/MM/YYYY) Who               Description
    * ----------------- ----------------- --------------------------------
    *  11/06/2012        Martin Mareš      GitHub distribution
    * ============================================================================
    */

    FUNCTION construct_compile_command (schema_name_in IN VARCHAR2
                                       ,object_name_in IN VARCHAR2
                                       ,object_type_in IN VARCHAR2) RETURN VARCHAR2
    IS
        l_return_compile_comm VARCHAR2(2000);

    BEGIN
        l_return_compile_comm := 'ALTER ' ||

            CASE
                WHEN object_type_in IN('PACKAGE', 'PACKAGE BODY')
                    THEN 'PACKAGE'
                WHEN object_type_in IN('JAVA CLASS', 'JAVA SOURCE')
                    THEN 'JAVA CLASS'
                ELSE object_type_in
            END ||
                                 ' "' ||
                                 schema_name_in ||
                                 '"."' ||
                                 object_name_in ||
                                 '"' ||

            CASE
                WHEN object_type_in IN('JAVA CLASS', 'JAVA SOURCE')
                    THEN ' RESOLVE'
                ELSE ' COMPILE ' ||

                    CASE
                        WHEN object_type_in IN('PACKAGE BODY')
                            THEN 'BODY'
                        ELSE NULL
                    END
            END;
        RETURN l_return_compile_comm;
    END construct_compile_command;

    FUNCTION get_list_objects(schema_name_in  IN VARCHAR2 DEFAULT NULL
                             ,object_name_in  IN VARCHAR2 DEFAULT NULL
                             ,show_skipped_in IN VARCHAR2 DEFAULT 'N') RETURN list_objects
    IS
        l_struct_object struct_object;
        l_list_objects  list_objects;

    BEGIN

        <<list_all_objects>>
        FOR cur_objects IN  (  SELECT obj.owner AS schema_name
                                     ,obj.object_name AS object_name
                                     ,obj.object_type AS object_type
                                 FROM dba_objects obj
                                WHERE obj.status <> 'VALID'
                                  AND NOT (obj.owner = c_SELF_SCHEMA_NAME
                                  AND obj.object_name = c_SELF_OBJECT_NAME)  -- don't compile itself
                                  AND obj.object_type IN('TRIGGER', 'PACKAGE', 'PACKAGE BODY', 'VIEW', 'PROCEDURE', 'FUNCTION', 'JAVA CLASS', 'JAVA SOURCE')
                                  AND obj.owner = COALESCE(schema_name_in, obj.owner)
                                  AND obj.object_name = COALESCE(object_name_in, obj.object_name)
                             ORDER BY DECODE(obj.object_type, 'JAVA SOURCE', 1, 'JAVA CLASS', 2, 'PACKAGE', 3, 'PACKAGE BODY', 4, 'PROCEDURE', 5,
                                      'FUNCTION', 6, 'TRIGGER', 7, 'VIEW', 8, 10) ) LOOP
            l_struct_object.schema_name := cur_objects.schema_name;
            l_struct_object.object_name := cur_objects.object_name;
            l_struct_object.object_type := cur_objects.object_type;
            l_list_objects(l_list_objects.COUNT) := l_struct_object;
        END LOOP list_all_objects;

        <<objects_not_necessary>>
        FOR cur_objects IN  (SELECT schema_name
                                   ,object_name
                               FROM utl$db_compile_obj_ignore ) LOOP

            IF (l_list_objects.COUNT > 0) THEN

                <<loop_all_objects>>
                FOR i IN l_list_objects.FIRST..l_list_objects.LAST LOOP

                    IF (l_list_objects.EXISTS(i)) THEN
                        l_struct_object := l_list_objects(i);

                        IF l_struct_object.schema_name LIKE cur_objects.schema_name
                           AND l_struct_object.object_name LIKE cur_objects.object_name THEN
                            l_list_objects.DELETE(i);

                            IF (UPPER(show_skipped_in) IN('Y', 'YES', 'A', 'ANO')) THEN
                                DBMS_OUTPUT.put_line('Skip ' ||
                                                     l_struct_object.schema_name ||
                                                     '.' ||
                                                     l_struct_object.object_name ||
                                                     ' (Pattern: ' ||
                                                     cur_objects.schema_name ||
                                                     '/' ||
                                                     cur_objects.object_name ||
                                                     ')');
                            END IF;

                        END IF;

                    END IF;

                END LOOP loop_all_objects;
            END IF;

        END LOOP objects_not_necessary;

        RETURN l_list_objects;
    END get_list_objects;

    PROCEDURE compile_objects(schema_name_in  IN VARCHAR2 DEFAULT NULL
                             ,object_name_in  IN VARCHAR2 DEFAULT NULL
                             ,show_skipped_in IN VARCHAR2 DEFAULT 'N')
    IS
        l_compile_command VARCHAR2(2000);
        l_struct_object   struct_object;
        l_list_objects    list_objects;
        l_count_first     NUMBER;
        l_count_before    NUMBER;
        l_count_after     NUMBER;

    BEGIN
        l_list_objects := get_list_objects(schema_name_in => schema_name_in, object_name_in => object_name_in, show_skipped_in => show_skipped_in);
        l_count_first := l_list_objects.COUNT;
        l_count_before := l_count_first;
        l_count_after := 0;

        WHILE(l_count_before <> l_count_after) LOOP
            l_count_before := l_list_objects.COUNT;

            IF (l_list_objects.COUNT > 0) THEN
                FOR i IN l_list_objects.FIRST..l_list_objects.LAST LOOP

                    IF (l_list_objects.EXISTS(i)) THEN
                        l_struct_object := l_list_objects(i);
                        l_compile_command := construct_compile_command (schema_name_in => l_struct_object.schema_name, object_name_in => l_struct_object.object_name,
                                                                        object_type_in => l_struct_object.object_type);

                        BEGIN
                            EXECUTE IMMEDIATE l_compile_command ;
                            EXCEPTION
                                WHEN OTHERS THEN

                                    IF (SQLCODE NOT IN( - 24344, - 4052, - 1031)) THEN
                                        DBMS_OUTPUT.put_line('SQLCODE = ' ||
                                                             SQLCODE);
                                        DBMS_OUTPUT.put_line('SQLERRM = ' ||
                                                             SQLERRM);
                                        DBMS_OUTPUT.put_line('Try Execute = ' ||
                                                             l_compile_command);
                                        RAISE_APPLICATION_ERROR (e_ALL_EXCEPTIONS, 'Exception in execute immediate command (' ||
                                                                                   sqlerrm ||
                                                                                   ').');
                                    END IF;

                        END;
                    END IF;

                END LOOP;
            END IF;

            l_list_objects := get_list_objects(schema_name_in => schema_name_in, object_name_in => object_name_in);
            l_count_after := l_list_objects.COUNT;
        END LOOP;

        IF (l_list_objects.COUNT > 0) THEN
            DBMS_OUTPUT.put_line(RPAD('-- [Invalid objects after compilation] ', c_LINE_LENGTH, '-'));

            FOR i IN l_list_objects.FIRST..l_list_objects.LAST LOOP

                IF (l_list_objects.EXISTS(i)) THEN
                    l_struct_object := l_list_objects(i);
                    DBMS_OUTPUT.put_line(l_struct_object.schema_name ||
                                         '.' ||
                                         l_struct_object.object_name ||
                                         ' (' ||
                                         l_struct_object.object_type ||
                                         ')');
                END IF;

            END LOOP;

        END IF;

        DBMS_OUTPUT.put_line(RPAD('-- [Summary] ', c_LINE_LENGTH, '-'));
        DBMS_OUTPUT.put_line('Invalid objects before compilation = ' ||
                             l_count_first);
        DBMS_OUTPUT.put_line('Invalid objects after compilation = ' ||
                             l_count_after);
    END compile_objects;

    FUNCTION table_with_column_exists(schema_name_in IN VARCHAR2
                                     ,table_name_in  IN VARCHAR2
                                     ,column_name_in IN VARCHAR2) RETURN BOOLEAN
    IS
        l_count PLS_INTEGER;

    BEGIN

        SELECT COUNT(1)
          INTO l_count
          FROM all_tab_columns
         WHERE owner = schema_name_in
           AND table_name = table_name_in
           AND column_name = (        CASE
                                                             WHEN column_name_in IS NULL
                                                                 THEN column_name
                                                             ELSE column_name_in
                                                 END);

        RETURN
            CASE
                WHEN l_count > 0
                    THEN TRUE
                ELSE FALSE
            END;
    END table_with_column_exists;

    FUNCTION table_exists(schema_name_in IN VARCHAR2
                         ,table_name_in  IN VARCHAR2) RETURN BOOLEAN
    IS

    BEGIN
        RETURN table_with_column_exists(schema_name_in, table_name_in, NULL);
    END table_exists;

    PROCEDURE alter_table_add(schema_name_in IN VARCHAR2
                             ,table_name_in  IN VARCHAR2
                             ,column_name_in IN VARCHAR2
                             ,data_type_in   IN VARCHAR2)
    IS

    BEGIN

        IF (table_exists(schema_name_in, table_name_in)
            AND NOT table_with_column_exists(schema_name_in, table_name_in, column_name_in)) THEN
            EXECUTE IMMEDIATE 'ALTER TABLE ' || schema_name_in || '.' || table_name_in || ' ADD ' || column_name_in || ' ' || data_type_in ;
        END IF;

    END alter_table_add;

    FUNCTION generate_temporary_table_name(schema_name_in IN VARCHAR2) RETURN VARCHAR2
    IS
        l_table_prefix VARCHAR2(30) := 'TEMP$';
        l_table_name   VARCHAR2(30);
        l_counter      PLS_INTEGER := 1;

    BEGIN
        l_table_name := l_table_prefix ||
                        l_counter;

        WHILE(table_exists(schema_name_in, l_table_name)) LOOP
            l_table_name := l_table_prefix ||
                            l_counter;
            l_counter := l_counter + 1;
            EXIT WHEN l_counter > 1000;
        END LOOP;

        RETURN l_table_name;
    END generate_temporary_table_name;

    PROCEDURE table_copy(schema_name_source_in     IN VARCHAR2
                        ,table_name_source_in      IN VARCHAR2
                        ,table_name_destination_in IN VARCHAR2)
    IS

    BEGIN
        table_copy(schema_name_source_in, table_name_source_in, NULL, table_name_destination_in);
    END table_copy;

    PROCEDURE table_copy(schema_name_source_in      IN VARCHAR2
                        ,table_name_source_in       IN VARCHAR2
                        ,schema_name_destination_in IN VARCHAR2
                        ,table_name_destination_in  IN VARCHAR2)
    IS

    BEGIN
        EXECUTE IMMEDIATE 'CREATE TABLE ' || COALESCE(schema_name_destination_in, schema_name_source_in) || '.' || table_name_destination_in || ' AS SELECT * FROM ' || schema_name_source_in || '.' || table_name_source_in ;
    END table_copy;

    PROCEDURE alter_table_add_at_position(schema_name_in IN VARCHAR2
                                         ,table_name_in  IN VARCHAR2
                                         ,column_name_in IN VARCHAR2
                                         ,data_type_in   IN VARCHAR2
                                         ,position_in    IN NUMBER)
    IS

    BEGIN

        IF (table_exists(schema_name_in, table_name_in)
            AND NOT table_with_column_exists(schema_name_in, table_name_in, column_name_in)) THEN
            EXECUTE IMMEDIATE 'ALTER TABLE ' || schema_name_in || '.' || table_name_in || ' ADD ' || column_name_in || ' ' || data_type_in ;
        END IF;

    END alter_table_add_at_position;

    PROCEDURE alter_table_add_after_column(schema_name_in       IN VARCHAR2
                                          ,table_name_in        IN VARCHAR2
                                          ,column_name_in       IN VARCHAR2
                                          ,data_type_in         IN VARCHAR2
                                          ,after_column_name_in IN VARCHAR2)
    IS

    BEGIN
        NULL;
    END alter_table_add_after_column;

    FUNCTION is_not_null_constraint(schema_name_in     IN VARCHAR2
                                   ,table_name_in      IN VARCHAR2
                                   ,constraint_name_in IN VARCHAR2) RETURN BOOLEAN
    IS
        l_count              PLS_INTEGER;
        l_search_condition   ALL_CONSTRAINTS.SEARCH_CONDITION%TYPE;
        l_is_not_null_string VARCHAR2(2000);
        l_its_check_not_null BOOLEAN;

    BEGIN
        l_its_check_not_null := FALSE;

        BEGIN

            SELECT a.SEARCH_CONDITION
                  ,'"' || b.column_name || '" IS NOT NULL'
              INTO l_search_condition
                  ,l_is_not_null_string
              FROM ALL_CONSTRAINTS a
                  ,ALL_CONS_COLUMNS b
             WHERE a.OWNER = schema_name_in
               AND a.CONSTRAINT_TYPE IN(c_CHECK_CONSTRAINT)
               AND a.table_name = table_name_in
               AND a.CONSTRAINT_NAME = constraint_name_in
               AND b.OWNER = a.OWNER
               AND b.table_name = a.table_name
               AND b.constraint_name = a.constraint_name
               AND 1 =
                   (SELECT COUNT(1)
                      FROM ALL_CONS_COLUMNS bb
                     WHERE bb.OWNER = a.owner
                       AND bb.table_name = a.table_name
                       AND bb.constraint_name = a.CONSTRAINT_NAME)
               AND 1 =
                   (SELECT COUNT(1)
                      FROM ALL_TAB_COLUMNS cc
                     WHERE cc.OWNER = a.owner
                       AND cc.TABLE_NAME = a.table_name
                       AND cc.COLUMN_NAME = b.COLUMN_NAME
                       AND cc.NULLABLE = 'N');

            IF (l_search_condition = l_is_not_null_string) THEN
                l_its_check_not_null := TRUE;
            END IF;

            EXCEPTION
                WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
                    l_its_check_not_null := FALSE;
        END;
        RETURN l_its_check_not_null;
    END is_not_null_constraint;

    FUNCTION get_primary_key_ddl(schema_name_in IN VARCHAR2
                                ,table_name_in  IN VARCHAR2) RETURN LONG_TEXT
    IS

    BEGIN
        RETURN get_constraints_ddl(schema_name_in => schema_name_in, table_name_in => table_name_in, constraint_type_in => c_PRIMARY_KEY_CONSTRAINT);
    END get_primary_key_ddl;

    FUNCTION get_foreign_key_ddl(schema_name_in      IN VARCHAR2
                                ,table_name_in       IN VARCHAR2
                                ,foreign_key_name_in IN VARCHAR2) RETURN LONG_TEXT
    IS

    BEGIN
        RETURN get_constraint_ddl(schema_name_in => schema_name_in, table_name_in => table_name_in, constraint_name_in => foreign_key_name_in, constraint_type_in => c_FOREIGN_KEY_CONSTRAINT);
    END get_foreign_key_ddl;

    FUNCTION get_foreign_keys_ddl(schema_name_in IN VARCHAR2
                                 ,table_name_in  IN VARCHAR2) RETURN LONG_TEXT
    IS

    BEGIN
        RETURN get_constraints_ddl(schema_name_in => schema_name_in, table_name_in => table_name_in, constraint_type_in => c_FOREIGN_KEY_CONSTRAINT);
    END get_foreign_keys_ddl;

    FUNCTION get_check_constraint_ddl(schema_name_in      IN VARCHAR2
                                     ,table_name_in       IN VARCHAR2
                                     ,foreign_key_name_in IN VARCHAR2) RETURN LONG_TEXT
    IS

    BEGIN
        RETURN get_constraint_ddl(schema_name_in => schema_name_in, table_name_in => table_name_in, constraint_name_in => foreign_key_name_in, constraint_type_in => c_CHECK_CONSTRAINT);
    END get_check_constraint_ddl;

    FUNCTION get_check_constraints_ddl(schema_name_in IN VARCHAR2
                                      ,table_name_in  IN VARCHAR2) RETURN LONG_TEXT
    IS

    BEGIN
        RETURN get_constraints_ddl(schema_name_in => schema_name_in, table_name_in => table_name_in, constraint_type_in => c_CHECK_CONSTRAINT);
    END get_check_constraints_ddl;

    FUNCTION get_constraint_ddl(schema_name_in     IN VARCHAR2
                               ,table_name_in      IN VARCHAR2
                               ,constraint_name_in IN VARCHAR2
                               ,constraint_type_in IN VARCHAR2) RETURN LONG_TEXT
    IS
        l_ddl                 LONG_TEXT;
        l_ddl_begin           LONG_TEXT;
        l_ddl_columns         LONG_TEXT;
        l_ddl_columns_ref     LONG_TEXT;
        l_ddl_end             LONG_TEXT;
        l_ddl_ref             LONG_TEXT;
        l_ddl_check           LONG_TEXT;
        l_type_of_key         VARCHAR2(100);
        l_ref_owner           all_constraints.R_OWNER%TYPE;
        l_ref_constraint_name all_constraints.R_CONSTRAINT_NAME%TYPE;
        l_ref_table_name      all_constraints.TABLE_NAME%TYPE;
        l_search_condition    all_constraints.SEARCH_CONDITION%TYPE;

    BEGIN
        l_type_of_key :=
            CASE
                WHEN constraint_type_in = c_PRIMARY_KEY_CONSTRAINT
                    THEN 'PRIMARY KEY'
                WHEN constraint_type_in = c_FOREIGN_KEY_CONSTRAINT
                    THEN 'FOREIGN KEY'
                WHEN constraint_type_in = c_CHECK_CONSTRAINT
                    THEN 'CHECK'
            END;

        SELECT 'ALTER TABLE ' || owner || '.' || table_name || ' ADD CONSTRAINT ' || constraint_name || ' ' || l_type_of_key
              ,R_OWNER
              ,R_CONSTRAINT_NAME
              ,SEARCH_CONDITION
          INTO l_ddl_begin
              ,l_ref_owner
              ,l_ref_constraint_name
              ,l_search_condition
          FROM ALL_CONSTRAINTS
         WHERE OWNER = schema_name_in
           AND CONSTRAINT_NAME = constraint_name_in
           AND TABLE_NAME = table_name_in;

        /**
        * ----------------------------------------------------------------------
        * Only for PRIMARY KEYS
        * ----------------------------------------------------------------------
        */

        IF (constraint_type_in IN(c_PRIMARY_KEY_CONSTRAINT, c_FOREIGN_KEY_CONSTRAINT)) THEN
            l_ddl_columns := l_ddl_columns ||
                             '(';

            <<list_all_columns_in_constraint>>
            FOR list_columns IN  (  SELECT POSITION
                                          ,COLUMN_NAME
                                      FROM ALL_CONS_COLUMNS
                                     WHERE OWNER = schema_name_in
                                       AND TABLE_NAME = table_name_in
                                       AND CONSTRAINT_NAME = constraint_name_in
                                  ORDER BY POSITION ) LOOP
                l_ddl_columns := l_ddl_columns ||

                    CASE
                        WHEN list_columns.position = 1
                            THEN ''
                        ELSE ', '
                    END ||
                                 list_columns.column_name;
            END LOOP list_all_columns_in_constraint;

            l_ddl_columns := l_ddl_columns ||
                             ')';
        END IF;

        /**
        * ----------------------------------------------------------------------
        * Only for FOREIGN KEYS
        * ----------------------------------------------------------------------
        */

        IF (constraint_type_in = c_FOREIGN_KEY_CONSTRAINT) THEN
            l_ddl_columns_ref := l_ddl_columns_ref ||
                                 '(';

            <<list_all_columns_in_r_table>>
            FOR list_ref_columns IN  (  SELECT POSITION
                                              ,COLUMN_NAME
                                              ,TABLE_NAME
                                          FROM ALL_CONS_COLUMNS
                                         WHERE OWNER = l_ref_owner
                                           AND CONSTRAINT_NAME = l_ref_constraint_name
                                      ORDER BY POSITION ) LOOP
                l_ref_table_name := list_ref_columns.TABLE_NAME;
                l_ddl_columns_ref := l_ddl_columns_ref ||

                    CASE
                        WHEN list_ref_columns.position = 1
                            THEN ''
                        ELSE ', '
                    END ||
                                     list_ref_columns.column_name;
            END LOOP list_all_columns_in_r_table;

            l_ddl_columns_ref := l_ddl_columns_ref ||
                                 ')';
            l_ddl_ref := ' REFERENCES ' ||
                         l_ref_owner ||
                         '.' ||
                         l_ref_table_name ||
                         l_ddl_columns_ref;
        END IF;

        /**
        * ----------------------------------------------------------------------
        * Only for CHECK CONSTRAINTS
        * ----------------------------------------------------------------------
        */

        IF (constraint_type_in = c_CHECK_CONSTRAINT) THEN
            l_ddl_check := '(' ||
                           l_search_condition ||
                           ')';
        END IF;

        l_ddl := l_ddl_begin ||
                 l_ddl_columns ||
                 l_ddl_ref ||
                 l_ddl_check ||
                 l_ddl_end;
        RETURN l_ddl;
    END get_constraint_ddl;

    FUNCTION get_constraints_ddl(schema_name_in     IN VARCHAR2
                                ,table_name_in      IN VARCHAR2
                                ,constraint_type_in IN VARCHAR2) RETURN LONG_TEXT
    IS
        l_ddls LONG_TEXT;

    BEGIN

        <<list_all_table_constraints>>
        FOR list_constraints IN  (SELECT OWNER
                                        ,TABLE_NAME
                                        ,CONSTRAINT_NAME
                                        ,CONSTRAINT_TYPE
                                    FROM ALL_CONSTRAINTS
                                   WHERE OWNER = schema_name_in
                                     AND CONSTRAINT_TYPE = constraint_type_in
                                     AND table_name = table_name_in ) LOOP

            IF ( NOT is_not_null_constraint(list_constraints.owner, list_constraints.table_name, list_constraints.constraint_name)) THEN
                l_ddls := l_ddls ||
                          get_constraint_ddl(schema_name_in => list_constraints.owner, table_name_in => list_constraints.table_name, constraint_name_in => list_constraints.constraint_name,
                                             constraint_type_in => list_constraints.constraint_type) ||
                          c_LINE_ENDING;
            END IF;

        END LOOP list_all_table_constraints;

        RETURN l_ddls;
    END get_constraints_ddl;

END UTL$DB;
/
