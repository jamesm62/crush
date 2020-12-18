//
//  Camera.swift
//  rate
//
//  Created by James McGivern on 12/9/17.
//  Copyright © 2017 rate. All rights reserved.
//

import UIKit
import AVFoundation
import Parse

class Camera: UIViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet var background: UIView!
    
    @IBOutlet var photo: UIButton!
    @IBOutlet var switchCamera: UIButton!
    @IBOutlet var flash: UIButton!
    
    var capturedImage = UIImage(named: "profilePic.png")
    
    var right = UIBarButtonItem()
    
    var isPhoto = true
    
    let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])
    
    var isBackCamera = true
    var flashOn = false
    
    var captureSession = AVCaptureSession()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var capturePhotoOutput = AVCapturePhotoOutput()
    
    var isCaptureSessionConfigured = false
    
    override func viewWillAppear(_ animated: Bool) {
        
        previewLayer.session = captureSession
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraView.layer.insertSublayer(previewLayer, at: 0)
        
        if self.isCaptureSessionConfigured {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        } else {
            // First time: request camera access, configure capture session and start it.
            self.checkCameraAuthorization({ authorized in
                guard authorized else {
                    let alert = UIAlertController(title: "Oops", message: "This app is not authorized to use the camera", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                self.configureCaptureSession({ success in
                    guard success else { return }
                    self.isCaptureSessionConfigured = true
                    self.captureSession.startRunning()
                })
            })
        }
    }
    
    override func viewDidLoad() {
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = false
        photoSettings.previewPhotoFormat = [
            kCVPixelBufferPixelFormatTypeKey : photoSettings.availablePreviewPhotoPixelFormatTypes.first!,
            kCVPixelBufferWidthKey : 500,
            kCVPixelBufferHeightKey : 500
            ] as [String: Any]
        
        right = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(Camera.done))
        right.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = right
        right.isEnabled = false
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = UIColor.black
        navigationItem.backBarButtonItem = backItem
    }
    
    @objc func done() {
        if isProfilePic {
            pic = capturedImage!
        } else {
            addedPics.append(capturedImage!)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        self.previewLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width)
    }
    
    func checkCameraAuthorization(_ completionHandler: @escaping ((_ authorized: Bool) -> Void)) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            //The user has previously granted access to the camera.
            completionHandler(true)
        case .notDetermined:
            // The user has not yet been presented with the option to grant video access so request access.
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { success in
                completionHandler(success)
            })
        case .denied:
            // The user has previously denied access.
            completionHandler(false)
            
        case .restricted:
            // The user doesn't have the authority to request access e.g. parental restriction.
            completionHandler(false)
        }
    }
    
    func defaultDevice(isBackCamera: Bool) -> AVCaptureDevice {
        if isBackCamera {
            if let device = AVCaptureDevice.default(.builtInDualCamera,
                                                    for: .video,
                                                    position: .back) {
                return device // use dual camera on supported devices
            } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                           for: .video,
                                                           position: .back) {
                return device // use default back facing camera otherwise
            } else {
                fatalError("All supported devices are expected to have at least one of the queried capture devices.")
            }
        } else {
            if let device = AVCaptureDevice.default(.builtInDualCamera,
                                                    for: .video,
                                                    position: .front) {
                return device // use dual camera on supported devices
            } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                           for: .video,
                                                           position: .front) {
                return device // use default back facing camera otherwise
            } else {
                fatalError("All supported devices are expected to have at least one of the queried capture devices.")
            }
        }
    }
    
    func configureCaptureSession(_ completionHandler: ((_ success: Bool) -> Void)) {
        var success = false
        defer { completionHandler(success) } // Ensure all exit paths call completion handler.
        
        // Get video input for the default camera.
        let videoCaptureDevice = defaultDevice(isBackCamera: isBackCamera)
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            print("Unable to obtain video input for default camera.")
            return
        }
        
        // Create and configure the photo output.
        let capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput.isHighResolutionCaptureEnabled = false
        
        // Make sure inputs and output can be added to session.
        guard self.captureSession.canAddInput(videoInput) else { return }
        guard self.captureSession.canAddOutput(capturePhotoOutput) else { return }
        
        // Configure the session.
        self.captureSession.beginConfiguration()
        self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
        self.captureSession.addInput(videoInput)
        self.captureSession.addOutput(capturePhotoOutput)
        self.captureSession.commitConfiguration()
        
        self.capturePhotoOutput = capturePhotoOutput
        
        success = true
    }

    @IBAction func photo(_ sender: Any) {
        if isPhoto {
            isPhoto = false
            photo.setImage(UIImage(named: "back.png"), for: .normal)
            switchCamera.isHidden = true
            flash.isHidden = true
            snapPhoto()
        } else {
            isPhoto = true
            right.isEnabled = false
            photo.setImage(UIImage(named: "cameraIcon.png"), for: .normal)
            switchCamera.isHidden = false
            flash.isHidden = false
            captureSession.startRunning()
            previewLayer.connection?.isEnabled = true
        }
    }
    
    func snapPhoto() {
        let capturePhotoOutput = self.capturePhotoOutput
        let photoSettings = AVCapturePhotoSettings(from: self.photoSettings)
        
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        previewLayer.connection?.isEnabled = false
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        captureSession.stopRunning()
        if error != nil {
            let alert = UIAlertController(title: "Oops", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            guard let previewImage = photo.previewCGImageRepresentation() else { return }
            let normalPreviewImage = previewImage.takeUnretainedValue()
            let photo = UIImage(cgImage: normalPreviewImage)
            let jpegData = UIImageJPEGRepresentation(photo, 0.5)!
            let dataProvider = CGDataProvider(data: jpegData as CFData)
            let def = CGColorRenderingIntent.defaultIntent
            let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: def)
            var image = UIImage(cgImage: cgImageRef!)
            if isBackCamera {
                image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
            } else {
                image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.leftMirrored)
            }
            
            let sz = image.size
            
            UIGraphicsBeginImageContextWithOptions(
                CGSize(width:sz.width, height:sz.width),
                false, 0)
            image.draw(at:CGPoint(x: 0, y: -(sz.height-sz.width)/2))
            let tmpImg = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            capturedImage = tmpImg
            
            right.isEnabled = true
        }
    }
    
    @IBAction func switchCamera(_ sender: Any) {
        captureSession.stopRunning()
        captureSession.removeInput(captureSession.inputs[0])
        isBackCamera = !isBackCamera
        let videoCaptureDevice = defaultDevice(isBackCamera: isBackCamera)
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            print("Unable to obtain video input for default camera.")
            return
        }
        if videoCaptureDevice.isFlashAvailable {
            flash.isEnabled = true
        } else {
            flash.isEnabled = false
        }
        
        guard self.captureSession.canAddInput(videoInput) else { return }
        self.captureSession.addInput(videoInput)
        self.captureSession.commitConfiguration()
        photoSettings.flashMode = .off
        flash.setImage(UIImage(named: "flash.png"), for: .normal)
        captureSession.startRunning()
    }
    
    @IBAction func flash(_ sender: Any) {
        if flashOn {
            flashOn = false
            photoSettings.flashMode = .off
            flash.setImage(UIImage(named: "flash.png"), for: .normal)
        } else {
            flashOn = true
            photoSettings.flashMode = .on
            flash.setImage(UIImage(named: "flashOn.png"), for: .normal)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
