CREATE OR REPLACE
PACKAGE BODY UTL$UNIT
IS

    /**
    * ============================================================================
    *                           History of changes
    * ============================================================================
    *  Date (DD/MM/YYYY) Who               Description
    * ----------------- ----------------- --------------------------------
    *  06/10/2010        Martin Mareš      Create package
    *  11/06/2011        Martin Mareš      Basic Assert functions added
    *  11/06/2012        Martin Mareš      GitHub distribution
    * ============================================================================
    */
    l_LAST_CHANGED        T_SMALL_STRING := '27/05/2011 (DD/MM/YYYY)';
    l_TEST_COUNTER_OK     T_SMALL_INTEGER := 0;
    l_TEST_COUNTER_FAILED T_SMALL_INTEGER := 0;
    l_START_TIME          T_BIG_INTEGER;
    l_STOP_TIME           T_BIG_INTEGER;

    TYPE t_BUFFER IS TABLE OF T_MAX_STRING INDEX BY T_BINARY_INTEGER;
    l_DEBUG_ENABLED       T_BOOLEAN := FALSE;
    l_DBMS_OUTPUT_ENABLED T_BOOLEAN := TRUE;
    l_DBMS_OUTPUT_BUFFER  T_BUFFER;
    l_USER_MESSAGES       T_USER_MESSAGES;
    l_TEST_PROCEDURES     T_TEST_PROCEDURES;
    l_TEST_SUITE_NAME     T_BIG_STRING;

    PROCEDURE DEBUG_ON
    IS

    BEGIN
        l_DEBUG_ENABLED := TRUE;
    END DEBUG_ON;

    PROCEDURE DEBUG_OFF
    IS

    BEGIN
        l_DEBUG_ENABLED := FALSE;
    END DEBUG_OFF;

    PROCEDURE DBMS_OUTPUT_ON
    IS

    BEGIN
        l_DBMS_OUTPUT_ENABLED := TRUE;
    END DBMS_OUTPUT_ON;

    PROCEDURE DBMS_OUTPUT_OFF
    IS

    BEGIN
        l_DBMS_OUTPUT_ENABLED := FALSE;
    END DBMS_OUTPUT_OFF;

    PROCEDURE wrap_put_line(input_text_in IN VARCHAR2)
    IS

    BEGIN

        IF (l_DBMS_OUTPUT_ENABLED) THEN

            IF (LENGTH(input_text_in) > 255) THEN
                DBMS_OUTPUT.put_line(SUBSTR(input_text_in, 1, 255 - 3) ||
                                     '...');
            ELSE
                DBMS_OUTPUT.put_line(input_text_in);
            END IF;

        END IF;

        l_DBMS_OUTPUT_BUFFER(l_DBMS_OUTPUT_BUFFER.COUNT) := input_text_in;
    END wrap_put_line;

    PROCEDURE wrap_put_(input_text_in IN VARCHAR2)
    IS

    BEGIN

        IF (l_DBMS_OUTPUT_ENABLED) THEN
            DBMS_OUTPUT.put(input_text_in);
        END IF;

        IF (l_DBMS_OUTPUT_BUFFER.COUNT > 0) THEN
            l_DBMS_OUTPUT_BUFFER(l_DBMS_OUTPUT_BUFFER.LAST) := input_text_in;
        END IF;

    END wrap_put_;

    FUNCTION get_test_id RETURN T_NUMBER
    IS

    BEGIN
        RETURN l_TEST_COUNTER_OK + l_TEST_COUNTER_FAILED;
    END get_test_id;

    FUNCTION get_replaced_special_string(text_in           IN T_MAX_STRING
                                        ,special_string_in IN T_SMALL_STRING
                                        ,replace_what_in   IN T_MAX_STRING) RETURN T_MAX_STRING
    IS
        l_return T_MAX_STRING;

    BEGIN
        l_return := REPLACE(text_in, c_SPECIAL_STRING_BEGIN ||
                                     c_SPECIAL_CHAR ||
                                     special_string_in ||
                                     c_SPECIAL_STRING_END, replace_what_in);
        RETURN l_return;
    END get_replaced_special_string;

    FUNCTION get_plural_for_number(number_in IN T_SMALL_INTEGER) RETURN T_SMALL_STRING
    IS
        l_return T_SMALL_STRING;

    BEGIN
        l_return :=
            CASE
                WHEN number_in > 1
                    THEN 's'
                ELSE NULL
            END;
        RETURN l_return;
    END get_plural_for_number;

    PROCEDURE print_ok
    IS

    BEGIN
        wrap_put_line(' ');
        wrap_put_line(UPPER(c_OK));
    END print_ok;

    PROCEDURE print_failed
    IS

    BEGIN
        wrap_put_line(' ');
        wrap_put_line(UPPER(c_FAILED));
    END print_failed;

    FUNCTION get_date_as_string(date_in   IN T_DATE
                               ,format_in IN T_SMALL_STRING DEFAULT c_DEFAULT_DATE_FORMAT) RETURN VARCHAR2
    IS

    BEGIN
        RETURN TO_CHAR(date_in, format_in);
    END get_date_as_string;

    FUNCTION get_time_as_string(date_in   IN T_DATE
                               ,format_in IN T_SMALL_STRING DEFAULT c_DEFAULT_TIME_FORMAT) RETURN VARCHAR2
    IS

    BEGIN
        RETURN TO_CHAR(date_in, format_in);
    END get_time_as_string;

    FUNCTION get_truncated_date(date_in   IN T_DATE
                               ,format_in IN T_SMALL_STRING DEFAULT c_DEFAULT_DATE_PRECISION) RETURN DATE
    IS

    BEGIN
        RETURN TO_DATE(TO_CHAR(date_in, format_in), format_in);
    END get_truncated_date;

    FUNCTION exists_failed_user_message(user_messages_list IN T_USER_MESSAGES) RETURN T_BOOLEAN
    IS
        l_return T_BOOLEAN;

    BEGIN
        l_return := FALSE;

        IF (user_messages_list.COUNT > 0) THEN

            <<find_failed_user_message>>
            FOR i_message IN user_messages_list.FIRST..user_messages_list.LAST LOOP

                IF (user_messages_list(i_message).outcome_type = c_FAILED) THEN
                    l_return := TRUE;
                END IF;

            END LOOP find_failed_user_message;

        END IF;

        RETURN l_return;
    END exists_failed_user_message;

    PROCEDURE print_header
    IS
        l_complete_result T_BOOLEAN := FALSE;
        l_global_name     T_BIG_STRING;

    BEGIN

        SELECT GLOBAL_NAME
          INTO l_global_name
          FROM GLOBAL_NAME;

        IF (l_DEBUG_ENABLED) THEN
            wrap_put_line('Debug option enabled!');
        END IF;

        wrap_put_line('Started on: ' ||
                      TO_CHAR(SYSDATE, 'DD. MM. YYYY (HH24:MI:SS)'));
        wrap_put_line('Database:   ' ||
                      l_global_name);
        wrap_put_('Tests:      ');
    END print_header;

    PROCEDURE print_one_user_message(user_messages_list IN T_USER_MESSAGES
                                    ,position_in        IN T_NUMBER)
    IS
        l_position          T_NUMBER;
        l_assert_words      VARCHAR2(2000);
        l_assert_words_list T_ASSERT_WORDS;

    BEGIN

        IF (user_messages_list.COUNT > 0) THEN
            l_position := COALESCE(position_in, user_messages_list.FIRST);
            l_assert_words_list := user_messages_list(l_position).assert_words_list;

            IF (l_assert_words_list.COUNT > 0) THEN

                <<assert_words_list>>
                FOR i_word IN l_assert_words_list.FIRST..l_assert_words_list.LAST LOOP
                    l_assert_words := l_assert_words ||
                                      l_assert_words_list(i_word);
                END LOOP assert_words_list;

            END IF;

            wrap_put_line(c_PREFIX ||
                          LPAD(user_messages_list(l_position).test_id, 4, '0') ||
                          c_SUFFIX ||
                          c_MESSAGE_DELIMITER ||
                          c_PREFIX ||
                          get_time_as_string(user_messages_list(l_position).start_time) ||
                          c_SUFFIX ||
                          c_MESSAGE_DELIMITER ||
                          RPAD(c_PREFIX ||
                               user_messages_list(l_position).test_identifier ||
                               c_SUFFIX, c_LONGEST_IDENTIFIER_LENGTH, ' ') ||
                          c_MESSAGE_DELIMITER ||
                          RPAD(c_PREFIX ||
                               user_messages_list(l_position).data_type ||
                               c_SUFFIX, c_LONGEST_DATATYPE_LENGTH, ' ') ||
                          c_MESSAGE_DELIMITER ||
                          RPAD(c_PREFIX ||
                               user_messages_list(l_position).outcome_type ||
                               c_SUFFIX, c_MESSAGE_PREFIX_LENGTH, ' ') ||
                          c_MESSAGE_DELIMITER ||
                          RPAD(c_ROUND_PARENTHES_BEGIN ||
                               'Assert: ' ||
                               l_assert_words ||
                               c_ROUND_PARENTHES_END, c_PARAMETERS_LENGTH, ' ') ||
                          c_MESSAGE_DELIMITER ||
                          '"' ||
                          user_messages_list(l_position).user_message ||
                          '"');
        END IF;

    END print_one_user_message;

    PROCEDURE print_failed_user_messages(user_messages_list IN T_USER_MESSAGES)
    IS
        l_position          T_NUMBER;
        l_assert_words      VARCHAR2(2000);
        l_assert_words_list T_ASSERT_WORDS;
        l_indentation       T_SMALL_STRING;
        l_indentation2x     T_SMALL_STRING;

    BEGIN

        IF (user_messages_list.COUNT > 0) THEN
            l_indentation := RPAD(c_INDENTATION_SEP_CHAR, c_BASIC_INDENTATION_LENGTH, c_INDENTATION_SEP_CHAR);
            l_indentation2x := RPAD(c_INDENTATION_SEP_CHAR, c_BASIC_INDENTATION_LENGTH * 2, c_INDENTATION_SEP_CHAR);
            wrap_put_line(' ');
            wrap_put_line(' ');

            <<list_user_messages>>
            FOR i_mess IN user_messages_list.FIRST..user_messages_list.LAST LOOP

                -- Print only "failed" messages!

                IF (user_messages_list(i_mess).outcome_type = c_FAILED) THEN
                    l_assert_words := NULL;
                    l_position := i_mess;
                    l_assert_words_list := user_messages_list(l_position).assert_words_list;

                    IF (l_assert_words_list.COUNT > 0) THEN

                        <<assert_words_list>>
                        FOR i_word IN l_assert_words_list.FIRST..l_assert_words_list.LAST LOOP
                            l_assert_words := l_assert_words ||
                                              l_assert_words_list(i_word);
                        END LOOP assert_words_list;
                    END IF;

                    wrap_put_line(l_indentation ||
                                  c_PREFIX ||
                                  user_messages_list(l_position).test_id ||
                                  c_SUFFIX);
                    wrap_put_line(l_indentation2x ||
                                  'Start time: ' ||
                                  get_time_as_string(user_messages_list(l_position).start_time));
                    wrap_put_line(l_indentation2x ||
                                  'Identifier: ' ||
                                  user_messages_list(l_position).test_identifier);
                    wrap_put_line(l_indentation2x ||
                                  'Data type:  ' ||
                                  user_messages_list(l_position).data_type);
                    wrap_put_line(l_indentation2x ||
                                  'Failed assert:  ' ||
                                  l_assert_words);
                    wrap_put_line(l_indentation2x ||
                                  'User message:  ' ||
                                  '"' ||
                                  user_messages_list(l_position).user_message ||
                                  '"');
                    wrap_put_line(' ');
                END IF;

            END LOOP list_user_messages;

        END IF;

    END print_failed_user_messages;

    PROCEDURE print_finished_in
    IS
        l_finished_in_text         T_SMALL_STRING;
        l_time_in_hunderts_of_secs T_SMALL_INTEGER;
        l_time_in_secs             T_SMALL_INTEGER;
        l_hundred                  T_SMALL_INTEGER;

    BEGIN
        l_hundred := 100;
        l_time_in_hunderts_of_secs := l_STOP_TIME - l_START_TIME;
        l_time_in_secs := l_time_in_hunderts_of_secs / l_hundred;

        IF (l_time_in_hunderts_of_secs < l_hundred) THEN
            l_finished_in_text := 'Finished in ' ||
                                  l_time_in_hunderts_of_secs ||
                                  ' hundrets of a second' ||
                                  get_plural_for_number(l_time_in_hunderts_of_secs);
        ELSE
            l_finished_in_text := 'Finished in ' ||
                                  l_time_in_secs ||
                                  ' second' ||
                                  get_plural_for_number(l_time_in_secs);
        END IF;

        wrap_put_line(l_finished_in_text);
    END print_finished_in;

    PROCEDURE print_results
    IS
        l_complete_result         BOOLEAN := FALSE;
        l_number_of_tests         T_SMALL_INTEGER;
        l_number_of_failure_tests T_SMALL_INTEGER;
        l_number_of_success_tests T_SMALL_INTEGER;
        l_result                  T_SMALL_STRING;

    BEGIN
        l_number_of_tests := (l_TEST_COUNTER_OK + l_TEST_COUNTER_FAILED);
        l_number_of_failure_tests := l_TEST_COUNTER_FAILED;
        l_number_of_success_tests := l_TEST_COUNTER_OK;

        IF (exists_failed_user_message(user_messages_list => l_USER_MESSAGES)
            AND NOT l_DEBUG_ENABLED) THEN
            print_failed_user_messages(user_messages_list => l_USER_MESSAGES);
        ELSE
            wrap_put_line(' ');
        END IF;

        wrap_put_line(' ');
        l_result := l_number_of_tests ||
                    ' test' ||
                    get_plural_for_number(l_number_of_tests) ||
                    ', ' ||
                    l_number_of_failure_tests ||
                    ' failure' ||
                    get_plural_for_number(l_number_of_failure_tests);

        IF (l_TEST_COUNTER_OK = 0
            AND l_TEST_COUNTER_FAILED = 0) THEN
            l_result := 'Found no test';
        END IF;

        print_finished_in();
        wrap_put_line(l_result);

        IF (l_TEST_COUNTER_FAILED = 0
            AND l_TEST_COUNTER_OK > 0) THEN
            print_ok();
        ELSE
            print_failed();
        END IF;

    END print_results;

    PROCEDURE print_run_suite
    IS
        l_text T_BIG_STRING;

    BEGIN
        l_text := 'Run suite: "' ||
                  l_TEST_SUITE_NAME ||
                  '"';
        wrap_put_line(utl$base.str_group_box(text_in => l_text, line_length_in => c_DEFAULT_RPAD_LENGTH));
    END;

    PROCEDURE start_up_suite(test_suite_in IN T_BIG_STRING DEFAULT NULL)
    IS

    BEGIN
        l_TEST_SUITE_NAME := test_suite_in;
        print_run_suite();
    END start_up_suite;

    PROCEDURE tear_down_suite(test_suite_in IN T_BIG_STRING DEFAULT NULL)
    IS

    BEGIN
        l_TEST_SUITE_NAME := NULL;
    END tear_down_suite;

    PROCEDURE start_up(test_suite_in IN T_BIG_STRING DEFAULT NULL)
    IS

    BEGIN
        l_START_TIME := DBMS_UTILITY.get_time();
        l_DBMS_OUTPUT_BUFFER.DELETE;
        l_USER_MESSAGES.DELETE;
        l_TEST_PROCEDURES.DELETE;
        print_header();
        l_TEST_COUNTER_OK := 0;
        l_TEST_COUNTER_FAILED := 0;
    END start_up;

    PROCEDURE tear_down(test_suite_in IN T_BIG_STRING DEFAULT NULL)
    IS

    BEGIN
        l_STOP_TIME := DBMS_UTILITY.get_time();
        print_results();
        l_TEST_COUNTER_OK := 0;
        l_TEST_COUNTER_FAILED := 0;
    END tear_down;

    PROCEDURE test_package(package_owner_in IN T_SMALL_STRING
                          ,package_name_in  IN T_SMALL_STRING
                          ,test_suite_in    IN T_BIG_STRING   DEFAULT NULL)
    IS

    BEGIN
        NULL;
    END;

    PROCEDURE test_procedure(procedure_owner_in IN T_SMALL_STRING
                            ,procedure_name_in  IN T_SMALL_STRING
                            ,test_suite_in      IN T_SMALL_STRING DEFAULT NULL)
    IS

    BEGIN
        NULL;
    END;

    PROCEDURE test_function(function_owner_in IN T_SMALL_STRING
                           ,function_name_in  IN T_SMALL_STRING
                           ,test_suite_in     IN T_SMALL_STRING DEFAULT NULL)
    IS

    BEGIN
        NULL;
    END;

    FUNCTION get_version RETURN T_SMALL_STRING
    IS

    BEGIN
        RETURN VERSION;
    END get_version;

    PROCEDURE print_version
    IS

    BEGIN
        wrap_put_line('Package version: ' ||
                      VERSION);
        wrap_put_line('Created by: ' ||
                      CREATED_BY);
        wrap_put_line('Last changed: ' ||
                      l_LAST_CHANGED);
    END print_version;

    PROCEDURE plusplus(value_io IN OUT T_NUMBER)
    IS
        l_return_io T_NUMBER;

    BEGIN
        l_return_io := plusplus(value_io);
    END plusplus;

    FUNCTION plusplus(value_io IN OUT T_NUMBER) RETURN T_NUMBER
    IS

    BEGIN
        value_io := NVL(value_io, 0) + 1;
        RETURN value_io;
    END;

    FUNCTION get_parsed_user_message(expected_value_in IN T_MAX_STRING
                                    ,tested_value_in   IN T_MAX_STRING
                                    ,user_message_in   IN T_USER_MESSAGE) RETURN T_USER_MESSAGE
    IS
        l_user_message T_USER_MESSAGE;

    BEGIN
        l_user_message := user_message_in;
        l_user_message := get_replaced_special_string(l_user_message, c_SPECIAL_EXPECTED_VALUE, expected_value_in);
        l_user_message := get_replaced_special_string(l_user_message, c_SPECIAL_TESTED_VALUE, tested_value_in);
        RETURN l_user_message;
    END get_parsed_user_message;

    PROCEDURE print_message(test_identifier_in   IN T_SMALL_STRING
                           ,data_type_in         IN T_SMALL_STRING
                           ,outcome_type_in      IN T_SMALL_STRING
                           ,assert_words_list_in IN T_ASSERT_WORDS
                           ,user_message_in      IN T_USER_MESSAGE)
    IS
        l_assert_words VARCHAR2(2000);
        l_test_id      T_NUMBER;
        l_start_time   T_DATE;
        l_time_snap    T_BIG_INTEGER;

    BEGIN
        l_test_id := get_test_id();
        l_start_time := SYSDATE;
        l_time_snap := DBMS_UTILITY.get_time();

        IF (assert_words_list_in.COUNT > 0) THEN

            FOR i_word IN assert_words_list_in.FIRST..assert_words_list_in.LAST LOOP
                l_assert_words := l_assert_words ||
                                  assert_words_list_in(i_word);
            END LOOP;

        END IF;

        l_USER_MESSAGES(l_USER_MESSAGES.COUNT).test_id := l_test_id;
        l_USER_MESSAGES(l_USER_MESSAGES.LAST).start_time := l_start_time;
        l_USER_MESSAGES(l_USER_MESSAGES.LAST).test_identifier := test_identifier_in;
        l_USER_MESSAGES(l_USER_MESSAGES.LAST).data_type := data_type_in;
        l_USER_MESSAGES(l_USER_MESSAGES.LAST).outcome_type := outcome_type_in;
        l_USER_MESSAGES(l_USER_MESSAGES.LAST).assert_words_list := assert_words_list_in;
        l_USER_MESSAGES(l_USER_MESSAGES.LAST).user_message := user_message_in;
        l_USER_MESSAGES(l_USER_MESSAGES.LAST).time_snap := l_time_snap;

        IF (l_DEBUG_ENABLED) THEN

            IF (l_test_id <= 1) THEN
                wrap_put_line(' ');
                wrap_put_line(' ');
            END IF;

            print_one_user_message(user_messages_list => l_USER_MESSAGES, position_in => l_USER_MESSAGES.LAST);
        ELSE

            IF (outcome_type_in = c_OK) THEN
                wrap_put_(c_OK_CHAR);
            ELSE
                wrap_put_(c_FAILED_CHAR);
            END IF;

        END IF;

    END print_message;

    PROCEDURE print_message_ok(test_identifier_in   IN T_SMALL_STRING
                              ,data_type_in         IN T_SMALL_STRING
                              ,assert_words_list_in IN T_ASSERT_WORDS
                              ,user_message_in      IN T_USER_MESSAGE)
    IS

    BEGIN
        plusplus(l_TEST_COUNTER_OK);
        print_message(test_identifier_in => test_identifier_in, data_type_in => data_type_in, outcome_type_in => c_OK, assert_words_list_in => assert_words_list_in,
                      user_message_in => user_message_in);
    END print_message_ok;

    PROCEDURE print_message_failed(test_identifier_in   IN T_SMALL_STRING
                                  ,data_type_in         IN T_SMALL_STRING
                                  ,assert_words_list_in IN T_ASSERT_WORDS
                                  ,user_message_in      IN T_USER_MESSAGE)
    IS

    BEGIN
        plusplus(l_TEST_COUNTER_FAILED);
        print_message(test_identifier_in => test_identifier_in, data_type_in => data_type_in, outcome_type_in => c_FAILED, assert_words_list_in => assert_words_list_in,
                      user_message_in => user_message_in);
    END print_message_failed;

    -- boolean

    PROCEDURE assert_true(condition_in    IN T_BOOLEAN
                         ,user_message_in IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN condition_in
                    THEN c_TRUE
                ELSE c_FALSE
            END;
        l_assert_words(l_assert_words.COUNT) := ' is ';
        l_assert_words(l_assert_words.COUNT) := c_TRUE;

        IF (condition_in) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_BOOLEAN, data_type_in => c_DATATYPE_BOOLEAN, assert_words_list_in => l_assert_words,
                             user_message_in => user_message_in);
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_BOOLEAN, data_type_in => c_DATATYPE_BOOLEAN, assert_words_list_in => l_assert_words,
                                 user_message_in => user_message_in);
        END IF;

    END assert_true;

    PROCEDURE assert_false(condition_in    IN T_BOOLEAN
                          ,user_message_in IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN NOT condition_in
                    THEN c_TRUE
                ELSE c_FALSE
            END;
        l_assert_words(l_assert_words.COUNT) := ' is not ';
        l_assert_words(l_assert_words.COUNT) := c_TRUE;

        IF ( NOT condition_in) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_BOOLEAN, data_type_in => c_DATATYPE_BOOLEAN, assert_words_list_in => l_assert_words,
                             user_message_in => user_message_in);
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_BOOLEAN, data_type_in => c_DATATYPE_BOOLEAN, assert_words_list_in => l_assert_words,
                                 user_message_in => user_message_in);
        END IF;

    END assert_false;

    PROCEDURE assert_null(tested_value_in IN T_BOOLEAN
                         ,user_message_in IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE c_NOT_NULL
            END;
        l_assert_words(l_assert_words.COUNT) := ' is ' ||
                                                c_NULL;

        IF (tested_value_in IS NULL) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_BOOLEAN, data_type_in => c_DATATYPE_BOOLEAN, assert_words_list_in => l_assert_words,
                             user_message_in => user_message_in);
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_BOOLEAN, data_type_in => c_DATATYPE_BOOLEAN, assert_words_list_in => l_assert_words,
                                 user_message_in => user_message_in);
        END IF;

    END assert_null;

    PROCEDURE assert_equal(expected_value_in IN T_BOOLEAN
                          ,tested_value_in   IN T_BOOLEAN
                          ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                WHEN expected_value_in
                    THEN c_TRUE
                ELSE c_FALSE
            END;
        l_assert_words(l_assert_words.COUNT) := c_EQUAL;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                WHEN tested_value_in
                    THEN c_TRUE
                ELSE c_FALSE
            END;

        IF ((expected_value_in = tested_value_in)
            OR (expected_value_in IS NULL
                AND tested_value_in IS NULL)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_EQUAL, data_type_in => c_DATATYPE_BOOLEAN, assert_words_list_in => l_assert_words,
                             user_message_in => user_message_in);
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_EQUAL, data_type_in => c_DATATYPE_BOOLEAN, assert_words_list_in => l_assert_words,
                                 user_message_in => user_message_in);
        END IF;

    END assert_equal;

    PROCEDURE assert_not_equal(expected_value_in IN T_BOOLEAN
                              ,tested_value_in   IN T_BOOLEAN
                              ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                WHEN expected_value_in
                    THEN c_TRUE
                ELSE c_FALSE
            END;
        l_assert_words(l_assert_words.COUNT) := c_NOT_EQUAL;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                WHEN tested_value_in
                    THEN c_TRUE
                ELSE c_FALSE
            END;

        IF ((expected_value_in <> tested_value_in)
            OR (expected_value_in IS NULL
                AND tested_value_in IS NOT NULL)
            OR (expected_value_in IS NOT NULL
                AND tested_value_in IS NULL)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_NOT_EQUAL, data_type_in => c_DATATYPE_BOOLEAN, assert_words_list_in => l_assert_words,
                             user_message_in => user_message_in);
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_NOT_EQUAL, data_type_in => c_DATATYPE_BOOLEAN, assert_words_list_in => l_assert_words,
                                 user_message_in => user_message_in);
        END IF;

    END assert_not_equal;

    PROCEDURE assert_not_null(tested_value_in IN T_BOOLEAN
                             ,user_message_in IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE
                    CASE
                        WHEN tested_value_in = TRUE
                            THEN c_TRUE
                        ELSE c_FALSE
                    END
            END;
        l_assert_words(l_assert_words.COUNT) := ' is ' ||
                                                c_NOT_NULL;

        IF (tested_value_in IS NOT NULL) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_NOT_NULL, data_type_in => c_DATATYPE_BOOLEAN, assert_words_list_in => l_assert_words,
                             user_message_in => user_message_in);
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_NOT_NULL, data_type_in => c_DATATYPE_BOOLEAN, assert_words_list_in => l_assert_words,
                                 user_message_in => user_message_in);
        END IF;

    END assert_not_null;

    -- number

    PROCEDURE assert_null(tested_value_in IN T_NUMBER
                         ,user_message_in IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE c_NOT_NULL
            END;
        l_assert_words(l_assert_words.COUNT) := ' is ' ||
                                                c_NULL;

        IF (tested_value_in IS NULL) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_NULL, data_type_in => c_DATATYPE_NUMBER, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(NULL, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_NULL, data_type_in => c_DATATYPE_NUMBER, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(NULL, tested_value_in, user_message_in));
        END IF;

    END assert_null;

    PROCEDURE assert_not_null(tested_value_in IN T_NUMBER
                             ,user_message_in IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE c_NOT_NULL
            END;
        l_assert_words(l_assert_words.COUNT) := ' is ' ||
                                                c_NOT_NULL;

        IF (tested_value_in IS NOT NULL) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_NOT_NULL, data_type_in => c_DATATYPE_NUMBER, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(NULL, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_NOT_NULL, data_type_in => c_DATATYPE_NUMBER, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(NULL, tested_value_in, user_message_in));
        END IF;

    END assert_not_null;

    PROCEDURE assert_equal(expected_value_in IN T_NUMBER
                          ,tested_value_in   IN T_NUMBER
                          ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                ELSE TO_CHAR(expected_value_in)
            END;
        l_assert_words(l_assert_words.COUNT) := c_EQUAL;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE TO_CHAR(tested_value_in)
            END;

        IF ((expected_value_in = tested_value_in)
            OR (expected_value_in IS NULL
                AND tested_value_in IS NULL)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_EQUAL, data_type_in => c_DATATYPE_NUMBER, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_EQUAL, data_type_in => c_DATATYPE_NUMBER, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        END IF;

    END assert_equal;

    PROCEDURE assert_not_equal(expected_value_in IN T_NUMBER
                              ,tested_value_in   IN T_NUMBER
                              ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                ELSE TO_CHAR(expected_value_in)
            END;
        l_assert_words(l_assert_words.COUNT) := c_NOT_EQUAL;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE TO_CHAR(tested_value_in)
            END;

        IF ((expected_value_in <> tested_value_in)
            OR (expected_value_in IS NULL
                AND tested_value_in IS NOT NULL)
            OR (expected_value_in IS NOT NULL
                AND tested_value_in IS NULL)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_NOT_EQUAL, data_type_in => c_DATATYPE_NUMBER, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_NOT_EQUAL, data_type_in => c_DATATYPE_NUMBER, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        END IF;

    END assert_not_equal;

    PROCEDURE assert_greather_then(expected_value_in IN T_NUMBER
                                  ,tested_value_in   IN T_NUMBER
                                  ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                ELSE TO_CHAR(expected_value_in)
            END;
        l_assert_words(l_assert_words.COUNT) := c_GREATHER_THEN;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE TO_CHAR(tested_value_in)
            END;

        IF ((expected_value_in > tested_value_in)
            OR (expected_value_in IS NOT NULL
                AND tested_value_in IS NULL)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_GREATER_THEN, data_type_in => c_DATATYPE_NUMBER, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_GREATER_THEN, data_type_in => c_DATATYPE_NUMBER, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        END IF;

    END assert_greather_then;

    PROCEDURE assert_greather_then_or_equal(expected_value_in IN T_NUMBER
                                           ,tested_value_in   IN T_NUMBER
                                           ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                ELSE TO_CHAR(expected_value_in)
            END;
        l_assert_words(l_assert_words.COUNT) := c_GREATHER_THEN_OR_EQUAL;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE TO_CHAR(tested_value_in)
            END;

        IF ((expected_value_in >= tested_value_in)
            OR (expected_value_in IS NOT NULL
                AND tested_value_in IS NULL)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_GREATER_THEN_OR_EQ, data_type_in => c_DATATYPE_NUMBER, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_GREATER_THEN_OR_EQ, data_type_in => c_DATATYPE_NUMBER, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        END IF;

    END assert_greather_then_or_equal;

    PROCEDURE assert_less_then(expected_value_in IN T_NUMBER
                              ,tested_value_in   IN T_NUMBER
                              ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                ELSE TO_CHAR(expected_value_in)
            END;
        l_assert_words(l_assert_words.COUNT) := c_LESS_THEN;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE TO_CHAR(tested_value_in)
            END;

        IF ((expected_value_in < tested_value_in)
            OR (expected_value_in IS NULL
                AND tested_value_in IS NOT NULL)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_LESS_THEN, data_type_in => c_DATATYPE_NUMBER, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_LESS_THEN, data_type_in => c_DATATYPE_NUMBER, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        END IF;

    END assert_less_then;

    PROCEDURE assert_less_then_or_equal(expected_value_in IN T_NUMBER
                                       ,tested_value_in   IN T_NUMBER
                                       ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                ELSE TO_CHAR(expected_value_in)
            END;
        l_assert_words(l_assert_words.COUNT) := c_LESS_THEN_OR_EQUAL;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE TO_CHAR(tested_value_in)
            END;

        IF ((expected_value_in <= tested_value_in)
            OR (expected_value_in IS NULL
                AND tested_value_in IS NOT NULL)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_LESS_THEN_OR_EQ, data_type_in => c_DATATYPE_NUMBER, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_LESS_THEN_OR_EQ, data_type_in => c_DATATYPE_NUMBER, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        END IF;

    END assert_less_then_or_equal;

    -- string

    PROCEDURE assert_null(tested_value_in IN T_MAX_STRING
                         ,user_message_in IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE c_NOT_NULL
            END;
        l_assert_words(l_assert_words.COUNT) := ' is ' ||
                                                c_NULL;

        IF (tested_value_in IS NULL) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_NULL, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(NULL, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_NULL, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(NULL, tested_value_in, user_message_in));
        END IF;

    END assert_null;

    PROCEDURE assert_not_null(tested_value_in IN T_MAX_STRING
                             ,user_message_in IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE c_NOT_NULL
            END;
        l_assert_words(l_assert_words.COUNT) := ' is ' ||
                                                c_NOT_NULL;

        IF (tested_value_in IS NOT NULL) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_NOT_NULL, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(NULL, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_NOT_NULL, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(NULL, tested_value_in, user_message_in));
        END IF;

    END assert_not_null;

    PROCEDURE assert_equal(expected_value_in IN T_MAX_STRING
                          ,tested_value_in   IN T_MAX_STRING
                          ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN LENGTH(expected_value_in) > 10
                    THEN expected_value_in
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                ELSE expected_value_in
            END;
        l_assert_words(l_assert_words.COUNT) := c_EQUAL;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN LENGTH(tested_value_in) > 10
                    THEN tested_value_in
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE tested_value_in
            END;

        IF (expected_value_in IS NULL
            AND tested_value_in IS NULL)
           OR (expected_value_in IS NOT NULL
               AND tested_value_in IS NOT NULL
               AND expected_value_in = tested_value_in) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_EQUAL, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_EQUAL, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        END IF;

    END assert_equal;

    PROCEDURE assert_not_equal(expected_value_in IN T_MAX_STRING
                              ,tested_value_in   IN T_MAX_STRING
                              ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN LENGTH(expected_value_in) > 10
                    THEN expected_value_in
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                ELSE expected_value_in
            END;
        l_assert_words(l_assert_words.COUNT) := c_NOT_EQUAL;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN LENGTH(tested_value_in) > 10
                    THEN tested_value_in
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE tested_value_in
            END;

        IF ((expected_value_in <> tested_value_in)
            OR (expected_value_in IS NULL
                AND tested_value_in IS NOT NULL)
            OR (expected_value_in IS NOT NULL
                AND tested_value_in IS NULL)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_NOT_EQUAL, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_NOT_EQUAL, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        END IF;

    END assert_not_equal;

    PROCEDURE assert_greather_then(expected_value_in IN T_MAX_STRING
                                  ,tested_value_in   IN T_MAX_STRING
                                  ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) := 'String length ';
        l_assert_words(l_assert_words.COUNT) := NVL(LENGTH(expected_value_in), 0);
        l_assert_words(l_assert_words.COUNT) := c_GREATHER_THEN;
        l_assert_words(l_assert_words.COUNT) := NVL(LENGTH(tested_value_in), 0);

        IF (NVL(LENGTH(expected_value_in), 0) > NVL(LENGTH(tested_value_in), 0)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_GREATER_THEN, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_GREATER_THEN, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        END IF;

    END assert_greather_then;

    PROCEDURE assert_greather_then_or_equal(expected_value_in IN T_MAX_STRING
                                           ,tested_value_in   IN T_MAX_STRING
                                           ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) := 'String length ';
        l_assert_words(l_assert_words.COUNT) := NVL(LENGTH(expected_value_in), 0);
        l_assert_words(l_assert_words.COUNT) := c_GREATHER_THEN_OR_EQUAL;
        l_assert_words(l_assert_words.COUNT) := NVL(LENGTH(tested_value_in), 0);

        IF (NVL(LENGTH(expected_value_in), 0) >= NVL(LENGTH(tested_value_in), 0)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_GREATER_THEN_OR_EQ, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_GREATER_THEN_OR_EQ, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        END IF;

    END assert_greather_then_or_equal;

    PROCEDURE assert_less_then(expected_value_in IN T_MAX_STRING
                              ,tested_value_in   IN T_MAX_STRING
                              ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) := 'String length ';
        l_assert_words(l_assert_words.COUNT) := NVL(LENGTH(expected_value_in), 0);
        l_assert_words(l_assert_words.COUNT) := c_LESS_THEN;
        l_assert_words(l_assert_words.COUNT) := NVL(LENGTH(tested_value_in), 0);

        IF (NVL(LENGTH(expected_value_in), 0) < NVL(LENGTH(tested_value_in), 0)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_LESS_THEN, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_LESS_THEN, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        END IF;

    END assert_less_then;

    PROCEDURE assert_less_then_or_equal(expected_value_in IN T_MAX_STRING
                                       ,tested_value_in   IN T_MAX_STRING
                                       ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) := 'String length ';
        l_assert_words(l_assert_words.COUNT) := NVL(LENGTH(expected_value_in), 0);
        l_assert_words(l_assert_words.COUNT) := c_LESS_THEN_OR_EQUAL;
        l_assert_words(l_assert_words.COUNT) := NVL(LENGTH(tested_value_in), 0);

        IF (NVL(LENGTH(expected_value_in), 0) <= NVL(LENGTH(tested_value_in), 0)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_LESS_THEN_OR_EQ, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_LESS_THEN_OR_EQ, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        END IF;

    END assert_less_then_or_equal;

    PROCEDURE assert_contains(expected_value_in IN T_MAX_STRING
                             ,tested_value_in   IN T_MAX_STRING
                             ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN LENGTH(tested_value_in) > 10
                    THEN tested_value_in
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE tested_value_in
            END;
        l_assert_words(l_assert_words.COUNT) := c_SPACE_CHAR ||
                                                c_CONTAINS ||
                                                c_SPACE_CHAR;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN LENGTH(expected_value_in) > 10
                    THEN expected_value_in
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                ELSE expected_value_in
            END;

        IF ((tested_value_in IS NOT NULL
             AND expected_value_in IS NOT NULL
             AND tested_value_in LIKE c_LIKE_CHAR ||
                                                expected_value_in ||
                                                c_LIKE_CHAR)
            OR (tested_value_in IS NOT NULL
                AND expected_value_in IS NULL)
            OR (tested_value_in IS NULL
                AND expected_value_in IS NULL)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_CONTAINS, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_CONTAINS, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        END IF;

    END assert_contains;

    PROCEDURE assert_not_contains(expected_value_in IN T_MAX_STRING
                                 ,tested_value_in   IN T_MAX_STRING
                                 ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN LENGTH(tested_value_in) > 10
                    THEN tested_value_in
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE tested_value_in
            END;
        l_assert_words(l_assert_words.COUNT) := c_SPACE_CHAR ||
                                                c_NOT_CONTAINS ||
                                                c_SPACE_CHAR;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN LENGTH(expected_value_in) > 10
                    THEN expected_value_in
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                ELSE expected_value_in
            END;

        IF ( NOT ((tested_value_in IS NOT NULL
                   AND expected_value_in IS NOT NULL
                   AND tested_value_in LIKE c_LIKE_CHAR ||
                                                expected_value_in ||
                                                c_LIKE_CHAR)
                  OR (tested_value_in IS NOT NULL
                      AND expected_value_in IS NULL)
                  OR (tested_value_in IS NULL
                      AND expected_value_in IS NULL))) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_NOT_CONT, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_NOT_CONT, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        END IF;

    END assert_not_contains;

    PROCEDURE assert_contains_at_begin(expected_value_in IN T_MAX_STRING
                                      ,tested_value_in   IN T_MAX_STRING
                                      ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;
        l_user_message T_USER_MESSAGE;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN LENGTH(tested_value_in) > 10
                    THEN tested_value_in
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE tested_value_in
            END;
        l_assert_words(l_assert_words.COUNT) := c_SPACE_CHAR ||
                                                c_CONTAINS_AT_BEGIN ||
                                                c_SPACE_CHAR;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN LENGTH(expected_value_in) > 10
                    THEN expected_value_in
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                ELSE expected_value_in
            END;

        IF ((tested_value_in IS NOT NULL
             AND expected_value_in IS NOT NULL
             AND tested_value_in LIKE expected_value_in ||
                                                c_LIKE_CHAR)
            OR (tested_value_in IS NOT NULL
                AND expected_value_in IS NULL)
            OR (tested_value_in IS NULL
                AND expected_value_in IS NULL)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_CONTAINS_AT_BEGIN, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_CONTAINS_AT_BEGIN, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        END IF;

    END assert_contains_at_begin;

    PROCEDURE assert_contains_at_end(expected_value_in IN T_MAX_STRING
                                    ,tested_value_in   IN T_MAX_STRING
                                    ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;
        l_user_message T_USER_MESSAGE;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN LENGTH(tested_value_in) > 10
                    THEN tested_value_in
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE tested_value_in
            END;
        l_assert_words(l_assert_words.COUNT) := c_SPACE_CHAR ||
                                                c_CONTAINS_AT_END ||
                                                c_SPACE_CHAR;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN LENGTH(expected_value_in) > 10
                    THEN expected_value_in
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                ELSE expected_value_in
            END;

        IF ((tested_value_in IS NOT NULL
             AND expected_value_in IS NOT NULL
             AND tested_value_in LIKE c_LIKE_CHAR ||
                                                expected_value_in)
            OR (tested_value_in IS NOT NULL
                AND expected_value_in IS NULL)
            OR (tested_value_in IS NULL
                AND expected_value_in IS NULL)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_CONTAINS_AT_END, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                             user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_CONTAINS_AT_END, data_type_in => c_DATATYPE_STRING, assert_words_list_in => l_assert_words,
                                 user_message_in => get_parsed_user_message(expected_value_in, tested_value_in, user_message_in));
        END IF;

    END assert_contains_at_end;

    -- date

    PROCEDURE assert_null(tested_value_in IN T_DATE
                         ,user_message_in IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE c_NOT_NULL
            END;
        l_assert_words(l_assert_words.COUNT) := ' is ' ||
                                                c_NULL;

        IF (tested_value_in IS NULL) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_NULL, data_type_in => c_DATATYPE_DATE, assert_words_list_in => l_assert_words, user_message_in => user_message_in);
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_NULL, data_type_in => c_DATATYPE_DATE, assert_words_list_in => l_assert_words,
                                 user_message_in => user_message_in);
        END IF;

    END assert_null;

    PROCEDURE assert_not_null(tested_value_in IN T_DATE
                             ,user_message_in IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE c_NOT_NULL
            END;
        l_assert_words(l_assert_words.COUNT) := ' is ' ||
                                                c_NOT_NULL;

        IF (tested_value_in IS NOT NULL) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_NOT_NULL, data_type_in => c_DATATYPE_DATE, assert_words_list_in => l_assert_words,
                             user_message_in => user_message_in);
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_NOT_NULL, data_type_in => c_DATATYPE_DATE, assert_words_list_in => l_assert_words,
                                 user_message_in => user_message_in);
        END IF;

    END assert_not_null;

    PROCEDURE assert_equal(expected_value_in IN T_DATE
                          ,tested_value_in   IN T_DATE
                          ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                ELSE get_date_as_string(expected_value_in, c_DEFAULT_DATE_FULL)
            END;
        l_assert_words(l_assert_words.COUNT) := c_EQUAL;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE get_date_as_string(tested_value_in, c_DEFAULT_DATE_FULL)
            END;

        IF (expected_value_in IS NULL
            AND tested_value_in IS NULL)
           OR (expected_value_in IS NOT NULL
               AND tested_value_in IS NOT NULL
               AND get_truncated_date(expected_value_in) = get_truncated_date(tested_value_in)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_EQUAL, data_type_in => c_DATATYPE_DATE, assert_words_list_in => l_assert_words, user_message_in => user_message_in);
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_EQUAL, data_type_in => c_DATATYPE_DATE, assert_words_list_in => l_assert_words,
                                 user_message_in => user_message_in);
        END IF;

    END assert_equal;

    PROCEDURE assert_not_equal(expected_value_in IN T_DATE
                              ,tested_value_in   IN T_DATE
                              ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                ELSE get_date_as_string(expected_value_in, c_DEFAULT_DATE_FULL)
            END;
        l_assert_words(l_assert_words.COUNT) := c_NOT_EQUAL;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE get_date_as_string(tested_value_in, c_DEFAULT_DATE_FULL)
            END;

        IF ((get_truncated_date(expected_value_in) <> get_truncated_date(tested_value_in))
            OR (expected_value_in IS NULL
                AND tested_value_in IS NOT NULL)
            OR (expected_value_in IS NOT NULL
                AND tested_value_in IS NULL)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_NOT_EQUAL, data_type_in => c_DATATYPE_DATE, assert_words_list_in => l_assert_words,
                             user_message_in => user_message_in);
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_NOT_EQUAL, data_type_in => c_DATATYPE_DATE, assert_words_list_in => l_assert_words,
                                 user_message_in => user_message_in);
        END IF;

    END assert_not_equal;

    PROCEDURE assert_greather_then(expected_value_in IN T_DATE
                                  ,tested_value_in   IN T_DATE
                                  ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                ELSE get_date_as_string(expected_value_in, c_DEFAULT_DATE_FULL)
            END;
        l_assert_words(l_assert_words.COUNT) := c_GREATHER_THEN;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE get_date_as_string(tested_value_in, c_DEFAULT_DATE_FULL)
            END;

        IF ((expected_value_in IS NOT NULL
             AND tested_value_in IS NOT NULL
             AND get_truncated_date(expected_value_in) > get_truncated_date(tested_value_in))
            OR (expected_value_in IS NOT NULL
                AND tested_value_in IS NULL)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_GREATER_THEN, data_type_in => c_DATATYPE_DATE, assert_words_list_in => l_assert_words,
                             user_message_in => user_message_in);
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_GREATER_THEN, data_type_in => c_DATATYPE_DATE, assert_words_list_in => l_assert_words,
                                 user_message_in => user_message_in);
        END IF;

    END assert_greather_then;

    PROCEDURE assert_greather_then_or_equal(expected_value_in IN T_DATE
                                           ,tested_value_in   IN T_DATE
                                           ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                ELSE get_date_as_string(expected_value_in, c_DEFAULT_DATE_FULL)
            END;
        l_assert_words(l_assert_words.COUNT) := c_GREATHER_THEN_OR_EQUAL;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE get_date_as_string(tested_value_in, c_DEFAULT_DATE_FULL)
            END;

        IF ((expected_value_in IS NOT NULL
             AND tested_value_in IS NOT NULL
             AND get_truncated_date(expected_value_in) >= get_truncated_date(tested_value_in))
            OR (expected_value_in IS NOT NULL
                AND tested_value_in IS NULL)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_GREATER_THEN_OR_EQ, data_type_in => c_DATATYPE_DATE, assert_words_list_in => l_assert_words,
                             user_message_in => user_message_in);
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_GREATER_THEN_OR_EQ, data_type_in => c_DATATYPE_DATE, assert_words_list_in => l_assert_words,
                                 user_message_in => user_message_in);
        END IF;

    END assert_greather_then_or_equal;

    PROCEDURE assert_less_then(expected_value_in IN T_DATE
                              ,tested_value_in   IN T_DATE
                              ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                ELSE get_date_as_string(expected_value_in, c_DEFAULT_DATE_FULL)
            END;
        l_assert_words(l_assert_words.COUNT) := c_LESS_THEN;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE get_date_as_string(tested_value_in, c_DEFAULT_DATE_FULL)
            END;

        IF ((expected_value_in IS NOT NULL
             AND tested_value_in IS NOT NULL
             AND get_truncated_date(expected_value_in) < get_truncated_date(tested_value_in))
            OR (expected_value_in IS NULL
                AND tested_value_in IS NOT NULL)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_LESS_THEN, data_type_in => c_DATATYPE_DATE, assert_words_list_in => l_assert_words,
                             user_message_in => user_message_in);
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_LESS_THEN, data_type_in => c_DATATYPE_DATE, assert_words_list_in => l_assert_words,
                                 user_message_in => user_message_in);
        END IF;

    END assert_less_then;

    PROCEDURE assert_less_then_or_equal(expected_value_in IN T_DATE
                                       ,tested_value_in   IN T_DATE
                                       ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;

    BEGIN
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN expected_value_in IS NULL
                    THEN c_NULL
                ELSE get_date_as_string(expected_value_in, c_DEFAULT_DATE_FULL)
            END;
        l_assert_words(l_assert_words.COUNT) := c_LESS_THEN_OR_EQUAL;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN tested_value_in IS NULL
                    THEN c_NULL
                ELSE get_date_as_string(tested_value_in, c_DEFAULT_DATE_FULL)
            END;

        IF ((expected_value_in IS NOT NULL
             AND tested_value_in IS NOT NULL
             AND get_truncated_date(expected_value_in) <= get_truncated_date(tested_value_in))
            OR (expected_value_in IS NULL
                AND tested_value_in IS NOT NULL)) THEN
            print_message_ok(test_identifier_in => c_ID_ASSERT_LESS_THEN_OR_EQ, data_type_in => c_DATATYPE_DATE, assert_words_list_in => l_assert_words,
                             user_message_in => user_message_in);
        ELSE
            print_message_failed(test_identifier_in => c_ID_ASSERT_LESS_THEN_OR_EQ, data_type_in => c_DATATYPE_DATE, assert_words_list_in => l_assert_words,
                                 user_message_in => user_message_in);
        END IF;

    END assert_less_then_or_equal;

    FUNCTION exists_object(object_owner_in IN T_SMALL_STRING
                          ,object_name_in  IN T_SMALL_STRING
                          ,object_type_in  IN T_SMALL_STRING) RETURN T_BOOLEAN
    IS
        l_return       T_BOOLEAN := FALSE;
        l_object_count T_PLS_INTEGER;
        l_owner        T_SMALL_STRING;
        l_object_name  T_SMALL_STRING;

    BEGIN
        l_owner := COALESCE(object_owner_in, USER);
        l_object_name := object_name_in;

        IF (l_object_name IS NOT NULL) THEN

            IF (object_type_in IN(c_OBJECT_TYPE_TABLE
                                 ,c_OBJECT_TYPE_PROCEDURE
                                 ,c_OBJECT_TYPE_FUNCTION
                                 ,c_OBJECT_TYPE_PACKAGE
                                 ,c_OBJECT_TYPE_PACKAGE_B)) THEN

                SELECT COUNT(1)
                  INTO l_object_count
                  FROM ALL_OBJECTS
                 WHERE OWNER = object_owner_in
                   AND OBJECT_NAME = object_name_in
                   AND OBJECT_TYPE = object_type_in;

            END IF;

        END IF;

        l_return :=
            CASE
                WHEN l_object_count > 0
                    THEN TRUE
                ELSE FALSE
            END;
        RETURN l_return;
    END exists_object;

    PROCEDURE assert_exists_object(object_owner_in IN T_SMALL_STRING
                                  ,object_name_in  IN T_SMALL_STRING
                                  ,object_type_in  IN T_SMALL_STRING
                                  ,user_message_in IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;
        l_exists_table T_BOOLEAN;
        l_data_type    T_SMALL_STRING;
        l_user_message T_USER_MESSAGE;

    BEGIN
        l_assert_words(l_assert_words.COUNT) := c_EXISTS;
        l_assert_words(l_assert_words.COUNT) := c_SPACE_CHAR;
        l_assert_words(l_assert_words.COUNT) := LOWER(object_type_in);
        l_assert_words(l_assert_words.COUNT) := c_SPACE_CHAR;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN object_owner_in IS NULL
                    THEN c_NULL
                ELSE UPPER(TRIM(object_owner_in))
            END;
        l_assert_words(l_assert_words.COUNT) := c_OWNER_AND_OBJ_NAME_SEP;
        l_assert_words(l_assert_words.COUNT) :=
            CASE
                WHEN object_name_in IS NULL
                    THEN c_NULL
                ELSE UPPER(TRIM(object_name_in))
            END;
        l_assert_words(l_assert_words.COUNT) := c_QUESTION_MARK_CHAR;
        l_exists_table := exists_object(object_owner_in => object_owner_in, object_name_in => object_name_in, object_type_in => object_type_in);
        l_data_type :=
            CASE
                WHEN object_type_in = c_OBJECT_TYPE_TABLE
                    THEN c_DATA_TYPE_OBJECT_TABLE
                WHEN object_type_in = c_OBJECT_TYPE_PROCEDURE
                    THEN c_DATA_TYPE_OBJECT_PROCEDURE
                WHEN object_type_in = c_OBJECT_TYPE_FUNCTION
                    THEN c_DATA_TYPE_OBJECT_FUNCTION
                WHEN object_type_in = c_OBJECT_TYPE_PACKAGE
                    THEN c_DATA_TYPE_OBJECT_PACKAGE
                WHEN object_type_in = c_OBJECT_TYPE_PACKAGE_B
                    THEN c_DATA_TYPE_OBJECT_PACKAGE_B
            END;

        IF (user_message_in IS NOT NULL) THEN
            l_user_message := user_message_in;
        ELSE
            l_user_message := 'There is an {$OBJECT_TYPE} with the name of the {$OBJECT_OWNER}.{$OBJECT_NAME}?';
        END IF;

        l_user_message := get_replaced_special_string(l_user_message, c_SPECIAL_OBJECT_OWNER, UPPER(object_owner_in));
        l_user_message := get_replaced_special_string(l_user_message, c_SPECIAL_OBJECT_NAME, UPPER(object_name_in));
        l_user_message := get_replaced_special_string(l_user_message, c_SPECIAL_OBJECT_TYPE, LOWER(object_type_in));

        IF (l_exists_table) THEN
            print_message_ok(test_identifier_in => c_ID_EXISTS_OBJECT, data_type_in => l_data_type, assert_words_list_in => l_assert_words, user_message_in => l_user_message);
        ELSE
            print_message_failed(test_identifier_in => c_ID_EXISTS_OBJECT, data_type_in => l_data_type, assert_words_list_in => l_assert_words,
                                 user_message_in => l_user_message);
        END IF;

    END assert_exists_object;

    PROCEDURE assert_exists_table(table_owner_in  IN T_SMALL_STRING
                                 ,table_name_in   IN T_SMALL_STRING
                                 ,user_message_in IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;
        l_exists_table T_BOOLEAN;

    BEGIN
        assert_exists_object(object_owner_in => table_owner_in, object_name_in => table_name_in, object_type_in => c_OBJECT_TYPE_TABLE, user_message_in => user_message_in);
    END assert_exists_table;

    PROCEDURE assert_exists_procedure(procedure_owner_in IN T_SMALL_STRING
                                     ,procedure_name_in  IN T_SMALL_STRING
                                     ,user_message_in    IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;
        l_exists_table T_BOOLEAN;

    BEGIN
        assert_exists_object(object_owner_in => procedure_owner_in, object_name_in => procedure_name_in, object_type_in => c_OBJECT_TYPE_PROCEDURE,
                             user_message_in => user_message_in);
    END assert_exists_procedure;

    PROCEDURE assert_exists_function(function_owner_in IN T_SMALL_STRING
                                    ,function_name_in  IN T_SMALL_STRING
                                    ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;
        l_exists_table T_BOOLEAN;

    BEGIN
        assert_exists_object(object_owner_in => function_owner_in, object_name_in => function_name_in, object_type_in => c_OBJECT_TYPE_FUNCTION,
                             user_message_in => user_message_in);
    END assert_exists_function;

    PROCEDURE assert_exists_package(package_owner_in IN T_SMALL_STRING
                                   ,package_name_in  IN T_SMALL_STRING
                                   ,user_message_in  IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;
        l_exists_table T_BOOLEAN;

    BEGIN
        assert_exists_object(object_owner_in => package_owner_in, object_name_in => package_name_in, object_type_in => c_OBJECT_TYPE_PACKAGE, user_message_in => user_message_in);
    END assert_exists_package;

    PROCEDURE assert_exists_package_b(package_b_owner_in IN T_SMALL_STRING
                                     ,package_b_name_in  IN T_SMALL_STRING
                                     ,user_message_in    IN T_USER_MESSAGE DEFAULT NULL)
    IS
        l_assert_words T_ASSERT_WORDS;
        l_exists_table T_BOOLEAN;

    BEGIN
        assert_exists_object(object_owner_in => package_b_owner_in, object_name_in => package_b_name_in, object_type_in => c_OBJECT_TYPE_PACKAGE_B,
                             user_message_in => user_message_in);
    END assert_exists_package_b;

    -- exceptions

    PROCEDURE should_raise_exception(lines_of_code_in           IN T_BIG_STRING_LIST
                                    ,exception_constant_name_in IN T_SMALL_STRING
                                    ,exception_number_in        IN T_BIG_INTEGER
                                    ,user_message_in            IN T_USER_MESSAGE    DEFAULT NULL)
    IS
        l_assert_words              T_ASSERT_WORDS;
        l_user_message              T_USER_MESSAGE;
        l_dyn_cursor                T_PLS_INTEGER;
        dyn_execute_return          T_SMALL_INTEGER;
        l_execute_dyn_sql_raise_err T_BOOLEAN;

    BEGIN

        --utl$base$err.CALL_RAISE(utl$base$err.e_MAPA_S_TIMTO_JMENEM_EXISTUJE);
        l_execute_dyn_sql_raise_err := FALSE;

        BEGIN

            IF (lines_of_code_in.COUNT > 0) THEN
                l_dyn_cursor := DBMS_SQL.open_cursor;
                DBMS_SQL.parse(l_dyn_cursor
                              ,lines_of_code_in
                              ,lines_of_code_in.FIRST
                              ,lines_of_code_in.LAST
                              ,FALSE
                              ,DBMS_SQL.NATIVE);
                dyn_execute_return := DBMS_SQL.execute(l_dyn_cursor);
            END IF;

            EXCEPTION
                WHEN OTHERS THEN

                    IF SQLCODE = exception_number_in THEN
                        l_execute_dyn_sql_raise_err := TRUE;
                    END IF;

        END;
        l_assert_words(l_assert_words.COUNT) := c_SHOULD_RAISE_EXCEPTION;
        l_assert_words(l_assert_words.COUNT) := c_SPACE_CHAR;
        l_assert_words(l_assert_words.COUNT) := UPPER(exception_constant_name_in) ||
                                                ' (' ||
                                                exception_number_in ||
                                                ')';

        IF (l_execute_dyn_sql_raise_err) THEN
            print_message_ok(test_identifier_in => c_ID_SHOULD_RAISE_EXCEPTION, data_type_in => c_EXCEPTION, assert_words_list_in => l_assert_words,
                             user_message_in => user_message_in);
        ELSE
            print_message_failed(test_identifier_in => c_ID_SHOULD_RAISE_EXCEPTION, data_type_in => c_EXCEPTION, assert_words_list_in => l_assert_words,
                                 user_message_in => user_message_in);
        END IF;

    END;

END UTL$UNIT;
/