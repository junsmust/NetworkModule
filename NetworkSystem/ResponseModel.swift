//
//  ResponseModel.swift
//  NetworkSystem
//
//  Created by 임주영 on 3/28/24.
//

import Foundation

struct ResponseModel<T: Decodable>: Decodable {
    var status: Int
    var message: String
    var data: T
}
