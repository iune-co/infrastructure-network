import XCTest

@testable import InfrastructureNetwork

final class NetworkProviderImplementationTests: XCTestCase {
        // MARK: - Test cases
        func test_whenDecodingFails_networkProviderThrowsNetworkErrorParsingError() async {
                // Given
                let sut = NetworkProviderImplementation(networkSession: NetworkSessionSpy.fixture())

                do {
                        // When
                        let _: StubInstance2 = try await sut.request(StubEndpoint.getEndpoint)
                        XCTFail("Expected NetworkError.parsingError, got success instead.")
                } catch let errorThrown as NetworkProviderError {
                        // Then
                        XCTAssertEqual(
                                errorThrown,
                                NetworkProviderError.parsingError
                        )
                } catch {
                        XCTFail("Expected NetworkError.parsingError, got error \(error) instead.")
                }
        }

        func test_whenNetworkSessionThrowsNotConnectedToInternet_networkProviderThrowsNoNetworkConnection() async {
                // Given
                let networkSessionSpy = NetworkSessionSpy(errorToThrow: URLError(.notConnectedToInternet))
                let networkProvider = NetworkProviderImplementation(networkSession: networkSessionSpy)

                do {
                        // When
                        let _: StubInstance1 = try await networkProvider.request(StubEndpoint.getEndpoint)
                        XCTFail("Expected NetworkError.noNetworkConnection, got success instead.")
                } catch let error as NetworkProviderError {
                        // Then
                        XCTAssertEqual(
                                error,
                                NetworkProviderError.noNetworkConnection
                        )
                } catch let error {
                        XCTFail("Expected NetworkError.noNetworkConnection, got \(error) instead.")
                }
        }

        func test_whenNetworkSessionThrowsNonHandledError_networkProviderThrowsSameError() async {
                // Given
                let expectedError = NetworkTestError.someError
                let networkSessionSpy = NetworkSessionSpy(errorToThrow: expectedError)
                let networkProvider = NetworkProviderImplementation(networkSession: networkSessionSpy)

                do {
                        // When
                        let _: StubInstance1 = try await networkProvider.request(StubEndpoint.getEndpoint)
                        XCTFail("Expected NetworkTestError.someError, got success instead.")
                } catch let error as NetworkTestError {
                        // Then
                        XCTAssertEqual(
                                error,
                                expectedError
                        )
                } catch let error {
                        XCTFail("Expected NetworkTestError.someError, got \(error) instead.")
                }
        }

        func test_whenAPIRespondsNonHandledStatusCode_networkProviderThrowsNetworkErrorOther() async {
                // Given
                let networkSessionSpy = NetworkSessionSpy(
                        dataToReturn: Data(),
                        urlResponseToReturn: HTTPURLResponse.fixture(statusCode: 1000)
                )
                let sut = NetworkProviderImplementation(networkSession: networkSessionSpy)

                do {
                        // When
                        let _: StubInstance1 = try await sut.request(StubEndpoint.getEndpoint)
                        XCTFail("Expected NetworkError.other, got success instead.")
                } catch let errorThrown as NetworkProviderError {
                        // Then
                        XCTAssertEqual(
                                errorThrown,
                                NetworkProviderError.other
                        )
                } catch {
                        XCTFail("Expected NetworkError.other, got error \(error) instead.")
                }
        }

        func test_whenAPIRespondsNonHTTPResponse_networkProviderThrowsNetworkErrorNonHTTPResponse() async {
                // Given
                let networkSessionSpy = NetworkSessionSpy(
                        dataToReturn: Data(),
                        urlResponseToReturn: URLResponse()
                )
                let sut = NetworkProviderImplementation(networkSession: networkSessionSpy)

                do {
                        // When
                        let _: StubInstance1 = try await sut.request(StubEndpoint.getEndpoint)
                        XCTFail("Expected NetworkError.nonHTTResponse, got success instead.")
                } catch let errorThrown as NetworkProviderError {
                        // Then
                        XCTAssertEqual(
                                errorThrown,
                                NetworkProviderError.nonHTTResponse
                        )
                } catch {
                        XCTFail("Expected NetworkError.nonHTTResponse, got error \(error) instead.")
                }
        }

        func test_whenAPIResponds403_networkProviderThrowsNetworkErrorUnauthorized() async {
                // Given
                let networkSessionSpy = NetworkSessionSpy.fixture(urlResponseToReturn: HTTPURLResponse.fixture(statusCode: 403))
                let sut = NetworkProviderImplementation(networkSession: networkSessionSpy)

                do {
                        // When
                        let _: StubInstance1 = try await sut.request(StubEndpoint.getEndpoint)
                        XCTFail("Expected NetworkError.unauthorized, got success instead.")
                } catch let errorThrown as NetworkProviderError {
                        // Then
                        XCTAssertEqual(
                                errorThrown,
                                NetworkProviderError.unauthorized
                        )
                } catch {
                        XCTFail("Expected NetworkError.unauthorized, got error \(error) instead.")
                }
        }

        func test_whenAPIResponds404_networkProviderThrowsNetworkErrorNotFound() async {
                // Given
                let networkSessionSpy = NetworkSessionSpy.fixture(urlResponseToReturn: HTTPURLResponse.fixture(statusCode: 404))
                let sut = NetworkProviderImplementation(networkSession: networkSessionSpy)

                do {
                        // When
                        let _: StubInstance1 = try await sut.request(StubEndpoint.getEndpoint)
                        XCTFail("Expected NetworkError.notFound, got success instead.")
                } catch let errorThrown as NetworkProviderError {
                        // Then
                        XCTAssertEqual(
                                errorThrown,
                                NetworkProviderError.notFound
                        )
                } catch {
                        XCTFail("Expected NetworkError.notFound, got error \(error) instead.")
                }
        }

        func test_whenAPIResponds408OrTimeout_networkProviderThrowsNetworkErrorTimeout() async {
                // Given
                let networkSessionSpy = NetworkSessionSpy.fixture(urlResponseToReturn: HTTPURLResponse.fixture(statusCode: 408))
                let sut = NetworkProviderImplementation(networkSession: networkSessionSpy)

                do {
                        // When
                        let _: StubInstance1 = try await sut.request(StubEndpoint.getEndpoint)
                        XCTFail("Expected NetworkError.timeout, got success instead.")
                } catch let errorThrown as NetworkProviderError {
                        // Then
                        XCTAssertEqual(
                                errorThrown,
                                NetworkProviderError.timeout
                        )
                } catch {
                        XCTFail("Expected NetworkError.timeout, got error \(error) instead.")
                }
        }

        func test_whenAPIRespondsRange400499_networkProviderThrowsNetworkErrorInvalidRequest() async {
                // Given
                let networkSessionSpy = NetworkSessionSpy.fixture(urlResponseToReturn: HTTPURLResponse.fixture(statusCode: 499))
                let sut = NetworkProviderImplementation(networkSession: networkSessionSpy)

                do {
                        // When
                        let _: StubInstance1 = try await sut.request(StubEndpoint.getEndpoint)
                        XCTFail("Expected NetworkError.invalidRequest, got success instead.")
                } catch let errorThrown as NetworkProviderError {
                        // Then
                        XCTAssertEqual(
                                errorThrown,
                                NetworkProviderError.invalidRequest
                        )
                } catch {
                        XCTFail("Expected NetworkError.invalidRequest, got error \(error) instead.")
                }
        }

        func test_whenAPIRespondsRange500599_networkProviderThrowsNetworkErrorServerError() async {
                // Given
                let networkSessionSpy = NetworkSessionSpy.fixture(urlResponseToReturn: HTTPURLResponse.fixture(statusCode: 599))
                let sut = NetworkProviderImplementation(networkSession: networkSessionSpy)

                do {
                        // When
                        let _: StubInstance1 = try await sut.request(StubEndpoint.getEndpoint)
                        XCTFail("Expected NetworkError.serverError, got success instead.")
                } catch let errorThrown as NetworkProviderError {
                        // Then
                        XCTAssertEqual(
                                errorThrown,
                                NetworkProviderError.serverError
                        )
                } catch {
                        XCTFail("Expected NetworkError.serverError, got error \(error) instead.")
                }
        }

        func test_whenAPIRespondsRange200299AndNoData_networkProviderThrowsNetworkErrorNoData() async {
                // Given
                let networkSessionSpy = NetworkSessionSpy.fixture(dataToReturn: Data())
                let sut = NetworkProviderImplementation(networkSession: networkSessionSpy)

                do {
                        // When
                        let _: StubInstance1 = try await sut.request(StubEndpoint.getEndpoint)
                        XCTFail("Expected NetworkError.noData, got success instead.")
                } catch let errorThrown as NetworkProviderError {
                        // Then
                        XCTAssertEqual(
                                errorThrown,
                                NetworkProviderError.noData
                        )
                } catch {
                        XCTFail("Expected NetworkError.noData, got error \(error) instead.")
                }
        }

        func test_whenURLIsInvalid_providerThrowsNetworkErrorInvalidURL() async {
                // Given
                let networkProvider = NetworkProviderImplementation(networkSession: NetworkSessionFake())

                do {
                        // When
                        let _: StubInstance1 = try await networkProvider.request(StubEndpoint.invalidURLEndpoint)
                        XCTFail("Expected NetworkError.invalidURL thrown, got success instead.")
                } catch let errorThrown as NetworkProviderError {
                        // Then
                        XCTAssertEqual(
                                errorThrown,
                                NetworkProviderError.invalidURL
                        )
                } catch let error {
                        XCTFail("Expected NetworkError.invalidURL, got error \(error) instead.")
                }
        }

        func test_whenProviderMakesSeveralRequests_usesTheSameNetworkSessionInstance() async {
                // Given
                let endpoint = StubEndpoint.getEndpoint
                let networkSessionSpy = NetworkSessionSpy.fixture()
                let networkProvider = NetworkProviderImplementation(networkSession: networkSessionSpy)

                do {
                        // When
                        let _: StubInstance1 = try await networkProvider.request(endpoint)
                        let _: StubInstance1 = try await networkProvider.request(endpoint)
                        let _: StubInstance1 = try await networkProvider.request(endpoint)

                        // Then
                        XCTAssertEqual(
                                networkSessionSpy.dataForRequestMethodWasCalledXTimes,
                                3
                        )
                } catch let error {
                        XCTFail("Expected success, got \(error) instead.")
                }
        }

        func test_whenEndpointBodyIsPlain_requestMustNotHaveBodyOrParameters() async {
                // Given
                let endpoint = StubEndpoint.getEndpoint
                let networkSessionSpy = NetworkSessionSpy.fixture()
                let sut = NetworkProviderImplementation(networkSession: networkSessionSpy)

                do {
                        // When
                        let _: StubInstance1 = try await sut.request(endpoint)
                        let receivedURLRequest = networkSessionSpy.receivedURLRequest
                        XCTAssertEqual(
                                receivedURLRequest?.url?.path(),
                                endpoint.path
                        )
                        XCTAssertNil(receivedURLRequest?.httpBody)
                        XCTAssertNil(receivedURLRequest?.value(forHTTPHeaderField: HTTPHeader.Key.contentType))
                } catch {
                        XCTFail("Expected success, got \(error) instead.")
                }
        }

        func test_whenEndpointBodyIsEncodable_requestHasJSONHeadersAndBody() async {
                // Given
                let networkSessionSpy = NetworkSessionSpy.fixture()
                let sut = NetworkProviderImplementation(networkSession: networkSessionSpy)
                let encodableRequest = StubRequest.fixture()
                let endpoint = StubEndpoint.encodableBodyEndpoint(encodableRequest)

                do {
                        // When
                        let _: StubInstance1 = try await sut.request(endpoint)

                        // Then
                        let receivedURLRequest = networkSessionSpy.receivedURLRequest
                        XCTAssertEqual(
                                receivedURLRequest?.url?.path(),
                                endpoint.path
                        )

                        if let receivedHTTPBody = receivedURLRequest?.httpBody {
                                if let receivedBody = try? JSONDecoder().decode(StubRequest.self, from: receivedHTTPBody) {
                                        XCTAssertEqual(
                                                receivedBody,
                                                encodableRequest
                                        )
                                } else {
                                        XCTFail(
                                                "Failed to decode HTTPBody into ValidEncodableRequest."
                                        )
                                }
                        } else {
                                XCTFail("Expected HTTPBody, got nil instead.")
                        }

                        XCTAssertEqual(
                                receivedURLRequest?.value(forHTTPHeaderField: HTTPHeader.Key.contentType),
                                HTTPHeader.Value.applicationJSON
                        )
                } catch {
                        XCTFail("Expected success, got \(error) instead.")
                }
        }

        func test_whenEndpointBodyIsQueryParameter_requestHasCorrectQueryItems() async {
                // Given
                let queryItemSorting: (URLQueryItem, URLQueryItem) -> Bool = { $0.name < $1.name }
                let queryParameters: [String: String?] = [
                        "string": "string",
                        "int": "1",
                        "double": "1.0",
                        "float": "1.0",
                        "parameterWithNoValue": nil,
                ]
                let expectedQueryParameters =
                        queryParameters
                        .map(URLQueryItem.init)
                        .sorted(by: queryItemSorting)
                let networkSessionSpy = NetworkSessionSpy.fixture()
                let sut = NetworkProviderImplementation(networkSession: networkSessionSpy)

                do {
                        // When
                        let _: StubInstance1 = try await sut.request(StubEndpoint.queryParametersEndpoint(queryParameters))

                        if let receivedURLRequest = networkSessionSpy.receivedURLRequest {
                                // Then
                                let receivedQueryParameters = getQueryItems(from: receivedURLRequest)
                                        .sorted(by: queryItemSorting)
                                XCTAssertEqual(
                                        receivedQueryParameters,
                                        expectedQueryParameters
                                )
                        } else {
                                XCTFail("Expected URLRequest, got nil instead.")
                        }
                } catch {
                        XCTFail("doesn't matter error \(error)")
                }
        }

        func test_whenEndpointHasCustomHeaders_requestHasCorrectHeaders() async {
                // Given
                let queryParameters: [String: String?] = [
                        "query": "value"
                ]
                let expectedHeaders = StubEndpoint.queryParametersEndpoint(queryParameters).headers
                let networkSessionSpy = NetworkSessionSpy.fixture()
                let sut = NetworkProviderImplementation(networkSession: networkSessionSpy)

                do {
                        // When
                        let _: StubInstance1 = try await sut.request(StubEndpoint.queryParametersEndpoint(queryParameters))

                        // Then
                        let receivedURLRequest = networkSessionSpy.receivedURLRequest
                        XCTAssertEqual(
                                receivedURLRequest?.allHTTPHeaderFields,
                                expectedHeaders
                        )
                } catch {
                        XCTFail("Expected success, got error \(error) instead.")
                }
        }

        func test_whenEndpointHasCustomPath_requestHasCorrectPath() async {
                // Given
                let queryParameters: [String: String?] = [
                        "key": "value"
                ]
                let endpoint = StubEndpoint.queryParametersEndpoint(queryParameters)
                let networkSessionSpy = NetworkSessionSpy.fixture()
                let sut = NetworkProviderImplementation(networkSession: networkSessionSpy)

                do {
                        // When
                        let _: StubInstance1 = try await sut.request(endpoint)

                        // Then
                        let receivedURLRequest = networkSessionSpy.receivedURLRequest
                        XCTAssertEqual(
                                receivedURLRequest?.url?.path(),
                                endpoint.path
                        )
                } catch {
                        XCTFail("Expected success, got error \(error) instead.")
                }
        }

        func test_networkProviderSetsCorrectHTTPMethodFromEndpointInURLRequest() async {
                // Given
                let networkSessionSpy = NetworkSessionSpy.fixture()
                let sut = NetworkProviderImplementation(networkSession: networkSessionSpy)

                do {
                        // When
                        let _: StubInstance1 = try await sut.request(StubEndpoint.getEndpoint)
                        let receivedGetURLRequest = networkSessionSpy.receivedURLRequest
                        let _: StubInstance1 = try await sut.request(StubEndpoint.postEndpoint)
                        let receivedPostURLRequest = networkSessionSpy.receivedURLRequest

                        // Then
                        XCTAssertEqual(
                                receivedGetURLRequest?.httpMethod,
                                HTTPMethod.get.rawValue
                        )
                        XCTAssertEqual(
                                receivedPostURLRequest?.httpMethod,
                                HTTPMethod.post.rawValue
                        )
                } catch {
                        XCTFail("Expected success, got error \(error) instead.")
                }
        }

        func test_networkProviderDecodesExpectedResponse() async {
                // Given
                let expectedInstance = StubInstance1.fixture()
                let sut = NetworkProviderImplementation(networkSession: NetworkSessionSpy.fixture())

                do {
                        // When
                        let receivedInstance: StubInstance1 = try await sut.request(StubEndpoint.getEndpoint)

                        // Then
                        XCTAssertEqual(
                                receivedInstance,
                                expectedInstance
                        )
                } catch {
                        XCTFail("Expected success, got error \(error) instead.")
                }
        }

        // MARK: - Utility methods
        func getQueryItems(from request: URLRequest) -> [URLQueryItem] {
                guard
                        let url = request.url,
                        let components = URLComponents(
                                url: url,
                                resolvingAgainstBaseURL: false
                        ),
                        let queryItems = components.queryItems
                else {
                        return .init()
                }

                return queryItems
        }
}
