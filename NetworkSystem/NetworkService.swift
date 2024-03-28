//
//  NetworkService.swift
//  NetworkSystem
//
//  Created by 임주영 on 3/28/24.
//

import Foundation
import Moya
import RxSwift

public struct NetworkService {
    public static func request<T: Decodable>(T: T.Type, target: some BaseTargetType) -> Single<Result<T, Error>> {
        return .create { single in
            target.provider.request(target) { result in
                switch result {
                case .success(let response):
                    print("response ")
                    do {
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(T.self, from: response.data)
                        
                        single(.success(.success(model)))
                    }
                    catch {
                        single(.failure(error))
                    }

                case .failure(_):
                    print("error")
                }
            }
            return Disposables.create()

        }
    }
}

public protocol BaseTargetType: TargetType {
    var provider: MoyaProvider<Self> { get }
}
extension BaseTargetType {
    public var provider: MoyaProvider<Self> {
        MoyaProvider<Self>()
    }
    
    public var baseURL: URL {
        return URL(string: APIConfig.baseURL) ?? URL(string: "")!
    }
    
    public var path: String {
        return ""
    }
    
    public var method: Moya.Method { .get }
    
    public var task: Moya.Task { .requestPlain }
    
    public var headers: [String : String]? { nil }
}

enum APIConfig {
    static let baseURL = "www.naver.com"
}
