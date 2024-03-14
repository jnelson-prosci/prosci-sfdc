/**
 * Generic Test Mock Class
 */
@isTest
public with sharing class TestUtils_TestMock implements StubProvider {

    Map<String, Object> mapMethodReturns;
    // set true to throw exception and help test catch blocks
    private Boolean forceException = false;
    private String forceExceptionStubbedMethodName;

    public TestUtils_TestMock(){}

    public TestUtils_TestMock(Map<String, Object> mapMethodReturns){
        this.mapMethodReturns = mapMethodReturns;
    }

    /**
     * Method to rig mocked class to throw exception for testing catch blocks
     * @param  stubbedMethodName method invocation to force exception
     * @return                   return this class instance
     */
    public TestUtils_TestMock forceException(String stubbedMethodName){
        this.forceException = true;
        this.forceExceptionStubbedMethodName = stubbedMethodName;
        return this;
    }

    public Object handleMethodCall(Object stubbedObject, String stubbedMethodName
        , Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames
        , List<Object> listOfArgs) {

        if(this.forceException && this.forceExceptionStubbedMethodName == stubbedMethodName){
            throw new TestMockException();
        }

        if(mapMethodReturns != null){
            return mapMethodReturns.get(stubbedMethodName);
        }

        return null;
    }

    public class TestMockException extends Exception {}
}