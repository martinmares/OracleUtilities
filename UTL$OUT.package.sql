CREATE OR REPLACE
PACKAGE UTL$OUT
IS

    /**
    * ======================================================================
    *                               LICENSE and ANNOTATION
    * ======================================================================
    *
    * Library to perform smarter PUT_LINE procedure for PL/SQL developers :)
    * Enjoy it!
    *
    * ======================================================================
    * Distributed under "The GNU Lesser General Public License, version 3.0 (LGPLv3)"
    * ======================================================================
    *
    * UTL$OUT
    *
    * Copyright (c) 2010, Martin Mareš <martin at sequel-code.cz>
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
    * Constants
    * ----------------------------------------------------------------------
    */
    c_DEBUG_FLAG               CONSTANT BOOLEAN := FALSE;
    c_INFINITE_LOOP            CONSTANT PLS_INTEGER := 999;
    c_QUOTE_CHAR               CONSTANT VARCHAR2(10) := '"';
    c_XML_TAG_BEGIN_CHARS      CONSTANT VARCHAR2(10) := '<';
    c_XML_TAG_END_CHARS        CONSTANT VARCHAR2(10) := '>';
    c_HTML_ESC_TAG_BEGIN_CHARS CONSTANT VARCHAR2(10) := '&lt;';
    c_HTML_ESC_TAG_END_CHARS   CONSTANT VARCHAR2(10) := '&gt;';
    c_eol_WINDOWS              CONSTANT VARCHAR2(2) := CHR(13) || CHR(10);
    c_eol_UNIX                 CONSTANT VARCHAR2(2) := CHR(10);
    c_eol_MAC                  CONSTANT VARCHAR2(2) := CHR(13);
    c_eol_DEFAULT              CONSTANT VARCHAR2(2) := c_eol_UNIX;
    c_LINE_SIZE                CONSTANT PLS_INTEGER := 80;
    c_MAX_LINE_SIZE            CONSTANT PLS_INTEGER := 255;

    SUBTYPE VARCHAR2_LINE_TYPE IS VARCHAR2(255);

    SUBTYPE VARCHAR2_MAX_TYPE IS VARCHAR2(32767);
    c_WINDOWS CONSTANT VARCHAR2(15) := 'WINDOWS';
    c_UNIX    CONSTANT VARCHAR2(15) := 'UNIX';
    c_MAC     CONSTANT VARCHAR2(15) := 'MAC';

    /**
    * ----------------------------------------------------------------------
    * Public PROCEDURES and FUNCTIONS
    * ----------------------------------------------------------------------
    */

    PROCEDURE set_debug_flag(value_in IN BOOLEAN);

    PROCEDURE write_line(string_in              IN CLOB
                        ,line_size_in           IN NUMBER   DEFAULT c_LINE_SIZE
                        ,end_of_line_type_in    IN VARCHAR2 DEFAULT c_WINDOWS  /* WINDOWS or UNIX or MAC */
                        ,remove_end_of_lines_in IN BOOLEAN  DEFAULT TRUE
                        ,wrap_words_in          IN BOOLEAN  DEFAULT FALSE
                        ,append_line_numbers_in IN BOOLEAN  DEFAULT FALSE
                        ,append_quotes_in       IN BOOLEAN  DEFAULT FALSE
                        ,trim_output_lines_in   IN BOOLEAN  DEFAULT FALSE
                        ,markup_input_in        IN BOOLEAN  DEFAULT FALSE
                        ,tag_begin_chars_in     IN VARCHAR2 DEFAULT c_XML_TAG_BEGIN_CHARS  /* for example "<" or "&lt;" */
                        ,quote_char_in          IN VARCHAR2 DEFAULT c_QUOTE_CHAR
                        ,white_chars_in         IN VARCHAR2 DEFAULT CHR(32) || CHR(9));

END UTL$OUT;
/
