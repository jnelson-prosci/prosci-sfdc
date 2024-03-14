/**
 * @author CloudMasonry
 * @date 2021
 * @group Test
 * @description generic HttpCalloutMock class implementation
 *              allowing variable setting of status code for
 *              testing web service results and fored
 *              exceptions for testing catch blocks
 */
@isTest
public class PushToBcGenericMock implements HttpCalloutMock {

    Integer statusCode;
    Boolean throwMockException;

    public PushToBcGenericMock(Integer statusCode){
        this.statusCode = statusCode;
        this.throwMockException = false;
    }

    public PushToBcGenericMock forceMockException(){
        this.throwMockException = true;
        return this;
    }
   
    public HTTPResponse respond(HTTPRequest request) {
        if (throwMockException) {
            throw new MockException();
        }
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setBody('{}');
        return response;

    }

    public class MockException extends Exception {}

}