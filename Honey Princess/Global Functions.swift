//
//  Global Functions.swift
//  Honey Princess
//
//  Created by Bryan Ye on 31/1/17.
//  Copyright © 2017 Bryan Ye. All rights reserved.
//

import UIKit

func doesOpenSansExist() -> Bool {
    print(UIFont.fontNames(forFamilyName: "Open Sans"))
    
    let fontFamilies = UIFont.familyNames
    if fontFamilies.contains("Open Sans") {
        let fontNames = UIFont.fontNames(forFamilyName: "Open Sans")
        if fontNames.contains("OpenSans") {
            return true
        }
    }
    
    return false
}
