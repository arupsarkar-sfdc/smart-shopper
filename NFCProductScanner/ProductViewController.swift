//
//  ProductViewController.swift
//  NFCProductScanner
//
//  Created by Alfian Losari on 1/26/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit

class ProductViewController: UITableViewController {
    
    var product: Product!
    
    @IBAction func closeTapped(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func addToCart(sender:UIButton) {
        print("---> Add to Cart")
//        let configuration = URLSessionConfiguration .default
//        let session = URLSession(configuration: configuration)
//        let urlString = NSString(format: "https://reqbin.com/echo/get/json")
//        print("---> url triggered... \(urlString)")
//        let request : NSMutableURLRequest = NSMutableURLRequest()
//        request.url = NSURL(string: NSString(format: "%@", urlString) as String) as URL?
//        request.httpMethod = "GET"
//        request.timeoutInterval = 30
//
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let url = URL(string: "https://bnb-loyalty-app.herokuapp.com/cart/insert?item=SKU-RES2-982019")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("---> Error - \(error)")
                //self.handleClientError(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                //self.handleServerError(response)
                return
            }
            if let mimeType = httpResponse.mimeType, mimeType == "application/json",
                let data = data,
                let string = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    print("---> string = \(string)")
                    print("---> data = \(data)")
                    //self.webView.loadHTMLString(string, baseURL: url)
                }
            }
        }
        task.resume()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = product.name
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        let footerView = UIView()
        //footerView.backgroundColor = colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)

        
        
        
        
        footerView.backgroundColor = UIColor.lightGray
        footerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height:100)
        
        
        let button = UIButton()
        button.frame = CGRect(x: 20, y: 10, width: 300, height: 50)
        button.setTitle("Add to Cart", for: .normal)
        button.setTitleColor( UIColor.black, for: .normal)
        button.backgroundColor = UIColor.cyan
        button.addTarget(self, action: #selector(addToCart), for: .touchUpInside)
        footerView.addSubview(button)
        
        //tableView.tableFooterView = UIView()
        tableView.tableFooterView = footerView
        

        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath)
            let imageView = cell.viewWithTag(1001) as? UIImageView
            imageView?.image = product.image
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath)
            cell.textLabel?.text = "Name"
            cell.detailTextLabel?.text = product.name
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath)
            cell.textLabel?.text = "Price"
            cell.detailTextLabel?.text = product.price
            return cell
         
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath)
            cell.textLabel?.text = "Availability"
            cell.detailTextLabel?.text = product.inStock ? "In stock" : "Out of stock"
            return cell
            
            
        case 4:
          
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath)
            cell.textLabel?.text = "SKU"
            cell.detailTextLabel?.text = product.id
            return cell
            
            
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = product.description
            return cell
                        
            
        default: fatalError()
            
            
        }
        
        
        
    }
    
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footerView = UIView()
//        //footerView.backgroundColor = colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
//        footerView.backgroundColor = UIColor.lightGray
//        footerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height:10)
//        return footerView
//    }
}
