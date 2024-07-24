//
//  FetchMoviesUseCaseTests.swift
//  MovieIMDBTests
//
//  Created by macbook pro on 2024-07-22.
//

import XCTest
import Combine
@testable import MovieIMDB

class FetchMoviesUseCaseTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
        URLProtocol.registerClass(MockURLProtocol.self)
    }
    
    override func tearDown() {
        cancellables = nil
        URLProtocol.unregisterClass(MockURLProtocol.self)
        super.tearDown()
    }
    
    func testFetchMoviesSuccess() {
        // Given
        let useCase = FetchMoviesUseCase()
        let mockResponseData = """
        {
            "Search": [
                {
                    "Title": "Test Movie",
                    "Year": "2024",
                    "imdbID": "1111",
                    "Type": "movie",
                    "Poster": "https://example.com/poster.jpg"
                }
             ],
            "totalResults": "1",
            "Response": "True"
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockResponseData)
        }
        
        let expectation = XCTestExpectation(description: "Fetch movies")
        
        // When
        useCase.fetchMovies(title: "Test Movie")
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected successful completion, got \(error) instead")
                }
            }, receiveValue: { movies in
                // Then
                XCTAssertEqual(movies.count, 1)
                XCTAssertEqual(movies.first?.title, "Test Movie")
                XCTAssertEqual(movies.first?.year, "2024")
                XCTAssertEqual(movies.first?.thumbnail, "https://example.com/poster.jpg")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchMoviesFailure() {
        // Given
        let useCase = FetchMoviesUseCase()
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        let expectation = XCTestExpectation(description: "Fetch movies failure")
        
        // When
        useCase.fetchMovies(title: "Test Movie")
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    expectation.fulfill()
                }
            }, receiveValue: { movies in
                XCTFail("Expected failure, got \(movies) instead")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
}

