import Foundation

struct MovieSearchResponse: Decodable {
    let search: [Movie]
    let totalResults: String
    let response: String
    
    // CodingKeys enum to map JSON keys to the struct properties.
    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults
        case response = "Response"
    }
}
