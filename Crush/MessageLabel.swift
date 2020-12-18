//
//  MessageLabel.swift
//  rate
//
//  Created by James McGivern on 4/22/18.
//  Copyright © 2018 rate. All rights reserved.
//

import UIKit

@IBDesignable
extension MessageLabel {
    
    // currently UIEdgeInsets is no supported IBDesignable type,
    // so we have to fan it out here:
    @IBInspectable
    var leftTextInset: CGFloat {
        set { textInsets.left = newValue }
        get { return textInsets.left }
    }
    
    // Same for the right, top and bottom edges.
}

@IBDesignable
extension MessageLabel {
    
    // currently UIEdgeInsets is no supported IBDesignable type,
    // so we have to fan it out here:
    @IBInspectable
    var rightTextInset: CGFloat {
        set { textInsets.right = newValue }
        get { return textInsets.right }
    }
    
    // Same for the right, top and bottom edges.
}

@IBDesignable
extension MessageLabel {
    
    // currently UIEdgeInsets is no supported IBDesignable type,
    // so we have to fan it out here:
    @IBInspectable
    var topTextInset: CGFloat {
        set { textInsets.top = newValue }
        get { return textInsets.top }
    }
    
    // Same for the right, top and bottom edges.
}

@IBDesignable
extension MessageLabel {
    
    // currently UIEdgeInsets is no supported IBDesignable type,
    // so we have to fan it out here:
    @IBInspectable
    var bottomTextInset: CGFloat {
        set { textInsets.bottom = newValue }
        get { return textInsets.bottom }
    }
    
    // Same for the right, top and bottom edges.
}

class MessageLabel: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = UIEdgeInsetsInsetRect(bounds, textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return UIEdgeInsetsInsetRect(textRect, invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, textInsets))
    }
}
