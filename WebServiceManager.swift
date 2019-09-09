//
//  WebServiceManager.swift
//  My Train Info
//
//  Created by AppAspect on 01/12/18.
//  Copyright © 2018 AppAspect. All rights reserved.
//

import UIKit
import Alamofire
import KRProgressHUD

let objWebServiceInstanc = WebServiceManager.sharedInstance
typealias ServiceResponse = (_ responce: [String:Any],_ sucess:Bool) -> Void

class WebServiceManager: NSObject
{
    static let sharedInstance = WebServiceManager()
    
    func CallAPI(urlString:String, parameters: Parameters, showProgressBar: Bool, onCompletion: @escaping ServiceResponse){
        if isInternetAvailable == false {
            show_NoInternetAlert()
            return
        }
        if showProgressBar {
            KRProgressHUD.show()
        }
        let apiKey = Key_apikey + appDelegate().APIkeyValue + "/"

        let fullURl = BaseAPIURL + urlString.replacingOccurrences(of: Key_apikey, with: apiKey)
        print("Full URl: \(fullURl)")
        
//        Alamofire.request(fullURl, method: .get).responseJSON { (response) in
//
//        }
        Alamofire.request(fullURl, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success(_):
                // check for errors
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("Inside error guard")
                    print(response.result.error!)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        KRProgressHUD.dismiss()
                    }
                    return
                }
                // make sure we got some JSON since that's what we expect
                guard let json = response.result.value as? [String: Any] else {
                    print("didn't get todo object as JSON from API")
                    if let error = response.result.error {
                        print("Error: \(error)")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        KRProgressHUD.dismiss()
                    }
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    KRProgressHUD.dismiss()
                }
                switch Int(json["ResponseCode"] as? String ?? "") {
                case 200:
                    onCompletion(json, true)
                    break
                case 201:
//                    showAlertWith(title: "Alert", message: (json["Message"] != nil) ? json["Message"] as! String : "Failed to load")
                    let message = ((json["Message"] as? String) != nil) ? json["Message"] as! String : "Failed to load"
                    let dict = ["Message" : message]
                    onCompletion(dict, false)
                    break
                default:
                    break
                }
                
                break
            case .failure(_):
                print("Error response:\(response.result.error!)")
                let dict = ["Message" : response.result.error?.localizedDescription]
                onCompletion(dict as [String : Any],false)
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    KRProgressHUD.dismiss()
                }
                break
            }
        }
    }
    /*
    func CallAPI(centerURL:String, parameters: Parameters, showProgressBar: Bool, onCompletion: @escaping ServiceResponse){
        if isInternetAvailable == false {
            show_NoInternetAlert()
            return
        }
        if showProgressBar {
            KRProgressHUD.show()
        }
        let fullURl = BaseAPIURL + centerURL + Key_apikey + appDelegate().APIkeyValue
        print("Full URl: \(fullURl)")
        
        Alamofire.request(fullURl, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success(_):
                if response.result.value != nil
                {
                    print("success response:\(response.result.value!)")
                    if (response.result.value as! NSDictionary)["response_code"] as! Int == 200
                    {
                        onCompletion(response.result.value as! NSDictionary,true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            KRProgressHUD.dismiss()
                        }
                    }
                    else{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            KRProgressHUD.dismiss()
                        }
                        
                        if (response.result.value as! NSDictionary)["response_code"] as! Int == 220
                        {
                            showAlertWith(title: "Alert", message: "Sorry! This PNR is either flushed or not yet genrated.")
                        }
                        else if (response.result.value as! NSDictionary)["response_code"] as! Int == 221
                        {
                            showAlertWith(title: "Alert", message: "Sorry! This PNR is Invalid.")
                        }
                        else if (response.result.value as! NSDictionary)["response_code"] as! Int == 404
                        {
                            showAlertWith(title: "Alert", message: "Sorry! Data couldn’t be loaded on our servers. No data available.")
                        }
                        else if (response.result.value as! NSDictionary)["response_code"] as! Int == 405
                        {
                            showAlertWith(title: "Alert", message: "Data couldn’t be loaded on our servers. Request couldn’t go through.")
                        }
                        else if (response.result.value as! NSDictionary)["response_code"] as! Int == 500
                        {
                            showAlertWith(title: "Alert", message: "Something wrong, Please contact to admin.")
                        }
                        else if (response.result.value as! NSDictionary)["response_code"] as! Int == 210
                        {
                            showAlertWith(title: "Alert", message: "Train doesn’t run on the date queried.")
                        }
                    }
                }
                break
            case .failure(_):
                print("Error response:\(response.result.error!)")
                let dict = [response.result.error?.localizedDescription: "message"]
                onCompletion(dict as NSDictionary,false)
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    KRProgressHUD.dismiss()
                }
                break
            }
        }
    }*/
    

}




//MARK:- How to call
let srtURL = key_TrainSchedule + Key_apikey + "TrainNumber/" + train_number + "/"
objWebServiceInstanc.CallAPI(urlString: srtURL, parameters: [:], showProgressBar: true) { (dictResponse, success) in
    print("dictResponse ==== %@",dictResponse)
    if success {
    }
}
