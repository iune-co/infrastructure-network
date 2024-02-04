import Foundation

extension StubInstance1 {
    static func fixture(stubVar1: String = "stubVar1Value") -> StubInstance1 {
        StubInstance1(stubVar1: stubVar1)
    }
    
    static func jsonFixture(stubVar1: String = "stubVar1Value") -> String {
        """
        {
            "stubVar1": "\(stubVar1)"
        }
        """
    }
    
    static func jsonDataFixture(stubVar1: String = "stubVar1Value") -> Data {
        StubInstance1
            .jsonFixture(stubVar1: stubVar1)
            .data(using: .utf8)!
    }
}
