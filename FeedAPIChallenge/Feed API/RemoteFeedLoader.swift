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
		self.client.get(from: url) { [weak self] clientResult in
			
			guard self != nil else { return }
			
			switch clientResult {
			case .success((let data, let response)):
				if let feedImages = try? FeedImageMapper.map(data, response) {
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
	private struct Root: Decodable {
		let items: [JsonFeedImageModel]
	}

	// MARK: - JsonFeedImageModel
	private struct JsonFeedImageModel: Decodable {
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
