import Foundation

@objc public protocol RPushPNPSessionable {
    @objc(dataTaskWithRequest:completionHandler:) func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: RPushPNPSessionable {}
