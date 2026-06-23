//
//  SharedTestHelpers.swift
//  NewsTests
//
//  Created by Eyüphan Akkaya on 23.06.2026.
//

import Foundation

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 1)
}

func anyHTTPURLResponse(for url: URL = URL(string: "https://any-url.com")!) -> HTTPURLResponse {
    return HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
}

func nonHTTPURLResponse() -> URLResponse {
    return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}
