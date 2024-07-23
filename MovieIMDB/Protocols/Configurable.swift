//
//  Configurable.swift
//  MovieIMDB
//
//  Created by macbook pro on 2024-07-22.
//

protocol Configurable {
    associatedtype ConfigurationItem
    func configure(with item: ConfigurationItem)
}

