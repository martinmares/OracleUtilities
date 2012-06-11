CREATE OR REPLACE
PACKAGE UTL$BASE
IS
    /**
    * ======================================================================
    *                               LICENSE and ANNOTATION
    * ======================================================================
    *
    * Basic utilities - better work with Oracle database ;-)
    *
    * ======================================================================
    * Distributed under "The GNU Lesser General Public License, version 3.0 (LGPLv3)"
    * ======================================================================
    *
    * UTL$BASE
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

    c_OBJECT_NAME CONSTANT UTL$DATA_TYPES.T_BIG_STRING := 'UTL$BASE';

    SUBTYPE T_DB_BOOLEAN IS UTL$DATA_TYPES.T_DB_BOOLEAN;
    SUBTYPE T_DATE IS UTL$DATA_TYPES.T_DATE;
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
    SUBTYPE T_BIG_DATA IS UTL$DATA_TYPES.T_BIG_DATA;
    SUBTYPE T_BIG_BINARY_DATA IS UTL$DATA_TYPES.T_BIG_BINARY_DATA;
    SUBTYPE T_BIG_DATA_LIST IS UTL$DATA_TYPES.T_BIG_DATA_LIST;

    -- Types
    TYPE r_hash_map_value IS RECORD (
        value_index        T_SMALL_DOUBLE,
        value_name         T_SMALL_STRING,
        data_type          T_SMALL_STRING,
        value_description  T_BIG_STRING,
        value_extra_data   T_BIG_STRING,
        number_value       T_MAX_DOUBLE,
        string_value       T_MAX_STRING,
        date_value         T_DATE
    );

    TYPE r_hash_map_value_extended IS RECORD (
        value_index        T_SMALL_DOUBLE,
        value_name         T_SMALL_STRING,
        data_type          T_SMALL_STRING,
        value_description  T_BIG_STRING,
        value_extra_data   T_BIG_STRING,
        number_value       T_MAX_DOUBLE,
        string_value       T_MAX_STRING,
        date_value         T_DATE,
        timestamp_value    T_MAX_TIMESTAMP,
        xml_type_value     XMLTYPE,
        blob_value         T_BIG_BINARY_DATA,
        clob_value         T_BIG_DATA
    );

    TYPE t_hash_map_value IS TABLE OF R_HASH_MAP_VALUE INDEX BY BINARY_INTEGER;
    TYPE t_hash_map_value_extended IS TABLE OF R_HASH_MAP_VALUE_EXTENDED INDEX BY BINARY_INTEGER;
    TYPE r_hash_map IS RECORD (
        map_index        T_SMALL_DOUBLE,
        map_name         T_SMALL_STRING,
        map_description  T_BIG_STRING,
        map_extra_data   T_BIG_STRING,
        array_of_values  T_HASH_MAP_VALUE
    );

    TYPE r_hash_map_extended IS RECORD (
        index_value      T_SMALL_DOUBLE,
        name_value       T_SMALL_STRING,
        array_of_values  T_HASH_MAP_VALUE_EXTENDED
    );

    TYPE t_hash_map IS TABLE OF R_HASH_MAP INDEX BY BINARY_INTEGER;
    g_HASH_MAP_INDEX       T_SMALL_DOUBLE;
    g_HASH_MAP_VALUE_INDEX T_SMALL_DOUBLE;

    FUNCTION hash_map_create(map_name_in        T_SMALL_STRING
                            ,map_description_in T_BIG_STRING   DEFAULT NULL
                            ,map_extra_data_in  T_BIG_STRING   DEFAULT NULL) RETURN R_HASH_MAP;

    PROCEDURE hash_map_register(t_hash_map_io IN OUT T_HASH_MAP
                               ,r_hash_map_in IN     R_HASH_MAP);

    FUNCTION hash_map_register_contains(t_hash_map_in IN T_HASH_MAP
                                       ,map_name_in      T_SMALL_STRING) RETURN BOOLEAN;

    PROCEDURE hash_map_flush_index;

    PROCEDURE hash_map_put(r_hash_map_io        IN OUT R_HASH_MAP
                          ,value_name_in        IN     T_SMALL_STRING
                          ,number_value_in      IN     T_MAX_DOUBLE
                          ,value_description_in IN     T_BIG_STRING   DEFAULT NULL
                          ,value_extra_data_in  IN     T_BIG_STRING   DEFAULT NULL);

    PROCEDURE hash_map_put(r_hash_map_io        IN OUT R_HASH_MAP
                          ,value_name_in        IN     T_SMALL_STRING
                          ,string_value_in      IN     T_MAX_STRING
                          ,value_description_in IN     T_BIG_STRING   DEFAULT NULL
                          ,value_extra_data_in  IN     T_BIG_STRING   DEFAULT NULL);

    PROCEDURE hash_map_put(r_hash_map_io        IN OUT R_HASH_MAP
                          ,value_name_in        IN     T_SMALL_STRING
                          ,date_value_in        IN     T_DATE
                          ,value_description_in IN     T_BIG_STRING   DEFAULT NULL
                          ,value_extra_data_in  IN     T_BIG_STRING   DEFAULT NULL);

    PROCEDURE hash_map_put(r_hash_map_io        IN OUT R_HASH_MAP
                          ,value_name_in        IN     T_SMALL_STRING
                          ,data_type_in         IN     T_SMALL_STRING
                          ,value_description_in IN     T_BIG_STRING   DEFAULT NULL
                          ,value_extra_data_in  IN     T_BIG_STRING   DEFAULT NULL
                          ,number_value_in      IN     T_MAX_DOUBLE
                          ,string_value_in      IN     T_MAX_STRING
                          ,date_value_in        IN     T_DATE);

    FUNCTION hash_map_get(t_hash_map_in IN T_HASH_MAP
                         ,value_name_in IN T_SMALL_STRING) RETURN T_MAX_STRING;

    FUNCTION str_remove_spaces(text_in IN VARCHAR2) RETURN VARCHAR2;

    FUNCTION str_remove_any_duplicate_char(text_in      IN VARCHAR2
                                          ,character_in IN CHAR) RETURN VARCHAR2;

    FUNCTION str_any_char_to_space(text_in      IN VARCHAR2
                                  ,character_in IN CHAR) RETURN VARCHAR2;

    FUNCTION str_special_chars_to_space(text_in IN VARCHAR2) RETURN VARCHAR2;

    FUNCTION str_group_box(text_in        IN VARCHAR2
                          ,line_length_in IN NUMBER
                          ,separator_in   IN CHAR     := '-') RETURN VARCHAR2;

    FUNCTION base64_encode_clob(clob_in IN T_BIG_DATA) RETURN T_BIG_DATA;

    /**
    * ======================================================================
    *  Unit test shuld be the last section
    * ======================================================================
    */

    PROCEDURE ut$(test_suite_in IN T_BIG_STRING DEFAULT NULL);

END UTL$BASE;
/
