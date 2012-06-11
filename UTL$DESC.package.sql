CREATE OR REPLACE
PACKAGE UTL$DESC
IS
    /**
    * ======================================================================
    *                               LICENSE and ANNOTATION
    * ======================================================================
    *
    * Oracle SQL*Plus DESC replacement
    *
    * ======================================================================
    * Distributed under "The GNU Lesser General Public License, version 3.0 (LGPLv3)"
    * ======================================================================
    *
    * UTL$DESC
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


    /**
    * ----------------------------------------------------------------------
    * Types and Subtypes
    * ----------------------------------------------------------------------
    */
    SUBTYPE T_MAX_STRING IS UTL$DATA_TYPES.T_MAX_STRING;
    SUBTYPE T_SMALL_STRING IS UTL$DATA_TYPES.T_SMALL_STRING;
    SUBTYPE T_MAX_SQL_STRING IS UTL$DATA_TYPES.T_MAX_SQL_STRING;
    SUBTYPE T_PLS_INTEGER IS UTL$DATA_TYPES.T_PLS_INTEGER;
    SUBTYPE T_DB_BOOLEAN IS UTL$DATA_TYPES.T_DB_BOOLEAN;
    SUBTYPE T_SMALL_INTEGER IS UTL$DATA_TYPES.T_SMALL_INTEGER;
    SUBTYPE T_BIG_INTEGER IS UTL$DATA_TYPES.T_BIG_INTEGER;
    SUBTYPE T_LONG_STRING IS UTL$DATA_TYPES.T_LONG_STRING;
    SUBTYPE T_BINARY_INTEGER IS UTL$DATA_TYPES.T_BINARY_INTEGER;

    /**
    * ----------------------------------------------------------------------
    * Basic constants
    * ----------------------------------------------------------------------
    */
    -- Object types
    C_OBJECT            CONSTANT T_SMALL_STRING := 'OBJECT';
    C_TABLE             CONSTANT T_SMALL_STRING := 'TABLE';
    C_INDEX             CONSTANT T_SMALL_STRING := 'INDEX';
    C_TRIGGER           CONSTANT T_SMALL_STRING := 'TRIGGER';
    C_SEQUENCE          CONSTANT T_SMALL_STRING := 'SEQUENCE';
    C_CONSTRAINT        CONSTANT T_SMALL_STRING := 'CONSTRAINT';
    C_PROCEDURE         CONSTANT T_SMALL_STRING := 'PROCEDURE';
    C_FUNCTION          CONSTANT T_SMALL_STRING := 'FUNCTION';
    C_PACKAGE           CONSTANT T_SMALL_STRING := 'PACKAGE';

    -- Objects
    C_OBJ_CREATED       CONSTANT T_SMALL_STRING := '{ObjectCreated}';
    C_OBJ_LAST_DDL_TIME CONSTANT T_SMALL_STRING := '{ObjectLastDdlTime}';

    -- Tables
    C_TBL_OWNER         CONSTANT T_SMALL_STRING := '{TableOwner}';
    C_TBL_NAME          CONSTANT T_SMALL_STRING := '{TableName}';

    -- Columns
    C_COL_NAME          CONSTANT T_SMALL_STRING := '{ColumnName}';
    C_COL_DATA_TYPE     CONSTANT T_SMALL_STRING := '{ColumnDataType}';
    C_COL_COMMENT       CONSTANT T_SMALL_STRING := '{ColumnComment}';

    /**
    * ----------------------------------------------------------------------
    * Export format type constants
    * ----------------------------------------------------------------------
    */
    C_FORMAT_ASCII      CONSTANT T_SMALL_STRING := 'ASCII';
    C_FORMAT_MARKDOWN   CONSTANT T_SMALL_STRING := 'MARKDOWN';
    C_FORMAT_TWIKI      CONSTANT T_SMALL_STRING := 'TWIKI';
    C_FORMAT_DEFAULT    CONSTANT T_SMALL_STRING := C_FORMAT_ASCII;

    /**
    * ----------------------------------------------------------------------
    * Containers
    * ----------------------------------------------------------------------
    */
    -- Records

    TYPE R_TABLE_COLUMN IS RECORD (
        DATA_TYPE       T_SMALL_STRING,
        DATA_LENGTH     T_SMALL_INTEGER,
        DATA_PRECISION  T_SMALL_INTEGER,
        DATA_SCALE      T_SMALL_INTEGER,
        NULLABLE        T_DB_BOOLEAN,
        DATA_DEFAULT    T_LONG_STRING
    );

    -- Containers

    TYPE LST_TABLE_COLUMNS IS TABLE OF R_TABLE_COLUMN INDEX BY T_BINARY_INTEGER;

    /**
    * ----------------------------------------------------------------------
    * Basic functions
    * ----------------------------------------------------------------------
    */
    PROCEDURE prn(string_in IN T_MAX_STRING);

    /**
    * ----------------------------------------------------------------------
    * All objects
    * ----------------------------------------------------------------------
    */

    FUNCTION desc_table(table_name_in IN T_SMALL_STRING) RETURN T_MAX_STRING;

    FUNCTION desc_table(owner_in      IN T_SMALL_STRING
                       ,table_name_in IN T_SMALL_STRING) RETURN T_MAX_STRING;

    FUNCTION desc_table(owner_in         IN T_SMALL_STRING
                       ,table_name_in    IN T_SMALL_STRING
                       ,output_format_in IN T_SMALL_STRING) RETURN T_MAX_STRING;

END UTL$DESC;
/
