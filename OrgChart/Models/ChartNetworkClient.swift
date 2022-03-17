//
//  ChartNetworkClient.swift
//  TheMartianTimesTests
//
//  Created by Chanick on 7/18/21.
//

import Foundation


enum BundleRequestError: Error {
    case invalidPath
    case invalidData
}

//
// ChartNetworkClient
// Load from local json file
//
class ChartNetworkClient : NetworkClient {
    var basePath: String = ""
    
    
    func request(method: HttpMethod, path: String, parameters: [String : Any]?, httpBody: Data?, complete: @escaping (NetworkClientResult<Data>) -> Void) {
        
        // load json file from local
        guard let url = Bundle.main.url(forResource: path, withExtension: "json") else {
            complete(.failure([BundleRequestError.invalidPath.localizedDescription]))
            return
        }
        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            complete(.success(data))
        } catch {
            // handle error
            complete(.failure([BundleRequestError.invalidData.localizedDescription]))
        }
    }
    
    func request<T>(method: HttpMethod, path: String, parameters: [String : Any]?, httpBody: Data?, complete: @escaping (NetworkClientResult<T>) -> Void) where T : Decodable, T : Encodable {
        // load json file from local
        request(method: method, path: path, parameters: parameters, httpBody: httpBody) { (dataResult) in
            switch dataResult {
            case .success(let data):
                do {
                    let codable = try JSONDecoder().decode(T.self, from: data)
                    complete(.success(codable))
                } catch let error {
                    complete(.failure([error.localizedDescription]))
                }
            case .failure(let error):
                complete(.failure(error))
            }
        }
    }
    
    func request<T>(method: HttpMethod, path: String, parameters: [String : Any]?, httpBody: Data?, keyPath: String?, complete: @escaping (NetworkClientResult<T>) -> Void) where T : Decodable, T : Encodable {
        //
    }
}
