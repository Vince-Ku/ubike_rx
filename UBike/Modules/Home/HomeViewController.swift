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
    @IBOutlet unowned var mapView : MKMapView!
    @IBOutlet unowned var showUserLocationButton : ShadowButton!
    @IBOutlet unowned var refreshBtn : ShadowButton!
    @IBOutlet unowned var showListBtn : ShadowButton!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var navigationButton: UIButton!
    @IBOutlet weak var favoriteStationButton: IdentifiableButton!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var bikesSpaceLabel: UILabel!
    @IBOutlet weak var emptySpaceLabel: UILabel!
    
    var viewModel: HomeViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViewModel()
        initUI()
        setUpRx()
        setupLocation()
        setupBottomSheetEvent()
        
        viewModel.viewDidLoad.accept(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
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
        let ubikeStationsRepository = UbikeStationsRepository(remoteDataSource: AlamofireNetworkService.shared,
                                                              ubikeStationCoreDataService: UBikeStationCoreDataService.shared)
        let mapper = UibikeStationBottomSheetStateMapper()
        viewModel = HomeViewModel(locationManager: locationManager, ubikeStationsRepository: ubikeStationsRepository, mapper: mapper)
    }
    
    private func initUI(){
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.register(UbikeStationAnnotationView.self, forAnnotationViewWithReuseIdentifier: "UbikeStationAnnotationView")
    }
    
    private func setUpRx(){
        
        showListBtn.rx.controlEvent(.touchUpInside).subscribe(onNext:{ [unowned self] in
            self.performSegue(withIdentifier: "bikesListSegue", sender: nil)

        }).disposed(by:disposeBag)
        
        refreshBtn.rx.tap
            .bind(to: viewModel.refreshButtonDidTap)
            .disposed(by: disposeBag)

        showUserLocationButton.rx.tap
            .bind(to: viewModel.showUserLocationButtonDidTap)
            .disposed(by: disposeBag)
        
//        viewModel.selectAnnotation.subscribe(onNext:{ [weak self] ubike in
//            guard let self = self , let selectedSno = ubike.sno else { return }
//
//            for annotation in self.mapView.annotations {
//                let ubikeAnnotation = self.mapView.view(for: annotation)?.annotation as? UBikeAnnotation
//
//                if let sno = ubikeAnnotation?.ubike?.sno {
//                    if sno == selectedSno {
//                        self.mapView.selectAnnotation(annotation, animated: true)
//                        break
//                    }
//                }
//            }
//
//        }).disposed(by: disposeBag)
        
        viewModel.showUibikeStationsAnnotation.asDriver()
            .drive(onNext: { [weak self] annotations in
                guard let mapView = self?.mapView else { return }
                
                //initialize
                mapView.removeAnnotations(mapView.annotations)
                mapView.removeOverlays(mapView.overlays)

                mapView.addAnnotations(annotations)
                
            })
            .disposed(by: disposeBag)
        
//        viewModel.guideTap.subscribe(onNext:{ [weak self] ubike in
//            guard let currentLocation = self?.currentLocation ,
//                  let lat = Double(ubike.lat ?? ""),
//                  let lng = Double(ubike.lng ?? "")  else { return }
//
//            // remove all current routes
//            if let overlays = self?.mapView.overlays {
//                self?.mapView.removeOverlays(overlays)
//            }
//
//            //
//            // destination
//            //
//            let toCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
//            let toMKPlacemark = MKPlacemark(coordinate: toCoordinate, addressDictionary: nil)
//            let toLocation = MKMapItem(placemark: toMKPlacemark)
//
//            //
//            // current location
//            //
//            let meCoordinate = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
//            let meMKPlacemark = MKPlacemark(coordinate: meCoordinate, addressDictionary: nil)
//            let meLocation = MKMapItem(placemark: meMKPlacemark)
//
//            //request for apple direction apit
//            let request = MKDirections.Request()
//            request.transportType = .walking
//            request.source = meLocation
//            request.destination = toLocation
//
//            let directions = MKDirections(request: request)
//
//            // call Apple api to get route
//            directions.calculate { [weak self] (response:MKDirections.Response?, error:Error?) in
//                if let resp = response, let route = resp.routes.first {// only show one route , temporarily
//
//                    // add expected teavel time
//                    switch route.expectedTravelTime {
//                    case 0..<60: // less then one minute
//                        self?.mapInfoVC?.guideBtn.setTitle("步行，1分鐘以內", for: .normal)
//                        break
//
//                    case 60..<3600: // less then one hour
//                        let title = "步行，\(Int(route.expectedTravelTime / 60))分鐘"
//                        self?.mapInfoVC?.guideBtn.setTitle(title, for: .normal)
//                        break
//
//                    case 3600...:
//                        let result = Int(route.expectedTravelTime).quotientAndRemainder(dividingBy: 3600)
//                        let hour = result.quotient
//                        let min = result.remainder / 60
//
//                        let title = "步行，\(hour)小時 \(min)分鐘"
//                        self?.mapInfoVC?.guideBtn.setTitle(title, for: .normal)
//                        break
//                    default:
//                        print("unpredicted expectedTravelTime")
//                    }
//
//                    // add route
//                    self?.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
//
//                    let center = CLLocation(latitude: (toCoordinate.latitude + meCoordinate.latitude)/2,
//                                            longitude: (toCoordinate.longitude + meCoordinate.longitude)/2)
//
//                    //use route.distance to show span
//                    //because it can definitely cover the whole route
//                    self?.showLocation(center, route.distance , route.distance)
//
//                }
//            }
//
//        }).disposed(by: disposeBag)
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
            .bind(to: viewModel.navigationButtonDidTap)
            .disposed(by: disposeBag)
        
        viewModel.updateUibikeSpaceText
            .bind(to: bikesSpaceLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.updateEmptySpaceText
            .bind(to: emptySpaceLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.updateFavoriteButtonState
            .bind(to: favoriteStationButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        viewModel.updateUibikeStationBottomSheet.asDriver()
            .drive(onNext: { [weak self] state in
                switch state {
                case .empty:
                    self?.favoriteStationButton.id = nil
                    self?.favoriteStationButton.isEnabled = false
                    self?.navigationButton.isEnabled = false
                    self?.stationNameLabel.text = "尚未選擇站點"
                    
                case .regular(let viewObject):
                    self?.favoriteStationButton.id = viewObject.id
                    self?.favoriteStationButton.isEnabled = true
                    self?.navigationButton.isEnabled = true
                    self?.stationNameLabel.text = viewObject.nameText
                }
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

extension HomeViewController : MKMapViewDelegate {
    //
    // route's style related
    //
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline{
            let render = MKPolylineRenderer(overlay: overlay)
            render.lineWidth = 10
            render.strokeColor = #colorLiteral(red: 0.03796023922, green: 0.5027811544, blue: 0.9708467497, alpha: 1)
            return render

        }
        return MKOverlayRenderer()
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
