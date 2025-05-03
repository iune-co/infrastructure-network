import Foundation

public protocol NetworkSession: Sendable {
        func data(for: URLRequest) async throws -> (Data, URLResponse)
}
