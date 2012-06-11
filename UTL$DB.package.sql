CREATE OR REPLACE
PACKAGE UTL$DB
IS
    /**
    * ======================================================================
    *                               LICENSE and ANNOTATION
    * ======================================================================
    *
    * Basic package for database object compilation
    *
    * ======================================================================
    * Distributed under "The GNU Lesser General Public License, version 3.0 (LGPLv3)"
    * ======================================================================
    *
    * UTL$DB
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

    c_LINE_LENGTH      CONSTANT NUMBER := 60;
    c_SELF_SCHEMA_NAME CONSTANT VARCHAR2(50) := 'NXT';  -- don't compile itself
    c_SELF_OBJECT_NAME CONSTANT VARCHAR2(50) := 'UTL$DB';  -- don't compile itself
    e_ALL_EXCEPTIONS   CONSTANT NUMBER := - 20001;
    ALL_EXCEPTIONS EXCEPTION;

    SUBTYPE LONG_TEXT IS CLOB;

    -- contraint types
    c_PRIMARY_KEY_CONSTRAINT CONSTANT CHAR(1) := 'P';
    c_FOREIGN_KEY_CONSTRAINT CONSTANT CHAR(1) := 'R';
    c_UNIQUE_KEY_CONSTRAINT  CONSTANT CHAR(1) := 'U';
    c_CHECK_CONSTRAINT       CONSTANT CHAR(1) := 'C';
    c_LINE_ENDING            CONSTANT VARCHAR2(10) := CHR(10);

    PRAGMA EXCEPTION_INIT(ALL_EXCEPTIONS, - 20001);

    TYPE struct_object IS RECORD (
        schema_name UTL$DB_COMPILE_OBJ_IGNORE.SCHEMA_NAME%TYPE,
        object_name UTL$DB_COMPILE_OBJ_IGNORE.OBJECT_NAME%TYPE,
        object_type VARCHAR2(200)
    );

    TYPE list_objects IS TABLE OF struct_object INDEX BY BINARY_INTEGER;

    PROCEDURE compile_objects(schema_name_in  IN VARCHAR2 DEFAULT NULL
                             ,object_name_in  IN VARCHAR2 DEFAULT NULL
                             ,show_skipped_in IN VARCHAR2 DEFAULT 'N');

    PROCEDURE alter_table_add(schema_name_in IN VARCHAR2
                             ,table_name_in  IN VARCHAR2
                             ,column_name_in IN VARCHAR2
                             ,data_type_in   IN VARCHAR2);

    PROCEDURE alter_table_add_at_position(schema_name_in IN VARCHAR2
                                         ,table_name_in  IN VARCHAR2
                                         ,column_name_in IN VARCHAR2
                                         ,data_type_in   IN VARCHAR2
                                         ,position_in    IN NUMBER);

    PROCEDURE alter_table_add_after_column(schema_name_in       IN VARCHAR2
                                          ,table_name_in        IN VARCHAR2
                                          ,column_name_in       IN VARCHAR2
                                          ,data_type_in         IN VARCHAR2
                                          ,after_column_name_in IN VARCHAR2);

    FUNCTION generate_temporary_table_name(schema_name_in IN VARCHAR2) RETURN VARCHAR2;

    PROCEDURE table_copy(schema_name_source_in      IN VARCHAR2
                        ,table_name_source_in       IN VARCHAR2
                        ,schema_name_destination_in IN VARCHAR2
                        ,table_name_destination_in  IN VARCHAR2);

    PROCEDURE table_copy(schema_name_source_in     IN VARCHAR2
                        ,table_name_source_in      IN VARCHAR2
                        ,table_name_destination_in IN VARCHAR2);

    FUNCTION get_primary_key_ddl(schema_name_in IN VARCHAR2
                                ,table_name_in  IN VARCHAR2) RETURN LONG_TEXT;

    FUNCTION get_foreign_key_ddl(schema_name_in      IN VARCHAR2
                                ,table_name_in       IN VARCHAR2
                                ,foreign_key_name_in IN VARCHAR2) RETURN LONG_TEXT;

    FUNCTION get_foreign_keys_ddl(schema_name_in IN VARCHAR2
                                 ,table_name_in  IN VARCHAR2) RETURN LONG_TEXT;

    FUNCTION get_check_constraint_ddl(schema_name_in      IN VARCHAR2
                                     ,table_name_in       IN VARCHAR2
                                     ,foreign_key_name_in IN VARCHAR2) RETURN LONG_TEXT;

    FUNCTION get_check_constraints_ddl(schema_name_in IN VARCHAR2
                                      ,table_name_in  IN VARCHAR2) RETURN LONG_TEXT;

    FUNCTION get_constraint_ddl(schema_name_in     IN VARCHAR2
                               ,table_name_in      IN VARCHAR2
                               ,constraint_name_in IN VARCHAR2
                               ,constraint_type_in IN VARCHAR2) RETURN LONG_TEXT;

    FUNCTION get_constraints_ddl(schema_name_in     IN VARCHAR2
                                ,table_name_in      IN VARCHAR2
                                ,constraint_type_in IN VARCHAR2) RETURN LONG_TEXT;

END UTL$DB;
/
