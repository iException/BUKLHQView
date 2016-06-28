//
//  BUKLHQView.swift
//  Pods
//
//  Created by Monzy Zhang on 6/28/16.
//
//

import UIKit

@objc public protocol BUKLHQViewDelegate: class {
    func buk_lhqView(lhqView: BUKLHQView, didSelectButtonAtIndex index: Int)
}

@objc public protocol BUKLHQViewDataSource: class {
    func buk_numberOfButtonsInLHQView(lhqView: BUKLHQView) -> Int
    func buk_lhqView(lhqView: BUKLHQView, imageForButtonAtIndex index: Int) -> UIImage?
    func buk_lhqView(lhqView: BUKLHQView, titleForButtonAtIndex index: Int) -> String?
    func buk_lhqView(lhqView: BUKLHQView, titleColorForButtonAtIndex index: Int) -> UIColor?
}

@objc public class BUKLHQView: UIView {
    // MARK: properties
    // MARK: public
    public var buttons: [UIButton] = [UIButton]()
    public var circleView: UIImageView!
    public var isPlaying: Bool = false
    public weak var delegate: BUKLHQViewDelegate?
    public weak var dataSource: BUKLHQViewDataSource? {
        didSet {
            if let dataSource = self.dataSource {
                let numberOfButtons = dataSource.buk_numberOfButtonsInLHQView(lhqView: self)
                for i in 0..<numberOfButtons {
                    let button = UIButton(type: .system)
                    button.setTitleColor(UIColor.white(), for: .application)
                    button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
                    button.backgroundColor = UIColor.white()            
                    button.clipsToBounds = true
                    button.frame = buttonFrameFor(index: i, numberOfButton: numberOfButtons)
                    button.layer.cornerRadius = button.frame.width / 2
                    buttons.append(button)
                    circleView.addSubview(button)
                    
                }
            }
        }
    }
    
    // MARK: private
    private var timer: Timer!
    private var flowTimer: Timer!
    private var panGesture: UIPanGestureRecognizer!
    private var beginPoint: CGPoint = CGPoint.zero
    private var movePoint: CGPoint = CGPoint.zero
    private var date: Date = Date()
    private var startTouchDate: Date = Date()
    private var mStartAngle: CGFloat = 0.0
    private var mRadius: CGFloat {
        get {
            return frame.size.width / 2
        }
    }
    private var mFlingableValue: CGFloat = 200.0
    private var mTmpAngle: CGFloat = 0.0
    private var anglePerSecond: CGFloat = 0.0
    private var speed: CGFloat = 0.0
    
    // MARK: lifecycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.fireDate = Date.distantFuture
        timer?.invalidate()
    }
    
    // MARK: event handler
    @objc private func panHandler(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            mTmpAngle = 0.0
            beginPoint = sender.location(in: self)
            startTouchDate = Date()
        case .changed:
            let startAngleLast = mStartAngle
            movePoint = sender.location(in: self)
            let start = getAngle(point: beginPoint)
            let end = getAngle(point: movePoint)
            if getQuadrant(point: movePoint) == 1 || getQuadrant(point: movePoint) == 4 {
                mStartAngle += end - start
                mTmpAngle += end - start
            } else {
                mStartAngle += start - end
                mTmpAngle += start - end
            }
            layoutButtons()
            beginPoint = movePoint
            speed = mStartAngle - startAngleLast            
        case .ended:
            let time = Date().timeIntervalSince(startTouchDate)
            anglePerSecond = CGFloat(mTmpAngle * 50.0).divided(by: CGFloat(time))
            if CGFloat(fabsf(Float(anglePerSecond))) > mFlingableValue && !isPlaying {
                isPlaying = true
                flowTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(flowAction), userInfo: nil, repeats: true)
            }
        default:
            break
        }
    }
    
    @objc private func buttonPressed(sender: UIButton) {
        if let delegate = delegate, let index = buttons.index(of: sender) {
            delegate.buk_lhqView(lhqView: self, didSelectButtonAtIndex: index)
        }
    }

    // MARK: privates
    // MARK: calculator
    private func layoutButtons() {
        for (index, button) in buttons.enumerated() {
            button.frame = buttonFrameFor(index: index, numberOfButton: buttons.count)
        }
    }
    
    private func initUI() {
        //self
        translatesAutoresizingMaskIntoConstraints = false
        
        //circleview
        circleView = UIImageView(frame: bounds)
        circleView.layer.cornerRadius = frame.size.width / 2
        circleView.isUserInteractionEnabled = true
        circleView.clipsToBounds = true
        circleView.backgroundColor = UIColor.black()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        //pan
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panHandler))
        circleView.addGestureRecognizer(panGesture)
        
        addSubview(circleView)
    }
    
    private func buttonFrameFor(index: Int, numberOfButton: Int) -> CGRect {
        let width = frame.size.width / 4
        let viewRadius = frame.size.width / 2
        let radius = viewRadius / 1.5

        let angle = (CGFloat(index) / CGFloat(numberOfButton)) * CGFloat(M_PI * 2)
        let yy = viewRadius - cos(angle - mStartAngle) * radius
        let xx = viewRadius - sin(angle - mStartAngle) * radius        
        let origin = CGPoint(x: xx - width / 2, y: yy - width / 2)
        let size = CGSize(width: width, height: width)
        return CGRect(origin: origin, size: size)
    }
    
    private func getAngle(point: CGPoint) -> CGFloat {
        let x = point.x - mRadius
        let y = point.y - mRadius
        return asin(y / hypot(x, y))
    }
    
    private func getCurrentIndex() -> Int {
        var z = 0
        var b = 0
        var itemCount = CGFloat(buttons.count)
        b = Int(mStartAngle.divided(by: (CGFloat(2 * M_PI) / itemCount)))
        if mStartAngle >= 0 {
            z = (1 + b % Int(itemCount)) % Int(itemCount)
        } else {
            z = (Int(itemCount) - (-b) % Int(itemCount)) % Int(itemCount)
        }
        return z
    }
    
    private func getQuadrant(point: CGPoint) -> Int {
        var tmpX = Int(point.x - mRadius)
        var tmpY = Int(point.y - mRadius)
        if tmpX >= 0 {
            return tmpY >= 0 ?1: 4
        } else {
            return tmpY >= 0 ?2: 3 
        }
    }
    
    func flowAction() {
        if speed < 0.001 && speed > -0.001 {
            isPlaying = false
            flowTimer.invalidate()
            flowTimer = nil
            return
        }
        mStartAngle += speed
        speed = speed / 1.03
        layoutButtons()
    }
}
