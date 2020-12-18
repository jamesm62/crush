//
//  Homescreen.swift
//  rate
//
//  Created by James McGivern on 12/6/17.
//  Copyright © 2017 rate. All rights reserved.
//

import UIKit
import Parse

var name = ""
var last = ""
var age = 0
var gender = true
var username = ""
var pass = ""
var pic = UIImage(named: "profilePic.png")!
var addedPics:[UIImage] = []
var descrip = ""
var school:String?
var latitude:Double = 0.0
var longitude:Double = 0.0

extension UIColor {
    convenience init(_ hex: UInt) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

typealias GradientType = (x: CGPoint, y: CGPoint)

enum GradientPoint {
    case leftRight
    case rightLeft
    case topBottom
    case bottomTop
    case topLeftBottomRight
    case bottomRightTopLeft
    case topRightBottomLeft
    case bottomLeftTopRight
    
    func draw() -> GradientType {
        switch self {
        case .leftRight:
            return (x: CGPoint(x: 0, y: 0.5), y: CGPoint(x: 1, y: 0.5))
        case .rightLeft:
            return (x: CGPoint(x: 1, y: 0.5), y: CGPoint(x: 0, y: 0.5))
        case .topBottom:
            return (x: CGPoint(x: 0.5, y: 0), y: CGPoint(x: 0.5, y: 1))
        case .bottomTop:
            return (x: CGPoint(x: 0.5, y: 1), y: CGPoint(x: 0.5, y: 0))
        case .topLeftBottomRight:
            return (x: CGPoint(x: 0, y: 0), y: CGPoint(x: 1, y: 1))
        case .bottomRightTopLeft:
            return (x: CGPoint(x: 1, y: 1), y: CGPoint(x: 0, y: 0))
        case .topRightBottomLeft:
            return (x: CGPoint(x: 1, y: 0), y: CGPoint(x: 0, y: 1))
        case .bottomLeftTopRight:
            return (x: CGPoint(x: 0, y: 1), y: CGPoint(x: 1, y: 0))
        }
    }
}

protocol GradientViewProvider {
    associatedtype GradientViewType
}

extension GradientViewProvider where Self: UIView, GradientViewType: CAGradientLayer {
    var gradientLayer: Self.GradientViewType {
        return layer as! Self.GradientViewType
    }
}

extension UIView: GradientViewProvider {
    typealias GradientViewType = GradientLayer
}

class HomeScreen: UIViewController {
    
    @IBOutlet var signIn: UIButton!
    @IBOutlet var register: UIButton!
    override func viewDidLoad() {
        /*
        var backgroundImage = UIImageView(image: UIImage(named: "homeScreenBackground.png"))
        self.view.addSubview(backgroundImage)
        self.view.sendSubview(toBack: backgroundImage)
        */
        
        signIn.layer.borderColor = UIColor.white.cgColor
        register.layer.borderColor = UIColor.white.cgColor
        signIn.layer.borderWidth = 2.0
        register.layer.borderWidth = 2.0
        
        name = ""
        last = ""
        age = 0
        gender = true
        username = ""
        pass = ""
        pic = UIImage(named: "profilePic.png")!
        addedPics = []
        descrip = ""
        school = ""
        latitude = 0.0
        longitude = 0.0
        
        signIn.layer.cornerRadius = 5
        register.layer.cornerRadius = 5
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
        
        self.view.gradientLayer.colors = [UIColor.cyan.cgColor, UIColor.magenta.cgColor]
        self.view.gradientLayer.gradient = GradientPoint.bottomLeftTopRight.draw()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    @IBAction func signIn(_ sender: Any) {
        self.performSegue(withIdentifier: "signIn", sender: self)
    }
    @IBAction func register(_ sender: Any) {
        self.performSegue(withIdentifier: "register", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

