//
//  NewsModel.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 16.06.2026.
//

import Foundation

public struct NewsModel: Equatable {
    public let id: String
    public let title: String
    public let imageURL: String?
    public let creator: [String]?
    public let pubDate: String
    public let description: String?
    
    public init(id: String, title: String, imageURL: String?, creator: [String]?, pubDate: String, description: String?) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.creator = creator
        self.pubDate = pubDate
        self.description = description
    }
    
    var creatorText: String? {
        creator?.joined(separator: ", ").capitalized
    }
}
