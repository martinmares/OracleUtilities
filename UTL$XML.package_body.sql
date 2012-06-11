CREATE OR REPLACE
PACKAGE BODY UTL$XML
IS
    /**
    * ============================================================================
    *                           History of changes
    * ============================================================================
    *  Date (DD/MM/YYYY) Who               Description
    * ----------------- ----------------- --------------------------------
    *  11/06/2012        Martin Mareš      GitHub distribution
    * ============================================================================
    */

    FUNCTION get_xsd_date_time(date_in           IN DATE
                              ,with_time_zone_in IN BOOLEAN DEFAULT FALSE) RETURN VARCHAR2
    IS

    BEGIN
        RETURN
            CASE
                WHEN date_in IS NOT NULL
                    THEN TO_CHAR(date_in, 'YYYY-MM-DD') ||
'T' ||
TO_CHAR(date_in, 'HH24:MI:SS') ||

                        CASE
                            WHEN with_time_zone_in
                                THEN '.0Z'
                            ELSE NULL
                        END
                ELSE NULL
            END;
    END get_xsd_date_time;

    FUNCTION get_xsd_date_time(date_in           IN DATE
                              ,with_time_zone_in IN VARCHAR2) RETURN VARCHAR2
    IS

    BEGIN

        IF (with_time_zone_in IN('A', 'Y')) THEN
            RETURN get_xsd_date_time(date_in, true);
        ELSE
            RETURN get_xsd_date_time(date_in, false);
        END IF;

    END get_xsd_date_time;

    FUNCTION get_xsd_date_time_long(date_in IN DATE) RETURN VARCHAR2
    IS

    BEGIN
        RETURN
            CASE
                WHEN date_in IS NOT NULL
                    THEN TO_CHAR(date_in, 'YYYY-MM-DD') ||
'T' ||
TO_CHAR(date_in, 'HH24:MI:SS') ||
'.000+01:00'
                ELSE NULL
            END;
    END get_xsd_date_time_long;

    FUNCTION escape_xml_chars(text_in IN VARCHAR2) RETURN VARCHAR2
    IS

    BEGIN
        RETURN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(text_in, '&', '&amp;'), '>', '&gt;'), '<', '&lt;'), '''', '&#039;'), '"', '&quot;');
    END escape_xml_chars;

    FUNCTION unescape_xml_chars(text_in IN VARCHAR2) RETURN VARCHAR2
    IS

    BEGIN
        RETURN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(text_in, '&amp;', '&'), '&gt;', '>'), '&lt;', '<'), '&#039;', ''''), '&quot;', '"');
    END unescape_xml_chars;

    FUNCTION get_cdata_begin RETURN VARCHAR2
    IS

    BEGIN
        RETURN '<![CDATA[';
    END get_cdata_begin;

    FUNCTION get_cdata_end RETURN VARCHAR2
    IS

    BEGIN
        RETURN ']]>';
    END get_cdata_end;

    FUNCTION fix_xsd_double(number_in IN NUMBER) RETURN VARCHAR2
    IS
        l_str VARCHAR2(2000);

    BEGIN
        l_str := number_in;
        l_str := REPLACE(l_str, ',', '.');
        RETURN l_str;
    END fix_xsd_double;

END UTL$XML;
/
