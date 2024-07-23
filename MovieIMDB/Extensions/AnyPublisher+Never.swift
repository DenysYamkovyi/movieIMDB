//
//  AnyPublisher+Never.swift
//  MovieIMDB
//
//  Created by macbook pro on 2024-07-22.
//

import Combine

extension AnyPublisher {
    static func never() -> Self {
        Empty(completeImmediately: false).eraseToAnyPublisher()
    }
}

