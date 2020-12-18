//
//  GradientView.swift
//  Crush
//
//  Created by James McGivern on 7/16/18.
//  Copyright © 2018 Crush. All rights reserved.
//

import UIKit

class GradientView: UIView {
    override public class var layerClass: Swift.AnyClass {
        get {
            return GradientLayer.self
        }
    }
}
