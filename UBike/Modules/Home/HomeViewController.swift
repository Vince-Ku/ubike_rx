//
//  ViewController.swift
//  UBike
//
//  Created by Vince on 2021/5/12.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var showUserLocationButton: ShadowButton!
    @IBOutlet weak var refreshAnnotationButton: ShadowButton!
    @IBOutlet weak var showListButton: ShadowButton!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var navigationButton: IdentifiableButton!
    @IBOutlet weak var favoriteStationButton: BorderButton!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var bikesSpaceLabel: UILabel!
    @IBOutlet weak var emptySpaceLabel: UILabel!
    
    private var viewModel: HomeViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViewModel()
        setupMap()
        setupLocation()
        setupBottomSheetEvent()
        
        viewModel.viewDidLoad.accept(())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomSheetView.layer.cornerRadius = bottomSheetView.bounds.height / 8
        bottomSheetView.layer.shadowColor = UIColor.black.cgColor
        bottomSheetView.layer.shadowRadius = bottomSheetView.bounds.height / 8
        bottomSheetView.layer.shadowOpacity = 0.3
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "bikesListSegue":
            let vc = segue.destination as? UBikesViewController
            // TODO: fix me
            vc?.homeViewModel = viewModel
            return
            
        default:
            print("unpredicted segue")
        }
    }
    
    private func createViewModel() {
        let locationManager = LocationManagerProxy()
        locationManager.delegate = self
        let ubikeStationsRepository = UbikeStationsRepository(alamofireNetworkService: AlamofireNetworkService.shared,
                                                              ubikeStationCoreDataService: UBikeStationCoreDataService.shared)
        let routeRepository = RouteRepository(appleMapService: .shared)
        let mapper = UibikeStationBottomSheetStateMapper()
        
        viewModel = HomeViewModel(locationManager: locationManager,
                                  ubikeStationsRepository: ubikeStationsRepository,
                                  routeRepository: routeRepository,
                                  mapper: mapper)
    }
    
    private func setupMap(){
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.register(UbikeStationAnnotationView.self, forAnnotationViewWithReuseIdentifier: "UbikeStationAnnotationView")

        showListButton.rx.tap
            .subscribe(onNext:{ [weak self] in
                self?.performSegue(withIdentifier: "bikesListSegue", sender: nil)
            })
            .disposed(by:disposeBag)
        
        refreshAnnotationButton.rx.tap
            .bind(to: viewModel.refreshAnnotationButtonDidTap)
            .disposed(by: disposeBag)

        showUserLocationButton.rx.tap
            .bind(to: viewModel.showUserLocationButtonDidTap)
            .disposed(by: disposeBag)
        
        viewModel.showUibikeStationsAnnotation.asDriver()
            .drive(onNext: { [weak self] annotations in
                guard let mapView = self?.mapView else { return }
                
                //initialize
                mapView.removeAnnotations(mapView.annotations)
                
                mapView.addAnnotations(annotations)
            })
            .disposed(by: disposeBag)
        
        viewModel.updateRoute.asDriver()
            .drive(onNext: { [weak self] route in
                guard let mapView = self?.mapView else { return }
                
                // remove all
                mapView.removeOverlays(mapView.overlays)
                
                guard let polyline = route?.polyline else { return  }
                // add route
                mapView.addOverlay(polyline, level: .aboveRoads)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupLocation() {
        viewModel.showLocation.asSignal()
            .emit(onNext: { [weak self] location, distance in
                self?.showLocation(location, distance, distance)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupBottomSheetEvent() {
        favoriteStationButton.rx.tap
            .withUnretained(favoriteStationButton)
            .compactMap { button, _ -> (String, Bool)? in
                guard let id = button.id else { return nil }
                return (id, !button.isSelected)
            }
            .bind(to: viewModel.favoriteStationButtonDidTap)
            .disposed(by: disposeBag)
            
        navigationButton.rx.tap
            .withUnretained(favoriteStationButton)
            .compactMap(\.0.id)
            .bind(to: viewModel.navigationButtonDidTap)
            .disposed(by: disposeBag)
        
        viewModel.updateUibikeStationBottomSheet.asDriver()
            .drive(onNext: { [weak self] state in
                switch state {
                case .empty:
                    self?.favoriteStationButton.id = nil
                    self?.favoriteStationButton.isEnabled = false
                    self?.navigationButton.isEnabled = false
                    
                case .regular(let id):
                    self?.favoriteStationButton.id = id
                    self?.favoriteStationButton.isEnabled = true
                    self?.navigationButton.isEnabled = true
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.updateUibikeStationNameText
            .bind(to: stationNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.updateFavoriteButtonState
            .bind(to: favoriteStationButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        viewModel.updateUibikeSpaceText
            .bind(to: bikesSpaceLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.updateEmptySpaceText
            .bind(to: emptySpaceLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.updateNavigationTitle.asDriver()
            .drive(onNext: { [weak self] titleText in
                self?.navigationButton.setTitle(titleText, for: .normal)
            })
            .disposed(by: disposeBag)
    }
    
    private func showLocation(_ location: CLLocation, _ latMeters : CLLocationDistance?, _ lngMeters:CLLocationDistance?) {
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude)
        
        guard let latMeters = latMeters, let lngMeters = lngMeters else {
            mapView.setCenter(center, animated: true)
            return
        }
        
        let region = MKCoordinateRegion(center: center, latitudinalMeters: latMeters ,longitudinalMeters: lngMeters)
        mapView.setRegion(region, animated: true)
    }

}

extension HomeViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }

        let renderer = MKPolylineRenderer(overlay: polyline)
        renderer.lineWidth = 10
        renderer.strokeColor = #colorLiteral(red: 0.03796023922, green: 0.5027811544, blue: 0.9708467497, alpha: 1)
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let ubikeStationAnnotation = annotation as? UBikeStationAnnotation else {
            return nil
        }
        
        guard let ubikeStationAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "UbikeStationAnnotationView") as? UbikeStationAnnotationView else {
            return nil
        }

        ubikeStationAnnotationView.setup(ubikeStation: ubikeStationAnnotation.ubikeStation)
        return ubikeStationAnnotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let ubikeStation = (view.annotation as? UBikeStationAnnotation)?.ubikeStation else { return }

        viewModel.annotationDidSelect.accept(ubikeStation)
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard let ubikeStation = (view.annotation as? UBikeStationAnnotation)?.ubikeStation else { return }

        viewModel.annotationDidDeselect.accept(ubikeStation)
    }
}

extension HomeViewController: LocationManagerProxyDelegate {
    
    func openLocationSettingAlert(completion: @escaping (() -> Void)) {
        let alert = UIAlertController(title: "需要位置權限", message: "請允許「UBike」取用位置權限後，才可取得定位、地圖資訊、導航等功能。", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "前往設定", style: .default, handler: { _ in
            guard let bundleIdentifier = Bundle.main.bundleIdentifier,
                  let URL = URL(string: "\(UIApplication.openSettingsURLString)&path=//\(bundleIdentifier)"),
                  UIApplication.shared.canOpenURL(URL) else {
                return
            }
            
            UIApplication.shared.open(URL, options: [:]) { _ in }
        }))
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true, completion: completion)
    }
    
}
