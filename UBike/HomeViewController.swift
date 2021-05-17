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
    @IBOutlet unowned var showCurrentBtn : ShadowButton!
    @IBOutlet unowned var refreshBtn : ShadowButton!
    @IBOutlet unowned var showListBtn : ShadowButton!
    
    var viewModel = HomeViewModel()
    private var locationManager: CLLocationManager!
    private var firstLoading : Bool = true
    private var currentLocation: CLLocation? {
        didSet{
            if firstLoading {
                showLocation(currentLocation,5000,5000)
                firstLoading = false
            }
        }
    }
    weak var mapInfoVC : MapInfoViewController?
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        setUpRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "mapInfoSegue":
            mapInfoVC = segue.destination as? MapInfoViewController
            mapInfoVC?.homeViewModel = viewModel
            return
            
        case "bikesListSegue":
            let vc = segue.destination as? UBikesViewController
            vc?.homeViewModel = viewModel
            return
            
        default:
            print("unpredicted segue")
        }
    }
    
    private func initUI(){
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.register(UBikeAnnotationView.self, forAnnotationViewWithReuseIdentifier: "ubikePin")
        
        // location service
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
    }
    
    private func setUpRx(){
        
        showListBtn.rx.controlEvent(.touchUpInside).subscribe(onNext:{ [unowned self] in
            self.performSegue(withIdentifier: "bikesListSegue", sender: nil)

        }).disposed(by:disposeBag)
        
        refreshBtn.rx.controlEvent(.touchUpInside)
            .bind(to: self.viewModel.refresh)
            .disposed(by: disposeBag)

        showCurrentBtn.rx.controlEvent(.touchUpInside).subscribe(onNext:{ [unowned self] in
            showLocation(currentLocation, nil,nil)
            
        }).disposed(by:disposeBag)
        
        viewModel.selectAnnotation.subscribe(onNext:{ [weak self] ubike in
            guard let self = self , let selectedSno = ubike.sno else { return }
            
            for annotation in self.mapView.annotations {
                let ubikeAnnotation = self.mapView.view(for: annotation)?.annotation as? UBikeAnnotation
                
                if let sno = ubikeAnnotation?.ubike?.sno {
                    if sno == selectedSno {
                        self.mapView.selectAnnotation(annotation, animated: true)
                        break
                    }
                }
            }
            
        }).disposed(by: disposeBag)
        
        viewModel.ubikes.subscribe(onNext:{ [weak self] ubikes in
            guard let self = self else { return }
            //initialize
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.removeOverlays(self.mapView.overlays)
            
            //display ubikes station on Apple Map
            for ubike in ubikes{
                var uBikesPoint : [UBikeAnnotation] = []
                if let lat = Double(ubike.lat ?? "") , let lng = Double(ubike.lng ?? ""){
                    
                    let uBikePoint = UBikeAnnotation()
                    
                    uBikePoint.ubike = ubike
                    uBikePoint.title = ubike.sna
                    uBikePoint.coordinate.latitude = lat
                    uBikePoint.coordinate.longitude = lng
                    
                    uBikesPoint.append(uBikePoint)
                }
                self.mapView.addAnnotations(uBikesPoint)
            }
            
        }).disposed(by: disposeBag)
        
        viewModel.guideTap.subscribe(onNext:{ [weak self] ubike in
            guard let currentLocation = self?.currentLocation ,
                  let lat = Double(ubike.lat ?? ""),
                  let lng = Double(ubike.lng ?? "")  else { return }
            
            // remove all current routes
            if let overlays = self?.mapView.overlays {
                self?.mapView.removeOverlays(overlays)
            }
            
            //
            // destination
            //
            let toCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            let toMKPlacemark = MKPlacemark(coordinate: toCoordinate, addressDictionary: nil)
            let toLocation = MKMapItem(placemark: toMKPlacemark)
            
            //
            // current location
            //
            let meCoordinate = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            let meMKPlacemark = MKPlacemark(coordinate: meCoordinate, addressDictionary: nil)
            let meLocation = MKMapItem(placemark: meMKPlacemark)
            
            //request for apple direction apit
            let request = MKDirections.Request()
            request.transportType = .walking
            request.source = meLocation
            request.destination = toLocation

            let directions = MKDirections(request: request)
            
            // call Apple api to get route
            directions.calculate { [weak self] (response:MKDirections.Response?, error:Error?) in
                if let resp = response, let route = resp.routes.first {// only show one route , temporarily
                    
                    // add expected teavel time
                    switch route.expectedTravelTime {
                    case 0..<60: // less then one minute
                        self?.mapInfoVC?.guideBtn.setTitle("步行，1分鐘以內", for: .normal)
                        break
                        
                    case 60..<3600: // less then one hour
                        let title = "步行，\(Int(route.expectedTravelTime / 60))分鐘"
                        self?.mapInfoVC?.guideBtn.setTitle(title, for: .normal)
                        break
                        
                    case 3660...:
                        let result = Int(route.expectedTravelTime).quotientAndRemainder(dividingBy: 3600)
                        let hour = result.quotient
                        let min = result.remainder / 60
                        
                        let title = "步行，\(hour)小時 \(min)分鐘"
                        self?.mapInfoVC?.guideBtn.setTitle(title, for: .normal)
                        break
                    default:
                        print("unpredicted expectedTravelTime")
                    }
                    
                    // add route
                    self?.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
                    
                    let center = CLLocation(latitude: (toCoordinate.latitude + meCoordinate.latitude)/2,
                                            longitude: (toCoordinate.longitude + meCoordinate.longitude)/2)
                    
                    //use route.distance to show span
                    //because it can definitely cover the whole route
                    self?.showLocation(center, route.distance , route.distance)
                    
                }
            }
            
        }).disposed(by: disposeBag)
    }
    
    private func showLocation(_ location:CLLocation? ,_ latMeters : CLLocationDistance?,_ lngMeters:CLLocationDistance?){
        if let location = location{
            
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                longitude: location.coordinate.longitude)
            
            var region : MKCoordinateRegion!
            
            if let latMeters = latMeters , let lngMeters = lngMeters {
                region = MKCoordinateRegion(center: center, latitudinalMeters: latMeters ,longitudinalMeters: lngMeters)
            }else{
                region = MKCoordinateRegion(center: center, span: mapView.region.span)
            }
            
            mapView.setRegion(region, animated: true)
        }
    }

}


extension HomeViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
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
    
    //MARK: - Custom Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is UBikeAnnotation else {
            return nil
        }
        var annotationView : MKAnnotationView?
        
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "ubikePin") as? UBikeAnnotationView {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }else {
            annotationView = UBikeAnnotationView(annotation: annotation, reuseIdentifier: "ubikePin")
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        guard view.annotation is UBikeAnnotation else {
            return
        }
        let pin = view.annotation as! UBikeAnnotation
        
        if let lat = Double(pin.ubike?.lat ?? "") , let lng = Double(pin.ubike?.lng ?? "") {
            showLocation(CLLocation(latitude: lat, longitude: lng), nil, nil)
        }
        
        mapInfoVC?.ubike = pin.ubike
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView){
        guard view.annotation is UBikeAnnotation else {
            return
        }
        
        //initialize
        mapView.removeOverlays(mapView.overlays)
        mapInfoVC?.favoriteBtn.isEnabled = false
        mapInfoVC?.guideBtn.isEnabled = false
        mapInfoVC?.stationName.text = "尚未選擇站點"
        mapInfoVC?.bikesSpace.text = ":"
        mapInfoVC?.emptySpace.text = ":"
        mapInfoVC?.guideBtn.setTitle("", for: .normal)
    }
}
