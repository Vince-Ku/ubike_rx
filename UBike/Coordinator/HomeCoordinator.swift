//
//  HomeCoordinator.swift
//  UBike
//
//  Created by Vince on 2023/4/26.
//

import UIKit

class HomeCoordinator: HomeCoordinatorType {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController

        navigationController.pushViewController(viewController, animated: true)
    }
    
}
