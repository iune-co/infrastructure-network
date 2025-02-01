import Foundation

public protocol NetworkProvider {
        func request<
                ResponseType: Decodable,
                EndpointType: Endpoint
        >(_ endpoint: EndpointType) async throws(NetworkProviderError) -> ResponseType
}
