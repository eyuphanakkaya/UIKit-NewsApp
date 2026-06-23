//
//  HTTPClientSpy.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 23.06.2026.
//

import Foundation
import NewsApp


final class HTTPClientSpy: HTTPClient {
    private(set) var requestURLs = [URL]()
    var stubbedResult: Result<(Data, HTTPURLResponse), Error> = .failure(
        NSError(domain: "HTTPClientSpy", code: 0)
    )
    
    func get(url: URL) async throws -> (Data, HTTPURLResponse) {
        requestURLs.append(url)
        return try stubbedResult.get()
    }
    
    // MARK: - Helpers
    func completeWithSuccess(_ data: Data, for url: URL = URL(string: "https://any-url.com")!) {
        let response = anyHTTPURLResponse(for: url)
        stubbedResult = .success((data, response))
    }
    
    func completeWithError(_ error: Error = NSError(domain: "HTTPClientSpy", code: 0)) {
        stubbedResult = .failure(error)
    }
}
