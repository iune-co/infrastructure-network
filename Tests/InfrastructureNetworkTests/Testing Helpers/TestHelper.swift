import Foundation

struct TestHelper {
        static func getQueryItems(from request: URLRequest) -> [URLQueryItem] {
                guard
                        let url = request.url,
                        let components = URLComponents(
                                url: url,
                                resolvingAgainstBaseURL: false
                        ),
                        let queryItems = components.queryItems
                else {
                        return .init()
                }
                
                return queryItems
        }
}
