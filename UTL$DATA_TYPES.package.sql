CREATE OR REPLACE
PACKAGE UTL$DATA_TYPES
IS
    /**
    * ======================================================================
    *                               LICENSE and ANNOTATION
    * ======================================================================
    *
    * Basic data types for UTL$... libraries
    *
    * ======================================================================
    * Distributed under "The GNU Lesser General Public License, version 3.0 (LGPLv3)"
    * ======================================================================
    *
    * UTL$DATA_TYPES
    *
    * Copyright (c) 2012, Martin Mareš
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

    -- Basic types
    SUBTYPE T_DB_BOOLEAN IS CHAR(1);
    SUBTYPE T_DATE IS DATE;
    SUBTYPE T_BOOLEAN IS BOOLEAN;
    SUBTYPE T_NUMBER IS NUMBER;
    SUBTYPE T_VARCHAR2 IS VARCHAR2(32767);
    SUBTYPE T_BINARY_INTEGER IS BINARY_INTEGER;
    SUBTYPE T_PLS_INTEGER IS PLS_INTEGER;
    SUBTYPE T_BOOLEAN IS BOOLEAN;
    SUBTYPE T_BIG_DATA IS CLOB;
    SUBTYPE T_BIG_BINARY_DATA IS BLOB;

    -- Data types variations
    SUBTYPE T_SMALL_INTEGER IS NUMBER(5,0);
    SUBTYPE T_BIG_INTEGER IS NUMBER(19,0);
    SUBTYPE T_MAX_INTEGER IS NUMBER(38);
    SUBTYPE T_SMALL_DOUBLE IS NUMBER(10,5);  -- 10 with precision 5 = 10 (5 = SMALLINT)
    SUBTYPE T_BIG_DOUBLE IS NUMBER(24,5);  -- 24 with precision 5 = 19 (19 = BIGINT)
    SUBTYPE T_MAX_DOUBLE IS NUMBER(38,5);
    SUBTYPE T_SMALL_STRING IS VARCHAR2(255);
    SUBTYPE T_BIG_STRING IS VARCHAR2(4095);
    SUBTYPE T_MAX_STRING IS VARCHAR2(32767);
    SUBTYPE T_MAX_SQL_STRING IS VARCHAR2(4000);
    SUBTYPE T_LONG_STRING IS LONG;
    SUBTYPE T_SMALL_TIMESTAMP IS TIMESTAMP(3);
    SUBTYPE T_BIG_TIMESTAMP IS TIMESTAMP(6);
    SUBTYPE T_MAX_TIMESTAMP IS TIMESTAMP(9);
    SUBTYPE T_USER_MESSAGE IS T_BIG_STRING;

    -- Specific data types
    SUBTYPE T_BIG_STRING_LIST IS DBMS_SQL.VARCHAR2A;
    SUBTYPE T_SMALL_STRING_LIST IS DBMS_SQL.VARCHAR2S;
    SUBTYPE T_NUMBER_LIST IS DBMS_SQL.NUMBER_TABLE;
    SUBTYPE T_STRING_LIST IS DBMS_SQL.VARCHAR2_TABLE;
    SUBTYPE T_DATE_LIST IS DBMS_SQL.DATE_TABLE;
    SUBTYPE T_BIG_DATA_LIST IS DBMS_SQL.CLOB_TABLE;
END UTL$DATA_TYPES;
/