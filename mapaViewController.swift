//
//  MapaViewController.swift
//  wonderRun
//
//  Created by  on 6/3/19.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit



class MapaViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    var seguimiento = false
    var distorignal:Double = 0
    var horas:String = "00"
    var minutos:String = "00"
    var segundos:String = "00"
    
   
    @IBAction func parar(_ sender: UIButton) {
        self.seguimiento = false
        self.poly.removeAll()
    }
    
    @IBOutlet weak var velocidadact: UILabel!
    
    @IBOutlet weak var velocidadM: UILabel!
    
    @IBOutlet weak var cronometro: UILabel!
    
    
    @IBAction func empezar(_ sender: UIButton) {
        self.seguimiento=true
    }
    
    var userCoords = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var poly:[CLLocationCoordinate2D] = []
    
    @IBOutlet weak var map: MKMapView!
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    @IBOutlet weak var distancia: UILabel!
    @IBOutlet weak var mostrarUbicacion: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        startLocation = nil
        //Fetch User Current Location
        self.fetchUserCurrentLocation()
        print(userCoords.latitude + userCoords.longitude)
        locationManager.startUpdatingLocation()
        
        map.delegate = self        // Do any additional setup after loading the view.
    }
    func fetchUserCurrentLocation() {
        
        let locationFetch = FetchLocation.SharedManager
        locationFetch.parentObject = self
        //locationFetch.startUpdatingLocation()
        locationFetch.completionBlock = { [unowned self] (userCoordinates, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "")
            }
            
            if let userLocation = userCoordinates as? CLLocationCoordinate2D {
                print(userLocation.latitude, userLocation.longitude)
                self.userCoords = userLocation
                //self.poly.append(self.userCoords)
            }
            self.map.centerCoordinate=self.userCoords
            let latDelta:CLLocationDegrees=0.01
            let longDelta:CLLocationDegrees=0.01
            let span:MKCoordinateSpan=MKCoordinateSpan(latitudeDelta: latDelta,longitudeDelta: longDelta)
            let region:MKCoordinateRegion=MKCoordinateRegion(center: self.userCoords,span: span)
            self.map.showsUserLocation=true
            self.map.setRegion(region, animated: true)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let posicion = locations[0].coordinate
        
        print(posicion.latitude, posicion.longitude)
        self.userCoords = posicion
        
        self.map.centerCoordinate=self.userCoords
        let latDelta:CLLocationDegrees=0.01
        let longDelta:CLLocationDegrees=0.01
        let span:MKCoordinateSpan=MKCoordinateSpan(latitudeDelta: latDelta,longitudeDelta: longDelta)
        let region:MKCoordinateRegion=MKCoordinateRegion(center: self.userCoords,span: span)
        self.map.setRegion(region, animated: false)
        if self.seguimiento
        {
            self.poly.append(self.userCoords)
            let linea=MKPolyline(coordinates: self.poly, count: self.poly.count)
            self.map.addOverlay(linea)
            if poly.count>2
            {
                calcularDistancia(coor1: poly[poly.count-1], coor2: poly[poly.count-2])
            }
            /*else if self.seguimiento==2
             {
             self.seguimiento=1
             self.poly.removeAll()
             }*/
            tiempo()
            velocidadMedia()
            
        }
        
        
    }
    func calcularDistancia( coor1: CLLocationCoordinate2D, coor2: CLLocationCoordinate2D)
    {
        /*let c1lat = coor1.latitude
         let c1lon = coor1.longitude
         let c2lat = coor2.latitude
         let c2lon = coor2.longitude
         
         let toRad = 0.0174532925
         let dlat = (c2lat-c1lat)
         let dlong = (c2lon-c1lon)
         let a = sin(dlat/2) * sin(dlat/2) + cos(c1lat * toRad) * cos(c2lat * toRad) * sin(dlong/2) * sin(dlong/2)
         let c = 2 * atan2(sqrt(a), sqrt(1-a))
         let distancia = self.distancia.text
         if distancia != nil {
         var distanc=6371 * c
         self.distorignal = self.distorignal + distanc
         distanc = self.distorignal.rounded()/100
         //let dist = Double(distancia)! + distanc
         self.distancia.text=String(distanc)
         }*/
        let cor1=CLLocation(latitude: coor1.latitude, longitude: coor1.longitude)
        let cor2=CLLocation(latitude: coor2.latitude, longitude: coor2.longitude)
        let distanceinmet = cor2.distance(from: cor1)
        //print(distanceinmet.rounded())
        self.distorignal=self.distorignal+distanceinmet/1000
        
        self.distancia.text=String(rounded(toPlaces: 1,numero: self.distorignal))
        velocidaAct(distancia: distanceinmet.rounded())
        
        
        
    }
    func tiempo()
    {
        var horass:Int = Int(self.horas)!
        var minutoss:Int = Int(self.minutos)!
        var segundoss:Int = Int(self.segundos)!
        segundoss = segundoss + 1
        
        if segundoss <= 9
        {
            self.segundos="0"+String(segundoss)
        }
        else if segundoss == 59
        {
            self.segundos="00"
            minutoss=minutoss+1
        }
        else
        {
            self.segundos=String(segundoss)
        }
        
        if minutoss <= 9
        {
            self.minutos="0"+String(minutoss)
        }
        else if minutoss == 59
        {
            self.minutos="00"
            horass=horass+1
        }
        else{
            self.minutos=String(minutoss)
        }
        
        if horass <= 9
        {
            self.horas="0"+String(horass)
        }
        else
        {
            self.horas=String(horass)
        }
        
        cronometro.text=self.horas+":"+self.minutos+":"+self.segundos
    }
    func velocidaAct(distancia:Double)
    {
        let velocidad = (distancia*3600)/1000
        self.velocidadact.text=String(Int(velocidad.rounded()))
    }
    func velocidadMedia()
    {
        var tiempo:Double=(Double(self.horas)! * 60 * 60)+(Double(self.minutos)! * 60)+Double(self.segundos)!
        tiempo = tiempo/3600
        let espacio:Double=self.distorignal//.rounded()/100
        
        var velocidad=espacio/tiempo
        
        
        self.velocidadM.text=String(Int(velocidad.rounded()))
        
        
    }
    func rounded(toPlaces places:Int,numero:Double) -> Double {
        let divisor = pow(10.0, Double(places))
        return (numero * divisor).rounded() / divisor
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //Return an `MKPolylineRenderer` for the `MKPolyline` in the `MKMapViewDelegate`s method
        if let polyline = overlay as? MKPolyline {
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = .blue
            testlineRenderer.lineWidth = 2.0
            return testlineRenderer
        }
        fatalError("Something wrong...")
        //return MKOverlayRenderer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
