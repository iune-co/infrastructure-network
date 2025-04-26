import Foundation

public protocol NetworkProvider<Path>: Actor {
        associatedtype Path: Endpoint
        
        func request<ResponseType: Decodable & Sendable>(_ endpoint: Path) async throws(NetworkProviderError) -> ResponseType
        
        func requestData(_ endpoint: Path) async throws(NetworkProviderError) -> Data
}
