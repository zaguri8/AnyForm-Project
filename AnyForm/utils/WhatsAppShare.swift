//
//  WhatsAppShare.swift
//  AnyForm
//
//  Created by נדב אבנון on 25/07/2021.
//

import Foundation
import UIKit
import PDFKit
class WhatsAppShare {
    static  func whatsappShareWithImages(_ url: URL,controller:inout UIDocumentInteractionController, viewcontroller:UIViewController){
        let urlWhats = "whatsapp://app"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                    controller = UIDocumentInteractionController(url: url)
                    controller.uti = "net.whatsapp.document"
                    controller.presentOpenInMenu(from: CGRect.zero, in: viewcontroller.view, animated: true)
                } else {
                    let alert = UIAlertController(title: "AnyForm", message: "Could not open Whatsapp", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default))
                    viewcontroller.present(alert, animated: true)
                }
            }
        }
        
    }
    
    
}
