import Foundation

extension StubInstance2 {
    static func fixture(stubVar2: String = "stubVar2Value") -> StubInstance2 {
        StubInstance2(stubVar2: stubVar2)
    }
    
    static func jsonFixture(stubVar2: String = "stubVar2Value") -> String {
        """
        {
            "stubVar2": "\(stubVar2)"
        }
        """
    }
    
    static func jsonDataFixture(stubVar2: String = "stubVar2Value") -> Data {
        StubInstance2
            .jsonFixture(stubVar2: stubVar2)
            .data(using: .utf8)!
    }
}
