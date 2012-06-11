CREATE OR REPLACE
PACKAGE BODY UTL$OUT
IS

    /**
    * ============================================================================
    *                           History of changes
    * ============================================================================
    *  Date (DD/MM/YYYY) Who               Description
    * ----------------- ----------------- --------------------------------
    *  02/09/2010        Martin Mareš      First public version
    *  03/09/2010        Martin Mareš      Fix: Prevent last line cut
    *  11/06/2012        Martin Mareš      GitHub distribution
    * ============================================================================
    */
    l_DEBUG_FLAG BOOLEAN := c_DEBUG_FLAG;

    FUNCTION can_debug RETURN BOOLEAN
    IS

    BEGIN
        RETURN COALESCE(l_DEBUG_FLAG, c_DEBUG_FLAG);
    END can_debug;

    PROCEDURE set_debug_flag(value_in IN BOOLEAN)
    IS

    BEGIN
        l_DEBUG_FLAG := value_in;
    END set_debug_flag;

    PROCEDURE write_debug(string_in IN VARCHAR2
                         ,value_in  IN VARCHAR2 DEFAULT NULL)
    IS
        l_value VARCHAR2(2000);

    BEGIN

        IF (value_in IS NOT NULL) THEN
            l_value := ' = "' ||
                       value_in ||
                       '"';
        END IF;

        IF (can_debug) THEN
            DBMS_OUTPUT.put_line(' => ' ||
                                 string_in ||
                                 l_value);
        END IF;

    END write_debug;

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
                        ,white_chars_in         IN VARCHAR2 DEFAULT CHR(32) || CHR(9))  /* Space, Tab */
    IS
        l_string                      CLOB := string_in;

        TYPE array_clobs IS TABLE OF CLOB INDEX BY BINARY_INTEGER;
        clob_lines                    array_clobs;
        l_length                      PLS_INTEGER;
        l_lines                       PLS_INTEGER;
        l_correct_line_size           PLS_INTEGER;
        l_line_buffer                 VARCHAR2_LINE_TYPE;
        l_char                        CHAR(1);
        l_separator                   CHAR(1);
        l_openings                    PLS_INTEGER := 0;
        l_closings                    PLS_INTEGER := 0;
        l_is_markup_strip             BOOLEAN := FALSE;
        l_white_char_position         PLS_INTEGER := 0;
        l_white_char_pos_tmp          PLS_INTEGER := 0;
        l_eol_first_occurrance        PLS_INTEGER := 0;
        l_white_char_forward_position PLS_INTEGER := 0;
        l_tag_begin_chars_position    PLS_INTEGER := 0;
        l_white_chars                 VARCHAR2(100) := white_chars_in;
        l_sanity_check                PLS_INTEGER := 0;
        l_eol_at_first_position       PLS_INTEGER := 1;
        l_line_counter                PLS_INTEGER := 0;
        l_found_EOL                   BOOLEAN := FALSE;

        FUNCTION split_string(list_in      IN CLOB
                             ,delimiter_in IN VARCHAR2 := c_eol_DEFAULT) RETURN array_clobs
        IS
            l_idx    PLS_INTEGER;
            l_list   CLOB := list_in;
            l_return array_clobs;

        BEGIN

            LOOP
                l_idx := INSTR(l_list, delimiter_in);

                IF l_idx > 0 THEN
                    l_return(l_return.COUNT) := SUBSTR(l_list, 1, l_idx - 1);
                    l_list := SUBSTR(l_list, l_idx + LENGTH(delimiter_in));
                ELSE
                    l_return(l_return.COUNT) := l_list;
                    EXIT;
                END IF;

            END LOOP;

            RETURN l_return;
        END split_string;

        PROCEDURE put_line_wrapper(string_in            IN     VARCHAR2
                                  ,trim_output_lines_in IN     BOOLEAN     DEFAULT FALSE
                                  ,counter_io           IN OUT PLS_INTEGER)
        IS
            l_quotes               VARCHAR2(10) := NULL;
            l_string               CLOB := string_in;
            l_end_line_occurrences PLS_INTEGER;

        BEGIN

            IF (remove_end_of_lines_in) THEN
                l_end_line_occurrences := INSTR(l_string, c_eol_DEFAULT, - 1, 1);

                IF (l_end_line_occurrences = LENGTH(l_string)) THEN
                    l_string := SUBSTR(l_string, 1, l_end_line_occurrences - LENGTH(c_eol_DEFAULT));
                END IF;

            END IF;

            IF (append_quotes_in) THEN
                l_quotes := COALESCE(quote_char_in, c_QUOTE_CHAR);
            END IF;

            IF (append_line_numbers_in) THEN
                DBMS_OUTPUT.put('[' ||
                                LPAD(counter_io, 4, '0') ||
                                '] ');
            END IF;

            IF (trim_output_lines_in) THEN
                DBMS_OUTPUT.put_line(l_quotes ||
                                     TRIM(l_string) ||
                                     l_quotes);
            ELSE
                DBMS_OUTPUT.put_line(l_quotes ||
                                     l_string ||
                                     l_quotes);
            END IF;

            counter_io := counter_io + 1;
        END put_line_wrapper;

    BEGIN

        /**
        * ----------------------------------------------------------------------
        * Normalize input string to UNIX line ends, for better processing
        * For printing to std_out is using DBMS_OUTPUT.NEW_LINE()
        * which is depended on platorm to Oracle run )
        * ----------------------------------------------------------------------
        */
        write_debug('Length of string before normalize', LENGTH(l_string));

        IF (end_of_line_type_in = c_WINDOWS) THEN
            l_string := REPLACE(l_string, c_eol_WINDOWS, c_eol_DEFAULT);
        ELSIF (end_of_line_type_in = c_MAC) THEN
            l_string := REPLACE(l_string, c_eol_MAC, c_eol_DEFAULT);
        END IF;

        IF (trim_output_lines_in) THEN
            clob_lines := split_string(l_string);

            IF (clob_lines.COUNT > 0) THEN
                l_string := NULL;

                FOR i IN clob_lines.FIRST..clob_lines.LAST LOOP

                    IF (SUBSTR(clob_lines(i), LENGTH(clob_lines(i))) = c_eol_DEFAULT) THEN
                        l_string := l_string ||
                                    TRIM(clob_lines(i));
                    ELSE
                        l_string := l_string ||
                                    TRIM(clob_lines(i)) ||
                                    c_eol_DEFAULT;
                    END IF;

                END LOOP;

            END IF;

        END IF;

        write_debug('Length of string after normalize', LENGTH(l_string));
        l_length := LENGTH(l_string);
        l_white_chars := white_chars_in ||
                         c_eol_DEFAULT;

        IF (l_length > 0) THEN
            l_correct_line_size := COALESCE(LEAST(line_size_in, c_MAX_LINE_SIZE), c_LINE_SIZE);
            l_lines := CEIL(l_length / l_correct_line_size);

            WHILE(LENGTH(l_string) > 0) LOOP
                l_line_buffer := SUBSTR(l_string, 1, l_correct_line_size);
                l_white_char_position := 0;
                l_eol_first_occurrance := INSTR(l_line_buffer, c_eol_DEFAULT, 1, 1);

                /**
                * ----------------------------------------------------------------------
                * EOL chars are an absolute priority !
                * ----------------------------------------------------------------------
                */

                IF (l_eol_first_occurrance > 0) THEN
                    l_white_char_position := l_eol_first_occurrance;
                    write_debug('White char pos. (1)', l_white_char_position);
                ELSE

                    IF ( NOT wrap_words_in) THEN

                        /**
                        * ----------------------------------------------------------------------
                        * Try find last white char in line buffer
                        * ----------------------------------------------------------------------
                        */

                        <<white_chars>>
                        FOR char_position IN 1..LENGTH(l_white_chars) LOOP
                            l_char := SUBSTR(l_white_chars, char_position, 1);
                            l_white_char_pos_tmp := INSTR(l_line_buffer, l_char, - 1, 1);

                            IF (l_white_char_pos_tmp > l_white_char_position) THEN
                                l_white_char_position := l_white_char_pos_tmp;
                            END IF;

                        END LOOP white_chars;
                        write_debug('White char pos. (2)', l_white_char_position);
                    ELSE
                        l_white_char_position := l_correct_line_size;
                    END IF;

                END IF;

                /**
                * ----------------------------------------------------------------------
                * EOL chars - absolute priority !
                * ----------------------------------------------------------------------
                */

                IF (l_eol_first_occurrance = 0) THEN

                    IF (markup_input_in) THEN
                        l_tag_begin_chars_position := INSTR(l_line_buffer, tag_begin_chars_in, - 1, 1);

                        IF (l_tag_begin_chars_position > 0
                            AND l_white_char_position < l_tag_begin_chars_position) THEN
                            l_white_char_position := l_tag_begin_chars_position - 1;
                        END IF;

                        write_debug('White char pos. (3)', l_white_char_position);
                    END IF;

                END IF;

                /**
                * ----------------------------------------------------------------------
                * Try find first white char after line buffer (next loop print line)
                * ----------------------------------------------------------------------
                */

                <<white_chars_forward>>
                FOR char_position IN 1..LENGTH(l_white_chars) LOOP
                    l_char := SUBSTR(l_white_chars, char_position, 1);
                    l_white_char_forward_position := INSTR(SUBSTR(l_line_buffer, 1, 1), l_char, 1);
                    EXIT white_chars_forward WHEN l_white_char_position > 0;
                END LOOP white_chars_forward;
                write_debug('Line buffer content', l_line_buffer);
                write_debug('EOL first occurrance', l_eol_first_occurrance);
                write_debug('Tag begin chars pos.', l_tag_begin_chars_position);
                write_debug('White char position', l_white_char_position);
                write_debug('White char forward position', l_white_char_forward_position);

                IF (l_white_char_position = 0
                    OR l_white_char_forward_position = 1) THEN
                    l_white_char_position := l_correct_line_size;
                END IF;

                /**
                * ----------------------------------------------------------------------
                * If first character in line buffer is CHR(10), must be removed from output
                * ----------------------------------------------------------------------
                */

                IF (SUBSTR(l_line_buffer, 1, 1) = c_eol_DEFAULT) THEN
                    l_eol_at_first_position := 1;
                ELSE
                    l_eol_at_first_position := 0;
                END IF;

                /**
                * ----------------------------------------------------------------------
                * Prevent last line cut
                * ----------------------------------------------------------------------
                */

                IF (LENGTH(l_line_buffer) < l_correct_line_size
                    AND l_eol_first_occurrance = 0) THEN
                    l_white_char_position := l_correct_line_size;
                    write_debug('Preventing last line cut');
                END IF;

                write_debug('Cut line_buffer at position', l_white_char_position);
                l_line_buffer := SUBSTR(l_string, 1 + l_eol_at_first_position, l_white_char_position);
                l_string := SUBSTR(l_string, l_white_char_position + 1 + l_eol_at_first_position);
                put_line_wrapper(l_line_buffer, trim_output_lines_in, l_line_counter);
                l_sanity_check := l_sanity_check + 1;

                /**
                * ----------------------------------------------------------------------
                * Prevent infinite loop
                * ----------------------------------------------------------------------
                */
                EXIT WHEN l_sanity_check > c_INFINITE_LOOP;
            END LOOP;

        END IF;

    END write_line;

END UTL$OUT;
/
