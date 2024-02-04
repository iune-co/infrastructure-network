@testable import InfrastructureNetwork
import Foundation
import InfrastructureNetworkAPI

final class NetworkSessionFake: NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)  {
        (Data(), URLResponse())
    }
}
