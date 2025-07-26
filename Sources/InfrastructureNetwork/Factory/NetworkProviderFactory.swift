import Foundation

public struct NetworkProviderFactory {
        public static func createDefault<Path: Endpoint>(withCachePolicy policy: NSURLRequest.CachePolicy = .returnCacheDataElseLoad) -> some NetworkProvider<Path> {
                let cache = URLCache(
                        memoryCapacity: 50 * 1024 * 1024,
                        diskCapacity: 200 * 1024 * 1024,
                        diskPath: "urlcache"
                )
                let config = URLSessionConfiguration.default
                config.urlCache = cache
                config.requestCachePolicy = policy
                return NetworkProviderImplementation(
                        logger: NetworkLoggerImplementation(),
                        networkSession: URLSession(configuration: config)
                )
        }

        public static func create<
                Path: Endpoint,
                Logger: NetworkLogger
        >(with logger: Logger) -> some NetworkProvider<Path> {
                NetworkProviderImplementation(
                        logger: logger,
                        networkSession: URLSession.shared
                )
        }

        public static func create<
                Path: Endpoint,
                Network: NetworkSession
        >(with session: Network) -> some NetworkProvider<Path> {
                NetworkProviderImplementation(
                        logger: NetworkLoggerImplementation(),
                        networkSession: session
                )
        }

        public static func create<
                Path: Endpoint,
                Logger: NetworkLogger,
                Network: NetworkSession
        > (
                with logger: Logger,
                and session: Network
        ) -> some NetworkProvider<Path> {
                NetworkProviderImplementation(
                        logger: logger,
                        networkSession: session
                )
        }
}
