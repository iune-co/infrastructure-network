public enum NetworkError: Error 
{
    case unauthorized
    case invalidRequest
    case notFound
    case timeout
    case nonHTTResponse
    case serverError
    case invalidURL
    case noData
    case other
    case parsingError
}
