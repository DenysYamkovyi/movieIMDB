//
//  MoviesListViewModelTests.swift
//  MovieIMDBTests
//
//  Created by macbook pro on 2024-07-22.
//

import XCTest
import Combine
@testable import MovieIMDB

class MoviesListViewModelTests: XCTestCase {
    
    var viewModel: MoviesListViewModel!
    var fetchMoviesUseCaseMock: FetchMoviesUseCaseMock!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        fetchMoviesUseCaseMock = FetchMoviesUseCaseMock()
        viewModel = MoviesListViewModel(fetchMoviesUseCase: fetchMoviesUseCaseMock)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        fetchMoviesUseCaseMock = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testUserDidSearchFetchesMovies() {
        // Arrange
        let expectedMovies = [MovieModel(title: "Test Movie", thumbnail: "", year: "2024")]
        fetchMoviesUseCaseMock.result = .success(expectedMovies)
        
        let expectation = XCTestExpectation(description: "Movies loaded")
        
        // Act
        viewModel.userDidSearch(text: "Test")
        
        // Assert
        XCTAssertEqual(viewModel.isLoading, true)
        
        viewModel.$movies
            .dropFirst() // Skip the initial value
            .sink { movies in
                XCTAssertEqual(movies, expectedMovies)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testUserDidSearchHandlesError() {
        // Arrange
        let expectedError = NSError(domain: "Test", code: 1, userInfo: nil)
        fetchMoviesUseCaseMock.result = .failure(expectedError)
        
        // Act
        viewModel.userDidSearch(text: "Test")
        
        // Assert
        XCTAssertEqual(viewModel.isLoading, true)
        
        viewModel.error
            .sink { error in
                XCTAssertEqual(error as NSError, expectedError)
            }
            .store(in: &cancellables)
    }
    
    func testUserDidSelectPublishesMovie() {
        // Arrange
        let selectedMovie = MovieModel(title: "Selected Movie", thumbnail: "", year: "2024")
        
        // Act
        viewModel.userDidSelect(selectedMovie)
        
        // Assert
        viewModel.showMovieOverview
            .sink { movie in
                XCTAssertEqual(movie, selectedMovie)
            }
            .store(in: &cancellables)
    }
}
