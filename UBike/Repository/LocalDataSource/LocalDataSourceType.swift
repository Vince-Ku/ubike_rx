//
//  LocalDataSourceType.swift
//  UBike
//
//  Created by Vince on 2023/4/18.
//

protocol LocalDataSourceType {
    static var shared: Self { get }
}
