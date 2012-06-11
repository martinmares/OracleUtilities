-- Load czech locales
DELETE FROM NXT.UTL$LOCALE_MESSAGES WHERE ID_LOCALE = 'cs';

INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_CONTINUE',                       'cs', 'N', 'Klient m��e pokra�ovat v zas�l�n� po�adavku.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_SWITCHING_PROTOCOLS',            'cs', 'N', 'Server m�n� protokol.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_OK',                             'cs', 'N', 'Operace prob�hla bez chyby, po�adavek je �sp�n� spln�n.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_CREATED',                        'cs', 'N', 'V�sledkem po�adavku je nov� vytvo�en� objekt.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_ACCEPTED',                       'cs', 'N', 'Byl p�ijat asynchronn� po�adavek. Po�adavek byl spr�vn� akceptov�n, odpov�daj�c� �innost se v�ak je�t� zat�m nemusela prov�st.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_NO_CONTENT',                     'cs', 'N', 'Po�adavek byl �sp�sn�, ale jeho v�sledkem nejsou ��dn� data pro klienta.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_MULTIPLE_CHOICES',               'cs', 'N', 'Po�adovan� zdroj se d� z�skat z n�kolika r�zn�ch m�st. V odpov�di se vrac� seznam v�ech mo�nost�.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_MOVED_PERMANENTLY',              'cs', 'N', 'Po�adovan� adresa URL se trvale p�esunula na novou adresu URL. V�echny dal�� odkazy mus� pou��t tuto novou URL.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_NOT_MODIFIED',                   'cs', 'N', 'Podm�n�n� po�adavek byl spr�vn� zpracov�n, dokument v�ak od udan� doby nebyl modifikov�n.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_TEMPORARY_REDIRECT',             'cs', 'N', 'Po�adovan� adresa URL se do�asn� p�esunula na novou adresu URL. V�echny dal�� odkazy mohou pou��vat dosavadn� URL.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_BAD_REQUEST',                    'cs', 'N', 'Server nerozum� po�adavku, klient jej mus� opravit a poslat znovu.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_UNAUTHORIZED',                   'cs', 'N', 'Jestli�e byl p�vodn� po�adavek klienta anonymn�, mus� b�t nyn� autentizov�n. Pokud u� po�adavek byl autentizov�n, pak byl p�istup odep�en.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_FORBIDDEN',                      'cs', 'N', 'Server nem��e po�adavku vyhov�t, autorizace nebyla �sp�n�.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_NOT_FOUND',                      'cs', 'N', 'Server nena�el zadanou adresu URL.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_METHOD_NOT_ALLOWED',             'cs', 'N', 'Pou�it� metoda nen� p��pustn� pro dosa�en� po�adovan�ho objektu.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_NOT_ACCEPTABLE',                 'cs', 'N', 'Po�adovan� objekt nen� k dispozici ve form�tu podporovan�m klientem.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_REQUEST_TIMEOUT',                'cs', 'N', 'Klient nedokon�il odes�l�n� po�adavku v �asov�m limitu.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_GONE',                           'cs', 'N', 'Po�adovan� objekt byl trvale odstran�n.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_UNSUPPORTED_MEDIA_TYPE',         'cs', 'N', 'Po�adavek obsahuje data v serveru nezn�m�m form�tu.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_INTERNAL_SERVER_ERROR',          'cs', 'N', 'Na serveru do�lo k neo�ek�van� chyb�.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_NOT_IMPLEMENTED',                'cs', 'N', 'Tento po�adavek server nepodporuje.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_BAD_GATEWAY',                    'cs', 'N', 'Proxy server nebo br�na obdr�ely od dal��ho serveru neplatnou odpov��.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_SERVICE_UNAVAILABLE',            'cs', 'N', 'Server do�asn� nem��e nebo nechce zpracovat po�adavek. V�t�inou kdy� je p�et�en� nebo se prov�d� �dr�ba.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_VERSION_NOT_SUPPORT',            'cs', 'N', 'Server nepodporuje verzi HTTP v dan�m po�adavku.');
