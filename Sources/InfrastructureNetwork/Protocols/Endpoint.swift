public protocol Endpoint {
        var baseURL: String { get }
        var path: String { get }
        var method: HTTPMethod { get }
        var headers: [String: String]? { get }
        var body: RequestBody { get }
}

extension Endpoint {
        public var method: HTTPMethod { .get }
        public var headers: [String: String]? { nil }
        public var body: RequestBody { .plain }
}
