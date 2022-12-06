import Foundation

private let pnpDateFormatter = ISO8601DateFormatter()

@objc public extension NSDate {
    /// - Returns: an ISO-8601 string from a date.
    var toISO8601String: String {
        pnpDateFormatter.string(from: self as Date)
    }
}

@objc public extension NSString {
    /// - Returns: a date from an ISO-8601 string.
    var toISO8601Date: Date? {
        pnpDateFormatter.date(from: self as String)
    }
}
