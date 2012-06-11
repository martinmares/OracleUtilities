CREATE OR REPLACE
PACKAGE UTL$HTTP
IS
    /**
    * ======================================================================
    *                               LICENSE and ANNOTATION
    * ======================================================================
    *
    * Basic HTTP utilities
    *
    * ======================================================================
    * Distributed under "The GNU Lesser General Public License, version 3.0 (LGPLv3)"
    * ======================================================================
    *
    * UTL$HTTP
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

    c_OBJECT_NAME                  CONSTANT UTL$DATA_TYPES.T_BIG_STRING := 'UTL$HTTP';

    /**
    * ----------------------------------------------------------------------
    * UTL_HTTP exceptions
    * ----------------------------------------------------------------------
    */
    CIP_HTTP_INIT_FAILED           CONSTANT NUMBER(10) := - 29272;
    CIP_HTTP_REQUEST_FAILED        CONSTANT NUMBER(10) := - 29273;
    CIP_HTTP_BAD_ARGUMENT          CONSTANT NUMBER(10) := - 29261;
    CIP_HTTP_BAD_URL               CONSTANT NUMBER(10) := - 29262;
    CIP_HTTP_PROTOCOL_ERROR        CONSTANT NUMBER(10) := - 29263;
    CIP_HTTP_UNKNOWN_SCHEME        CONSTANT NUMBER(10) := - 29264;
    CIP_HTTP_HEADER_NOT_FOUND      CONSTANT NUMBER(10) := - 29265;
    CIP_HTTP_END_OF_BODY           CONSTANT NUMBER(10) := - 29266;
    CIP_HTTP_ILLEGAL_CALL          CONSTANT NUMBER(10) := - 29267;
    CIP_HTTP_HTTP_CLIENT_ERROR     CONSTANT NUMBER(10) := - 29268;
    CIP_HTTP_HTTP_SERVER_ERROR     CONSTANT NUMBER(10) := - 29269;
    CIP_HTTP_TOO_MANY_REQUESTS     CONSTANT NUMBER(10) := - 29270;
    CIP_HTTP_PARTIAL_MULTIBYTE_CH  CONSTANT NUMBER(10) := - 29275;
    CIP_HTTP_TRANSFER_TIMEOUT      CONSTANT NUMBER(10) := - 29276;

    /**
    * ----------------------------------------------------------------------
    * HTTP versions
    * ----------------------------------------------------------------------
    */
    HTTP_VERSION_1_0               CONSTANT VARCHAR2(10) := 'HTTP/1.0';
    HTTP_VERSION_1_1               CONSTANT VARCHAR2(10) := 'HTTP/1.1';
    DEFAULT_HTTP_VERSION           CONSTANT VARCHAR2(10) := HTTP_VERSION_1_1;

    /**
    * ----------------------------------------------------------------------
    * HTTP statuses
    * ----------------------------------------------------------------------
    */
    STATUS_CONTINUE                CONSTANT NUMBER(10) := 100;
    STATUS_SWITCHING_PROTOCOLS     CONSTANT NUMBER(10) := 101;
    STATUS_PROCESSING              CONSTANT NUMBER(10) := 102;
    STATUS_REQUEST_URI_TOO_LONG    CONSTANT NUMBER(10) := 122;
    STATUS_OK                      CONSTANT NUMBER(10) := 200;
    STATUS_CREATED                 CONSTANT NUMBER(10) := 201;
    STATUS_ACCEPTED                CONSTANT NUMBER(10) := 202;
    STATUS_NON_AUTHORITATIVE_INFOR CONSTANT NUMBER(10) := 203;
    STATUS_NO_CONTENT              CONSTANT NUMBER(10) := 204;
    STATUS_RESET_CONTENT           CONSTANT NUMBER(10) := 205;
    STATUS_PARTIAL_CONTENT         CONSTANT NUMBER(10) := 206;
    STATUS_MULTI_STATUS            CONSTANT NUMBER(10) := 207;
    STATUS_IM_USED                 CONSTANT NUMBER(10) := 226;
    STATUS_MULTIPLE_CHOICES        CONSTANT NUMBER(10) := 300;
    STATUS_MOVED_PERMANENTLY       CONSTANT NUMBER(10) := 301;
    STATUS_FOUND                   CONSTANT NUMBER(10) := 302;
    STATUS_SEE_OTHER               CONSTANT NUMBER(10) := 303;
    STATUS_NOT_MODIFIED            CONSTANT NUMBER(10) := 304;
    STATUS_USE_PROXY               CONSTANT NUMBER(10) := 305;
    STATUS_SWITCH_PROXY            CONSTANT NUMBER(10) := 306;
    STATUS_TEMPORARY_REDIRECT      CONSTANT NUMBER(10) := 307;
    STATUS_BAD_REQUEST             CONSTANT NUMBER(10) := 400;
    STATUS_UNAUTHORIZED            CONSTANT NUMBER(10) := 401;
    STATUS_PAYMENT_REQUIRED        CONSTANT NUMBER(10) := 402;
    STATUS_FORBIDDEN               CONSTANT NUMBER(10) := 403;
    STATUS_NOT_FOUND               CONSTANT NUMBER(10) := 404;
    STATUS_METHOD_NOT_ALLOWED      CONSTANT NUMBER(10) := 405;
    STATUS_NOT_ACCEPTABLE          CONSTANT NUMBER(10) := 406;
    STATUS_PROXY_AUTH_REQUIRED     CONSTANT NUMBER(10) := 407;
    STATUS_REQUEST_TIMEOUT         CONSTANT NUMBER(10) := 408;
    STATUS_CONFLICT                CONSTANT NUMBER(10) := 409;
    STATUS_GONE                    CONSTANT NUMBER(10) := 410;
    STATUS_LENGTH_REQUIRED         CONSTANT NUMBER(10) := 411;
    STATUS_PRECONDITION_FAILED     CONSTANT NUMBER(10) := 412;
    STATUS_REQUEST_ENTITY_TOO_LARG CONSTANT NUMBER(10) := 413;
    STATUS_REQUEST_URI_TOO_LARGE   CONSTANT NUMBER(10) := 414;
    STATUS_UNSUPPORTED_MEDIA_TYPE  CONSTANT NUMBER(10) := 415;
    STATUS_REQUESTED_RANGE_NOT_SAT CONSTANT NUMBER(10) := 416;
    STATUS_EXPECTATION_FAILED      CONSTANT NUMBER(10) := 417;
    I_M_A_TEAPOT                   CONSTANT NUMBER(10) := 418;
    UNPROCESSABLE_ENTITY           CONSTANT NUMBER(10) := 422;
    LOCKED                         CONSTANT NUMBER(10) := 423;
    FAILED_DEPENDENCY              CONSTANT NUMBER(10) := 424;
    UNORDERED_COLLECTION           CONSTANT NUMBER(10) := 425;
    UPGRADE_REQUIRED               CONSTANT NUMBER(10) := 426;
    NO_RESPONSE                    CONSTANT NUMBER(10) := 444;
    RETRY_WITH                     CONSTANT NUMBER(10) := 449;
    BLOCKED_BY_WIN_PARENT_CONTROLS CONSTANT NUMBER(10) := 450;
    CLIENT_CLOSED_REQUEST          CONSTANT NUMBER(10) := 499;
    STATUS_INTERNAL_SERVER_ERROR   CONSTANT NUMBER(10) := 500;
    STATUS_NOT_IMPLEMENTED         CONSTANT NUMBER(10) := 501;
    STATUS_BAD_GATEWAY             CONSTANT NUMBER(10) := 502;
    STATUS_SERVICE_UNAVAILABLE     CONSTANT NUMBER(10) := 503;
    STATUS_GATEWAY_TIMEOUT         CONSTANT NUMBER(10) := 504;
    STATUS_VERSION_NOT_SUPPORT     CONSTANT NUMBER(10) := 505;
    STATUS_VARIANT_ALSO_NEGOTIATES CONSTANT NUMBER(10) := 506;
    STATUS_INSUFFICIENT_STORAGE    CONSTANT NUMBER(10) := 507;
    STATUS_BANDWIDTH_LIMIT_EXCEED  CONSTANT NUMBER(10) := 509;
    STATUS_NOT_EXTENDED            CONSTANT NUMBER(10) := 510;

    -- Functions
    FUNCTION get_status_code_message(http_status_in IN NUMBER) RETURN VARCHAR2;

END UTL$HTTP;
/
