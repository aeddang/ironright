
import Foundation
import UIKit
import os.log

protocol GestureDelegate{
    func stateChange(_ g:Gesture,e:Gesture.GestureType)
    func rotateChange(_ g:Gesture,rotate:Double)
    func pinchChange(_ g:Gesture,dist:Double)
    func gestureComplete(_ g:Gesture,e:Gesture.GestureType)
}

extension GestureDelegate {
    func stateChange(_ g:Gesture,e:Gesture.GestureType){}
    func rotateChange(_ g:Gesture,rotate:Double){}
    func pinchChange(_ g:Gesture,dist:Double){}
    func gestureComplete(_ g:Gesture,e:Gesture.GestureType){}
}

open class GestureBody: UIView, Component{
    var closeType = Gesture.GestureType.PAN_DOWN
    private(set) lazy var isVertical = { return closeType == Gesture.GestureType.PAN_UP || closeType == Gesture.GestureType.PAN_DOWN }()
    private(set) lazy var isHorizontal = { return closeType == Gesture.GestureType.PAN_LEFT || closeType == Gesture.GestureType.PAN_RIGHT }()
    
    lazy var gesture:Gesture = {
        let gesture = Gesture(self, isVertical: isVertical, isHorizontal: isHorizontal)
        return gesture
    }()
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        onCreated()
    }
    
    deinit {
        os_log("GestureBody : deinit", log: OSLog.default, type: .info)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        onCreated()
    }
    
    func onCreated() {
    }
    
    func onDestroy() {
        gesture.onDestroy()
    }
    
    override open func touchesBegan(_ touches:Set<UITouch>, with event: UIEvent?) {
        gesture.touchesBegan( touches )
        super.touchesBegan(touches, with: event)
    }
    
    override open func touchesMoved(_ touches:Set<UITouch>, with event: UIEvent?) {
        var triger:Bool = true
        triger = gesture.touchesMoved( touches )
        if triger { super.touchesMoved(touches, with: event) }
    }
    
    override open func touchesEnded(_ touches:Set<UITouch>, with event: UIEvent?) {
        gesture.touchesEnded( touches )
        super.touchesEnded(touches, with: event)
    }
}


class Gesture {
    
    enum GestureType {
        case NONE, START, END, CANCEL
        case MOVE, MOVE_V, MOVE_H
        case LONG_TOUCH, TOUCH
        case PAN, PAN_RIGHT, PAN_LEFT, PAN_UP, PAN_DOWN
        case PINCH_MOVE, PINCH_RIGHT, PINCH_LEFT, PINCH_UP, PINCH_DOWN, PINCH_IN, PINCH_OUT, PINCH_ROTATE
    }

    enum MoveType{
        case NONE, VERTICAL, HOLIZONTAL
    }
    
    var delegate:GestureDelegate?
    private(set) var startPosA:Array<CGPoint>
    private(set) var changePosA:Array<CGPoint>
    private(set) var movePosA:Array<CGPoint>
    
    
    private var eventProvider:GestureBody?
    private var isHorizontal:Bool
    private var isVertical:Bool
    private var moveType:MoveType = MoveType.NONE
    private var isEventStart:Bool = false
    private var startRotate:Double = 0
    private var startDistance:Double = 0
    private var startTime:Double = 0
    private var endTime:Double = 0
    private let changeRotate:Double = 30.0
    private let longTime = 2.0
    private let changeMin:CGFloat = 10
    private let changeMax:CGFloat = 50
    private let spdMD:Double=100.0
    
    
    init(_ eventProvider:GestureBody , isVertical:Bool = false, isHorizontal:Bool = false) {
        self.eventProvider = eventProvider
        self.isVertical = isVertical
        self.isHorizontal = isHorizontal
        self.startPosA = Array<CGPoint>()
        self.changePosA = Array<CGPoint>()
        self.movePosA = Array<CGPoint>()
    }
    
    func onDestroy() {
        
        delegate=nil
        eventProvider = nil
        self.startPosA.removeAll()
        self.changePosA.removeAll()
        self.movePosA.removeAll()
    }
    
    deinit {
        os_log("Gesture : deinit", log: OSLog.default, type: .info)
    }
    
    fileprivate func touchesBegan(_ touches: Set<NSObject>) {
        startEvent(getLocation(touches))
    }
    
    fileprivate func touchesMoved(_ touches: Set<NSObject>)->Bool{
        return moveEvent(getLocation(touches))
    }
    
    fileprivate func touchesEnded(_ touches: Set<NSObject>) {
        endEvent(true)
    }
    
    private func getLocation(_ touches: Set<NSObject>)->Array<CGPoint>
    {
        var locations=Array<CGPoint>()
        for t: AnyObject in touches{
            let touch:UITouch = t as! UITouch
            let p = touch.location(in: eventProvider)
            let x = p.x
            let y = p.y
            let point = CGPoint( x:x, y:y)
            locations.append(point)
        }
        return locations
    }
    
    private func startEvent(_ locations:Array<CGPoint>) {
        isEventStart=true
        moveType = MoveType.NONE
        startPosA=locations
        changePosA=Array<CGPoint>()
        for _ in locations {
            changePosA.append(CGPoint(x:0,y:0))
        }
        let now = Date()
        startTime = now.timeIntervalSince1970 as Double
        startDistance=0
        startRotate=0
        delegate?.stateChange(self,e: GestureType.START);
    }
    
    private func moveEvent( _ locations:Array<CGPoint>)->Bool {
        var trigger=true
        if isEventStart==false {
            startEvent(locations)
            return trigger
        }
        
        let len=locations.count
        if len == startPosA.count {
            movePosA = Array<CGPoint>()
            var location:CGPoint
            var movePoint:CGPoint
            for i in 0..<len {
                location = locations[i]
                movePoint = CGPoint(x:location.x,y:location.y)
                movePosA.append(movePoint)
            }
            var start:CGPoint
            var change:CGPoint
            checkEvent(false)
            
            for i in 0..<len {
				location = movePosA[i]
				start = startPosA[i]
				changePosA[i].x = location.x-start.x;
				changePosA[i].y = location.y-start.y;
            }
            change = changePosA[0]
           
            if abs(change.x) > abs(change.y) {
                if isHorizontal == true { trigger = false }
                moveType = MoveType.HOLIZONTAL
				if isHorizontal && len==1 { delegate?.stateChange(self,e:GestureType.MOVE_H) }
            }
            else if abs(change.y)>abs(change.x) {
                if isVertical == true { trigger = false }
                moveType = MoveType.VERTICAL
                if isVertical && len==1 { delegate?.stateChange(self,e:GestureType.MOVE_V) }
            }
            delegate?.stateChange(self,e:GestureType.MOVE)
        }
        else if len > startPosA.count {
            delegate?.stateChange(self,e:GestureType.CANCEL)
            endEvent(false)
        }
        return trigger
    }
    
    private func endEvent(_ isComplete:Bool) {
        if isEventStart==false { return }
        let now = Date()
        endTime = now.timeIntervalSince1970 as Double
        checkEvent(isComplete)
        delegate?.stateChange(self,e:GestureType.END)
        isEventStart=false;
    }
    
    private func checkEvent(_ isComplete:Bool) {
        if startPosA.count != movePosA.count && isComplete==false { return }
        var moveMD = 0.0
        var start:CGPoint
        var move:CGPoint
	    var change:CGPoint
        var gestureTime=0.0
        if isComplete==true { gestureTime=(endTime-startTime)*1000/spdMD }
        if startPosA.count == 1 {
            change = changePosA[0]
            if isComplete==true {
                if gestureTime >= longTime {
                    if abs(change.x) < changeMin && abs(change.y) < changeMin {
                        delegate?.gestureComplete(self,e:GestureType.LONG_TOUCH)
                    }
				}
				if moveType == MoveType.HOLIZONTAL {
                    moveMD = Double(change.x)/gestureTime
                    if moveMD > Double(changeMax) { delegate?.gestureComplete(self,e:GestureType.PAN_RIGHT) }
                    else if moveMD < -Double(changeMax) { delegate?.gestureComplete(self,e:GestureType.PAN_LEFT) }
                }
				if moveType == MoveType.VERTICAL {
                    moveMD = Double(change.y)/gestureTime
                    if moveMD > Double(changeMax) { delegate?.gestureComplete(self,e:GestureType.PAN_DOWN) }
                    else if moveMD < -Double(changeMax) { delegate?.gestureComplete(self,e:GestureType.PAN_UP) }
				}
                
                if abs(change.x) < changeMin && abs(change.y) < changeMin { delegate?.gestureComplete(self,e:GestureType.TOUCH) }
            }
            else {
                if abs(change.x)>changeMin || abs(change.y)>changeMin { delegate?.stateChange(self,e:GestureType.PAN) }
            }
        }
        else if startPosA.count >= 2 {
            if movePosA.count<2 { return }
            let start2:CGPoint=startPosA[1]
            let move2:CGPoint=movePosA[1]
            let change2:CGPoint=changePosA[1]
            change=changePosA[0]
            start=startPosA[0]
            move=movePosA[0]
            
            if startDistance==0 {
                let dy = Double(abs(start.y-start2.y))
                let dx = Double(abs(start.x-start2.x))
                startDistance = Double(sqrt((dx * dx) + (dy * dy)))
            }
            let startDist=startDistance
            let mx = Double(abs(move.x-move2.x))
            let my = Double(abs(move.y-move2.y))
            let moveDist:Double = Double(sqrt((mx * mx) + (my * my)))
            let dist:Double = moveDist-startDist
            var rotate:Double = 0
            var w:Double = 0
            var h:Double = 0
            if startRotate==0 {
                w = Double(start.x-start2.x)
                h = Double(start.y-start2.y)
                startRotate = atan2(h,w) / Double.pi * 360
            }
            w = Double(move.x-move2.x)
            h = Double(move.y-move2.y)
            rotate = atan2(h,w) / Double.pi * 360
            
            rotate = startRotate-rotate
            delegate?.rotateChange(self,rotate: rotate)
            
            if isComplete == true && abs(rotate)>changeRotate { delegate?.gestureComplete(self,e:GestureType.PINCH_ROTATE) }
            if isComplete == true {
				if abs(dist) > Double(changeMax) {
                    if dist > 0 { delegate?.gestureComplete(self,e:GestureType.PINCH_OUT) }
                    else { delegate?.gestureComplete(self,e:GestureType.PINCH_IN) }
				}
                else {
                    moveMD = Double(change.x+change2.y)/gestureTime
                    let moveMDH = Double(change.y+change2.y)/gestureTime
                    if abs(moveMD) > abs(moveMDH) {
                        if moveMD > Double(changeMax) { delegate?.gestureComplete(self,e:GestureType.PINCH_RIGHT) }
                        else if moveMD < -Double(changeMax) { delegate?.gestureComplete(self,e:GestureType.PINCH_LEFT) }
                    }
                    else {
                        if moveMDH < Double(changeMax) { delegate?.gestureComplete(self,e:GestureType.PINCH_UP) }
                        else if moveMDH < -Double(changeMax) { delegate?.gestureComplete(self,e:GestureType.PINCH_DOWN) }
                    }
                }
            }
            else {
                if abs(dist) > Double(changeMin) { delegate?.pinchChange(self,dist:dist) }
                else { delegate?.stateChange(self,e:GestureType.PINCH_MOVE) }
            }
        }
    }
}
