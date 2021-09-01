//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		self.client.get(from: url) { clientResult in

			switch clientResult {
			case .success((let data, let response)):
				if response.statusCode == 200,
				   let feedImages = try? FeedImageMapper.map(data) {
					completion(.success(feedImages))
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

// MARK: - FeedImageMapper
private final class FeedImageMapper {
	private typealias Root = [JsonFeedImageModel]

	// MARK: - JsonFeedImageModel
	private struct JsonFeedImageModel: Codable {
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

	static func map(_ data: Data) throws -> [FeedImage] {
		guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw RemoteFeedLoader.Error.invalidData
		}
		return root.map {
			$0.feedImage
		}
	}
}
