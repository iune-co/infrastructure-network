struct StubInstance1: Codable, Equatable {
        let stubVar1: String

        init(stubVar1: String = "stubVar1Value") {
                self.stubVar1 = stubVar1
        }
}
