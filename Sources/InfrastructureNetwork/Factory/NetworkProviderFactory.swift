import Foundation

public struct NetworkProviderFactory {
        public static func createDefault() -> NetworkProvider {
                let cache = URLCache(
                        memoryCapacity: 50 * 1024,
                        diskCapacity: 200 * 1024 * 1024,
                        diskPath: "urlcache"
                )
                let config = URLSessionConfiguration.default
                config.urlCache = cache
                config.requestCachePolicy = .useProtocolCachePolicy
                return NetworkProviderImplementation(
                        logger: NetworkLoggerImplementation(),
                        networkSession: URLSession(configuration: config)
                )
        }
        
        public static func createDefault(with cache: URLCache) -> NetworkProvider {
                let config = URLSessionConfiguration.default
                config.urlCache = cache
                config.requestCachePolicy = .useProtocolCachePolicy
                return NetworkProviderImplementation(
                        logger: NetworkLoggerImplementation(),
                        networkSession: URLSession(configuration: config)
                )
        }

        public static func create(with logger: NetworkLogger) -> NetworkProvider {
                NetworkProviderImplementation(
                        logger: logger,
                        networkSession: URLSession.shared
                )
        }

        public static func create(with session: NetworkSession) -> NetworkProvider {
                NetworkProviderImplementation(
                        logger: NetworkLoggerImplementation(),
                        networkSession: session
                )
        }

        public static func create(
                with logger: NetworkLogger,
                and session: NetworkSession
        ) -> NetworkProvider {
                NetworkProviderImplementation(
                        logger: logger,
                        networkSession: session
                )
        }
}
