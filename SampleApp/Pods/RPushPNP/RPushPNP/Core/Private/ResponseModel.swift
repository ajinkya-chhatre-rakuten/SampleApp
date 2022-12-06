import Foundation

// MARK: - ErrorModel

struct ErrorModel: Codable {
    let errorMessage: String
    let statusCode: Int
}

// MARK: - AccessTokenErrorModel

struct AccessTokenErrorModel: Codable {
    let errorDescription: String
    let error: String

    private enum CodingKeys: String, CodingKey {
        case errorDescription = "error_description"
        case error
    }
}
