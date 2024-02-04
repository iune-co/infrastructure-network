import Foundation
import InfrastructureDependencyContainer
import InfrastructureNetworkAPI

public struct NetworkServiceRegistrar: ServiceRegister {
    public init() {}
    
    public func register(on container: DependencyContainer){
        container.register(service: NetworkProvider.self) {
            NetworkProviderImplementation(
                logger: NetworkLoggerImplementation(),
                networkSession: URLSession.shared
            )
        }
    }
}
