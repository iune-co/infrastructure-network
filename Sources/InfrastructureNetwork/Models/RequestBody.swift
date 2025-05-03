import Foundation

public enum RequestBody {
        case plain
        case encodable(Encodable)
        case queryParameters([QueryParameter])
}
