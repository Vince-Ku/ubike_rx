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
                showLocation(currentLocation)
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
            print("prepare none ")
        }
    }
    
    private func initUI(){
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pin")
        
        // location service
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
    }
    
    private func showLocation(_ location:CLLocation?){
        if let location = location{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            let region = MKCoordinateRegion(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
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
            showLocation(currentLocation)
            
        }).disposed(by:disposeBag)
        
        viewModel.selectAnnotation.subscribe(onNext:{ [weak self] ubike in
            guard let self = self , let lat = Double(ubike.lat ?? ""), let lng = Double(ubike.lng ?? ""), let selectedSno = ubike.sno else { return }
            
            self.showLocation(CLLocation(latitude: lat, longitude: lng))
            
            for annotation in self.mapView.annotations {
                let ubikeAnnotation = self.mapView.view(for: annotation)?.annotation as? UBikePointAnnotation
                
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
            
            //display ubikes station on Apple Map
            for ubike in ubikes{
                
                var uBikesPoint : [UBikePointAnnotation] = []
                if let lat = Double(ubike.lat ?? "") , let lng = Double(ubike.lng ?? ""){
                    
                    let uBikePoint = UBikePointAnnotation()
                    
                    uBikePoint.ubike = ubike
                    uBikePoint.title = ubike.sna
                    uBikePoint.coordinate.latitude = lat
                    uBikePoint.coordinate.longitude = lng
                    
                    uBikesPoint.append(uBikePoint)
                }
                self.mapView.addAnnotations(uBikesPoint)
            }
            
        }).disposed(by: disposeBag)
        
        viewModel.navigateTap.subscribe(onNext:{ [weak self] ubike in
            guard let currentLocation = self?.currentLocation ,
                  let lat = Double(ubike?.lat ?? ""),
                  let lng = Double(ubike?.lng ?? "")  else { return }
            
            if let overlays = self?.mapView.overlays {
                self?.mapView.removeOverlays(overlays)
            }
            
            //MKPlacemark(coordinate: CLLocationCoordinate2D, addressDictionary: [String : Any]?)
            // coordinate 2D ---> MKPlacemark ---> MKMapItem
            let toCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            let toMKPlacemark: MKPlacemark = MKPlacemark(coordinate: toCoordinate, addressDictionary: nil)
            let toLocation: MKMapItem = MKMapItem(placemark: toMKPlacemark)
            toLocation.name = "去的地方";
            
            let meCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            let meMKPlacemark: MKPlacemark = MKPlacemark(coordinate: meCoordinate, addressDictionary: nil)
            let meLocation: MKMapItem = MKMapItem(placemark: meMKPlacemark)
            meLocation.name = "我在的地方";
            
            // 创建请求导航路线数据信息
            let request: MKDirections.Request = MKDirections.Request()
            request.transportType = .walking
            // 创建起点:根据 CLPlacemark 地标对象创建 MKPlacemark 地标对象
            request.source = meLocation
            // 创建终点:根据 CLPlacemark 地标对象创建 MKPlacemark 地标对象)
            request.destination = toLocation

            // 创建导航对象，根据请求，获取实际路线信息
            let directions: MKDirections = MKDirections(request: request)

            // 计算路线信息
            directions.calculate { (response:MKDirections.Response?, error:Error?) in
                if let resp = response {
                    // 遍历 routes （MKRoute对象）：因为有多种路线
                    for route: MKRoute in resp.routes {
                        // 添加折线
                        self?.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
                    }
                }
            }
            
        }).disposed(by: disposeBag)
    }

}


extension HomeViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("didUpdateLocations")
//        print("經度 -> \(String(describing: locations.last?.coordinate.latitude))")
//        print("緯度 -> \(String(describing: locations.last?.coordinate.longitude))")
        currentLocation = locations.last
        
    }
}

extension HomeViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // 折线覆盖层
        if overlay is MKPolyline{
            
            // 创建折线渲染对象 (不同的覆盖层数据模型, 对应不同的覆盖层视图来显示)
            let render: MKPolylineRenderer = MKPolylineRenderer(overlay: overlay)
            render.lineWidth = 6                // 设置线宽
            render.strokeColor = UIColor.red    // 设置颜色
            return render

        }
        return MKOverlayRenderer()
    }
    
    //temp //MARK: - Custom Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is UBikePointAnnotation else {
            return nil
        }
        var annotationView : MKAnnotationView?
        
        //
        // why use dequeueReusableAnnotationView(withIdentifier, image can't reset
        //
//        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") {
//            annotationView = dequeuedAnnotationView
//            annotationView?.annotation = annotation
//        }else {
//        }
        
        annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        
        if let annotationView = annotationView {
            let ubikePin = annotationView.annotation as? UBikePointAnnotation
            
            if let bikesSpace = Int(ubikePin?.ubike?.sbi ?? "") ,
               let emptySpace = Int(ubikePin?.ubike?.bemp ?? "") {
                
                // according to remaining parking space to set the image
                if bikesSpace == 0{
                    annotationView.image = UIImage(named: "icon_pin_red")
                }else if emptySpace == 0{
                    annotationView.image = UIImage(named: "icon_pin_brown")
                }else{
                    annotationView.image = UIImage(named: "icon_pin_green")
                }
            }
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        guard view.annotation is UBikePointAnnotation else {
            return
        }
        let pin = view.annotation as! UBikePointAnnotation
        
        //temp
        view.frame = CGRect(origin: view.frame.origin, size: CGSize(width: view.frame.size.width * 1.5, height: view.frame.size.height * 1.5))

        if let lat = Double(pin.ubike?.lat ?? "") , let lng = Double(pin.ubike?.lng ?? "") {
            showLocation(CLLocation(latitude: lat, longitude: lng))
        }
        
        mapInfoVC?.ubike = pin.ubike
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView){
        guard view.annotation is UBikePointAnnotation else {
            return
        }
        //temp
        view.frame = CGRect(origin: view.frame.origin,
                            size: CGSize(width: view.frame.size.width / 1.5,
                                         height: view.frame.size.height / 1.5))
        
        //initialize
        mapView.removeOverlays(mapView.overlays)
        mapInfoVC?.stationName.text = "尚未選擇站點"
        mapInfoVC?.bikesSpace.text = ":"
        mapInfoVC?.emptySpace.text = ":"
        mapInfoVC?.guideBtn.setTitle("", for: .normal)
    }
}
