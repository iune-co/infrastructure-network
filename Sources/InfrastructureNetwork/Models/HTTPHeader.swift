public struct HTTPHeader {
        private init() {

        }

        public struct Key {
                public static let contentType = "Content-Type"
                public static let authorization = "Authorization"
        }

        public struct Value {
                public static let applicationJSON = "application/json"
        }
}
