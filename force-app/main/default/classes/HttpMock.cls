@isTest
global class HttpMock implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;
 
    public HttpMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }

    global HTTPResponse respond(HTTPRequest req) {
        system.debug(req.getEndpoint());
        system.debug(requests.keySet());
        HttpCalloutMock mock = requests.get(req.getEndpoint());
        if (mock != null) {
            requests.remove(req.getEndpoint());
            return mock.respond(req);
        }else {
            system.debug(req.getEndpoint());
             mock = requests.get(req.getEndpoint() + 'second');
            if(mock != null){
                return mock.respond(req);
            }else {
                throw new DMLException('Excepion Thrown HTTP callout not supported for test methods ');
            }
        }
    }

    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }

}