import Foundation

public enum RequestBody {
    case plain
    case encodable(Encodable)
    case queryParameter([String: String?])
}
