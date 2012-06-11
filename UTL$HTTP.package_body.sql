CREATE OR REPLACE
PACKAGE BODY     UTL$HTTP
IS
    /**
    * ============================================================================
    *                           History of changes
    * ============================================================================
    *  Date (DD/MM/YYYY) Who               Description
    * ----------------- ----------------- --------------------------------
    *  08/07/2011        Martin Mareš      Create package
    *  11/06/2012        Martin Mareš      GitHub distribution
    * ============================================================================
    */

    c_OBJECT_NAME CONSTANT UTL$DATA_TYPES.T_BIG_STRING := 'UTL$HTTP';

    FUNCTION get_status_code_message(http_status_in IN NUMBER) RETURN VARCHAR2
    IS
        l_return VARCHAR2(32767);

    BEGIN
        CASE http_status_in
            WHEN STATUS_CONTINUE THEN
                l_return := 'This means that the server has received the request headers, and that the client should proceed to send the request body (in the case of a request for which a body needs to be sent; for example, a POST request). If the request body is large, sending it to a server when a request has already been rejected based upon inappropriate headers is inefficient. To have a server check if the request could be accepted based on the request''s headers alone, a client must send Expect: 100-continue as a header in its initial request and check if a 100 Continue status code is received in response before continuing (or receive 417 Expectation Failed and not continue).';
            WHEN STATUS_SWITCHING_PROTOCOLS THEN
                l_return := 'This means the requester has asked the server to switch protocols and the server is acknowledging that it will do so.';
            WHEN STATUS_PROCESSING THEN
                l_return := 'As a WebDAV request may contain many sub-requests involving file operations, it may take a long time to complete the request. This code indicates that the server has received and is processing the request, but no response is available yet. This prevents the client from timing out and assuming the request was lost.';
            WHEN STATUS_REQUEST_URI_TOO_LONG THEN
                l_return := 'This is a non-standard IE7-only code which means the URI is longer than a maximum of 2083 characters.';
            WHEN STATUS_OK THEN
                l_return := 'Standard response for successful HTTP requests. The actual response will depend on the request method used. In a GET request, the response will contain an entity corresponding to the requested resource. In a POST request the response will contain an entity describing or containing the result of the action.';
            WHEN STATUS_CREATED THEN
                l_return := 'The request has been fulfilled and resulted in a new resource being created.';
            WHEN STATUS_ACCEPTED THEN
                l_return := 'The request has been accepted for processing, but the processing has not been completed. The request might or might not eventually be acted upon, as it might be disallowed when processing actually takes place.';
            WHEN STATUS_NON_AUTHORITATIVE_INFOR THEN
                l_return := 'The server successfully processed the request, but is returning information that may be from another source.';
            WHEN STATUS_NO_CONTENT THEN
                l_return := 'The server successfully processed the request, but is not returning any content.';
            WHEN STATUS_RESET_CONTENT THEN
                l_return := 'The server successfully processed the request, but is not returning any content. Unlike a 204 response, this response requires that the requester reset the document view.';
            WHEN STATUS_PARTIAL_CONTENT THEN
                l_return := 'The server is delivering only part of the resource due to a range header sent by the client. The range header is used by tools like wget to enable resuming of interrupted downloads, or split a download into multiple simultaneous streams.';
            WHEN STATUS_MULTI_STATUS THEN
                l_return := 'The message body that follows is an XML message and can contain a number of separate response codes, depending on how many sub-requests were made.';
            WHEN STATUS_IM_USED THEN
                l_return := 'The server has fulfilled a GET request for the resource, and the response is a representation of the result of one or more instance-manipulations applied to the current instance.';
            WHEN STATUS_MULTIPLE_CHOICES THEN
                l_return := 'Indicates multiple options for the resource that the client may follow. It, for instance, could be used to present different format options for video, list files with different extensions, or word sense disambiguation.';
            WHEN STATUS_MOVED_PERMANENTLY THEN
                l_return := 'This and all future requests should be directed to the given URI.';
            WHEN STATUS_FOUND THEN
                l_return := 'This is an example of industrial practice contradicting the standard. HTTP/1.0 specification (RFC 1945) required the client to perform a temporary redirect (the original describing phrase was "Moved Temporarily"), but popular browsers implemented 302 with the functionality of a 303 See Other. Therefore, HTTP/1.1 added status codes 303 and 307 to distinguish between the two behaviours. However, the majority of Web applications and frameworks still[as of?] use the 302 status code as if it were the 303.';
            WHEN STATUS_SEE_OTHER THEN
                l_return := 'The response to the request can be found under another URI using a GET method. When received in response to a POST (or PUT/DELETE), it should be assumed that the server has received the data and the redirect should be issued with a separate GET message.';
            WHEN STATUS_NOT_MODIFIED THEN
                l_return := 'Indicates the resource has not been modified since last requested. Typically, the HTTP client provides a header like the If-Modified-Since header to provide a time against which to compare. Using this saves bandwidth and reprocessing on both the server and client, as only the header data must be sent and received in comparison to the entirety of the page being re-processed by the server, then sent again using more bandwidth of the server and client.';
            WHEN STATUS_USE_PROXY THEN
                l_return := 'Many HTTP clients (such as Mozilla and Internet Explorer) do not correctly handle responses with this status code, primarily for security reasons.';
            WHEN STATUS_SWITCH_PROXY THEN
                l_return := 'No longer used.';
            WHEN STATUS_TEMPORARY_REDIRECT THEN
                l_return := 'In this occasion, the request should be repeated with another URI, but future requests can still use the original URI. In contrast to 303, the request method should not be changed when reissuing the original request. For instance, a POST request must be repeated using another POST request.';
            WHEN STATUS_BAD_REQUEST THEN
                l_return := 'The request cannot be fulfilled due to bad syntax.';
            WHEN STATUS_UNAUTHORIZED THEN
                l_return := 'Similar to 403 Forbidden, but specifically for use when authentication is possible but has failed or not yet been provided. The response must include a WWW-Authenticate header field containing a challenge applicable to the requested resource. See Basic access authentication and Digest access authentication.';
            WHEN STATUS_PAYMENT_REQUIRED THEN
                l_return := 'Reserved for future use. The original intention was that this code might be used as part of some form of digital cash or micropayment scheme, but that has not happened, and this code is not usually used. As an example of its use, however, Apple''s MobileMe service generates a 402 error ("httpStatusCode:402" in the Mac OS X Console log) if the MobileMe account is delinquent.';
            WHEN STATUS_FORBIDDEN THEN
                l_return := 'The request was a legal request, but the server is refusing to respond to it. Unlike a 401 Unauthorized response, authenticating will make no difference.';
            WHEN STATUS_NOT_FOUND THEN
                l_return := 'The requested resource could not be found but may be available again in the future. Subsequent requests by the client are permissible.';
            WHEN STATUS_METHOD_NOT_ALLOWED THEN
                l_return := 'A request was made of a resource using a request method not supported by that resource; for example, using GET on a form which requires data to be presented via POST, or using PUT on a read-only resource.';
            WHEN STATUS_NOT_ACCEPTABLE THEN
                l_return := 'The requested resource is only capable of generating content not acceptable according to the Accept headers sent in the request.';
            WHEN STATUS_PROXY_AUTH_REQUIRED THEN
                l_return := 'Proxy authentication required.';
            WHEN STATUS_REQUEST_TIMEOUT THEN
                l_return := 'The server timed out waiting for the request. According to W3 HTTP specifications: "The client did not produce a request within the time that the server was prepared to wait. The client MAY repeat the request without modifications at any later time."';
            WHEN STATUS_CONFLICT THEN
                l_return := 'Indicates that the request could not be processed because of conflict in the request, such as an edit conflict.';
            WHEN STATUS_GONE THEN
                l_return := 'Indicates that the resource requested is no longer available and will not be available again. This should be used when a resource has been intentionally removed and the resource should be purged. Upon receiving a 410 status code, the client should not request the resource again in the future. Clients such as search engines should remove the resource from their indices. Most use cases do not require clients and search engines to purge the resource, and a "404 Not Found" may be used instead.';
            WHEN STATUS_LENGTH_REQUIRED THEN
                l_return := 'The request did not specify the length of its content, which is required by the requested resource.';
            WHEN STATUS_PRECONDITION_FAILED THEN
                l_return := 'The server does not meet one of the preconditions that the requester put on the request.';
            WHEN STATUS_REQUEST_ENTITY_TOO_LARG THEN
                l_return := 'The request is larger than the server is willing or able to process.';
            WHEN STATUS_REQUEST_URI_TOO_LARGE THEN
                l_return := 'The URI provided was too long for the server to process.';
            WHEN STATUS_UNSUPPORTED_MEDIA_TYPE THEN
                l_return := 'The request entity has a media type which the server or resource does not support. For example, the client uploads an image as image/svg+xml, but the server requires that images use a different format.';
            WHEN STATUS_REQUESTED_RANGE_NOT_SAT THEN
                l_return := 'The client has asked for a portion of the file, but the server cannot supply that portion. For example, if the client asked for a part of the file that lies beyond the end of the file.';
            WHEN STATUS_EXPECTATION_FAILED THEN
                l_return := 'The server cannot meet the requirements of the Expect request-header field.';
            WHEN I_M_A_TEAPOT THEN
                l_return := 'This code was defined in 1998 as one of the traditional IETF April Fools'' jokes, in RFC 2324, Hyper Text Coffee Pot Control Protocol, and is not expected to be implemented by actual HTTP servers.';
            WHEN UNPROCESSABLE_ENTITY THEN
                l_return := 'The request was well-formed but was unable to be followed due to semantic errors.';
            WHEN LOCKED THEN
                l_return := 'The resource that is being accessed is locked.';
            WHEN FAILED_DEPENDENCY THEN
                l_return := 'The request failed due to failure of a previous request (e.g. a PROPPATCH).';
            WHEN UNORDERED_COLLECTION THEN
                l_return := 'Defined in drafts of "WebDAV Advanced Collections Protocol", but not present in "Web Distributed Authoring and Versioning (WebDAV) Ordered Collections Protocol".';
            WHEN UPGRADE_REQUIRED THEN
                l_return := 'The client should switch to a different protocol such as TLS/1.0.';
            WHEN NO_RESPONSE THEN
                l_return := 'A Nginx HTTP server extension. The server returns no information to the client and closes the connection (useful as a deterrent for malware).';
            WHEN RETRY_WITH THEN
                l_return := 'A Microsoft extension. The request should be retried after performing the appropriate action.';
            WHEN BLOCKED_BY_WIN_PARENT_CONTROLS THEN
                l_return := 'A Microsoft extension. This error is given when Windows Parental Controls are turned on and are blocking access to the given webpage.';
            WHEN CLIENT_CLOSED_REQUEST THEN
                l_return := 'An Nginx HTTP server extension. This code is introduced to log the case when the connection is closed by client while HTTP server is processing its request, making server unable to send the HTTP header back.';
            WHEN STATUS_INTERNAL_SERVER_ERROR THEN
                l_return := 'A generic error message, given when no more specific message is suitable.';
            WHEN STATUS_NOT_IMPLEMENTED THEN
                l_return := 'The server either does not recognise the request method, or it lacks the ability to fulfill the request.';
            WHEN STATUS_BAD_GATEWAY THEN
                l_return := 'The server was acting as a gateway or proxy and received an invalid response from the upstream server.';
            WHEN STATUS_SERVICE_UNAVAILABLE THEN
                l_return := 'The server is currently unavailable (because it is overloaded or down for maintenance). Generally, this is a temporary state.';
            WHEN STATUS_GATEWAY_TIMEOUT THEN
                l_return := 'The server was acting as a gateway or proxy and did not receive a timely response from the upstream server.';
            WHEN STATUS_VERSION_NOT_SUPPORT THEN
                l_return := 'The server does not support the HTTP protocol version used in the request.';
            WHEN STATUS_VARIANT_ALSO_NEGOTIATES THEN
                l_return := 'Transparent content negotiation for the request results in a circular reference.';
            WHEN STATUS_INSUFFICIENT_STORAGE THEN
                l_return := 'Insufficient storage.';
            WHEN STATUS_BANDWIDTH_LIMIT_EXCEED THEN
                l_return := 'This status code, while used by many servers, is not specified in any RFCs.';
            WHEN STATUS_NOT_EXTENDED THEN
                l_return := 'Further extensions to the request are required for the server to fulfill it.';
        END CASE;

        RETURN l_return;
    END get_status_code_message;

END UTL$HTTP;

/
