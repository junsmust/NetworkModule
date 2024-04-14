//
//  NetworkSystem.swift
//  NetworkSystem
//
//  Created by 임주영 on 3/28/24.
//

import Foundation
import Moya
import RxMoya
import RxSwift

enum NetworkErrorType: Error {
    case decodeError
}

public struct NetworkSystem {
    private init() { }
    public static let shared = NetworkSystem()
    var disposeBag = DisposeBag()
    
    private var jsonDecoder: JSONDecoder { JSONDecoder() }
    
    public func request<D: Decodable, T: TargetType>(D: D.Type, T: T.Type, target: T) -> Observable<Result<D,Error>> {
        let provider = MoyaProvider<T>()
        
        let single: Single<Result<D, Error>> = .create { single in
            provider.rx.request(target)
                .retry(3)
               .catch { error in
                   return .error(error)
               }
               .subscribe { response in
                   switch response {
                   case .success(let response):
                       let data = response.data
                       do {
                           if let responseModel = try? jsonDecoder.decode(D.self, from: data) {
                               single(.success(.success(responseModel)))
                           } else {
                               let responseModel = try jsonDecoder.decode(ResponseModel<D>.self, from: data)
                               if (200...300).contains(responseModel.status) {
                                   single(.success(.success(responseModel.data)))
                               } else {
                                   single(.failure(NetworkError.emptyData))
                               }
                           }
                       } catch {
                           single(.failure(NetworkErrorType.decodeError))
                       }
                   case .failure(let error):
                       single(.failure(error))
                   }
               }
               .disposed(by: disposeBag)
            
            return Disposables.create()
        }
    
        return single.asObservable().map { $0 }
    }
}


