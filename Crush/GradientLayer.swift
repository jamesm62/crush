//
//  GradientLayer.swift
//  Crush
//
//  Created by James McGivern on 7/16/18.
//  Copyright © 2018 Crush. All rights reserved.
//

import UIKit

class GradientLayer: CAGradientLayer {
    var gradient: GradientType? {
        didSet {
            startPoint = gradient?.x ?? CGPoint.zero
            endPoint = gradient?.y ?? CGPoint.zero
        }
    }
}
