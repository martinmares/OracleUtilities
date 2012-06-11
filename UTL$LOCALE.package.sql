CREATE OR REPLACE
PACKAGE UTL$LOCALE
IS

    /**
    * ======================================================================
    *                               LICENSE and ANNOTATION
    * ======================================================================
    *
    * Better work with locale (POSIX implementation) in Oracle.
    *
    * ======================================================================
    * Distributed under "The GNU Lesser General Public License, version 3.0 (LGPLv3)"
    * ======================================================================
    *
    * UTL$LOCALE
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

    c_OBJECT_NAME     CONSTANT UTL$DATA_TYPES.T_BIG_STRING := 'UTL$LOCALE';

    /**
    * ----------------------------------------------------------------------
    * Default locale
    * ----------------------------------------------------------------------
    */
    DEFAULT_LANG      CONSTANT CHAR(2) := 'en';
    DEFAULT_TERRITORY CONSTANT CHAR(2) := 'US';

    /**
    * ----------------------------------------------------------------------
    * Locale structure
    * ----------------------------------------------------------------------
    */

    TYPE struct_locale IS RECORD (
        lang       UTL$LOCALES.LANG%TYPE,
        territory  UTL$LOCALES.TERRITORY%TYPE,
        codeset    VARCHAR2(255),
        modifier   VARCHAR2(255)
    );

    SESSION_LOCALE STRUCT_LOCALE;

    -- Procedures

    PROCEDURE set_session_locale(lang_in IN UTL$LOCALES.LANG%TYPE);

    PROCEDURE set_session_locale(lang_in      IN UTL$LOCALES.LANG%TYPE
                                ,territory_in IN UTL$LOCALES.TERRITORY%TYPE);

    PROCEDURE set_session_locale(lang_in      IN UTL$LOCALES.LANG%TYPE
                                ,territory_in IN UTL$LOCALES.TERRITORY%TYPE
                                ,codeset_in   IN VARCHAR2
                                ,modifier_in  IN VARCHAR2);

    PROCEDURE reset_session_locale;

    PROCEDURE print_current_locale;

    -- Functions

    FUNCTION get_short_message(id_message_in    IN UTL$LOCALE_MESSAGES.ID_MESSAGE%TYPE
                              ,struct_locale_in IN STRUCT_LOCALE                           DEFAULT SESSION_LOCALE) RETURN VARCHAR2;

    FUNCTION get_long_message(id_message_in    IN UTL$LOCALE_MESSAGES.ID_MESSAGE%TYPE
                             ,struct_locale_in IN STRUCT_LOCALE                           DEFAULT SESSION_LOCALE) RETURN CLOB;

END UTL$LOCALE;
/
