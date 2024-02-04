extension StubRequest {
    static func fixture(
        encodableVar1: String = "encodableVar1Value",
        encodableVar2: Int = 1
    ) -> StubRequest {
        StubRequest(
            encodableVar1: encodableVar1,
            encodableVar2: encodableVar2
        )
    }
}
