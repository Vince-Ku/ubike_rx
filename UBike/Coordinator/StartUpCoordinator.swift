//
//  StartUpCoordinator.swift
//  UBike
//
//  Created by Vince on 2023/4/26.
//

import UIKit

class StartUpCoordinator {
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // setup the initial module when the app launched
    func start() {
        HomeCoordinator(navigationController: navigationController).start()
    }
}
