CREATE OR REPLACE
PACKAGE UTL$UNIT
IS

    /**
    * ======================================================================
    *                               LICENSE and ANNOTATION
    * ======================================================================
    *
    * Unit Testing - Small unit testing utilities.
    *
    * ======================================================================
    * Distributed under "The GNU Lesser General Public License, version 3.0 (LGPLv3)"
    * ======================================================================
    *
    * UTL$UNIT
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
    SUBTYPE T_ONE_CHAR IS UTL$DATA_TYPES.T_DB_BOOLEAN;
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
    SUBTYPE T_BIG_DATA IS UTL$DATA_TYPES.T_BIG_DATA;
    SUBTYPE T_BIG_STRING_LIST IS UTL$DATA_TYPES.T_BIG_STRING_LIST;

    -- VERSION
    VERSION                                 T_SMALL_STRING := '0.1';
    CREATED_BY                              T_SMALL_STRING := 'Martin Mareš';

    -- NULL values for BASIC data types
    c_NULL_BOOLEAN                          T_BOOLEAN := NULL;
    c_NULL_NUMBER                           T_BIG_INTEGER := NULL;
    c_NULL_VARCHAR2                         T_MAX_STRING := NULL;
    c_NULL_DATE                             T_DATE := NULL;

    -- Special parameters
    c_SPECIAL_STRING_BEGIN         CONSTANT T_SMALL_STRING := '{';
    c_SPECIAL_CHAR                 CONSTANT T_ONE_CHAR := '$';
    c_SPECIAL_STRING_END           CONSTANT T_SMALL_STRING := '}';
    c_SPECIAL_OBJECT_OWNER         CONSTANT T_SMALL_STRING := 'OBJECT_OWNER';
    c_SPECIAL_OBJECT_NAME          CONSTANT T_SMALL_STRING := 'OBJECT_NAME';
    c_SPECIAL_OBJECT_TYPE          CONSTANT T_SMALL_STRING := 'OBJECT_TYPE';
    c_SPECIAL_EXPECTED_VALUE       CONSTANT T_SMALL_STRING := 'EXPECTED_VALUE';
    c_SPECIAL_TESTED_VALUE         CONSTANT T_SMALL_STRING := 'TESTED_VALUE';
    c_LIKE_CHAR                    CONSTANT T_ONE_CHAR := '%';

    -- CONSTANTS
    c_SPACE_CHAR                   CONSTANT T_ONE_CHAR := ' ';
    c_QUESTION_MARK_CHAR           CONSTANT T_ONE_CHAR := '?';
    c_OK_CHAR                      CONSTANT T_ONE_CHAR := '.';
    c_OWNER_AND_OBJ_NAME_SEP       CONSTANT T_ONE_CHAR := '.';
    c_SINGLE_QUOTE_CHAR            CONSTANT T_ONE_CHAR := '''';
    c_DOUBLE_QUOTE_CHAR            CONSTANT T_ONE_CHAR := '"';
    c_FAILED_CHAR                  CONSTANT T_ONE_CHAR := 'F';
    c_LINE_SEP_CHAR                CONSTANT T_ONE_CHAR := '-';
    c_INDENTATION_SEP_CHAR         CONSTANT T_ONE_CHAR := ' ';
    c_PREFIX                       CONSTANT T_SMALL_STRING := '[';
    c_SUFFIX                       CONSTANT T_SMALL_STRING := ']';
    c_ROUND_PARENTHES_BEGIN        CONSTANT T_SMALL_STRING := '(';
    c_ROUND_PARENTHES_END          CONSTANT T_SMALL_STRING := ')';
    c_OK                           CONSTANT T_SMALL_STRING := 'Success';
    c_FAILED                       CONSTANT T_SMALL_STRING := 'Failed';
    c_MESSAGE_PREFIX_LENGTH        CONSTANT T_SMALL_INTEGER := LENGTH(c_PREFIX) + LENGTH(c_SUFFIX) + GREATEST(LENGTH(c_OK), LENGTH(c_FAILED));
    c_MESSAGE_DELIMITER            CONSTANT T_SMALL_STRING := ' - ';
    c_TRUE                         CONSTANT T_SMALL_STRING := 'True';
    c_FALSE                        CONSTANT T_SMALL_STRING := 'False';
    c_NULL                         CONSTANT T_SMALL_STRING := 'NULL';
    c_NOT                          CONSTANT T_SMALL_STRING := 'NOT';
    c_OR                           CONSTANT T_SMALL_STRING := 'OR';
    c_NOT_NULL                     CONSTANT T_SMALL_STRING := c_NOT || ' ' || c_NULL;
    c_DATATYPE_BOOLEAN             CONSTANT T_SMALL_STRING := 'BOOLEAN';
    c_DATATYPE_NUMBER              CONSTANT T_SMALL_STRING := 'NUMBER';
    c_DATATYPE_STRING              CONSTANT T_SMALL_STRING := 'STRING';
    c_DATATYPE_DATE                CONSTANT T_SMALL_STRING := 'DATE';
    c_LONGEST_DATATYPE_LENGTH      CONSTANT T_SMALL_INTEGER := LENGTH(c_PREFIX) + LENGTH(c_SUFFIX) + GREATEST(LENGTH(c_DATATYPE_BOOLEAN), LENGTH(c_DATATYPE_NUMBER), LENGTH(c_DATATYPE_STRING), LENGTH(c_DATATYPE_DATE));
    c_UNIT_TEST_MESSAGE            CONSTANT T_SMALL_STRING := 'Test';
    c_ID_ASSERT_BOOLEAN            CONSTANT T_SMALL_STRING := c_UNIT_TEST_MESSAGE || ' ' || c_DOUBLE_QUOTE_CHAR || c_TRUE || '/' || c_FALSE || ' value"';
    c_ID_ASSERT_NULL               CONSTANT T_SMALL_STRING := c_UNIT_TEST_MESSAGE || ' ' || c_DOUBLE_QUOTE_CHAR || c_NULL || ' value"';
    c_ID_ASSERT_NOT_NULL           CONSTANT T_SMALL_STRING := c_UNIT_TEST_MESSAGE || ' ' || c_DOUBLE_QUOTE_CHAR || c_NOT_NULL || ' value"';
    c_ID_ASSERT_EQUAL              CONSTANT T_SMALL_STRING := c_UNIT_TEST_MESSAGE || ' ' || '"Equals"';
    c_ID_ASSERT_NOT_EQUAL          CONSTANT T_SMALL_STRING := c_UNIT_TEST_MESSAGE || ' ' || c_DOUBLE_QUOTE_CHAR || c_NOT || ' Equals"';
    c_ID_ASSERT_GREATER_THEN       CONSTANT T_SMALL_STRING := c_UNIT_TEST_MESSAGE || ' ' || '"Greater then"';
    c_ID_ASSERT_GREATER_THEN_OR_EQ CONSTANT T_SMALL_STRING := c_UNIT_TEST_MESSAGE || ' ' || '"Greater then ' || c_OR || ' Equal"';
    c_ID_ASSERT_LESS_THEN          CONSTANT T_SMALL_STRING := c_UNIT_TEST_MESSAGE || ' ' || '"Less then"';
    c_ID_ASSERT_LESS_THEN_OR_EQ    CONSTANT T_SMALL_STRING := c_UNIT_TEST_MESSAGE || ' ' || '"Less then ' || c_OR || ' Equal"';
    c_ID_EXISTS_OBJECT             CONSTANT T_SMALL_STRING := c_UNIT_TEST_MESSAGE || ' ' || '"Exists object"';
    c_ID_SHOULD_RAISE_EXCEPTION    CONSTANT T_SMALL_STRING := c_UNIT_TEST_MESSAGE || ' ' || '"Should raise exception"';
    c_ID_ASSERT_CONTAINS           CONSTANT T_SMALL_STRING := c_UNIT_TEST_MESSAGE || ' ' || '"Contains text"';
    c_ID_ASSERT_CONTAINS_AT_BEGIN  CONSTANT T_SMALL_STRING := c_UNIT_TEST_MESSAGE || ' ' || '"Contains at beginning"';
    c_ID_ASSERT_CONTAINS_AT_END    CONSTANT T_SMALL_STRING := c_UNIT_TEST_MESSAGE || ' ' || '"Contains at end"';
    c_ID_ASSERT_NOT_CONT           CONSTANT T_SMALL_STRING := c_UNIT_TEST_MESSAGE || ' ' || '"Not contains text"';
    c_ID_ASSERT_NOT_CONT_AT_BEGIN  CONSTANT T_SMALL_STRING := c_UNIT_TEST_MESSAGE || ' ' || '"Not contains text at beginning"';
    c_ID_ASSERT_NOT_CONT_AT_END    CONSTANT T_SMALL_STRING := c_UNIT_TEST_MESSAGE || ' ' || '"Not contains text at end"';
    c_LONGEST_IDENTIFIER_LENGTH    CONSTANT T_SMALL_INTEGER := LENGTH(c_PREFIX) + LENGTH(c_SUFFIX) + GREATEST(LENGTH(c_ID_ASSERT_BOOLEAN)
                                                  ,LENGTH(c_ID_ASSERT_GREATER_THEN)
                                                  ,LENGTH(c_ID_ASSERT_GREATER_THEN_OR_EQ)
                                                  ,LENGTH(c_ID_ASSERT_LESS_THEN)
                                                  ,LENGTH(c_ID_ASSERT_LESS_THEN_OR_EQ));
    c_DEFAULT_RPAD_LENGTH          CONSTANT T_SMALL_INTEGER := 80;
    c_PARAMETERS_LENGTH            CONSTANT T_SMALL_INTEGER := 50;
    c_MAX_LINE_SIZE                CONSTANT T_SMALL_INTEGER := 255;
    c_BASIC_INDENTATION_LENGTH     CONSTANT T_SMALL_INTEGER := 4;
    c_DEFAULT_DATE_FORMAT          CONSTANT T_SMALL_STRING := 'dd. mm. yyyy hh24:mi';
    c_DEFAULT_TIME_FORMAT          CONSTANT T_SMALL_STRING := 'hh24:mi:ss';
    c_DEFAULT_DATE_PRECISION       CONSTANT T_SMALL_STRING := 'dd. mm. yyyy hh24:mi';
    c_DEFAULT_DATE_FULL            CONSTANT T_SMALL_STRING := 'dd. mm. yyyy hh24:mi:ss';
    c_EQUAL                        CONSTANT T_SMALL_STRING := ' = ';
    c_NOT_EQUAL                    CONSTANT T_SMALL_STRING := ' <> ';
    c_GREATHER_THEN                CONSTANT T_SMALL_STRING := ' > ';
    c_GREATHER_THEN_OR_EQUAL       CONSTANT T_SMALL_STRING := ' >= ';
    c_LESS_THEN                    CONSTANT T_SMALL_STRING := ' < ';
    c_LESS_THEN_OR_EQUAL           CONSTANT T_SMALL_STRING := ' <= ';
    c_EXISTS                       CONSTANT T_SMALL_STRING := 'Exists';
    c_CONTAINS                     CONSTANT T_SMALL_STRING := '"contains"';
    c_CONTAINS_AT_BEGIN            CONSTANT T_SMALL_STRING := '"contains at the beginning"';
    c_CONTAINS_AT_END              CONSTANT T_SMALL_STRING := '"contains at an end"';
    c_NOT_CONTAINS                 CONSTANT T_SMALL_STRING := '"not contains"';
    c_NOT_CONTAINS_AT_BEGIN        CONSTANT T_SMALL_STRING := '"not contains at the beginning"';
    c_NOT_CONTAINS_AT_END          CONSTANT T_SMALL_STRING := '"not contains at an end"';

    -- Object types
    c_OBJECT                       CONSTANT T_SMALL_STRING := 'Object:';
    c_OBJECT_TYPE_TABLE            CONSTANT T_SMALL_STRING := 'TABLE';
    c_OBJECT_TYPE_PROCEDURE        CONSTANT T_SMALL_STRING := 'PROCEDURE';
    c_OBJECT_TYPE_FUNCTION         CONSTANT T_SMALL_STRING := 'FUNCTION';
    c_OBJECT_TYPE_PACKAGE          CONSTANT T_SMALL_STRING := 'PACKAGE';
    c_OBJECT_TYPE_PACKAGE_B        CONSTANT T_SMALL_STRING := 'PACKAGE BODY';
    c_DATA_TYPE_OBJECT_TABLE       CONSTANT T_SMALL_STRING := c_OBJECT || ' ' || c_OBJECT_TYPE_TABLE;
    c_DATA_TYPE_OBJECT_PROCEDURE   CONSTANT T_SMALL_STRING := c_OBJECT || ' ' || c_OBJECT_TYPE_PROCEDURE;
    c_DATA_TYPE_OBJECT_FUNCTION    CONSTANT T_SMALL_STRING := c_OBJECT || ' ' || c_OBJECT_TYPE_FUNCTION;
    c_DATA_TYPE_OBJECT_PACKAGE     CONSTANT T_SMALL_STRING := c_OBJECT || ' ' || c_OBJECT_TYPE_PACKAGE;
    c_DATA_TYPE_OBJECT_PACKAGE_B   CONSTANT T_SMALL_STRING := c_OBJECT || ' ' || c_OBJECT_TYPE_PACKAGE_B;

    -- Exceptions
    c_EXCEPTION                    CONSTANT T_SMALL_STRING := 'EXCEPTION';
    c_SHOULD_RAISE_EXCEPTION       CONSTANT T_SMALL_STRING := 'Should raise exception';

    SUBTYPE t_holder_schema_name IS T_SMALL_STRING;
    SUBTYPE t_holder_scope_name IS T_SMALL_STRING;
    TYPE t_assert_words IS TABLE OF T_BIG_STRING INDEX BY t_BINARY_INTEGER;
    TYPE t_test_procedure IS RECORD (
        test_suite_id   T_NUMBER,
        procedure_name  T_MAX_STRING,
        user_message    T_MAX_STRING,
        start_time      T_DATE,
        time_snap       T_SMALL_INTEGER
    );

    TYPE t_test_procedures IS TABLE OF T_TEST_PROCEDURE INDEX BY t_BINARY_INTEGER;
    TYPE t_message IS RECORD (
        test_id            T_NUMBER,
        start_time         T_DATE,
        test_identifier    T_BIG_STRING,
        data_type          T_BIG_STRING,
        outcome_type       T_BIG_STRING,
        assert_words_list  T_ASSERT_WORDS,
        user_message       T_MAX_STRING,
        time_snap          T_SMALL_INTEGER
    );

    TYPE t_user_messages IS TABLE OF T_MESSAGE INDEX BY t_BINARY_INTEGER;
    PROCEDURE DBMS_OUTPUT_ON;

    PROCEDURE DBMS_OUTPUT_OFF;

    PROCEDURE DEBUG_ON;

    PROCEDURE DEBUG_OFF;

    PROCEDURE start_up_suite(test_suite_in IN T_BIG_STRING DEFAULT NULL);

    PROCEDURE tear_down_suite(test_suite_in IN T_BIG_STRING DEFAULT NULL);

    PROCEDURE start_up(test_suite_in IN T_BIG_STRING DEFAULT NULL);

    PROCEDURE tear_down(test_suite_in IN T_BIG_STRING DEFAULT NULL);

    PROCEDURE test_package(package_owner_in IN T_SMALL_STRING
                          ,package_name_in  IN T_SMALL_STRING
                          ,test_suite_in    IN T_BIG_STRING   DEFAULT NULL);

    PROCEDURE test_procedure(procedure_owner_in IN T_SMALL_STRING
                            ,procedure_name_in  IN T_SMALL_STRING
                            ,test_suite_in      IN T_SMALL_STRING DEFAULT NULL);

    PROCEDURE test_function(function_owner_in IN T_SMALL_STRING
                           ,function_name_in  IN T_SMALL_STRING
                           ,test_suite_in     IN T_SMALL_STRING DEFAULT NULL);

    FUNCTION get_version RETURN T_SMALL_STRING;

    PROCEDURE print_version;

    PROCEDURE plusplus(value_io IN OUT T_NUMBER);

    FUNCTION plusplus(value_io IN OUT T_NUMBER) RETURN T_NUMBER;

    -- boolean

    PROCEDURE assert_null(tested_value_in IN T_BOOLEAN
                         ,user_message_in IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_not_null(tested_value_in IN T_BOOLEAN
                             ,user_message_in IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_true(condition_in    IN T_BOOLEAN
                         ,user_message_in IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_false(condition_in    IN T_BOOLEAN
                          ,user_message_in IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_equal(expected_value_in IN T_BOOLEAN
                          ,tested_value_in   IN T_BOOLEAN
                          ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_not_equal(expected_value_in IN T_BOOLEAN
                              ,tested_value_in   IN T_BOOLEAN
                              ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    -- number

    PROCEDURE assert_null(tested_value_in IN T_NUMBER
                         ,user_message_in IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_not_null(tested_value_in IN T_NUMBER
                             ,user_message_in IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_equal(expected_value_in IN T_NUMBER
                          ,tested_value_in   IN T_NUMBER
                          ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_not_equal(expected_value_in IN T_NUMBER
                              ,tested_value_in   IN T_NUMBER
                              ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_greather_then(expected_value_in IN T_NUMBER
                                  ,tested_value_in   IN T_NUMBER
                                  ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_greather_then_or_equal(expected_value_in IN T_NUMBER
                                           ,tested_value_in   IN T_NUMBER
                                           ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_less_then(expected_value_in IN T_NUMBER
                              ,tested_value_in   IN T_NUMBER
                              ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_less_then_or_equal(expected_value_in IN T_NUMBER
                                       ,tested_value_in   IN T_NUMBER
                                       ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    -- string

    PROCEDURE assert_null(tested_value_in IN T_MAX_STRING
                         ,user_message_in IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_not_null(tested_value_in IN T_MAX_STRING
                             ,user_message_in IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_equal(expected_value_in IN T_MAX_STRING
                          ,tested_value_in   IN T_MAX_STRING
                          ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_not_equal(expected_value_in IN T_MAX_STRING
                              ,tested_value_in   IN T_MAX_STRING
                              ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_greather_then(expected_value_in IN T_MAX_STRING
                                  ,tested_value_in   IN T_MAX_STRING
                                  ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_greather_then_or_equal(expected_value_in IN T_MAX_STRING
                                           ,tested_value_in   IN T_MAX_STRING
                                           ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_less_then(expected_value_in IN T_MAX_STRING
                              ,tested_value_in   IN T_MAX_STRING
                              ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_less_then_or_equal(expected_value_in IN T_MAX_STRING
                                       ,tested_value_in   IN T_MAX_STRING
                                       ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_contains(expected_value_in IN T_MAX_STRING
                             ,tested_value_in   IN T_MAX_STRING
                             ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_not_contains(expected_value_in IN T_MAX_STRING
                                 ,tested_value_in   IN T_MAX_STRING
                                 ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_contains_at_begin(expected_value_in IN T_MAX_STRING
                                      ,tested_value_in   IN T_MAX_STRING
                                      ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_contains_at_end(expected_value_in IN T_MAX_STRING
                                    ,tested_value_in   IN T_MAX_STRING
                                    ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    -- date

    PROCEDURE assert_null(tested_value_in IN T_DATE
                         ,user_message_in IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_not_null(tested_value_in IN T_DATE
                             ,user_message_in IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_equal(expected_value_in IN T_DATE
                          ,tested_value_in   IN T_DATE
                          ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_not_equal(expected_value_in IN T_DATE
                              ,tested_value_in   IN T_DATE
                              ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_greather_then(expected_value_in IN T_DATE
                                  ,tested_value_in   IN T_DATE
                                  ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_greather_then_or_equal(expected_value_in IN T_DATE
                                           ,tested_value_in   IN T_DATE
                                           ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_less_then(expected_value_in IN T_DATE
                              ,tested_value_in   IN T_DATE
                              ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_less_then_or_equal(expected_value_in IN T_DATE
                                       ,tested_value_in   IN T_DATE
                                       ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    -- objects

    PROCEDURE assert_exists_object(object_owner_in IN T_SMALL_STRING
                                  ,object_name_in  IN T_SMALL_STRING
                                  ,object_type_in  IN T_SMALL_STRING
                                  ,user_message_in IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_exists_table(table_owner_in  IN T_SMALL_STRING
                                 ,table_name_in   IN T_SMALL_STRING
                                 ,user_message_in IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_exists_procedure(procedure_owner_in IN T_SMALL_STRING
                                     ,procedure_name_in  IN T_SMALL_STRING
                                     ,user_message_in    IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_exists_function(function_owner_in IN T_SMALL_STRING
                                    ,function_name_in  IN T_SMALL_STRING
                                    ,user_message_in   IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_exists_package(package_owner_in IN T_SMALL_STRING
                                   ,package_name_in  IN T_SMALL_STRING
                                   ,user_message_in  IN T_USER_MESSAGE DEFAULT NULL);

    PROCEDURE assert_exists_package_b(package_b_owner_in IN T_SMALL_STRING
                                     ,package_b_name_in  IN T_SMALL_STRING
                                     ,user_message_in    IN T_USER_MESSAGE DEFAULT NULL);

    -- exceptions

    PROCEDURE should_raise_exception(lines_of_code_in           IN T_BIG_STRING_LIST
                                    ,exception_constant_name_in IN T_SMALL_STRING
                                    ,exception_number_in        IN T_BIG_INTEGER
                                    ,user_message_in            IN T_USER_MESSAGE    DEFAULT NULL);

END UTL$UNIT;
/
