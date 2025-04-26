import Foundation
import Testing
@testable import InfrastructureNetwork

typealias Factory = NetworkProviderFactory

@Suite("NetworkProviderImplementations Tests")
struct NetworkProviderImplementationTests {
        @Suite("NetworkProviderImplementation Request Data Tests")
        struct NetworkProviderImplementationRequestDataTests {
                @Suite("Error Handling")
                struct ErrorHandlingTests {
                        @Test(
                                "When network session throws HTTPURLResponse with status code, it maps to expected error",
                                arguments: [
                                        (HTTPURLResponse.fixture(statusCode: 403), NetworkProviderError.unauthorized),
                                        (HTTPURLResponse.fixture(statusCode: 404), NetworkProviderError.notFound),
                                        (HTTPURLResponse.fixture(statusCode: 408), NetworkProviderError.timeout),
                                        (HTTPURLResponse.fixture(statusCode: 499), NetworkProviderError.invalidRequest),
                                        (HTTPURLResponse.fixture(statusCode: 599), NetworkProviderError.serverError),
                                        (HTTPURLResponse.fixture(statusCode: 1000), NetworkProviderError.other),
                                ]
                        )
                        func testErrorMapping(
                                returnURLResponse: HTTPURLResponse,
                                expectedError: NetworkProviderError
                        ) async {
                                // Given
                                let sut = Factory.createWithSpy(
                                        dataToReturn: Data(),
                                        urlResponseToReturn: returnURLResponse
                                )
                                
                                do {
                                        // When
                                        let _ = try await sut.requestData(.getEndpoint)
                                        Issue.record("Expected \(expectedError.testDescription), got success instead.")
                                } catch {
                                        // Then
                                        #expect(error == expectedError)
                                }
                        }
                        
                        @Test("When network sessions throws not connected to internet, network provider throws no network connection")
                        func testNoNetworkConnection() async {
                                // Given
                                let sut = Factory.createWithSpy(errorToThrow: URLError(.notConnectedToInternet))
                                
                                do {
                                        // When
                                        let _ = try await sut.requestData(.getEndpoint)
                                        Issue.record("Expected \(NetworkProviderError.noNetworkConnection.testDescription), got success instead.")
                                } catch {
                                        // Then
                                        #expect(error == NetworkProviderError.noNetworkConnection)
                                }
                        }
                        
                        @Test("When network sesions throws other error, network provider throws other error")
                        func testOtherError() async {
                                // Given
                                let expectedError = NetworkProviderError.other
                                let sut = Factory.createWithSpy(errorToThrow: expectedError)
                                
                                do {
                                        // When
                                        let _: StubInstance1 = try await sut.request(.getEndpoint)
                                        Issue.record("Expected \(NetworkProviderError.other.localizedDescription), got success instead.")
                                } catch {
                                        // Then
                                        #expect(error == expectedError)
                                }
                        }
                        
                        @Test("When API returns non HTTP response, network provider throws same error")
                        func testNonHTTPResponse() async {
                                // Given
                                let sut = Factory.createWithSpy(
                                        dataToReturn: Data(),
                                        urlResponseToReturn: URLResponse()
                                )
                                
                                do {
                                        // When
                                        let _ = try await sut.requestData(.getEndpoint)
                                        Issue.record("Expected \(NetworkProviderError.nonHTTResponse.testDescription), got success instead.")
                                } catch {
                                        // Then
                                        #expect(error == NetworkProviderError.nonHTTResponse)
                                }
                        }
                        
                        @Test("When API response is in range 200...299 and no data is returned, network provider throws no data")
                        func test200RangeNoData() async {
                                // Given
                                let sut = Factory.createWithSpy(dataToReturn: Data())
                                
                                do {
                                        // When
                                        let _ = try await sut.requestData(.getEndpoint)
                                        Issue.record("Expected \(NetworkProviderError.noData.testDescription), got success instead.")
                                } catch {
                                        // Then
                                        #expect(error == NetworkProviderError.noData)
                                }
                        }
                        
                        @Test("When URL is invalid, network provider throws same error")
                        func testInvalidURL() async {
                                // Given
                                let sut = Factory.createWithFake()
                                
                                do {
                                        // When
                                        let _ = try await sut.requestData(.invalidURLEndpoint)
                                        Issue.record("Expected \(NetworkProviderError.invalidURL.testDescription) thrown, got success instead.")
                                } catch {
                                        // Then
                                        #expect(error == NetworkProviderError.invalidURL)
                                }
                        }
                }
                
                @Suite("Processing")
                struct ProcessingTests {
                        @Test("When network provider makes several requests, it uses the same network session instance")
                        func testSameNetworkSessionInstance() async {
                                // Given
                                let endpoint = StubEndpoint.getEndpoint
                                let spy = NetworkSessionSpy.fixture()
                                let sut = Factory.create(with: spy)
                                
                                do {
                                        // When
                                        let _ = try await sut.requestData(endpoint)
                                        let _ = try await sut.requestData(endpoint)
                                        let _ = try await sut.requestData(endpoint)
                                        
                                        // Then
                                        #expect(spy.dataForRequestMethodWasCalledXTimes == 3)
                                } catch let error {
                                        Issue.record("Expected success, got \(error) instead.")
                                }
                        }
                        
                        @Test("When endpoint body is plain, request must not have body or parameters")
                        func testPlainEndpointBody() async {
                                // Given
                                let endpoint = StubEndpoint.getEndpoint
                                let spy = NetworkSessionSpy.fixture()
                                let sut = Factory.create(with: spy)
                                
                                do {
                                        // When
                                        let _ = try await sut.requestData(endpoint)
                                        let receivedURLRequest = spy.receivedURLRequest
                                        #expect(receivedURLRequest?.url?.path() == endpoint.path)
                                        #expect(receivedURLRequest?.httpBody == nil)
                                        #expect(receivedURLRequest?.value(forHTTPHeaderField: HTTPHeader.Key.contentType) == nil)
                                } catch {
                                        Issue.record("Expected success, got \(error) instead.")
                                }
                        }
                        
                        @Test("When endpoint body is encodable, request has JSON headers and body")
                        func testEncodableBody() async {
                                // Given
                                let spy = NetworkSessionSpy.fixture()
                                let sut = Factory.create(with: spy)
                                let request = StubRequest.fixture()
                                let endpoint = StubEndpoint.encodableBodyEndpoint(request)
                                
                                do {
                                        // When
                                        let _ = try await sut.requestData(endpoint)
                                        
                                        // Then
                                        let receivedURLRequest = spy.receivedURLRequest
                                        #expect(receivedURLRequest?.url?.path() == endpoint.path)
                                        
                                        if let receivedHTTPBody = receivedURLRequest?.httpBody {
                                                if let receivedBody = try? JSONDecoder().decode(StubRequest.self, from: receivedHTTPBody) {
                                                        #expect(receivedBody == request)
                                                } else {
                                                        Issue.record("Failed to decode HTTPBody into ValidEncodableRequest.")
                                                }
                                        } else {
                                                Issue.record("Expected HTTPBody, got nil instead.")
                                        }
                                        
                                        #expect(receivedURLRequest?.value(forHTTPHeaderField: HTTPHeader.Key.contentType) == HTTPHeader.Value.applicationJSON)
                                } catch {
                                        Issue.record("Expected success, got \(error) instead.")
                                }
                        }
                        
                        @Test("When endpoint body is query parameter, request has correct query items")
                        func testQueryParameter() async {
                                // Given
                                let queryItemSorting: (URLQueryItem, URLQueryItem) -> Bool = { $0.name < $1.name }
                                let queryParameters: [String: String?] = [
                                        "string": "string",
                                        "int": "1",
                                        "double": "1.0",
                                        "float": "1.0",
                                        "parameterWithNoValue": nil,
                                ]
                                let expectedQueryParameters = queryParameters
                                        .map(URLQueryItem.init)
                                        .sorted(by: queryItemSorting)
                                let spy = NetworkSessionSpy.fixture()
                                let sut = Factory.create(with: spy)
                                
                                do {
                                        // When
                                        let _  = try await sut.requestData(StubEndpoint.queryParametersEndpoint(queryParameters))
                                        
                                        if let receivedURLRequest = spy.receivedURLRequest {
                                                // Then
                                                let receivedQueryParameters = TestHelper
                                                        .getQueryItems(from: receivedURLRequest)
                                                        .sorted(by: queryItemSorting)
                                                #expect(receivedQueryParameters == expectedQueryParameters)
                                        } else {
                                                Issue.record("Expected URLRequest, got nil instead.")
                                        }
                                } catch {
                                        Issue.record("doesn't matter error \(error)")
                                }
                        }
                        
                        @Test("When endpoint has custom headers, request has correct headers")
                        func testHeaders() async {
                                // Given
                                let queryParameters: [String: String?] = [
                                        "query": "value"
                                ]
                                let expectedHeaders = StubEndpoint.queryParametersEndpoint(queryParameters).headers
                                let spy = NetworkSessionSpy.fixture()
                                let sut = Factory.create(with: spy)
                                
                                do {
                                        // When
                                        let _ = try await sut.requestData(.queryParametersEndpoint(queryParameters))
                                        
                                        // Then
                                        let receivedURLRequest = spy.receivedURLRequest
                                        #expect(receivedURLRequest?.allHTTPHeaderFields == expectedHeaders)
                                } catch {
                                        Issue.record("Expected success, got error \(error) instead.")
                                }
                        }
                        
                        @Test("When endpoint has custom path, request has correct path")
                        func testCustomPath() async {
                                // Given
                                let queryParameters: [String: String?] = [
                                        "key": "value"
                                ]
                                let endpoint = StubEndpoint.queryParametersEndpoint(queryParameters)
                                let spy = NetworkSessionSpy.fixture()
                                let sut = Factory.create(with: spy)
                                
                                do {
                                        // When
                                        let _ = try await sut.requestData(endpoint)
                                        
                                        // Then
                                        let receivedURLRequest = spy.receivedURLRequest
                                        #expect(receivedURLRequest?.url?.path() == endpoint.path)
                                } catch {
                                        Issue.record("Expected success, got error \(error) instead.")
                                }
                        }
                        
                        @Test("Network Provider sets correct HTTP method from endpoint in URL request")
                        func testHTTPMethod() async {
                                // Given
                                let spy = NetworkSessionSpy.fixture()
                                let sut = Factory.create(with: spy)
                                
                                do {
                                        // When
                                        let _ = try await sut.requestData(StubEndpoint.getEndpoint)
                                        let receivedGetURLRequest = spy.receivedURLRequest
                                        let _ = try await sut.requestData(StubEndpoint.postEndpoint)
                                        let receivedPostURLRequest = spy.receivedURLRequest
                                        
                                        // Then
                                        #expect(receivedGetURLRequest?.httpMethod == HTTPMethod.get.rawValue)
                                        #expect(receivedPostURLRequest?.httpMethod == HTTPMethod.post.rawValue)
                                } catch {
                                        Issue.record("Expected success, got error \(error) instead.")
                                }
                        }
                        
                        @Test("When API response is in range 200...299 and data is returned, network provider returns data payload")
                        func testSuccessfulData() async {
                                let payload = "Hello".data(using: .utf8)!
                                let sut = Factory.createWithSpy(
                                        dataToReturn: payload,
                                        urlResponseToReturn: HTTPURLResponse.fixture(statusCode: 200)
                                )
                                
                                do {
                                        let data = try await sut.requestData(.getEndpoint)
                                        #expect(data == payload)
                                } catch {
                                        Issue.record("Expected payload, got error \(error)")
                                }
                        }
                }
        }
        
        @Suite("NetworkProviderImplementation Request Tests")
        struct NetworkProviderImplementationRequestTests {
                @Suite("Error Handling")
                struct ErrorHandlingTests {
                        @Test(
                                "When network session throws HTTPURLResponse with status code, it maps to expected error",
                                arguments: [
                                        (HTTPURLResponse.fixture(statusCode: 403), NetworkProviderError.unauthorized),
                                        (HTTPURLResponse.fixture(statusCode: 404), NetworkProviderError.notFound),
                                        (HTTPURLResponse.fixture(statusCode: 408), NetworkProviderError.timeout),
                                        (HTTPURLResponse.fixture(statusCode: 499), NetworkProviderError.invalidRequest),
                                        (HTTPURLResponse.fixture(statusCode: 599), NetworkProviderError.serverError),
                                        (HTTPURLResponse.fixture(statusCode: 1000), NetworkProviderError.other),
                                ]
                        )
                        func testErrorMapping(
                                returnURLResponse: HTTPURLResponse,
                                expectedError: NetworkProviderError
                        ) async {
                                // Given
                                let sut = Factory.createWithSpy(
                                        dataToReturn: Data(),
                                        urlResponseToReturn: returnURLResponse
                                )
                                
                                do {
                                        // When
                                        let _: StubInstance1 = try await sut.request(.getEndpoint)
                                        Issue.record("Expected \(expectedError.testDescription), got success instead.")
                                } catch {
                                        // Then
                                        #expect(error == expectedError)
                                }
                        }
                        
                        @Test("When decoding fails, network provider throws parsing error")
                        func testFailDecoding() async {
                                // Given
                                let sut = Factory.createWithSpy()
                                
                                do {
                                        // When
                                        let _: StubInstance2 = try await sut.request(.getEndpoint)
                                        Issue.record("Expected \(NetworkProviderError.parsingError.testDescription), got success instead.")
                                } catch {
                                        // Then
                                        #expect(error == NetworkProviderError.parsingError)
                                }
                        }
                        
                        @Test("When network sessions throws not connected to internet, network provider throws no network connection")
                        func testNoNetworkConnection() async {
                                // Given
                                let sut = Factory.createWithSpy(errorToThrow: URLError(.notConnectedToInternet))
                                
                                do {
                                        // When
                                        let _: StubInstance1 = try await sut.request(.getEndpoint)
                                        Issue.record("Expected \(NetworkProviderError.noNetworkConnection.testDescription), got success instead.")
                                } catch {
                                        // Then
                                        #expect(error == NetworkProviderError.noNetworkConnection)
                                }
                        }
                        
                        @Test("When network sesions throws other error, network provider throws other error")
                        func testOtherError() async {
                                // Given
                                let expectedError = NetworkProviderError.other
                                let sut = Factory.createWithSpy(errorToThrow: expectedError)
                                
                                do {
                                        // When
                                        let _: StubInstance1 = try await sut.request(.getEndpoint)
                                        Issue.record("Expected \(NetworkProviderError.other.localizedDescription), got success instead.")
                                } catch {
                                        // Then
                                        #expect(error == expectedError)
                                }
                        }
                        
                        @Test("When API returns non HTTP response, network provider throws same error")
                        func testNonHTTPResponse() async {
                                // Given
                                let sut = Factory.createWithSpy(
                                        dataToReturn: Data(),
                                        urlResponseToReturn: URLResponse()
                                )
                                
                                do {
                                        // When
                                        let _: StubInstance1 = try await sut.request(.getEndpoint)
                                        Issue.record("Expected \(NetworkProviderError.nonHTTResponse.testDescription), got success instead.")
                                } catch {
                                        // Then
                                        #expect(error == NetworkProviderError.nonHTTResponse)
                                }
                        }
                        
                        @Test("When API response is in range 200...299 and no data is returned, network provider throws no data")
                        func test200RangeNoData() async {
                                // Given
                                let sut = Factory.createWithSpy(dataToReturn: Data())
                                
                                do {
                                        // When
                                        let _: StubInstance1 = try await sut.request(.getEndpoint)
                                        Issue.record("Expected \(NetworkProviderError.noData.testDescription), got success instead.")
                                } catch {
                                        // Then
                                        #expect(error == NetworkProviderError.noData)
                                }
                        }
                        
                        @Test("When URL is invalid, network provider throws same error")
                        func testInvalidURL() async {
                                // Given
                                let sut = Factory.createWithFake()
                                
                                do {
                                        // When
                                        let _: StubInstance1 = try await sut.request(.invalidURLEndpoint)
                                        Issue.record("Expected \(NetworkProviderError.invalidURL.testDescription) thrown, got success instead.")
                                } catch {
                                        // Then
                                        #expect(error == NetworkProviderError.invalidURL)
                                }
                        }
                }
                
                @Suite("Processing")
                struct ProcessingTests {
                        @Test("When network provider makes several requests, it uses the same network session instance")
                        func testSameNetworkSessionInstance() async {
                                // Given
                                let endpoint = StubEndpoint.getEndpoint
                                let spy = NetworkSessionSpy.fixture()
                                let sut = Factory.create(with: spy)
                                
                                do {
                                        // When
                                        let _: StubInstance1 = try await sut.request(endpoint)
                                        let _: StubInstance1 = try await sut.request(endpoint)
                                        let _: StubInstance1 = try await sut.request(endpoint)
                                        
                                        // Then
                                        #expect(spy.dataForRequestMethodWasCalledXTimes == 3)
                                } catch let error {
                                        Issue.record("Expected success, got \(error) instead.")
                                }
                        }
                        
                        @Test("When endpoint body is plain, request must not have body or parameters")
                        func testPlainEndpointBody() async {
                                // Given
                                let endpoint = StubEndpoint.getEndpoint
                                let spy = NetworkSessionSpy.fixture()
                                let sut = Factory.create(with: spy)
                                
                                do {
                                        // When
                                        let _: StubInstance1 = try await sut.request(endpoint)
                                        let receivedURLRequest = spy.receivedURLRequest
                                        #expect(receivedURLRequest?.url?.path() == endpoint.path)
                                        #expect(receivedURLRequest?.httpBody == nil)
                                        #expect(receivedURLRequest?.value(forHTTPHeaderField: HTTPHeader.Key.contentType) == nil)
                                } catch {
                                        Issue.record("Expected success, got \(error) instead.")
                                }
                        }
                        
                        @Test("When endpoint body is encodable, request has JSON headers and body")
                        func testEncodableBody() async {
                                // Given
                                let spy = NetworkSessionSpy.fixture()
                                let sut = Factory.create(with: spy)
                                let encodableRequest = StubRequest.fixture()
                                let endpoint = StubEndpoint.encodableBodyEndpoint(encodableRequest)
                                
                                do {
                                        // When
                                        let _: StubInstance1 = try await sut.request(endpoint)
                                        
                                        // Then
                                        let receivedURLRequest = spy.receivedURLRequest
                                        #expect(receivedURLRequest?.url?.path() == endpoint.path)
                                        
                                        if let receivedHTTPBody = receivedURLRequest?.httpBody {
                                                if let receivedBody = try? JSONDecoder().decode(StubRequest.self, from: receivedHTTPBody) {
                                                        #expect(receivedBody == encodableRequest)
                                                } else {
                                                        Issue.record("Failed to decode HTTPBody into ValidEncodableRequest.")
                                                }
                                        } else {
                                                Issue.record("Expected HTTPBody, got nil instead.")
                                        }
                                        
                                        #expect(receivedURLRequest?.value(forHTTPHeaderField: HTTPHeader.Key.contentType) == HTTPHeader.Value.applicationJSON)
                                } catch {
                                        Issue.record("Expected success, got \(error) instead.")
                                }
                        }
                        
                        @Test("When endpoint body is query parameter, request has correct query items")
                        func testQueryParameter() async {
                                // Given
                                let queryItemSorting: (URLQueryItem, URLQueryItem) -> Bool = { $0.name < $1.name }
                                let queryParameters: [String: String?] = [
                                        "string": "string",
                                        "int": "1",
                                        "double": "1.0",
                                        "float": "1.0",
                                        "parameterWithNoValue": nil,
                                ]
                                let expectedQueryParameters = queryParameters
                                        .map(URLQueryItem.init)
                                        .sorted(by: queryItemSorting)
                                let spy = NetworkSessionSpy.fixture()
                                let sut = Factory.create(with: spy)
                                
                                do {
                                        // When
                                        let _: StubInstance1 = try await sut.request(.queryParametersEndpoint(queryParameters))
                                        
                                        if let receivedURLRequest = spy.receivedURLRequest {
                                                // Then
                                                let receivedQueryParameters = TestHelper
                                                        .getQueryItems(from: receivedURLRequest)
                                                        .sorted(by: queryItemSorting)
                                                #expect(receivedQueryParameters == expectedQueryParameters)
                                        } else {
                                                Issue.record("Expected URLRequest, got nil instead.")
                                        }
                                } catch {
                                        Issue.record("doesn't matter error \(error)")
                                }
                        }
                        
                        @Test("When endpoint has custom headers, request has correct headers")
                        func testHeaders() async {
                                // Given
                                let queryParameters: [String: String?] = [
                                        "query": "value"
                                ]
                                let expectedHeaders = StubEndpoint.queryParametersEndpoint(queryParameters).headers
                                let spy = NetworkSessionSpy.fixture()
                                let sut = Factory.create(with: spy)
                                
                                do {
                                        // When
                                        let _: StubInstance1 = try await sut.request(.queryParametersEndpoint(queryParameters))
                                        
                                        // Then
                                        let receivedURLRequest = spy.receivedURLRequest
                                        #expect(receivedURLRequest?.allHTTPHeaderFields == expectedHeaders)
                                } catch {
                                        Issue.record("Expected success, got error \(error) instead.")
                                }
                        }
                        
                        @Test("When endpoint has custom path, request has correct path")
                        func testCustomPath() async {
                                // Given
                                let queryParameters: [String: String?] = [
                                        "key": "value"
                                ]
                                let endpoint = StubEndpoint.queryParametersEndpoint(queryParameters)
                                let spy = NetworkSessionSpy.fixture()
                                let sut = Factory.create(with: spy)
                                
                                do {
                                        // When
                                        let _: StubInstance1 = try await sut.request(endpoint)
                                        
                                        // Then
                                        let receivedURLRequest = spy.receivedURLRequest
                                        #expect(receivedURLRequest?.url?.path() == endpoint.path)
                                } catch {
                                        Issue.record("Expected success, got error \(error) instead.")
                                }
                        }
                        
                        @Test("Network Provider sets correct HTTP method from endpoint in URL request")
                        func testHTTPMethod() async {
                                // Given
                                let spy = NetworkSessionSpy.fixture()
                                let sut = Factory.create(with: spy)
                                
                                do {
                                        // When
                                        let _: StubInstance1 = try await sut.request(.getEndpoint)
                                        let receivedGetURLRequest = spy.receivedURLRequest
                                        let _: StubInstance1 = try await sut.request(.postEndpoint)
                                        let receivedPostURLRequest = spy.receivedURLRequest
                                        
                                        // Then
                                        #expect(receivedGetURLRequest?.httpMethod == HTTPMethod.get.rawValue)
                                        #expect(receivedPostURLRequest?.httpMethod == HTTPMethod.post.rawValue)
                                } catch {
                                        Issue.record("Expected success, got error \(error) instead.")
                                }
                        }
                        
                        @Test("Network provider decodes expected response")
                        func testDecodeResponse() async {
                                // Given
                                let expectedInstance = StubInstance1.fixture()
                                let sut = Factory.create(with: .fixture())
                                
                                do {
                                        // When
                                        let receivedInstance: StubInstance1 = try await sut.request(StubEndpoint.getEndpoint)
                                        
                                        // Then
                                        #expect(receivedInstance == expectedInstance)
                                } catch {
                                        Issue.record("Expected success, got error \(error) instead.")
                                }
                        }
                }
        }
}
