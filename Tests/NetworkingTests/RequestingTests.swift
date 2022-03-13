@testable import Networking
import XCTest

final class RequestingTests: XCTestCase {
    func testInvalidUrl() {
        // Given
        let requestData = RequestData(path: "")
        let request = Request<Model>(requestData: requestData)
        let expectation = expectation(description: "invalidURL")

        // When
        request.execute { result in
            // Then
            switch result {
            case let .failure(error):
                XCTAssertEqual(error.localizedDescription, NetworkingError.invalidURL.localizedDescription)
                expectation.fulfill()
            case .success:
                XCTFail("Should fail")
            }
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testSuccessWithMock() {
        // Given
        let requestData = RequestData(path: "/")
        let mock = SuccessRequestMock(requestData: requestData)
        let expectation = expectation(description: "success")

        // When
        mock.execute { result in
            // Then
            switch result {
            case .failure:
                XCTFail("Should not fail")
            case .success:
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
}

struct Model: Codable {
    let number: Int
}

final class SuccessRequestMock: Request<Model> {
    override func execute(completion: @escaping (Result<ResponseType, Error>) -> Void) {
        completion(.success(Model(number: 4)))
    }
}
