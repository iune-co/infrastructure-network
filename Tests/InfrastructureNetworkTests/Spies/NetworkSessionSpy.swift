import Foundation
@testable import InfrastructureNetwork

final class NetworkSessionSpy: NetworkSession {
        var errorToThrow: Error?
        var dataToReturn: Data?
        var urlResponseToReturn: URLResponse?
        private(set) var dataForRequestMethodWasCalledXTimes = 0
        private(set) var receivedURLRequest: URLRequest?

        init(
                errorToThrow: Error? = nil,
                dataToReturn: Data? = nil,
                urlResponseToReturn: URLResponse? = nil
        ) {
                self.errorToThrow = errorToThrow
                self.dataToReturn = dataToReturn
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
}
