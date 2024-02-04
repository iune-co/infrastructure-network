import Foundation
import InfrastructureNetworkAPI
import os.log

final class NetworkLoggerImplementation {
	// MARK: - Properties
	private let headingDash = "=========="
	private let logger = {
		let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
		
		return Logger(
			subsystem: bundleIdentifier + ".network",
			category: "NetworkLogging"
		)
	}()
}

// MARK: - NetworkLogger

extension NetworkLoggerImplementation: NetworkLogger {
    func log(request: URLRequest) {
        #if DEBUG
        let httpMethod = request.httpMethod ?? "HTTP Method not specified"
        let path = request.url?.absoluteString ?? "Path not specified"
        let headers = request.allHTTPHeaderFields ?? [:]
        let bodyData = request.httpBody
        
        logger.debug("\(self.headingDash) BEGIN NETWORK REQUEST \(self.headingDash)")
        logger.debug("Method: \(httpMethod)")
        logger.debug("Path: \(path)")
        logger.debug("Headers:")
        for (key, value) in headers {
            logger.debug("\t\(key): \(value)")
        }
        
        logger.debug("Body:")
        do {
            let bodyString = try getJSONString(from: bodyData)
            logger.debug("\(bodyString)")
        } catch {
            logger.debug("\tRequest without body or error showing body")
        }
        
        logger.debug("\(self.headingDash) END NETWORK REQUEST \(self.headingDash)")
        #endif
    }
    
    func log(
        response: URLResponse,
        data: Data?
    ) {
        #if DEBUG
        guard let response = response as? HTTPURLResponse else { return }
        let path = response.url?.absoluteString ?? "Not specified"
        let headers = response.allHeaderFields
        
        logger.debug("\(self.headingDash) BEGIN NETWORK RESPONSE \(self.headingDash)")
        logger.debug("Path: \(path)")
        logger.debug("Status code: \(response.statusCode)")
        logger.debug("Headers:")
        for (key, value) in headers {
            logger.debug("\t\(String(describing: key)): \(String(describing: value))")
        }
        
        logger.debug("Body:")
        do {
            let bodyString = try getJSONString(from: data)
            logger.debug("\(bodyString)")
        }
        catch {
            logger.debug("\tResponse without body or error showing body")
        }
        
        logger.debug("\(self.headingDash) END NETWORK RESPONSE \(self.headingDash)")
        #endif
    }
    
    func log(error: Error) {
        #if DEBUG
        logger.debug("\(self.headingDash) ERROR \(self.headingDash)")
        logger.debug("\(error.localizedDescription)")
        logger.debug("\n")
        #endif
    }
}

// MARK: - Private Methods

extension NetworkLoggerImplementation {
	private func getJSONString(from data: Data?) throws -> String {
		guard let data = data else {
			throw NSError(
				domain: "DataError",
				code: 0,
				userInfo: [
					NSLocalizedDescriptionKey: "Data is nil"
				]
			)
		}
		
		let jsonObject = try JSONSerialization.jsonObject(
			with: data,
			options: []
		)
		
		let prettyData = try JSONSerialization.data(
			withJSONObject: jsonObject,
			options: .prettyPrinted
		)
		
		if let prettyString = String(
			data: prettyData,
			encoding: .utf8
		) {
			return prettyString
				.split(separator: "\n")
				.map{ "\t\($0)" }
				.joined(separator: "\n")
		} else {
			throw NSError(
				domain: "StringError",
				code: 1,
				userInfo: [
					NSLocalizedDescriptionKey: "Couldn't create string from data"
				]
			)
		}
	}
}
