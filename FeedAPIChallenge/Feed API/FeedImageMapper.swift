//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Farzad Zamani on 9/1/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

// MARK: - FeedImageMapper
final class FeedImageMapper {
	private struct Root: Decodable {
		let items: [JsonFeedImageModel]
	}

	// MARK: - JsonFeedImageModel
	struct JsonFeedImageModel: Decodable {
		let imageId: UUID
		let imageDescription: String?
		let imageLocation: String?
		let imageURL: URL

		enum CodingKeys: String, CodingKey {
			case imageId = "image_id"
			case imageDescription = "image_desc"
			case imageLocation = "image_loc"
			case imageURL = "image_url"
		}

		var feedImage: FeedImage {
			return FeedImage(id: imageId, description: imageDescription, location: imageLocation, url: imageURL)
		}
	}

	static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.OK_200 else {
			throw RemoteFeedLoader.Error.invalidData
		}

		let root = try JSONDecoder().decode(Root.self, from: data)
		return root.items.map { $0.feedImage }
	}
}

// MARK: - HTTPURLResponse
extension HTTPURLResponse {
	var OK_200: Bool {
		return self.statusCode == 200
	}
}
