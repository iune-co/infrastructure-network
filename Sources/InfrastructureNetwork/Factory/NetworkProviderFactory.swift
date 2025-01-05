import Foundation

public struct NetworkProviderFactory {
        public static func createDefault() -> NetworkProvider {
                NetworkProviderImplementation(
                        logger: NetworkLoggerImplementation(),
                        networkSession: URLSession.shared
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
