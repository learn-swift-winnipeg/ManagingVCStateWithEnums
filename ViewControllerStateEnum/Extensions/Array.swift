//
//  Array.swift
//  ViewControllerStateEnum
//
//  Created by Justin Stanley on 2017-07-11.
//  Copyright © 2017 Justin Stanley. All rights reserved.
//

import Foundation

public extension Array {
    public var randomElement: Iterator.Element? {
        guard !self.isEmpty else { return nil }
        
        let randomIndex = Int(arc4random_uniform(UInt32(self.count)))
        
        return self[randomIndex]
    }
}
