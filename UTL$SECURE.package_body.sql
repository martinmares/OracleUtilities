CREATE OR REPLACE
PACKAGE BODY     UTL$SECURE
IS

    /**
    * ============================================================================
    *                           History of changes
    * ============================================================================
    *  Date (DD/MM/YYYY) Who               Description
    * ----------------- ----------------- --------------------------------
    *  20/09/2011        ...               Obtained from http://www.orafaq.com/node/2385
    *  11/06/2012        Martin Mareš      GitHub distribution
    * ============================================================================
    */
    FUNCTION generate_password(template_in IN VARCHAR2) RETURN VARCHAR2
    IS

        /**
        * ======================================================================
        *  Here is a scenario (template):
        *
        *      First char must be UPPERCASE
        *      Second and third one must be NUMBER
        *      Make fourth a NON-ALPHANUMERIC character
        *      Fifth one must be LOWERCASE
        *      Sixth is a NUMBER again
        *      Seventh is any character
        *      By the way, clients can't use all the non-alphanumerics, please choose them from easy's.
        *
        *   Usage:
        *      select fRandomPass('unnelnr') from dual;
        *
        *   Result:
        *      R91?k2y
        *
        * ======================================================================
        *  Template characters:
        *
        *      u - upper case alpha characters only
        *      l - lower case alpha characters only
        *      a - alpha characters only (mixed case)
        *      x - any alpha-numeric characters (upper)
        *      y - any alpha-numeric characters (lower)
        *      n - numeric characters*
        *      p - any printable char (ASCII subset)*
        *      c - any NON-alphanumeric characters
        *      b - any non-alpha characters
        *      d - any non-alpha characters (useful mode)
        *      e - any NON-alphanumeric characters (useful mode)
        * ======================================================================
        */
        n               NUMBER;
        l_return_chars  NUMBER;
        l_switch        VARCHAR2(1);
        l_return        VARCHAR2(4000);
        l_characters    VARCHAR2(4000);
        l_random_number NUMBER;

    BEGIN
        n := LENGTH(template_in);
        l_switch := '';
        l_return := '';

        FOR i IN 1..n LOOP
            l_switch := SUBSTR(template_in, i, 1);

            IF l_switch = 'u' THEN  -- upper case alpha characters only
                l_characters := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
            ELSIF l_switch = 'l' THEN  -- lower case alpha characters only
                l_characters := 'abcdefghijklmnopqrstuvwxyz';
            ELSIF l_switch = 'a' THEN  -- alpha characters only (mixed case)
                l_characters := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
            ELSIF l_switch = 'x' THEN  -- any alpha-numeric characters (upper)
                l_characters := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
            ELSIF l_switch = 'y' THEN  -- any alpha-numeric characters (lower)
                l_characters := '0123456789abcdefghijklmnopqrstuvwxyz';
            ELSIF l_switch = 'n' THEN  -- numeric characters
                l_characters := '0123456789';
            ELSIF l_switch = 'p' THEN  -- any printable char (ASCII subset)
                l_characters := ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~';
            ELSIF l_switch = 'r' THEN  -- any printable char (ASCII subset) (useful mode)
                l_characters := '!#$%&()*0123456789+/<=>?@\{}[]ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
            ELSIF l_switch = 'c' THEN  -- any NON-alphanumeric characters
                l_characters := ' !"#$%&''()*+,-./:;<=>?@[\]^_`{|}~';
            ELSIF l_switch = 'e' THEN  -- any NON-alphanumeric characters (useful mode)
                l_characters := '!#$%&()*+/<=>?@\{}[]';
            ELSIF l_switch = 'b' THEN  -- any non-alpha characters
                l_characters := ' !"#$%&''()*+,-./0123456789:;<=>?@[\]^_`{|}~';
            ELSIF l_switch = 'd' THEN  -- any non-alpha characters (useful mode)
                l_characters := '!#$%&()*0123456789+/<=>?@\{}[]';
            ELSE
                l_characters := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
            END IF;

            l_random_number := LENGTH(l_characters);
            l_return_chars := TRUNC(l_random_number * dbms_random.VALUE) + 1;
            l_return := l_return ||
                        SUBSTR(l_characters, l_return_chars, 1);
        END LOOP;

        RETURN l_return;
    END generate_password;

END UTL$SECURE;
/