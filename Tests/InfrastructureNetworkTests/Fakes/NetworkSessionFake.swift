import Foundation

@testable import InfrastructureNetwork

final class NetworkSessionFake: NetworkSession {
        func cache(for: URLRequest) -> Data? {
                nil
        }
        
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
                (Data(), URLResponse())
        }
}
