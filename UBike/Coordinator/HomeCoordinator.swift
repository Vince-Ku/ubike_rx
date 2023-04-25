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
        let viewController = createModule()
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func createModule() -> HomeViewController {
        // Location proxy
        let locationManager = LocationManagerProxy()
        locationManager.delegate = self

        // Repository
        let ubikeStationsRepository = UbikeStationsRepository(alamofireNetworkService: AlamofireNetworkService.shared,
                                                              ubikeStationCoreDataService: UBikeStationCoreDataService.shared)
        let routeRepository = RouteRepository(appleMapService: .shared)
        
        // Utility
        let mapper = UibikeStationBottomSheetStateMapper()
        
        let viewModel = HomeViewModel(locationManager: locationManager,
                                      ubikeStationsRepository: ubikeStationsRepository,
                                      routeRepository: routeRepository,
                                      mapper: mapper,
                                      coordinator: self)
        
        let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        viewController.viewModel = viewModel
        
        return viewController
    }
}

extension HomeCoordinator: LocationManagerProxyDelegate {
    func openLocationSettingAlert(completion: @escaping (() -> Void)) {
        let alert = UIAlertController(title: "需要位置權限", message: "請允許「UBike」取用位置權限後，才可取得定位、地圖資訊、導航等功能。", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "前往設定", style: .default, handler: { _ in
            guard let bundleIdentifier = Bundle.main.bundleIdentifier,
                  let URL = URL(string: "\(UIApplication.openSettingsURLString)&path=//\(bundleIdentifier)"),
                  UIApplication.shared.canOpenURL(URL) else {
                return
            }
            
            UIApplication.shared.open(URL, options: [:])
        }))
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        navigationController.topViewController?.present(alert, animated: true, completion: completion)
    }
}
