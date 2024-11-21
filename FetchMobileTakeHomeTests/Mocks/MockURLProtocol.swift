//
//  MockURLProtocol.swift
//  FetchMobileTakeHomeTests
//
//  Created by Jack Robinson on 11/21/24.
//

import Foundation

/// A mock URL protocol for testing network requests.
///
/// This protocol intercepts network requests and returns predefined responses,
/// allowing you to test network-dependent code without making actual network calls.
class MockURLProtocol: URLProtocol {
    /// A predefined response to be returned for intercepted requests.
    /// - `data`: Mock data for the response body.
    /// - `response`: Mock HTTP response.
    /// - `error`: Mock error to simulate a failure.
    static var mockResponse: (Data?, HTTPURLResponse?, Error?)?
    /// Determines whether this protocol can handle a given request.
    ///
    /// - Parameter request: The URL request to evaluate.
    /// - Returns: Always returns `true` to intercept all requests.
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    /// Returns the canonical version of a request.
    ///
    /// - Parameter request: The original request.
    /// - Returns: The unmodified request.
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    /// Starts loading the request with the predefined mock response.
    override func startLoading() {
        if let (data, response, error) = MockURLProtocol.mockResponse {
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    /// Stops loading the request. No-op for the mock implementation.
    override func stopLoading() {}
}
