@testable import InfrastructureNetwork
import Foundation

extension NetworkProviderFactory {
        static func create(with spy: NetworkSessionSpy) -> some NetworkProvider<StubEndpoint> {
                NetworkProviderImplementation(
                        logger: NetworkLoggerImplementation(),
                        networkSession: spy
                )
        }
  
        static func createWithSpy(
                errorToThrow: (any Error)? = nil,
                dataToReturn: Data? = StubInstance1.jsonDataFixture(),
                cachedDataToReturn: Data? = nil,
                urlResponseToReturn: URLResponse? = HTTPURLResponse.fixture()
        ) -> some NetworkProvider<StubEndpoint> {
                NetworkProviderImplementation(
                        logger: NetworkLoggerImplementation(),
                        networkSession: NetworkSessionSpy.fixture(
                                errorToThrow: errorToThrow,
                                dataToReturn: dataToReturn,
                                cachedDataToReturn: cachedDataToReturn,
                                urlResponseToReturn: urlResponseToReturn
                        )
                )
        }
        
//        static func createWithSpy(
//                errorToThrow: (any Error)? = nil,
//                dataToReturn: Data? = nil,
//                cachedDataToReturn: Data? = nil,
//                urlResponseToReturn: URLResponse? = nil
//        ) -> some NetworkProvider<StubEndpoint> {
//                NetworkProviderImplementation(
//                        logger: NetworkLoggerImplementation(),
//                        networkSession: NetworkSessionSpy(
//                                errorToThrow: errorToThrow,
//                                dataToReturn: dataToReturn,
//                                cachedDataToReturn: cachedDataToReturn,
//                                urlResponseToReturn: urlResponseToReturn
//                        )
//                )
//        }
        
        static func createWithFake() -> some NetworkProvider<StubEndpoint> {
                NetworkProviderImplementation(
                        logger: NetworkLoggerImplementation(),
                        networkSession: NetworkSessionFake()
                )
        }
}
