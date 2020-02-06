//
//  OTMClient.swift
//  OnTheMap_YY
//
//  Created by MacAir11 on 2019/12/9.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

class OTMClient {
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case login
        case getUserData
        case getStudentLocation
        case logout
        case postNewStudentLocation
        case putStudentLocation
        
        var stringValue: String {
            switch self {
            case .login:
                return Endpoints.base + "/session"
            case .getUserData:
                return Endpoints.base + "/users/" + StudentModel.accountKey
            case .getStudentLocation:
                return Endpoints.base + "/StudentLocation?order=-updatedAt"
            case .logout:
                return Endpoints.base + "/session"
            case .postNewStudentLocation:
                return Endpoints.base + "/StudentLocation"
            case .putStudentLocation:
                return Endpoints.base + "/StudentLocation/" + StudentModel.objectId
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }

    }
    
    class func taskForPOSTRequest<ResponseType: Decodable>(url: URL, apiName: String, httpMethod: String, responseType: ResponseType.Type, jsonbody: String, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.httpBody = jsonbody.data(using: .utf8)
        
        if apiName == "UDACITY_API" {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }else{
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                guard var data = data else {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    return
                }
                
                if apiName == "UDACITY_API" {
                    data = data.subdata(in: Range(uncheckedBounds: (5, data.count)))
                }
                
                //print(String(data: data, encoding: .utf8)!)

                let decoder = JSONDecoder()
                do {
                    let responseObject = try decoder.decode(ResponseType.self, from: data)
                    DispatchQueue.main.async {
                        completion(responseObject, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func taskForGetRequest<ResponseType : Decodable >(url: URL, apiName: String, response : ResponseType.Type, completion:@escaping(ResponseType?,Error?) -> Void){
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard var data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            if apiName == "UDACITY_API" {
                data = data.subdata(in: Range(uncheckedBounds: (5, data.count)))
            }
            
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func login(email: String, password: String, completion: @escaping (_ success: Bool, _ accountKey: String?, _ sessionId: String?, _ error: Error?) -> Void) {
        
        let body = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
        
        taskForPOSTRequest(url: Endpoints.login.url, apiName: "UDACITY_API", httpMethod: "POST", responseType: OTMResponse.self, jsonbody: body) { (response, error) in
            if let response = response {
                StudentModel.accountKey = response.account.key
                StudentModel.sessionId = response.session.id
                completion(true, StudentModel.accountKey, StudentModel.sessionId, nil)
            } else {
                completion(false, nil, nil, error)
            }
        }
    }

    class func getUserName(completion: @escaping(UserName?, Error?)-> Void){
        
        taskForGetRequest(url: Endpoints.getUserData.url, apiName: "UDACITY_API", response: UserName.self) { (response, error) in
            guard let response = response else {
                print(error!)
                completion(nil,error)
                return
            }

            StudentModel.userFirstName = response.firstName
            StudentModel.userLastName = response.lastName
            completion(response,nil)
        }
    }


    class func getStudentLocation(completion:@escaping([StudentLocation]?,Error?) -> Void){
        
        taskForGetRequest(url: Endpoints.getStudentLocation.url, apiName: "PARSE_API", response: MultiStudentLocation.self) { (response, error) in
            guard let response = response else {
                print(error!)
                completion(nil,error)
                return
            }

            completion(response.results,nil)
        }
    }

    class func logout(completion: @escaping () -> Void) {
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                return
            }
            
            guard let data = data else {
                return
            }
            let newData = data.subdata(in: Range(uncheckedBounds: (5, data.count)))
            print(String(data: newData, encoding: .utf8)!)
            
            completion()
        }
        task.resume()
        
    }
    
    class func postNewStudentLocation(uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double,  longitude: Double, completion: @escaping (PostStudentLocation?, Error?) -> Void) {
        
        let body = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        taskForPOSTRequest(url: Endpoints.postNewStudentLocation.url, apiName: "PARSE_API", httpMethod: "POST", responseType: PostStudentLocation.self, jsonbody: body) { (response, error) in
            if let response = response {
                StudentModel.objectId = response.objectId
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
  
    class func putStudentLocation(uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double,  longitude: Double, completion: @escaping (PostStudentLocation?, Error?) -> Void) {
        
        let body = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        
        taskForPOSTRequest(url: Endpoints.putStudentLocation.url, apiName: "PARSE_API", httpMethod: "PUT", responseType: PostStudentLocation.self, jsonbody: body) { (response, error) in
            if let response = response {
                StudentModel.objectId = response.objectId
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
 
}
