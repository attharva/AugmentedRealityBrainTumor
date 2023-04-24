//
//  Extension.swift
//  ARMajic
//
//  Created by Attharva Kulkarni on 16/03/23.
//  Copyright © 2023 Attharva Kulkarni. All rights reserved.
//

import UIKit

enum UIUserInterfaceIdiom: Int {
    case undefined
    case phone
    case pad
}

struct ScreenSize{
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
    static let maxlength = max(ScreenSize.width, ScreenSize.height)
    static let minLength = min(ScreenSize.width, ScreenSize.height)
}

struct DeviceType {
    static let isiPhoneX = UIDevice.current.userInterfaceIdiom ==
    .phone && ScreenSize.maxlength == 812.0
    static let isiPad = UIDevice.current.userInterfaceIdiom ==
        .pad && ScreenSize.maxlength == 1024.0
    static let isiPadPro = UIDevice.current.userInterfaceIdiom ==
        .pad && ScreenSize.maxlength == 1366.0
    
}


extension UIColor{
    convenience init(red: Int, green: Int , blue:Int){
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/256
        let newBlue = CGFloat(blue)/255
    
        self.init(red: newRed, green: newGreen, blue:newBlue, alpha:1.0)
    }
}



extension Int {
    var degreesToRadians: Double {return Double (self) * .pi/180 }
    
    
}
