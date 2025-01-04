@testable import InfrastructureNetwork

extension NetworkProviderError {
        var testDescription: String {
                switch self {
                        case .unauthorized: "unauthorized"
                        case .invalidRequest: "invalidRequest"
                        case .notFound: "notFound"
                        case .timeout: "timeout"
                        case .nonHTTResponse: "nonHTTResponse"
                        case .serverError: "serverError"
                        case .invalidURL: "invalidURL"
                        case .noData: "noData"
                        case .other: "other"
                        case .parsingError: "parsingError"
                        case .noNetworkConnection: "noNetworkConnection"
                }
        }
}
