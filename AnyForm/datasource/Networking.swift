//
//  Networking.swift
//  AnyForm
//
//  Created by נדב אבנון on 17/07/2021.
//

import Foundation
class Networking {
    func getForm(type:FormType,callback:@escaping (Data?,Error?)->Void) {
        DispatchQueue.global(qos:.userInteractive).async {
            guard let url = type.getFormURL() else {return}
            do {
                var data:Data?
                data = try Data(contentsOf: url)
                DispatchQueue.main.async {
                    callback(data,nil)
                }
            }catch {
                DispatchQueue.main.async {
                    callback(nil,error)
                }
            }
        }
    }
    
    func getGenericForm(url:String, callback:@escaping (Data?,Error?)->Void) {
        DispatchQueue.global(qos:.userInteractive).async {
            guard let url = URL(string:url) else {
                return}
            do {
                var data:Data?
                data = try Data(contentsOf: url)
                DispatchQueue.main.async {
                    callback(data,nil)
                }
            }catch {
                DispatchQueue.main.async {
                    callback(nil,error)
                }
            }
        }
    }
}
