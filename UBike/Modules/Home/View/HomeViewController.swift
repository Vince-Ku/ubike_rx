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
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.showsUserLocation = true
        map.register(UbikeStationAnnotationView.self, forAnnotationViewWithReuseIdentifier: "UbikeStationAnnotationView")
        return map
    }()
    
    private let buttonsContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    private let showListButton: RoundedRectangleShadowButton = {
        let btn = RoundedRectangleShadowButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "icon_list"), for: .normal)
        btn.backgroundColor = .white
        btn.imageEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
        return btn
    }()

    private let refreshAnnotationButton: RoundedRectangleShadowButton = {
        let btn = RoundedRectangleShadowButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "icon_refresh"), for: .normal)
        btn.backgroundColor = .white
        btn.imageEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
        return btn
    }()

    private let positioningButton: RoundedRectangleShadowButton = {
        let btn = RoundedRectangleShadowButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "icon_navigation"), for: .normal)
        btn.backgroundColor = .white
        btn.imageEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
        return btn
    }()
    
    private let bottomSheetView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()

    private let favoriteStationButton: ToggleButton = {
        let btn = ToggleButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.imageEdgeInsets = .init(top: 30, left: 30, bottom: 30, right: 30) //temp
        btn.setImage(UIImage(named: "icon_star_off"), for: .normal)
        btn.setImage(UIImage(named: "icon_star_on"), for: .selected)
        return btn
    }()

    private let stationNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let bikesSpaceIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "icon_bicycle"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let bikesSpaceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = .darkGray
        return label
    }()

    private let emptySpaceIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "icon_parkinglot"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptySpaceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = .darkGray
        return label
    }()
    
    private let navigationButton: BorderButton = {
        let btn = BorderButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "icon-direction"), for: .normal)
        btn.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 5)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        return btn
    }()
    
    private let viewModel: HomeViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupMapEvent()
        setupBottonsEvent()
        setupLocationEvent()
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
    
    private func setupLayout() {
        // Map
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Buttons
        buttonsContainerStackView.addArrangedSubview(showListButton)
        buttonsContainerStackView.addArrangedSubview(refreshAnnotationButton)
        buttonsContainerStackView.addArrangedSubview(positioningButton)
        view.addSubview(buttonsContainerStackView)
        NSLayoutConstraint.activate([
            buttonsContainerStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            showListButton.heightAnchor.constraint(equalToConstant: 40),
            showListButton.widthAnchor.constraint(equalToConstant: 40)
        ])

        // Bottom Sheet
        view.addSubview(bottomSheetView)
        NSLayoutConstraint.activate([
            bottomSheetView.topAnchor.constraint(equalTo: buttonsContainerStackView.bottomAnchor, constant: 10),
            bottomSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSheetView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        bottomSheetView.addSubview(favoriteStationButton)
        NSLayoutConstraint.activate([
            favoriteStationButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteStationButton.heightAnchor.constraint(equalToConstant: 30),
            favoriteStationButton.topAnchor.constraint(equalTo: bottomSheetView.topAnchor, constant: 20),
            favoriteStationButton.rightAnchor.constraint(equalTo: bottomSheetView.rightAnchor, constant: -20)
        ])
        
        bottomSheetView.addSubview(stationNameLabel)
        NSLayoutConstraint.activate([
            stationNameLabel.centerYAnchor.constraint(equalTo: favoriteStationButton.centerYAnchor),
            stationNameLabel.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: 20),
        ])
        
        bottomSheetView.addSubview(bikesSpaceIconImageView)
        NSLayoutConstraint.activate([
            bikesSpaceIconImageView.topAnchor.constraint(equalTo: stationNameLabel.bottomAnchor, constant: 10),
            bikesSpaceIconImageView.leadingAnchor.constraint(equalTo: stationNameLabel.leadingAnchor),
            bikesSpaceIconImageView.heightAnchor.constraint(equalToConstant: 25),
            bikesSpaceIconImageView.widthAnchor.constraint(equalToConstant: 25)
        ])
        
        bottomSheetView.addSubview(bikesSpaceLabel)
        NSLayoutConstraint.activate([
            bikesSpaceLabel.leadingAnchor.constraint(equalTo: bikesSpaceIconImageView.trailingAnchor, constant: 5),
            bikesSpaceLabel.centerYAnchor.constraint(equalTo: bikesSpaceIconImageView.centerYAnchor)
        ])
        
        bottomSheetView.addSubview(emptySpaceIconImageView)
        NSLayoutConstraint.activate([
            emptySpaceIconImageView.topAnchor.constraint(equalTo: bikesSpaceIconImageView.bottomAnchor, constant: 10),
            emptySpaceIconImageView.leadingAnchor.constraint(equalTo: stationNameLabel.leadingAnchor),
            emptySpaceIconImageView.heightAnchor.constraint(equalToConstant: 25),
            emptySpaceIconImageView.widthAnchor.constraint(equalToConstant: 25)
        ])
        
        bottomSheetView.addSubview(emptySpaceLabel)
        NSLayoutConstraint.activate([
            emptySpaceLabel.leadingAnchor.constraint(equalTo: emptySpaceIconImageView.trailingAnchor, constant: 5),
            emptySpaceLabel.centerYAnchor.constraint(equalTo: emptySpaceIconImageView.centerYAnchor)
        ])
        
        bottomSheetView.addSubview(navigationButton)
        NSLayoutConstraint.activate([
            navigationButton.leadingAnchor.constraint(equalTo: stationNameLabel.leadingAnchor),
            navigationButton.trailingAnchor.constraint(equalTo: favoriteStationButton.trailingAnchor),
            navigationButton.heightAnchor.constraint(equalToConstant: 36),
            navigationButton.topAnchor.constraint(equalTo: emptySpaceIconImageView.bottomAnchor, constant: 10),
            navigationButton.bottomAnchor.constraint(equalTo: bottomSheetView.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    private func setupMapEvent(){
        mapView.delegate = self
        
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
    
    private func setupBottonsEvent() {
        showListButton.rx.tap
            .bind(to: viewModel.showListButtonDidTap)
            .disposed(by:disposeBag)
        
        refreshAnnotationButton.rx.tap
            .bind(to: viewModel.refreshAnnotationButtonDidTap)
            .disposed(by: disposeBag)

        positioningButton.rx.tap
            .bind(to: viewModel.positioningButtonDidTap)
            .disposed(by: disposeBag)
    }
    
    private func setupLocationEvent() {
        viewModel.updateMapRegion.asSignal()
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
