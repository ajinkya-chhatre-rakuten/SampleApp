import Foundation

/// The Non-Member API-C Token model.
struct APICTokenNonMember: Decodable {
    let tokenType: String
    let accessToken: String
    let expiration: Int

    private enum CodingKeys: String, CodingKey {
        case tokenType = "token_type"
        case accessToken = "access_token"
        case expiration = "expires_in"
    }
}

/// The Member API-C Token model.
struct APICTokenMember: Decodable {
    let accessToken: String
    let issuedAt: Int

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case issuedAt = "issued_at"
    }
}
