//
//  Requesting.swift
//
//
//  Created by Manu Herrera on 12/03/2022.
//

import Foundation

protocol Requesting {
    associatedtype ResponseType: Codable
    func execute(completion: @escaping (Result<ResponseType, Error>) -> Void)
}

open class Request<Response: Codable>: Requesting {
    public typealias ResponseType = Response

    private var request: RequestData
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(
        requestData: RequestData,
        session: URLSession = URLSession.shared,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        request = requestData
        self.session = session
        decoder = jsonDecoder
    }

    public func execute(completion: @escaping (Result<ResponseType, Error>) -> Void) {
        guard let url = URL(string: request.path) else {
            completion(.failure(NetworkingError.invalidURL))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        do {
            if let params = request.params {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            }
        } catch {
            completion(.failure(error))
            return
        }

        session.dataTask(with: urlRequest) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkingError.noData))
                }
                return
            }

            do {
                let result = try self.decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(NetworkingError.decodingError))
                }
            }
        }.resume()
    }
}

public enum NetworkingError: Error {
    case invalidURL
    case noData
    case decodingError
}
