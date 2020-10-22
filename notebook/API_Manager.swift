
//
//  APIHelper.swift
//  Hausbrandt
//
//  Created by Rohit Saini on 18/09/20.
//  Copyright © 2020 AccessDenied. All rights reserved.
//

import Foundation
import SystemConfiguration
import Alamofire
import SainiUtils

public class APIManager {
    
    static let sharedInstance = APIManager()
    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    func getMultipartHeader() -> [String:String]{
        return ["Content-Type":"multipart/form-data"]
    }
    
    func getFormDataHeader() -> [String:String]{
        return ["Content-Type":"form-data"]
    }
    func getJsonHeader() -> [String:String]{
        return ["Content-Type":"application/json"]
    }
    func getUrlCodedHeader() -> [String: String]{
        return ["Content-Type":"application/x-www-form-urlencoded"]
    }
    
    func getJsonHeaderWithToken() -> [String:String]{
        return ["Content-Type":"application/json", "Authorization":"Bearer " + "AppModel.shared.accessToken"]
    }
    
    func getMultipartHeaderWithToken() -> [String:String]{
        return ["Content-Type":"multipart/form-data", "Authorization":"Bearer " + "AppModel.shared.accessToken"]
    }
    
    
    func getx_www_orm_urlencoded() -> [String:String]{
        return ["Content-Type":"x-www-form-urlencoded", "Authorization":"Bearer " + "AppModel.shared.accessToken"]
    }
    
    func networkErrorMsg()
    {
        log.error("You are not connected to the internet")/
        displayToast("You are not connected to the internet")
    }
    
    //MARK:- ERROR CODES
    func handleError(errorCode: Int, _ message : String) {
        switch errorCode {
        case 101:
            print("Missing Required Properties")
        case 104:
            displayToast(message)
        case 500:
            displayToast(message)
        default:
            print(message)
        }
    }
    
    //MARK:- MULTIPART_IS_COOL
    func MULTIPART_IS_COOL(_ imageData : Data,param: [String: Any],api: String,login: Bool, fileName:String,_ completion: @escaping (_ dictArr: Data?) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        
        DispatchQueue.main.async {
            showLoader()
        }
        var headerParams :[String : String] = [String : String]()
        if login == true {
            headerParams = getMultipartHeaderWithToken()
        }
        else{
            headerParams = getMultipartHeader()
        }
        var params :[String : Any] = [String : Any] ()
        
        params["data"] = toJson(param)//Converting Array into JSON Object
        log.info("HEADERS: \(Log.stats()) \(headerParams)")/
        log.info("PARAMS: \(Log.stats()) \(params)")/
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in param {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if imageData.count != 0
            {
                multipartFormData.append(imageData, withName: fileName, fileName: getCurrentTimeStampValue() + ".png", mimeType: "image/png")
            }
        }, usingThreshold: UInt64.init(), to: api, method: .post
        , headers: headerParams) { (result) in
            switch result{
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                    log.inprocess("Upload Progress: \(Progress.fractionCompleted)")/
                })
                upload.responseJSON { response in
                    
                    DispatchQueue.main.async {
                        removeLoader()
                    }
                    
                    log.result("\(String(describing: response.result.value))")/
                    log.ln("prettyJSON Start \n")/
                    log.result("\(String(describing: response.data?.sainiPrettyJSON))")/
                    log.ln("prettyJSON End \n")/
                    switch response.result{
                    case .success:
                        log.result("\(String(describing: response.result.value))")/
                        log.ln("prettyJSON Start \n")/
                        log.result("\(String(describing: response.data?.sainiPrettyJSON))")/
                        log.ln("prettyJSON End \n")/
                        DispatchQueue.main.async {
                            completion(response.data)
                        }
                    case .failure(let error):
                        log.error("\(Log.stats()) \(error)")/
                        
                        break
                    }
                }
                
            case .failure(let error):
                
                log.error("\(Log.stats()) \(error)")/
                
                break
            }
        }
    }
    
    //MARK: - CREATE_VIDEO_POST
    func CREATE_VIDEO_POST(_ videoData : Data,param: [String: Any],api: String,login: Bool, _ completion: @escaping (_ dictArr: Data?) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        
        DispatchQueue.main.async {
            showLoader()
        }
        var headerParams :[String : String] = [String : String]()
        if login == true{
            headerParams = getMultipartHeaderWithToken()
        }
        else{
            headerParams = getMultipartHeader()
        }
        var params :[String : Any] = [String : Any] ()
        
        params["data"] = toJson(param)//Converting Array into JSON Object
        log.info("HEADERS: \(Log.stats()) \(headerParams)")/
        log.info("PARAMS: \(Log.stats()) \(params)")/
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if videoData.count != 0
            {
                multipartFormData.append(videoData, withName: "video", fileName: getCurrentTimeStampValue() + ".mov", mimeType: "video/mov")
            }
        }, usingThreshold: UInt64.init(), to: api, method: .post
        , headers: headerParams) { (result) in
            switch result{
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                    log.inprocess("Upload Progress: \(Progress.fractionCompleted)")/
                })
                upload.responseJSON { response in
                    
                    DispatchQueue.main.async {
                        removeLoader()
                    }
                    
                    log.result("\(String(describing: response.result.value))")/
                    log.ln("prettyJSON Start \n")/
                    log.result("\(String(describing: response.data?.sainiPrettyJSON))")/
                    log.ln("prettyJSON End \n")/
                    if let result = response.result.value as? [String:Any]{
                        if let code = result["code"] as? Int{
                            if(code == 100){
                                if login == true{
                                    log.success("\(Log.stats()) User Logged In Successfully!")/
                                }
                                else{
                                    log.success("\(Log.stats()) User register Successfully!")/
                                }
                                DispatchQueue.main.async {
                                    completion(response.data)
                                }
                                return
                            }
                            else{
                                if let message = result["message"] as? String{
                                    log.error("\(Log.stats()) \(message)")/
                                    displayToast(message)
                                }
                                return
                            }
                        }
                        if let message = result["message"] as? String{
                            log.error("\(Log.stats()) \(message)")/
                            displayToast(message)
                            return
                        }
                    }
                    if let error = response.result.error
                    {
                        log.error("\(Log.stats()) \(error)")/
                        return
                    }
                }
                
            case .failure(let error):
                log.error("\(Log.stats()) \(error)")/
                break
            }
        }
    }
    
    //MARK:- MULTIPART_IS_COOL
    func MULTIPART_IS_COOL_With_Pictures(_ imageData : Data,_ imageData2: Data,param: [String: Any],api: String,login: Bool, _ completion: @escaping (_ dictArr: Data?) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        
        DispatchQueue.main.async {
            showLoader()
        }
        var headerParams :[String : String] = [String : String]()
        if login == true{
            headerParams = getMultipartHeaderWithToken()
        }
        else{
            headerParams = getMultipartHeader()
        }
        var params :[String : Any] = [String : Any] ()
        
        params["data"] = toJson(param)//Converting Array into JSON Object
        log.info("PARAMS: \(Log.stats()) \(params)")/
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if imageData.count != 0
            {
                multipartFormData.append(imageData, withName: "image", fileName: getCurrentTimeStampValue() + ".png", mimeType: "image/png")
                multipartFormData.append(imageData2, withName: "enrollmentId", fileName: getCurrentTimeStampValue() + ".png", mimeType: "image/png")
            }
            
        }, usingThreshold: UInt64.init(), to: api, method: .post
        , headers: headerParams) { (result) in
            switch result{
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                    log.inprocess("Upload Progress: \(Progress.fractionCompleted)")/
                })
                upload.responseJSON { response in
                    
                    DispatchQueue.main.async {
                        removeLoader()
                    }
                    
                    log.result("\(String(describing: response.result.value))")/
                    log.ln("prettyJSON Start \n")/
                    log.result("\(String(describing: response.data?.sainiPrettyJSON))")/
                    log.ln("prettyJSON End \n")/
                    if let result = response.result.value as? [String:Any] {
                        if let code = result["code"] as? Int{
                            if(code == 100){
                                
                                DispatchQueue.main.async {
                                    completion(response.data)
                                }
                                return
                            }
                            else{
                                DispatchQueue.main.async {
                                    completion(response.data)
                                }
                                if let message = result["message"] as? String{
                                    displayToast(message)
                                }
                                return
                            }
                        }
                        if let message = result["message"] as? String{
                            displayToast(message)
                            return
                        }
                    }
                    if let error = response.result.error
                    {
                        displayToast(error.localizedDescription)
                        return
                    }
                }
                
            case .failure(let error):
                
                print(error)
                displayToast("Server Error please check server logs.")
                break
            }
        }
    }
    
    //MARK:- I AM COOL
    func I_AM_COOL(params: [String: Any],api: String,Loader: Bool,isMultipart:Bool,_ completion: @escaping (_ dictArr: Data?) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        
        if Loader == true{
            DispatchQueue.main.async {
                showLoader()
            }
        }
        
        var headerParams :[String : String] = [String: String]()
        var Params:[String: Any] = [String: Any]()
        if isMultipart == true{
            headerParams = getMultipartHeaderWithToken()
            Params["data"] = toJson(params)
        }
        else{
            headerParams  = getJsonHeaderWithToken()
            Params = params
        }
        log.success("WORKING_THREAD:->>>>>>> \(Thread.current.threadName)")/
        log.info("HEADERS: \(Log.stats()) \(headerParams)")/
        log.info("API: \(Log.stats()) \(api)")/
        log.info("PARAMS: \(Log.stats()) \(Params)")/
        
        Alamofire.request(api, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            
            DispatchQueue.main.async {
                removeLoader()
            }
            
            switch response.result {
            case .success:
                log.result("\(String(describing: response.result.value))")/
                log.ln("prettyJSON Start \n")/
                log.result("\(String(describing: response.data?.sainiPrettyJSON))")/
                log.ln("prettyJSON End \n")/
                DispatchQueue.main.async {
                    completion(response.data)
                }
            case .failure(let error):
                log.error("\(Log.stats()) \(error)")/
                
                break
            }
        }
    }
    
    //MARK:- I AM COOL
    func I_AM_DAMN_COOL(params: [String: Any],api: String,Loader: Bool,isMultipart:Bool,_ completion: @escaping (_ dictArr: Data?) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        
        if Loader == true{
            DispatchQueue.main.async {
                showLoader()
            }
        }
        
        var headerParams :[String : String] = [String: String]()
        var Params:[String: Any] = [String: Any]()
        if isMultipart == true{
            headerParams = getMultipartHeaderWithToken()
            Params["data"] = toJson(params)
        }
        else{
            headerParams  = getUrlCodedHeader()
            Params = params
        }
        log.success("WORKING_THREAD:->>>>>>> \(Thread.current.threadName)")/
        log.info("HEADERS: \(Log.stats()) \(headerParams)")/
        log.info("API: \(Log.stats()) \(api)")/
        log.info("PARAMS: \(Log.stats()) \(Params)")/
        
        Alamofire.request(api, method: .post, parameters: params, headers: headerParams).responseJSON { (response) in
            
            DispatchQueue.main.async {
                removeLoader()
            }
            
            switch response.result {
            case .success:
                log.result("\(String(describing: response.result.value))")/
                log.ln("prettyJSON Start \n")/
                log.result("\(String(describing: response.data?.sainiPrettyJSON))")/
                log.ln("prettyJSON End \n")/
                DispatchQueue.main.async {
                    completion(response.data)
                }
            case .failure(let error):
                log.error("\(Log.stats()) \(error)")/
                
                break
            }
        }
    }
    
    //MARK:- I_AM_COOL_GET
    func I_AM_COOL_GET(params: [String: Any], api: String, Loader: Bool, isMultipart:Bool, _ completion: @escaping (_ dictArr: Data?) -> Void){
        if !APIManager.isConnectedToNetwork()
        {
            APIManager().networkErrorMsg()
            return
        }
        if Loader == true{
            DispatchQueue.main.async {
                showLoader()
            }
        }
        var headerParams :[String : String] = [String: String]()
        var Params:[String: Any] = [String: Any]()
        if isMultipart == true{
            headerParams = getMultipartHeaderWithToken()
            Params["data"] = toJson(params)
        }
        else{
            headerParams = getJsonHeaderWithToken()
            Params = params
        }
        log.success("WORKING_THREAD:->>>>>>> \(Thread.current.threadName)")/
        log.info("HEADERS: \(Log.stats()) \(headerParams)")/
        log.info("API: \(Log.stats()) \(api)")/
        log.info("PARAMS: \(Log.stats()) \(Params)")/
        Alamofire.request(api, method: .get, encoding: JSONEncoding.default, headers: headerParams).responseJSON { (response) in
            DispatchQueue.main.async {
                removeLoader()
            }
            switch response.result {
            case .success:
                log.result("\(String(describing: response.result.value))")/
                log.ln("prettyJSON Start \n")/
                log.result("\(String(describing: response.data?.sainiPrettyJSON))")/
                log.ln("prettyJSON End \n")/
                DispatchQueue.main.async {
                    completion(response.data)
                }
            case .failure(let error):
                log.error("\(Log.stats()) \(error)")/
                break
            }
        }
    }

}
