import Foundation

extension HTTPURLResponse {
    static func fixture(
        url: URL = URL(string: StubEndpoint.getEndpoint.baseURL)!,
        statusCode: Int = 200,
        httpVersion: String = "HTTP/1.1",
        headerFields: [String: String]? = nil
    ) -> HTTPURLResponse {
        HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: httpVersion,
            headerFields: headerFields
        )!
    }
}
