@testable import InfrastructureNetwork

enum StubEndpoint: Endpoint {
        case invalidURLEndpoint
        case getEndpoint
        case postEndpoint
        case queryParametersEndpoint([String: String?])
        case encodableBodyEndpoint(StubRequest)

        var baseURL: String {
                switch self {
                        case .invalidURLEndpoint:
                                "invalidscheme://malformed com"

                        default:
                                "https://test.com"
                }
        }

        var path: String {
                "/path/to/endpoint"
        }

        var headers: [String: String]? {
                [
                        "key1": "value1",
                        "key2": "value2",
                        "key3": "value3",
                ]
        }

        var method: HTTPMethod {
                switch self {
                        case .postEndpoint:
                                .post

                        default:
                                .get
                }
        }

        var body: RequestBody {
                switch self {
                        case .getEndpoint, .postEndpoint, .invalidURLEndpoint:
                                .plain

                        case .queryParametersEndpoint(let parameters):
                                .queryParameter(parameters)

                        case .encodableBodyEndpoint(let encodableBody):
                                .encodable(encodableBody)
                }
        }
}
