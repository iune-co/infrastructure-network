import Foundation

// MARK: - Init + Properties
actor NetworkProviderImplementation {
        private let logger: NetworkLogger?
        private let networkSession: NetworkSession

        public init(
                logger: NetworkLogger? = nil,
                networkSession: NetworkSession
        ) {
                self.logger = logger
                self.networkSession = networkSession
        }
}

// MARK: - NetworkProvider
extension NetworkProviderImplementation: NetworkProvider {
        public func request<
                ResponseType: Decodable & Sendable,
                EndpointType: Endpoint
        >(_ endpoint: EndpointType) async throws(NetworkProviderError) -> ResponseType {
                let data = try await perform {
                        try await fetchData(for: endpoint)
                }
                do {
                        return try JSONDecoder().decode(ResponseType.self, from: data)
                } catch {
                        await logger?.log(error: error)
                        throw NetworkProviderError.parsingError
                }
        }
        
        public func requestData<EndpointType: Endpoint>(_ endpoint: EndpointType) async throws(NetworkProviderError) -> Data {
                try await perform { [self] in
                        try await fetchData(for: endpoint)
                }
        }
}

// MARK: - Helpers
extension NetworkProviderImplementation {
        private func prepareUrlRequest<EndpointType: Endpoint>(for endpoint: EndpointType) throws -> URLRequest {
                let urlString = endpoint.baseURL + endpoint.path

                guard let url = URL(string: urlString) else {
                        throw NetworkProviderError.invalidURL
                }

                var urlRequest = URLRequest(url: url)

                endpoint.headers?
                        .forEach { (key, value) in
                                urlRequest.addValue(
                                        value,
                                        forHTTPHeaderField: key
                                )
                        }

                urlRequest.httpMethod = endpoint.method.rawValue

                switch endpoint.body
                {
                        case .plain:
                                break

                        case let .encodable(parameters):
                                urlRequest.httpBody = try JSONEncoder().encode(parameters)
                                urlRequest.addValue(
                                        HTTPHeader.Value.applicationJSON,
                                        forHTTPHeaderField: HTTPHeader.Key.contentType
                                )

                        case let .queryParameter(parameters):
                                guard var urlComponents = URLComponents(string: urlString) else {
                                        return urlRequest
                                }

                                urlComponents.queryItems = parameters.map(URLQueryItem.init)
                                urlRequest.url = urlComponents.url
                }

                return urlRequest
        }

        private func validate(
                urlResponse: URLResponse,
                data: Data
        ) throws(NetworkProviderError) {
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                        throw NetworkProviderError.nonHTTResponse
                }

                switch httpResponse.statusCode {
                        case 404:
                                throw NetworkProviderError.notFound

                        case 403:
                                throw NetworkProviderError.unauthorized

                        case 408:
                                throw NetworkProviderError.timeout

                        case 400...499:
                                throw NetworkProviderError.invalidRequest

                        case 500...599:
                                throw NetworkProviderError.serverError

                        case 200...299:
                                guard !data.isEmpty else {
                                        throw NetworkProviderError.noData
                                }
                                break

                        default:
                                throw NetworkProviderError.other
                }
        }
        
        private func fetchData<EndpointType: Endpoint>(for endpoint: EndpointType) async throws -> Data {
                let urlRequest = try prepareUrlRequest(for: endpoint)
                await logger?.log(request: urlRequest)
                let (data, response) = try await networkSession.data(for: urlRequest)
                await logger?.log(response: response, data: data)
                try validate(urlResponse: response, data: data)
                return data
        }
        
        private func perform<T: Sendable>(_ operation: @Sendable () async throws -> T) async throws(NetworkProviderError) -> T {
                do {
                        return try await operation()
                } catch let error as URLError where error.code == .timedOut {
                        await logger?.log(error: error)
                        throw NetworkProviderError.timeout
                } catch let error as URLError where error.code == .notConnectedToInternet {
                        await logger?.log(error: error)
                        throw NetworkProviderError.noNetworkConnection
                } catch let error as NetworkProviderError {
                        throw error
                } catch {
                        await logger?.log(error: error)
                        throw NetworkProviderError.other
                }
        }
}
