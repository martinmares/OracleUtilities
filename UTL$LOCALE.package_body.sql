CREATE OR REPLACE
PACKAGE BODY UTL$LOCALE
IS
    /**
    * ============================================================================
    *                           History of changes
    * ============================================================================
    *  Date (DD/MM/YYYY) Who               Description
    * ----------------- ----------------- --------------------------------
    *  12/07/2011        Martin Mareš      Create package
    *  11/06/2012        Martin Mareš      GitHub distribution
    * ============================================================================
    */

    l_DEFAULT_LOCALE STRUCT_LOCALE;

    PROCEDURE get_locale_message_out(id_message_in    IN     UTL$LOCALE_MESSAGES.ID_MESSAGE%TYPE
                                    ,id_locale_in     IN     UTL$LOCALES.ID_LOCALE%TYPE
                                    ,message_out         OUT UTL$LOCALE_MESSAGES.MESSAGE%TYPE
                                    ,clob_message_out    OUT UTL$LOCALE_MESSAGES.CLOB_MESSAGE%TYPE)
    IS

    BEGIN

        SELECT message
              ,clob_message
          INTO message_out
              ,clob_message_out
          FROM UTL$LOCALE_MESSAGES
         WHERE ID_MESSAGE = id_message_in
           AND ID_LOCALE = id_locale_in;

    END;

    PROCEDURE get_message(id_message_in    IN     UTL$LOCALE_MESSAGES.ID_MESSAGE%TYPE
                         ,has_clob_in      IN     BOOLEAN
                         ,struct_locale_in IN     STRUCT_LOCALE                             DEFAULT SESSION_LOCALE
                         ,message_out         OUT UTL$LOCALE_MESSAGES.MESSAGE%TYPE
                         ,clob_message_out    OUT UTL$LOCALE_MESSAGES.CLOB_MESSAGE%TYPE)
    IS
        l_id_locale          UTL$LOCALES.ID_LOCALE%TYPE;
        l_locale_is_complete BOOLEAN := FALSE;

    BEGIN

        IF (struct_locale_in.territory IS NOT NULL) THEN
            l_locale_is_complete := TRUE;
            l_id_locale := struct_locale_in.lang ||
                           '_' ||
                           struct_locale_in.territory;
        ELSE
            l_id_locale := struct_locale_in.lang;
        END IF;

        BEGIN
            get_locale_message_out(id_message_in => id_message_in, id_locale_in => l_id_locale, message_out => message_out, clob_message_out => clob_message_out);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN

                    IF (l_locale_is_complete) THEN

                        -- Get locale with "lang" part only, if input locale is "complete" (with "lang" and "territory")
                        l_id_locale := struct_locale_in.lang;

                        BEGIN
                            get_locale_message_out(id_message_in => id_message_in, id_locale_in => l_id_locale, message_out => message_out, clob_message_out => clob_message_out);
                            EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                    NULL;
                        END;
                    ELSE
                        NULL;
                    END IF;

        END;
    END get_message;

    FUNCTION get_short_message(id_message_in    IN UTL$LOCALE_MESSAGES.ID_MESSAGE%TYPE
                              ,struct_locale_in IN STRUCT_LOCALE                           DEFAULT SESSION_LOCALE) RETURN VARCHAR2
    IS
        l_message_out      UTL$LOCALE_MESSAGES.MESSAGE%TYPE;
        l_clob_message_out UTL$LOCALE_MESSAGES.CLOB_MESSAGE%TYPE;

    BEGIN
        get_message(id_message_in => id_message_in, has_clob_in => FALSE, struct_locale_in => struct_locale_in, message_out => l_message_out, clob_message_out => l_clob_message_out);

        IF (l_message_out IS NULL) THEN
            get_message(id_message_in => id_message_in, has_clob_in => FALSE, struct_locale_in => l_DEFAULT_LOCALE, message_out => l_message_out,
                        clob_message_out => l_clob_message_out);
        END IF;

        RETURN l_message_out;
    END get_short_message;

    FUNCTION get_long_message(id_message_in    IN UTL$LOCALE_MESSAGES.ID_MESSAGE%TYPE
                             ,struct_locale_in IN STRUCT_LOCALE                           DEFAULT SESSION_LOCALE) RETURN CLOB
    IS
        l_message_out      UTL$LOCALE_MESSAGES.MESSAGE%TYPE;
        l_clob_message_out UTL$LOCALE_MESSAGES.CLOB_MESSAGE%TYPE;

    BEGIN
        get_message(id_message_in => id_message_in, has_clob_in => TRUE, struct_locale_in => struct_locale_in, message_out => l_message_out, clob_message_out => l_clob_message_out);

        IF (l_clob_message_out IS NULL) THEN
            get_message(id_message_in => id_message_in, has_clob_in => TRUE, struct_locale_in => l_DEFAULT_LOCALE, message_out => l_message_out,
                        clob_message_out => l_clob_message_out);
        END IF;

        RETURN l_clob_message_out;
    END get_long_message;

    PROCEDURE set_session_locale(lang_in IN UTL$LOCALES.LANG%TYPE)
    IS

    BEGIN
        set_session_locale(lang_in => lang_in, territory_in => NULL, codeset_in => NULL, modifier_in => NULL);
    END set_session_locale;

    PROCEDURE set_session_locale(lang_in      IN UTL$LOCALES.LANG%TYPE
                                ,territory_in IN UTL$LOCALES.TERRITORY%TYPE)
    IS

    BEGIN
        set_session_locale(lang_in => lang_in, territory_in => territory_in, codeset_in => NULL, modifier_in => NULL);
    END set_session_locale;

    PROCEDURE set_session_locale(lang_in      IN UTL$LOCALES.LANG%TYPE
                                ,territory_in IN UTL$LOCALES.TERRITORY%TYPE
                                ,codeset_in   IN VARCHAR2
                                ,modifier_in  IN VARCHAR2)
    IS

    BEGIN
        SESSION_LOCALE.lang := lang_in;
        SESSION_LOCALE.territory := territory_in;
        SESSION_LOCALE.codeset := codeset_in;
        SESSION_LOCALE.modifier := modifier_in;
    END set_session_locale;

    PROCEDURE print_current_locale
    IS
        l_empty_text VARCHAR2(20) := '(no set)';

    BEGIN
        DBMS_OUTPUT.put_line(utl$base.str_group_box(text_in => 'Current locale settings', line_length_in => 80));
        DBMS_OUTPUT.put_line('Language  = ' ||
                             COALESCE(SESSION_LOCALE.lang, l_empty_text));
        DBMS_OUTPUT.put_line('Territory = ' ||
                             COALESCE(SESSION_LOCALE.territory, l_empty_text));
        DBMS_OUTPUT.put_line('Codeset   = ' ||
                             COALESCE(SESSION_LOCALE.codeset, l_empty_text));
        DBMS_OUTPUT.put_line('Modifier  = ' ||
                             COALESCE(SESSION_LOCALE.modifier, l_empty_text));
    END print_current_locale;

    PROCEDURE reset_session_locale
    IS

    BEGIN
        SESSION_LOCALE.lang := DEFAULT_LANG;
        SESSION_LOCALE.territory := DEFAULT_TERRITORY;
    END reset_session_locale;

BEGIN
    reset_session_locale();
    l_DEFAULT_LOCALE.lang := DEFAULT_LANG;
    l_DEFAULT_LOCALE.territory := DEFAULT_TERRITORY;
END UTL$LOCALE;
/
