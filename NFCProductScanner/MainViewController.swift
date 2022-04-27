//
//  ViewController.swift
//  NFCProductScanner
//
//  Created by Alfian Losari on 1/26/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit
import CoreNFC
import CoreLocation
import Auth0
import JWTDecode
import SimpleKeychain

class MainViewController: UIViewController {
    
    var session: NFCNDEFReaderSession?
    var productStore = ProductStore.shared
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func auth0Login(_ sender: Any) {
        print("--> Auth started")
        let keychain = A0SimpleKeychain(service: "Auth0")
        Auth0
            .webAuth()
            .scope("openid profile offline_access")
            .audience("https://dev-2xjf75by.us.auth0.com/userinfo")
            .start {
                switch $0 {
                case .failure(let error):
                    print(error)
                    break
                case .success(let credentials):
                        guard let accessToken = try? credentials.accessToken,
                      let refreshToken = credentials.refreshToken else {
                        // Handle error
                        return
                    }
                    print(accessToken)
                    print(refreshToken)
                    keychain.setString(accessToken, forKey: "access_token")
                    keychain.setString(refreshToken, forKey: "refresh_token")
                }

            }
        
        
    }
    
    @IBAction func scanTapped(_ sender: Any) {
        
        
        

        print("---> geofence monitoring !!! - Started ")
        self.locationManager.requestAlwaysAuthorization()
        // Your coordinates go here (lat, lon)
        let geofenceRegionCenter = CLLocationCoordinate2DMake(40.533550, -74.354460)
        
        /* Create a region centered on desired location,
           choose a radius for the region (in meters)
           choose a unique identifier for that region */
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter,
                                              radius: 100,
                                              identifier: "UniqueIdentifier")
        
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        self.locationManager.startMonitoring(for: geofenceRegion)
        print("---> geofence started monitoring !!! ")
        
        print("---> scan tapped !!! ")
        
        guard session == nil else {
            return
        }
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your iPhone near the item to learn more about it."
        session?.begin()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

}


extension MainViewController: NFCNDEFReaderSessionDelegate {
    
    
    // MARK: - NFCNDEFReaderSessionDelegate
    
    /// - Tag: processingTagData
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        
        guard
            let ndefMessage = messages.first,
            let record = ndefMessage.records.first,
            record.typeNameFormat == .absoluteURI || record.typeNameFormat == .nfcWellKnown,
            let payloadText = String(data: record.payload, encoding: .utf8),
            let sku = payloadText.split(separator: "/").last else {
                return
        }
        
        
        self.session = nil
        
        guard let product = productStore.product(withID: String(sku)) else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                let alertController = UIAlertController(title: "Info", message: "SKU Not found in catalog",preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alertController, animated: true, completion: nil)
            }
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.presentProductViewController(product: product)
        }
    }
    
    func presentProductViewController(product: Product) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
        vc.product = product
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .formSheet
        present(navVC, animated: true, completion: nil)
    }
    
    
    /// - Tag: endScanning
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Check the invalidation reason from the returned error.
        if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a success read
            // during a single tag read mode, or user canceled a multi-tag read mode session
            // from the UI or programmatically using the invalidate method call.
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                let alertController = UIAlertController(
                    title: "Session Invalidated",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        // A new session instance is required to read new tags.
        self.session = nil
    }
    
}
