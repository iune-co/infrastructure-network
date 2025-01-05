enum NetworkTestError: Error {
        case someError

        var testDescription: String {
                switch self {
                        case .someError: "someError"
                }
        }
}
