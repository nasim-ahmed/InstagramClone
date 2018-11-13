//
//  CameraController.swift
//  DuoSnap
//
//  Created by Nasim on 10/18/17.
//  Copyright © 2017 Nasim. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController, UIViewControllerTransitioningDelegate, PreviewPhotoContainerViewDelegate {

    var image: UIImage?
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "right_arrow_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.yellow.withAlphaComponent(0.8)
        return view
    }()
    
    
    let capturePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "capture_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        return button
    }()
    
    let capturePhotoButtonBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    
    @objc func handleDismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self
        
        setupCaptureSession()
        
        setupHUD()

    }
    
    
    
    let customAnimationPresenter = CustomAnimationPresenter()
    let customAnimationDismisser = CustomAnimationDismisser()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return customAnimationPresenter
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationDismisser
    }
   
    
    fileprivate func setupHUD() {
        view.addSubview(overlayView)
        overlayView.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: view.frame.width/2, height: 0)
        
        
        view.addSubview(capturePhotoButtonBackground)
        capturePhotoButtonBackground.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 100)
        view.addSubview(capturePhotoButtonBackground)
        
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingRight: 12, paddingBottom: 0, width: 50, height: 50)
        
        
        view.addSubview(capturePhotoButton)
        capturePhotoButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 20, width: 60, height: 60)
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc func handleCapturePhoto() {
        let settings = AVCapturePhotoSettings()
        self.output.capturePhoto(with: settings, delegate: self)
    }

    let output = AVCapturePhotoOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch let err {
            print("Could not setup camera input:", err)
        }
        
        //2. setup outputs
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        previewLayer?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
//        previewLayer?.frame = view.frame
        view.layer.addSublayer(previewLayer!)
        
        captureSession.startRunning()
    }
   
    override var shouldAutorotate: Bool{
        return false
    }
    
    func didHandleNext() {
        let sharePhotoController = SharePhotoController()
        sharePhotoController.selectedImage = containerView?.previewImageView.image
        navigationController?.pushViewController(sharePhotoController, animated: true)
    }
    
    var containerView: PreviewPhotoContainerView?
}


extension CameraController: AVCapturePhotoCaptureDelegate{
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {return}
        
        let previewImage = UIImage(data: imageData)
        
        
        containerView = PreviewPhotoContainerView()
        containerView?.delegate = self
        containerView?.previewImageView.image = previewImage
        view.addSubview(containerView!)
        containerView?.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
        
    }
}


