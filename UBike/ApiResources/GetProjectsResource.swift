//
//  GetProjectsResource.swift
//  UBike
//
//  Created by Vince on 2021/5/12.
//

import Foundation

struct ProjectResp : Codable {
    var projects : [Project]?
}

struct Project : Codable{
    var id : String?
    var picUrl : String?
    var title : String?
    var desc : String?
    var price : String?
    var review : String?
    var favorite : String?
    var flag : String?
}
