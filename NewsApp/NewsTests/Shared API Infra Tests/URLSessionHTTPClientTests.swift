//
//  URLSessionHTTPClientTests.swift
//  NewsTests
//
//  Created by Eyüphan Akkaya on 22.06.2026.
//

import XCTest
import NewsApp

final class URLSessionHTTPClientTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.removeStub()
    }

    func test_getFromURL_performGETRequestWithURL() async throws {
        let url = anyURL()
        let sut = makeSUT()
        
        URLProtocolStub.stub(
            data: Data(),
            response: anyHTTPURLResponse(),
            error: nil)
        
        _ = try await sut.get(url: url)
        
        XCTAssertEqual(URLProtocolStub.lastRequest?.url, url)
    }
    
    
    func test_getFromURL_failDataTask() async {
        let expectedError = anyNSError()
        
        let receivedError = await resultErrorFor((nil, nil, expectedError))
        
        XCTAssertEqual(receivedError?.domain, expectedError.domain)
        XCTAssertEqual(receivedError?.code, expectedError.code)
    }
    
    
    func test_getFromURL_successDataTask() async {
        let anyData = anyData()
        let anyResponse =  anyHTTPURLResponse()
        
        let receivedValue = await resultSuccessFor((anyData, anyResponse, nil))

        XCTAssertEqual(receivedValue?.0, anyData)
        XCTAssertEqual(anyResponse.url,receivedValue?.1.url)
        XCTAssertEqual(anyResponse.statusCode,receivedValue?.1.statusCode)
    }
    
    func test_getFromURL_successEmptyDataTask() async {
        let emptyData = Data()
        let anyResponse =  anyHTTPURLResponse()
        
        let receivedValue = await resultSuccessFor((emptyData, anyResponse, nil))
    
        XCTAssertEqual(receivedValue?.0, emptyData)
        XCTAssertEqual(anyResponse.url,receivedValue?.1.url)
        XCTAssertEqual(anyResponse.statusCode,receivedValue?.1.statusCode)
    }
    
    
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, file: StaticString = #filePath,line: UInt = #line) async  -> NSError? {
        do {
            let result = try await resultFor(values, file: file, line: line)
            XCTFail("Expected error but got success \(result)")
            return nil
        } catch {
            return error as NSError
        }
        
    }
    
    private func resultSuccessFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, file: StaticString = #filePath,line: UInt = #line) async  -> (Data, HTTPURLResponse)? {
        do {
            let result = try await resultFor(values, file: file, line: line)
            return result
        } catch {
            XCTFail("Expected failure", file: file, line: line)
            return nil
        }
        
    }
    
    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?,  file: StaticString = #file, line: UInt = #line) async throws  -> (Data, HTTPURLResponse) {
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        
        let sut = makeSUT(file: file,line: line)
        
        return try await sut.get(url: anyURL())
    }
}
