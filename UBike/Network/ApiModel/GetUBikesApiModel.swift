//
//  GetUBikesApiModel.swift
//  UBike
//
//  Created by Vince on 2021/5/12.
//

import Foundation

struct GetUBikesResp: Decodable {
    var retCode: Int?
    var retVal: Dictionary<Int, UBike>?
}

struct UBike: Decodable {
    //站點代號
    var sno: String?
    //場站中文名稱
    var sna: String?
    //場站總停車格
    var tot: String?
    //場站目前車輛數量
    var sbi: String?
    //場站區域
    var sarea: String?
    //資料更新時間
    var mday: String?
    //緯度
    var lat: String?
    //經度
    var lng: String?
    //地址
    var ar: String?
    //場站區域英文
    var sareaen: String?
    //場站名稱英文
    var snaen: String?
    //地址英文
    var aren: String?
    //空位數量
    var bemp: String?
    //全站禁用狀態
    var act: String?
}
