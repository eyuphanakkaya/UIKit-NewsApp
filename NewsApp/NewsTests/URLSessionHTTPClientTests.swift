//
//  URLSessionHTTPClientTests.swift
//  NewsTests
//
//  Created by Eyüphan Akkaya on 22.06.2026.
//

import XCTest
import NewsApp

final class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_performGETRequestWithURL() async throws {
        let url = URL(string: "https://any-url.com")!
        let sut = makeSUT()
        
        URLProtocolStub.stub(
            data: Data(),
            response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil),
            error: nil)
        
        _ = try await sut.get(url: url)
        
        XCTAssertEqual(URLProtocolStub.lastRequest?.url, url)
    }
    
    
    func test_getFromURL_failDataTask() async {
        let url = URL(string: "https://any-url.com")!
        let expectedError = NSError(domain: "any", code: 0)
        let sut = makeSUT()
        
        URLProtocolStub.stub(
            data: nil,
            response: nil,
            error: expectedError
        )
        
        do {
            _ = try await sut.get(url: url)
            XCTFail("Expected error but got success")
        } catch  let receivedError as NSError {
            XCTAssertEqual(receivedError.domain, expectedError.domain)
            XCTAssertEqual(receivedError.code, expectedError.code)
        }
    }
    
    
    func test_getFromURL_successDataTask() async throws {
        let url = URL(string: "https://any-url.com")!
        let anyData = Data("any data".utf8)
        let anyResponse =  HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let sut = makeSUT()
        
        URLProtocolStub.stub(
            data: anyData,
            response: anyResponse,
            error: nil
        )
        
        let (data, response) = try await sut.get(url: url)
        
        XCTAssertEqual(anyData, data)
        XCTAssertEqual(anyResponse?.url, response.url)
        XCTAssertEqual(anyResponse?.statusCode, response.statusCode)
    }
    
    func test_getFromURL_successEmptyDataTask() async throws {
        let url = URL(string: "https://any-url.com")!
        let emptyData = Data()
        let anyResponse =  HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let sut = makeSUT()
        
        URLProtocolStub.stub(
            data: emptyData,
            response: anyResponse,
            error: nil)
        
        let (data, response) = try await sut.get(url: url)
        
        XCTAssertEqual(data, emptyData)
        XCTAssertEqual(anyResponse?.url, response.url)
        XCTAssertEqual(anyResponse?.statusCode, response.statusCode)
    }
    
    
    
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        return sut
    }
    
    private final class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        static var lastRequest: URLRequest?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            URLProtocolStub.lastRequest = request
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
                    
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}

        
    }

}
