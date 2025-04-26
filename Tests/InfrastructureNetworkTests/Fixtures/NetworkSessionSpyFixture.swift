import Foundation

extension NetworkSessionSpy {
        static func fixture(
                errorToThrow: Error? = nil,
                dataToReturn: Data? = StubInstance1.jsonDataFixture(),
                cachedDataToReturn: Data? = nil,
                urlResponseToReturn: URLResponse? = HTTPURLResponse.fixture()
        ) -> NetworkSessionSpy {
                NetworkSessionSpy(
                        errorToThrow: errorToThrow,
                        dataToReturn: dataToReturn,
                        cachedDataToReturn: cachedDataToReturn,
                        urlResponseToReturn: urlResponseToReturn
                )
        }
}
