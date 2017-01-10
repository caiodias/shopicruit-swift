//
//  main.swift
//  Shopicruit-Swift
//
//  Created by Caio Dias on 2017-01-09.
//  Copyright © 2017 Caio Dias. All rights reserved.
//

import Foundation

print("Hello, Shopify")

var semaphore = DispatchSemaphore(value: 0)
let shopicruitUrl: String = "https://shopicruit.myshopify.com/admin/orders.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"

func getUrl(str: String) -> URL? {
    guard let url = URL(string: shopicruitUrl) else {
        print("Error: cannot create URL")
        return nil
    }
    
    return url
}

func handleJSON(data: Data) {
    let json = JSON(data: data)
    
    let arrayTotalPricesCAD =  json["orders"].arrayValue.map({$0["total_price"].doubleValue})
    let arrayTotalPricesUSD =  json["orders"].arrayValue.map({$0["total_price_usd"].doubleValue})
    var totalOrderRevenueCAD : Double = 0
    var totalOrderRevenueUSD : Double = 0
    
    for price in arrayTotalPricesCAD {
        totalOrderRevenueCAD += price
    }
    
    for price in arrayTotalPricesUSD {
        totalOrderRevenueUSD += price
    }
    
    print("Total Order Revenue in 🇨🇦 currency is \(totalOrderRevenueCAD)")
    print("Total Order Revenue in 🇺🇸 currency is \(totalOrderRevenueUSD)")
    
    let exchangeRate = totalOrderRevenueCAD / totalOrderRevenueUSD
    let exchangeRateFormatted = String(format: "%.2f", exchangeRate)
    
    print("The 🇺🇸 currency value by the day of this order was \(exchangeRateFormatted) 🇨🇦")
}

if let url = getUrl(str: shopicruitUrl) {
    let urlRequest = URLRequest(url: url)
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    
    // MARK: Request
    let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
        print(error ?? "No errors 😀")
        
        if (response != nil) {
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) { // success call
                    handleJSON(data: data!)
                } else {
                    print("oh, no! the shopicruit isn't working 😞")
                }
            }
        }
        
        semaphore.signal()
    })
    
    task.resume()
    semaphore.wait()
} else {
    print("This message should never appear, so I will leave an emoticon here: ☠")
}


