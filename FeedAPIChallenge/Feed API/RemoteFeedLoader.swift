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
			case let .success((data, response)):
				completion(Result { try FeedImageMapper.map(data, response) })
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}
