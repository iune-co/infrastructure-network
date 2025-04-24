import Foundation

@testable import InfrastructureNetwork

// FIX: not really sendable, mutable properties
final class NetworkSessionSpy: NetworkSession, @unchecked Sendable {
        var errorToThrow: Error?
        var dataToReturn: Data?
        var cachedDataToReturn: Data?
        var urlResponseToReturn: URLResponse?
        private(set) var dataForRequestMethodWasCalledXTimes = 0
        private(set) var cachedForRequestMethodWasCalledXTimes = 0
        private(set) var receivedURLRequest: URLRequest?
        private(set) var receivedCachedURLRequest: URLRequest?

        init(
                errorToThrow: Error? = nil,
                dataToReturn: Data? = nil,
                cachedDataToReturn: Data? = nil,
                urlResponseToReturn: URLResponse? = nil
        ) {
                self.errorToThrow = errorToThrow
                self.dataToReturn = dataToReturn
                self.cachedDataToReturn = cachedDataToReturn
                self.urlResponseToReturn = urlResponseToReturn
        }

        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
                receivedURLRequest = request
                dataForRequestMethodWasCalledXTimes += 1

                if let errorToThrow {
                        throw errorToThrow
                }

                guard
                        let dataToReturn,
                        let urlResponseToReturn
                else {
                        fatalError(
                                "NetworkSessionSpy must return Data and URLResponse if no errors are thrown."
                        )
                }

                return (dataToReturn, urlResponseToReturn)
        }
        
        func cache(for request: URLRequest) -> Data? {
                receivedCachedURLRequest = request
                cachedForRequestMethodWasCalledXTimes += 1
                return cachedDataToReturn
        }
}
