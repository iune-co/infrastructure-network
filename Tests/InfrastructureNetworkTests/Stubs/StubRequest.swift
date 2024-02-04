struct StubRequest: Codable, Equatable {
    let encodableVar1: String
    let encodableVar2: Int
    
    init(
        encodableVar1: String,
        encodableVar2: Int
    ) {
        self.encodableVar1 = encodableVar1
        self.encodableVar2 = encodableVar2
    }
}
