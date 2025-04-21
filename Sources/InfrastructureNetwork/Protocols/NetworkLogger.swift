import Foundation

public protocol NetworkLogger: Actor {
        func log(request: URLRequest)
        func log(response: URLResponse, data: Data?)
        func log(error: Error)
}
