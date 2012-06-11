-- Load czech locales
DELETE FROM NXT.UTL$LOCALE_MESSAGES WHERE ID_LOCALE = 'cs';

INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_CONTINUE',                       'cs', 'N', 'Klient mùže pokraèovat v zasílání požadavku.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_SWITCHING_PROTOCOLS',            'cs', 'N', 'Server mìní protokol.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_OK',                             'cs', 'N', 'Operace probìhla bez chyby, požadavek je úspìšnì splnìn.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_CREATED',                        'cs', 'N', 'Výsledkem požadavku je novì vytvoøený objekt.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_ACCEPTED',                       'cs', 'N', 'Byl pøijat asynchronní požadavek. Požadavek byl správnì akceptován, odpovídající èinnost se však ještì zatím nemusela provést.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_NO_CONTENT',                     'cs', 'N', 'Požadavek byl úspìsný, ale jeho výsledkem nejsou žádná data pro klienta.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_MULTIPLE_CHOICES',               'cs', 'N', 'Požadovaný zdroj se dá získat z nìkolika rùzných míst. V odpovìdi se vrací seznam všech možností.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_MOVED_PERMANENTLY',              'cs', 'N', 'Požadovaná adresa URL se trvale pøesunula na novou adresu URL. Všechny další odkazy musí použít tuto novou URL.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_NOT_MODIFIED',                   'cs', 'N', 'Podmínìný požadavek byl správnì zpracován, dokument však od udané doby nebyl modifikován.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_TEMPORARY_REDIRECT',             'cs', 'N', 'Požadovaná adresa URL se doèasnì pøesunula na novou adresu URL. Všechny další odkazy mohou používat dosavadní URL.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_BAD_REQUEST',                    'cs', 'N', 'Server nerozumí požadavku, klient jej musí opravit a poslat znovu.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_UNAUTHORIZED',                   'cs', 'N', 'Jestliže byl pùvodní požadavek klienta anonymní, musí být nyní autentizován. Pokud už požadavek byl autentizován, pak byl pøistup odepøen.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_FORBIDDEN',                      'cs', 'N', 'Server nemùže požadavku vyhovìt, autorizace nebyla úspìšná.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_NOT_FOUND',                      'cs', 'N', 'Server nenašel zadanou adresu URL.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_METHOD_NOT_ALLOWED',             'cs', 'N', 'Použitá metoda není pøípustná pro dosažení požadovaného objektu.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_NOT_ACCEPTABLE',                 'cs', 'N', 'Požadovaný objekt není k dispozici ve formátu podporovaném klientem.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_REQUEST_TIMEOUT',                'cs', 'N', 'Klient nedokonèil odesílání požadavku v èasovém limitu.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_GONE',                           'cs', 'N', 'Požadovaný objekt byl trvale odstranìn.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_UNSUPPORTED_MEDIA_TYPE',         'cs', 'N', 'Požadavek obsahuje data v serveru neznámém formátu.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_INTERNAL_SERVER_ERROR',          'cs', 'N', 'Na serveru došlo k neoèekávané chybì.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_NOT_IMPLEMENTED',                'cs', 'N', 'Tento požadavek server nepodporuje.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_BAD_GATEWAY',                    'cs', 'N', 'Proxy server nebo brána obdržely od dalšího serveru neplatnou odpovìï.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_SERVICE_UNAVAILABLE',            'cs', 'N', 'Server doèasnì nemùže nebo nechce zpracovat požadavek. Vìtšinou když je pøetížený nebo se provádí údržba.');
INSERT INTO nxt.utl$locale_messages(id_message, id_locale, has_clob, message) VALUES ('HTTP_STATUS_VERSION_NOT_SUPPORT',            'cs', 'N', 'Server nepodporuje verzi HTTP v daném požadavku.');
