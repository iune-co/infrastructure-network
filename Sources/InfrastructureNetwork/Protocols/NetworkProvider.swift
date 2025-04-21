import Foundation

public protocol NetworkProvider: Actor {
        func request<
                ResponseType: Decodable & Sendable,
                EndpointType: Endpoint
        >(_ endpoint: EndpointType) async throws(NetworkProviderError) -> ResponseType
        
        func requestData<EndpointType: Endpoint>(_ endpoint: EndpointType) async throws(NetworkProviderError) -> Data
}
