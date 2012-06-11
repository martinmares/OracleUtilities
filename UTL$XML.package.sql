CREATE OR REPLACE
PACKAGE UTL$XML
IS
    /**
    * ======================================================================
    *                               LICENSE and ANNOTATION
    * ======================================================================
    *
    * Basic utilities - for XML manipulation
    *
    * ======================================================================
    * Distributed under "The GNU Lesser General Public License, version 3.0 (LGPLv3)"
    * ======================================================================
    *
    * UTL$XML
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

    FUNCTION get_xsd_date_time(date_in           IN DATE
                              ,with_time_zone_in IN BOOLEAN DEFAULT FALSE) RETURN VARCHAR2;

    FUNCTION get_xsd_date_time(date_in           IN DATE
                              ,with_time_zone_in IN VARCHAR2) RETURN VARCHAR2;

    FUNCTION get_xsd_date_time_long(date_in IN DATE) RETURN VARCHAR2;

    FUNCTION escape_xml_chars(text_in IN VARCHAR2) RETURN VARCHAR2;

    FUNCTION unescape_xml_chars(text_in IN VARCHAR2) RETURN VARCHAR2;

    FUNCTION get_cdata_begin RETURN VARCHAR2;

    FUNCTION get_cdata_end RETURN VARCHAR2;

    FUNCTION fix_xsd_double(number_in IN NUMBER) RETURN VARCHAR2;

END UTL$XML;
/
