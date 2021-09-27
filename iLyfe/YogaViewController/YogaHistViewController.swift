//
//  YogaHistViewController.swift
//  iLyfe
//
//  Created by Sugianto on 4/8/19.
//  Copyright © 2019 Sugianto. All rights reserved.
//

import UIKit

class YogaHistViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var graphView: UIView!
    
    @IBOutlet weak var redViewLegend: UIView!
    @IBOutlet weak var yellowViewLegend: UIView!
    @IBOutlet weak var greenViewLegend: UIView!
    @IBOutlet weak var redViewLegend2: UIView!
    @IBOutlet weak var yellowViewLegend2: UIView!
    @IBOutlet weak var greenViewLegend2: UIView!
    
    @IBOutlet weak var timeLabelBasic: UILabel!
    @IBOutlet weak var timeLabelIntermediate: UILabel!
    @IBOutlet weak var timeLabelAdvance: UILabel!
    
    let shapeLayerRed = CAShapeLayer()
    let shapeLayerYellow = CAShapeLayer()
    let shapeLayerGreen = CAShapeLayer()
    
    var histDetail: YogaHistory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        setPageDetail()
        
        setGraph()
    }
    
    func setGraph() {
        
        // Get the time for each yoga difficulty
        let basicTime = Double(histDetail!.basicTime)
        let intermediateTime = Double(histDetail!.intermediateTime)
        let advanceTime = Double(histDetail!.advanceTime)
        let totalTime: Double = basicTime + intermediateTime + advanceTime
        
        print(basicTime/totalTime)
        print(intermediateTime/totalTime)
        print(advanceTime/totalTime)
        
        let endFirst = CGFloat(basicTime/totalTime) * (2 * CGFloat.pi)
        let endSecond = (CGFloat(intermediateTime/totalTime) * (2 * CGFloat.pi)) + endFirst
        let endThird = (CGFloat(advanceTime/totalTime) * (2 * CGFloat.pi)) + endSecond
        
        let center = CGPoint(x: graphView.bounds.width / 2, y: graphView.bounds.height / 2)
        
        // Track layer
        let trackLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 20
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        graphView.layer.addSublayer(trackLayer)
        
        // Shape layer RED
        let circularPathForRed = UIBezierPath(arcCenter: center, radius: 100, startAngle: 0, endAngle: endFirst, clockwise: true)

        shapeLayerRed.path = circularPathForRed.cgPath
        
        shapeLayerRed.strokeColor = UIColor.red.cgColor
        shapeLayerRed.lineWidth = 20
        shapeLayerRed.fillColor = UIColor.clear.cgColor
        shapeLayerRed.lineCap = CAShapeLayerLineCap.round
        shapeLayerRed.strokeEnd = 0
        graphView.layer.addSublayer(shapeLayerRed)
        
        // Shape layer YELLOW
        let circularPathForYellow = UIBezierPath(arcCenter: center, radius: 100, startAngle: endFirst, endAngle: endSecond, clockwise: true)
        
        shapeLayerYellow.path = circularPathForYellow.cgPath
        
        shapeLayerYellow.strokeColor = UIColor.yellow.cgColor
        shapeLayerYellow.lineWidth = 20
        shapeLayerYellow.fillColor = UIColor.clear.cgColor
        shapeLayerYellow.lineCap = CAShapeLayerLineCap.round
        shapeLayerYellow.strokeEnd = 0
        graphView.layer.addSublayer(shapeLayerYellow)
        
        // Shape layer GREEN
        let circularPathForGreen = UIBezierPath(arcCenter: center, radius: 100, startAngle: endSecond, endAngle: endThird, clockwise: true)
        
        shapeLayerGreen.path = circularPathForGreen.cgPath
        
        shapeLayerGreen.strokeColor = UIColor.green.cgColor
        shapeLayerGreen.lineWidth = 20
        shapeLayerGreen.fillColor = UIColor.clear.cgColor
        shapeLayerGreen.lineCap = CAShapeLayerLineCap.round
        shapeLayerGreen.strokeEnd = 0
        graphView.layer.addSublayer(shapeLayerGreen)
        
        
        // Add animation
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = 1
        
        basicAnimation.duration = 0.5
        
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayerYellow.add(basicAnimation, forKey: "addAnimation")
        shapeLayerRed.add(basicAnimation, forKey: "addAnimation")
        shapeLayerGreen.add(basicAnimation, forKey: "addAnimation")
    }
    
    // Set page data
    func setPageDetail() {
        // Get total time doing yoga
        let total = histDetail!.basicTime + histDetail!.intermediateTime + histDetail!.advanceTime
        
        let seconds = total % 60
        let minutes = (total / 60) % 60
        let hours = (total / 60) / 60
        
        timeLabel.text = "\(hours) Hours \(minutes) Minutes \(seconds) Seconds"
        
        // Change legend UIView
        redViewLegend.layer.cornerRadius = 10
        yellowViewLegend.layer.cornerRadius = 10
        greenViewLegend.layer.cornerRadius = 10
        
        redViewLegend2.layer.cornerRadius = 10
        yellowViewLegend2.layer.cornerRadius = 10
        greenViewLegend2.layer.cornerRadius = 10
        
        // Set time for each yoga
        let basicTime = histDetail?.basicTime
        let intermediateTime = histDetail?.intermediateTime
        let advanceTime = histDetail?.advanceTime
        
        timeLabelBasic.text = "\((basicTime! / 60) / 60) Hours \((basicTime! / 60) % 60) Minutes \(basicTime! % 60) Seconds"
        timeLabelIntermediate.text = "\((intermediateTime! / 60) / 60) Hours \((intermediateTime! / 60) % 60) Minutes \(intermediateTime! % 60) Seconds"
        timeLabelAdvance.text = "\((advanceTime! / 60) / 60) Hours \((advanceTime! / 60) % 60) Minutes \(advanceTime! % 60) Seconds"
    }
    
    // Set nav bar
    func setNavigationBar() {
        
        let date = histDetail!.date
        // Change the format of date
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd,MM,yyyy"
        
        let showDate = inputFormatter.date(from: date)
        inputFormatter.dateFormat = "dd MMM yyyy"
        
        let resultStr = inputFormatter.string(from: showDate!)
        
        // Title
        navigationItem.title = resultStr
        
        // Create back button
        let backButton = UIBarButtonItem(
            image: UIImage(named: "backIcon"),
            style: .plain,
            target: self,
            action: #selector(backButtonPressed(sender:)))
        navigationItem.leftBarButtonItem = backButton
    }
    
    // When back button is pressed
    @objc func backButtonPressed(sender: UIBarButtonItem) {
        // Back to previous page
        _ = navigationController?.popViewController(animated: true)
    }

}
