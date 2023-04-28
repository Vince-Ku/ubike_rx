//
//  LocationManagerProxyDelegate.swift
//  UBike
//
//  Created by Vince on 2023/4/27.
//

protocol LocationManagerProxyDelegate: AnyObject {
    func openLocationSettingAlert(completion: @escaping (() -> Void))
}
