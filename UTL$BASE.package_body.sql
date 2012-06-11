CREATE OR REPLACE
PACKAGE BODY UTL$BASE
IS

    /**
    * ============================================================================
    *                           History of changes
    * ============================================================================
    *  Date (DD/MM/YYYY) Who               Description
    * ----------------- ----------------- --------------------------------
    *  18/12/2009        Martin Mareš      Create package
    *  11/06/2012        Martin Mareš      GitHub distribution
    * ============================================================================
    */
    FUNCTION hash_map_create(map_name_in        T_SMALL_STRING
                            ,map_description_in T_BIG_STRING   DEFAULT NULL
                            ,map_extra_data_in  T_BIG_STRING   DEFAULT NULL) RETURN R_HASH_MAP
    IS
        l_hash_map R_HASH_MAP;

    BEGIN
        g_HASH_MAP_INDEX := COALESCE(g_HASH_MAP_INDEX, 0) + 1;
        l_hash_map.map_index := g_HASH_MAP_INDEX;
        l_hash_map.map_name := map_name_in;
        l_hash_map.map_description := map_description_in;
        l_hash_map.map_extra_data := map_extra_data_in;
        RETURN l_hash_map;
    END hash_map_create;

    PROCEDURE hash_map_register(t_hash_map_io IN OUT T_HASH_MAP
                               ,r_hash_map_in IN     R_HASH_MAP)
    IS
        l_index        T_SMALL_DOUBLE;
        l_err_instance T_BIG_DOUBLE;

    BEGIN

        IF (hash_map_register_contains(t_hash_map_io, r_hash_map_in.map_name)) THEN
            l_err_instance := utl$base$err.GET_INSTANCE(utl$base$err.e_MAPA_S_TIMTO_JMENEM_EXISTUJE);
            utl$base$err.SET_CONTEXT(l_err_instance, 'r_hash_map_in.map_name', r_hash_map_in.map_name);
            utl$base$err.CALL_RAISE(utl$base$err.e_MAPA_S_TIMTO_JMENEM_EXISTUJE);
        ELSE
            t_hash_map_io(t_hash_map_io.COUNT) := r_hash_map_in;
        END IF;

    END hash_map_register;

    FUNCTION hash_map_register_contains(t_hash_map_in IN T_HASH_MAP
                                       ,map_name_in      T_SMALL_STRING) RETURN BOOLEAN
    IS
        l_return BOOLEAN := FALSE;

    BEGIN

        IF (t_hash_map_in.COUNT > 0) THEN

            <<registered_hash_maps>>
            FOR i IN t_hash_map_in.FIRST..t_hash_map_in.LAST LOOP

                IF (t_hash_map_in(i).map_name = map_name_in) THEN
                    l_return := TRUE;
                    EXIT registered_hash_maps;
                END IF;

            END LOOP registered_hash_maps;

        END IF;

        RETURN l_return;
    END hash_map_register_contains;

    PROCEDURE hash_map_flush_index
    IS

    BEGIN
        g_HASH_MAP_INDEX := 0;
        g_HASH_MAP_VALUE_INDEX := 0;
    END hash_map_flush_index;

    PROCEDURE hash_map_put(r_hash_map_io        IN OUT R_HASH_MAP
                          ,value_name_in        IN     T_SMALL_STRING
                          ,number_value_in      IN     T_MAX_DOUBLE
                          ,value_description_in IN     T_BIG_STRING   DEFAULT NULL
                          ,value_extra_data_in  IN     T_BIG_STRING   DEFAULT NULL)
    IS

    BEGIN
        hash_map_put(r_hash_map_io => r_hash_map_io, value_name_in => value_name_in, data_type_in => 'INTEGER', number_value_in => number_value_in,
                     value_description_in => value_description_in, value_extra_data_in => value_extra_data_in, string_value_in => NULL, date_value_in => NULL);
    END hash_map_put;

    PROCEDURE hash_map_put(r_hash_map_io        IN OUT R_HASH_MAP
                          ,value_name_in        IN     T_SMALL_STRING
                          ,string_value_in      IN     T_MAX_STRING
                          ,value_description_in IN     T_BIG_STRING   DEFAULT NULL
                          ,value_extra_data_in  IN     T_BIG_STRING   DEFAULT NULL)
    IS

    BEGIN
        hash_map_put(r_hash_map_io => r_hash_map_io, value_name_in => value_name_in, data_type_in => 'STRING', number_value_in => NULL, value_description_in => value_description_in,
                     value_extra_data_in => value_extra_data_in, string_value_in => NULL, date_value_in => NULL);
    END hash_map_put;

    PROCEDURE hash_map_put(r_hash_map_io        IN OUT R_HASH_MAP
                          ,value_name_in        IN     T_SMALL_STRING
                          ,date_value_in        IN     T_DATE
                          ,value_description_in IN     T_BIG_STRING   DEFAULT NULL
                          ,value_extra_data_in  IN     T_BIG_STRING   DEFAULT NULL)
    IS

    BEGIN
        hash_map_put(r_hash_map_io => r_hash_map_io, value_name_in => value_name_in, data_type_in => 't_DATE', number_value_in => NULL, value_description_in => value_description_in,
                     value_extra_data_in => value_extra_data_in, string_value_in => NULL, date_value_in => date_value_in);
    END hash_map_put;

    PROCEDURE hash_map_put(r_hash_map_io        IN OUT R_HASH_MAP
                          ,value_name_in        IN     T_SMALL_STRING
                          ,data_type_in         IN     T_SMALL_STRING
                          ,value_description_in IN     T_BIG_STRING   DEFAULT NULL
                          ,value_extra_data_in  IN     T_BIG_STRING   DEFAULT NULL
                          ,number_value_in      IN     T_MAX_DOUBLE
                          ,string_value_in      IN     T_MAX_STRING
                          ,date_value_in        IN     T_DATE)
    IS
        l_hash_map_value_array T_HASH_MAP_VALUE;
        l_hash_map             R_HASH_MAP;

    BEGIN
        g_HASH_MAP_VALUE_INDEX := COALESCE(g_HASH_MAP_VALUE_INDEX, 0) + 1;
        l_hash_map_value_array := r_hash_map_io.array_of_values;

    /*l_hash_map_value.value_index := g_HASH_MAP_VALUE_INDEX;
        l_hash_map_value.value_name := value_name_in;
        l_hash_map_value.data_type := data_type_in;
        l_hash_map_value.value_description := value_description_in;
        l_hash_map_value.value_extra_data := value_extra_data_in;*/

    /*if(data_type_in = DATA_TYPE_INTEGER) then
        l_hash_map_value.number_value      t_MAX_DOUBLE;
    end if;
    l_hash_map_value.float_value       FLOAT_MAX;
    l_hash_map_value.string_value      t_MAX_STRING;
    l_hash_map_value.date_value*/
    END hash_map_put;

    FUNCTION hash_map_get(t_hash_map_in IN T_HASH_MAP
                         ,value_name_in IN T_SMALL_STRING) RETURN T_MAX_STRING
    IS

    BEGIN
        NULL;
    END hash_map_get;

    FUNCTION str_remove_any_duplicate_char(text_in      IN VARCHAR2
                                          ,character_in    CHAR) RETURN VARCHAR2
    IS
        l_text       VARCHAR2(32767);
        l_find       CHAR(2);
        l_replace_to CHAR(1);

    BEGIN
        l_text := text_in;
        l_text := TRIM(l_text);
        l_find := character_in ||
                  character_in;
        l_replace_to := character_in;

        WHILE INSTR(l_text, l_find) > 0 LOOP
            l_text := REPLACE(l_text, l_find, l_replace_to);
        END LOOP;

        RETURN l_text;
    END str_remove_any_duplicate_char;

    FUNCTION str_remove_spaces(text_in IN VARCHAR2) RETURN VARCHAR2
    IS

    BEGIN
        RETURN str_remove_any_duplicate_char(text_in, ' ');
    END str_remove_spaces;

    FUNCTION str_any_char_to_space(text_in      IN VARCHAR2
                                  ,character_in IN CHAR) RETURN VARCHAR2
    IS
        l_text VARCHAR2(32767);

    BEGIN
        l_text := text_in;
        l_text := REPLACE(l_text, character_in, ' ');
        RETURN l_text;
    END str_any_char_to_space;

    FUNCTION str_special_chars_to_space(text_in IN VARCHAR2) RETURN VARCHAR2
    IS
        l_text VARCHAR2(32767);

    BEGIN
        l_text := text_in;
        l_text := str_any_char_to_space(l_text, '-');
        l_text := str_any_char_to_space(l_text, '_');
        RETURN l_text;
    END str_special_chars_to_space;

    FUNCTION str_group_box(text_in        IN VARCHAR2
                          ,line_length_in IN NUMBER
                          ,separator_in   IN CHAR     := '-') RETURN VARCHAR2
    IS
        l_return        VARCHAR2(32767);
        l_left_bracket  CHAR(1) := '[';
        l_right_bracket CHAR(1) := ']';
        l_separator     VARCHAR2(10) := separator_in;
        l_BEGIN         VARCHAR2(10);
        l_END           VARCHAR2(10);
        l_DOTTED        VARCHAR2(10) := '...';

    BEGIN
        l_BEGIN := l_separator ||
                   l_separator ||
                   l_left_bracket;
        l_END := l_right_bracket ||
                 l_separator ||
                 l_separator;
        l_return := l_BEGIN ||
                    text_in ||
                    l_END ||
                    RPAD(l_separator, line_length_in - LENGTH(l_BEGIN) - LENGTH(text_in) - LENGTH(l_END), l_separator);

        IF (line_length_in <= LENGTH(l_BEGIN) + 2 * LENGTH(l_DOTTED) + LENGTH(l_END)
            OR line_length_in IS NULL) THEN
            l_return := l_BEGIN ||
                        SUBSTR(text_in, 1, line_length_in - LENGTH(l_BEGIN) - LENGTH(l_END)) ||
                        l_END ||
                        RPAD(l_separator, line_length_in - LENGTH(l_BEGIN) - LENGTH(text_in) - LENGTH(l_END), l_separator);
        ELSIF (LENGTH(l_BEGIN ||
                      text_in ||
                      l_END) > line_length_in) THEN
            l_return := l_BEGIN ||
                        SUBSTR(text_in ||
                               l_DOTTED, 1, line_length_in - LENGTH(l_BEGIN) - LENGTH(l_END) - LENGTH(l_DOTTED)) ||
                        l_DOTTED ||
                        l_END ||
                        RPAD(l_separator, line_length_in - LENGTH(l_BEGIN) - LENGTH(text_in) - LENGTH(l_END), l_separator);
        END IF;

        RETURN l_return;
    END str_group_box;

    FUNCTION base64_encode_clob(clob_in IN T_BIG_DATA) RETURN T_BIG_DATA
    IS
        l_clob_out      T_BIG_DATA;
        l_xml_string    VARCHAR2(32767);
        l_base64_encode VARCHAR2(32767);
        l_cast_to_raw   RAW(32767);
        l_string        VARCHAR2(32767);
        l_substr        VARCHAR2(32767);
        l_least         VARCHAR2(32767);
        l_start_pos     NUMBER := 0;
        l_base64_piece  NUMBER := 48;  --  The utl_encode.base64_encode function adds a linebreak for every 48 bytes of input data
        l_clob_length   NUMBER;

        SUBTYPE clob_array_type IS T_BIG_DATA_LIST;
        clob_array CLOB_ARRAY_TYPE;
        l_index    NUMBER := 0;

    BEGIN
        l_clob_length := LENGTH(clob_in);
        l_base64_piece := 48;
        l_xml_string := '';

        WHILE l_start_pos <= l_clob_length LOOP
            l_string := '';
            l_least := LEAST(l_base64_piece, l_clob_length - l_start_pos);
            l_substr := DBMS_LOB.SUBSTR(clob_in, l_least, l_start_pos + 1);
            l_cast_to_raw := utl_raw.cast_to_raw(l_substr);
            EXIT WHEN l_substr IS NULL;
            l_index := l_index + 1;
            l_base64_encode := utl_encode.base64_encode(l_cast_to_raw);
            l_string := utl_raw.cast_to_varchar2(l_base64_encode);
            l_start_pos := l_start_pos + l_base64_piece;
            clob_array(l_index) := l_string;
        END LOOP;

        l_clob_out := clob_array(1);

        FOR i IN 2..l_index LOOP
            DBMS_LOB.append(l_clob_out, clob_array(i));
        END LOOP;

        RETURN l_clob_out;
    END;

    /**
    * ======================================================================
    *  Unit test shuld be the last section
    * ======================================================================
    */

    PROCEDURE ut$STR_GROUP_BOX(test_suite_in IN T_BIG_STRING DEFAULT NULL)
    IS
        l_group_box_str VARCHAR2(2000) := NULL;

    BEGIN
        l_group_box_str := utl$base.str_group_box(text_in => RPAD('Text ', 2 * 80, 'Text '), line_length_in => 80);
        ut.ASSERT_EQUAL(80, LENGTH(l_group_box_str), 'Oèekáváná délka øetezce je ''{$EXPECTED_VALUE}''');
        ut.ASSERT_EQUAL('--[Text]--', utl$base.str_group_box('Text', LENGTH('--[Text]--')), 'Obsahuje text {$EXPECTED_VALUE}');
        ut.ASSERT_EQUAL('--[Text]---', utl$base.str_group_box('Text', LENGTH('--[Text]---')), 'Obsahuje text {$EXPECTED_VALUE}');
        ut.ASSERT_EQUAL('--[Text]------------', utl$base.str_group_box('Text', LENGTH('--[Text]------------')), 'Obsahuje text {$EXPECTED_VALUE}');
        ut.ASSERT_CONTAINS_AT_BEGIN('--[', l_group_box_str, 'Na zaèátku je text ''{$EXPECTED_VALUE}''');
        ut.ASSERT_CONTAINS_AT_END('--', l_group_box_str, 'Na konci je text ''{$EXPECTED_VALUE}''');
        ut.ASSERT_EQUAL('--[Text...]--', utl$base.str_group_box('Text Text', LENGTH('--[Text Te]--')), 'Obsahuje text {$EXPECTED_VALUE}');
        ut.ASSERT_EQUAL('--[Text Text Text]--', utl$base.str_group_box('Text Text Text', LENGTH('--[Text Text Text]--')), 'Návratová hodnota je rovna ''{$EXPECTED_VALUE}''');
        ut.ASSERT_EQUAL('--[Text...]--', utl$base.str_group_box('Text Text Text', LENGTH('--[Text...]--')), 'Návratová hodnota je rovna ''{$EXPECTED_VALUE}''');
        ut.ASSERT_EQUAL('--[ABCDEF]--' ||
                        RPAD('-', 10, '-'), utl$base.str_group_box('ABCDEF', LENGTH('--[ABCDEF]--') + LENGTH(RPAD('-', 10, '-'))), 'Návratová hodnota je rovna ''{$EXPECTED_VALUE}''');
        ut.ASSERT_EQUAL('--[ABCDEF]--' ||
                        RPAD('-', 100, '-'), utl$base.str_group_box('ABCDEF', LENGTH('--[ABCDEF]--') + LENGTH(RPAD('-', 100, '-'))), 'Návratová hodnota je rovna ''{$EXPECTED_VALUE}''');
        ut.ASSERT_EQUAL('--[ABCDEF]--', utl$base.str_group_box('ABCDEF', LENGTH('--[ABCDEF]--')), 'Návratová hodnota je rovna ''{$EXPECTED_VALUE}''');
        ut.ASSERT_EQUAL('--[ABCD]--', utl$base.str_group_box('ABCDEF', LENGTH('--[ABCD]--')), 'Návratová hodnota je rovna ''{$EXPECTED_VALUE}''');
        ut.ASSERT_EQUAL('--[ABC]--', utl$base.str_group_box('ABCDEF', LENGTH('--[ABC]--')), 'Návratová hodnota je rovna ''{$EXPECTED_VALUE}''');
        ut.ASSERT_EQUAL('--[AB]--', utl$base.str_group_box('ABCDEF', LENGTH('--[AB]--')), 'Návratová hodnota je rovna ''{$EXPECTED_VALUE}''');
        ut.ASSERT_EQUAL('--[A]--', utl$base.str_group_box('ABCDEF', LENGTH('--[A]--')), 'Návratová hodnota je rovna ''{$EXPECTED_VALUE}''');
        ut.ASSERT_EQUAL('--[]--', utl$base.str_group_box('ABCDEF', LENGTH('--[]--')), 'Návratová hodnota je rovna ''{$EXPECTED_VALUE}''');
        ut.ASSERT_EQUAL('--[]--', utl$base.str_group_box('ABCDEF', LENGTH('-')), 'Návratová hodnota je rovna ''{$EXPECTED_VALUE}''');
        ut.ASSERT_EQUAL('--[]--', utl$base.str_group_box('ABCDEF', LENGTH('')), 'Návratová hodnota je rovna ''{$EXPECTED_VALUE}''');
    END ut$STR_GROUP_BOX;

    PROCEDURE ut$(test_suite_in IN T_BIG_STRING DEFAULT NULL)
    IS

    BEGIN
        ut.start_up(test_suite_in);

        -- ut.run_procedure('STR_GROUP_BOX', test_suite_in);
        ut.tear_down(test_suite_in);
    END ut$;

/*
DECLARE
    l_map                          t_hash_map;
    l_submap                       t_hash_map;
    l_index_number                 NUMBER;
    l_index_date                   NUMBER;
    l_string                       VARCHAR2 ( 200 );
    l_date                         t_DATE;
    l_int                          NUMBER;
BEGIN
    -------------------- CREATE --------------------
    l_map := hash_map_create ( 'MyHashMap', 'BASIC' );
    -------------------- PUT --------------------
    hash_map_put ( l_map, 'valueName', 'NUMBER', 1 );
    -- nebo hash_map_put ( 'MyHashMap', 'valueName', 'NUMBER', 1 );
    l_index_date := hash_map_put ( l_map, 'valueDate', 't_DATE', SYSt_DATE );
    -- nebo l_index_date := hash_map_put ( 'MyHashMap', 'valueName', 't_DATE', SYSt_DATE );
    l_submap := hash_map_create ( 'SubMap', 'BASIC' );
    hash_map_put_map ( l_map, l_submap );
    hash_map_put ( l_submap, 'subValueName', 'NUMBER', 2 );
    -------------------- GET --------------------
    l_string := hash_map_get ( l_map, 'valueName' );  -- string convertion ???
    l_string := hash_map_get ( l_submap, 'subValueName' );  -- string convertion ???
    l_date := hash_map_get_date_value ( l_map, 'valueDate' );  -- date convertion ???
    l_int := hash_map_get_get_int_value ( l_submap, 'subValueName' ); -- int convertion ???
    -------------------- COPY --------------------
    -- all hierarchy parametr ???
    -------------------- CLONE --------------------
    -- all hierarchy parametr ???
    -------------------- PRINT --------------------
    -------------------- STORE --------------------
    -- store to DB, useknout délky typù na max délku datového typu v DB ???
END;
DECLARE
    l_map_array                     utl$base.t_hash_map;
    l_map                           utl$base.r_hash_map;
    l_submap                        utl$base.r_hash_map;
    l_index_number                  NUMBER;
    l_index_date                    NUMBER;
    l_string                        VARCHAR2 ( 200 );
    l_date                          t_DATE;
    l_int                           NUMBER;
BEGIN
    -------------------- CREATE --------------------
    utl$base.hash_map_flush_index();
    l_map := utl$base.hash_map_create ( 'MyHashMap', 'BASIC' );
    put_line('l_map.map_index = ' || l_map.map_index );
    put_line('l_map.map_name = ' || l_map.map_name );
    put_line('l_map.map_description = ' || l_map.map_description );
    l_submap := utl$base.hash_map_create ( 'MyHashMap2', 'BASIC' );
    put_line('l_submap.map_index = ' || l_submap.map_index );
    put_line('l_submap.map_name = ' || l_submap.map_name );
    put_line('l_submap.map_description = ' || l_submap.map_description );
    utl$base.hash_map_register(l_map_array, l_map);
    utl$base.hash_map_register(l_map_array, l_submap);
END;
*/

END UTL$BASE;
/
