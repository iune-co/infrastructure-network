import Foundation

// TODO: confirm URLSession is internally thread-safe
extension URLSession: NetworkSession, @unchecked Sendable {
        public func cache(for request: URLRequest) -> Data? {
                configuration.urlCache?.cachedResponse(for: request)?.data
        }
}
