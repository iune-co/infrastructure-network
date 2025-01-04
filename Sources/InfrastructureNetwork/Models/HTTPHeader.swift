public struct HTTPHeader {
        private init() {

        }

        public struct Key {
                static let contentType = "Content-Type"
                static let authorization = "Authorization"
        }

        public struct Value {
                static let applicationJSON = "application/json"
        }
}
