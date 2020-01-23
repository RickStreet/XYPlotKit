//
//  XYPlot.swift
//  XYGraph
//
//  Created by Rick Street on 10/12/15.
//  Copyright © 2015 Rick Street. All rights reserved.
//
//  Revisions:

import Cocoa

public protocol UserSelected: class {
    func userSelectedLimits(xMin: Double?, xMax: Double?, yMin: Double?, yMax: Double?)
    func userSelected(point: (x: Double, y: Double)?)
}

public enum MouseAction {
    case dragSelection
    case point
    case dragPoint
}


// @IBDesignable
public class XYPlot: NSView {
    // MARK: Properties
     
     public var plotData1: [(Double, Double)] = [] {
         didSet {
             if autoScaleX || autoScaleY {
                 getAutoScale()
             }
             // needsDisplay = true
         }
     }

    public var plotData2: [(Double, Double)] = [] {
         didSet {
             if autoScaleX || autoScaleY {
                 getAutoScale()
             }
             // needsDisplay = true
         }
     }
     
     public var plotData3 = [(Double, Double)]() // for outliers
    
    public weak var delegate: UserSelected? = nil
    
    /*
    override var isOpaque: Bool {
        return false    }
    */
    // lightGrey.setFill()
    
 
    public var mouseAction = MouseAction.dragSelection
    
    /// Auto Scale X-Axis
    public var autoScaleX: Bool = true
    
        /// Auto Scale Y-Axis
    public var autoScaleY: Bool = true
    
    // Plot Limits
    public var xLow: Double = 0.0
    public var xHigh: Double = 100.0
    public var yLow: Double = 0.0
    public var yHigh: Double = 100.0
    
    // Data Limits
    public var xMin = 0.0
    public var xMax = 0.0
    public var yMin = 0.0
    public var yMax = 0.0
    public var labelFormatX = "%.0f"
    public var labelFormatY = "%.0f"
    public var labelFormat = "%.0f"
    
    // Colors
    let borderColor = NSColor.black
    // let forestColor = NSColor(red: 0.0/255.0, green: 153.0/255.0, blue: 76.0/255.0, alpha: 1.0)
    let slectedColor = NSColor.red
    
    
    let borderLineWidth: CGFloat = 3.0
 
    let textSpacing: CGFloat = 5
    let tickHeight: CGFloat = 10
    let markerSize: CGFloat = 10.0
    public var segmentSize = 1 // Max distance to detect data slce (eng units) when drawing a lline


    public var yBy = 10.0
    public var xBy = 10.0
    
    var labelColor = NSColor.black
    var labelFont = NSFont(name: "Helvetica Neue", size: 15.0)!
    var labelXLow: NSMutableAttributedString = NSMutableAttributedString(string:"0.0")
    // var labelXHigh: NSMutableAttributedString = NSMutableAttributedString(string:"100.0")
    var labelYLow: NSMutableAttributedString = NSMutableAttributedString(string:"0.0")
    // var labelYHigh: NSMutableAttributedString = NSMutableAttributedString(string:"100.0")


    var titleColor = NSColor.black
    // var titleFontSize: Int
    
    @IBInspectable
    public var title: String {
        get {
            return String(describing: labelTitle)
        }
        set {
            labelTitle = NSMutableAttributedString(string: newValue)
            
        }
    }
    
    @IBInspectable
    public var xAxisTitle: String {
        get {
            return String(describing: labelXAxis)
        }
        set {
            labelXAxis = NSMutableAttributedString(string: newValue)
        }
    }
    
    @IBInspectable
    public var yAxisTitle: String {
        get {
            return String(describing: labelYAxis)
        }
        set {
            labelYAxis = NSMutableAttributedString(string: newValue)
        }
    }
    
    var labelTitle: NSMutableAttributedString = NSMutableAttributedString(string:"")
    var labelXAxis: NSMutableAttributedString = NSMutableAttributedString(string:"")
    var labelYAxis: NSMutableAttributedString = NSMutableAttributedString(string:"")
    public var attributeTitle: [NSAttributedString.Key: Any]
    public var attributeLabel: [NSAttributedString.Key: Any]
    public var attributeAxis: [NSAttributedString.Key: Any]
    // let attributeTitle: [NSAttributedStringKey: Any] = [ NSAttributedStringKey.foregroundColor: navy,
                                                         //NSAttributedStringKey.font: NSFont(name: "HelveticaNeue-BoldItalic", size: titleFontSize)!]
    // let attributeLabel: [NSAttributedStringKey: Any] = [ NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): navy,
                                                         // NSAttributedStringKey.font: NSFont(name: "Helvetica Neue", size: 20.0)!]
    // let attributeAxis: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): NSColor.black,
                                                     //  NSAttributedStringKey.font: NSFont(name: "Helvetica Neue", size: 15.0)!]
    // var toolTipText: String

    // toolTip = "(x, y)"
  
    
    
    public var plotColor1 = NSColor.blue
    public var plotLine1 = false
    public var plotMarker1 = true
    
    public var plotColor2 = forestColor
    public var plotLine2 = true
    public var plotMarker2 = false
    
    public var plotColor3 = NSColor.red
    public var plotLine3 = false
    public var plotMarker3 = true

    
    public let plotLineWidth: CGFloat = 2.0

    // MARK: Mouse Properties
    // Dragging Parameters
    var dragging = false
    var startPoint = CGPoint()
    var endPoint = CGPoint()
    var dragRect = CGRect()
    var selectedXMin: Double? // Drag selected
    var selectedXMax: Double?
    var selectedYMin: Double?
    var selectedYMax: Double?
    var shapeLayer : CAShapeLayer!
    
    // Point make/delete Parameters
    public var pwlPoint: (Double, Double)? = nil

    // MARK: Mouse Methods

    // Mouse/Drag Events
    override public func mouseDown(with event: NSEvent) {
        // Swift.print("mouse down")
         startPoint = convert(event.locationInWindow, from: nil)
        
        switch mouseAction {
        case .dragSelection:
            // Swift.print("dragging")
            shapeLayer = CAShapeLayer()
            shapeLayer.lineWidth = 1.0
            shapeLayer.fillColor = NSColor.clear.cgColor
            shapeLayer.strokeColor = NSColor.black.cgColor
            shapeLayer.lineDashPattern = [10,5]
            self.layer?.addSublayer(shapeLayer)
            
            var dashAnimation = CABasicAnimation()
            dashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
            dashAnimation.duration = 0.75
            dashAnimation.fromValue = 0.0
            dashAnimation.toValue = 15.0
            dashAnimation.repeatCount = .infinity
            shapeLayer.add(dashAnimation, forKey: "linePhase")
        case .point:
            break
        case .dragPoint:
            break
        }
    }
    
    override public func mouseUp(with event: NSEvent) {
        // Swift.print("mouse up")
        endPoint = convert(event.locationInWindow, from: nil)
        // Swift.print(endPoint)
        
        switch mouseAction {
        case .dragSelection:
            if dragging {
                dragging = false
                // make rectangle
                dragRect = makeRect(point1: startPoint, point2: endPoint)
                setSelectedLimits(point1: startPoint, point2: endPoint)
                // Swift.print(dragRect)
                needsDisplay = true
            } else {
                selectedXMin = nil
                selectedXMax = nil
                selectedYMin = nil
                selectedYMax = nil
            }
            self.shapeLayer.removeFromSuperlayer()
            self.shapeLayer = nil
        case .point:
            // let point = CGToXY(point: endPoint)
            // Swift.print(point)
            delegate?.userSelected(point: CGToXY(point: endPoint))
        case .dragPoint:
            break
        }
    }
    
    func makeRect(point1: CGPoint, point2: CGPoint) -> CGRect {
        var origin = CGPoint()
        var rect = CGRect()
        var size = CGSize()
        if point1.x <= point2.x {
            origin.x = point1.x
        } else {
            origin.x = point2.x
        }
        if point1.y <= point2.y {
            origin.y = point1.y
        } else {
            origin.y = point2.y
        }
        origin = convert(origin, from: nil)
        rect.origin = origin
        size.width = abs(point1.x - point2.x)
        size.height = abs(point1.y - point2.y)
        rect.size = size
        return rect
    }
    
    func setSelectedLimits(point1: CGPoint, point2: CGPoint) {
        var minPoint = CGPoint()
        var maxPoint = CGPoint()
        if point1.x <= point2.x {
            minPoint.x = point1.x
            maxPoint.x = point2.x
        } else {
            minPoint.x = point2.x
            maxPoint.x = point1.x
        }
        if point1.y <= point2.y {
            minPoint.y = point1.y
            maxPoint.y = point2.y
        } else {
            minPoint.y = point2.y
            maxPoint.y = point1.y
        }
        // Swift.print(minPoint)
        // Swift.print(maxPoint)
        let xyMin = CGToXY(point: minPoint)
        let xyMax = CGToXY(point: maxPoint)
        selectedXMin = xyMin.0
        selectedXMax = xyMax.0
        selectedYMin = xyMin.1
        selectedYMax = xyMax.1
        delegate?.userSelectedLimits(xMin: selectedXMin, xMax: selectedXMax, yMin: selectedYMin, yMax: selectedYMax)
        // Swift.print("xMin: \(selectedXMin)  xMax: \(selectedXMax)")
        // Swift.print("yMin: \(selectedYMin)   yMax: \(selectedYMax)")

        
    }
    
    override public func mouseDragged(with event: NSEvent) {
        dragging = true
        if mouseAction == .dragSelection {
            let point: NSPoint = convert(event.locationInWindow, from: nil)
            let path = CGMutablePath()
            path.move(to: startPoint)
            path.addLine(to: CGPoint(x: startPoint.x, y: point.y))
            path.addLine(to: point)
            path.addLine(to: CGPoint(x: point.x, y: startPoint.y))
            path.closeSubpath()
            self.shapeLayer.path = path
        }
    }
    
    // MARK: Plotting Methods
    
    /// Set x-axis properties
    /// - Parameters:
    ///   - from: Axes starting value
    ///   - to: axes ending value
    ///   - by: axes tick mark spacing
   public func xAxis(from: Double, to: Double, by: Double) {
        autoScaleX = false
        xLow = from
        xHigh = to
        xBy = by
    }
    
    /// Set y-axis properties
    /// - Parameters:
    ///   - from: Axes starting value
    ///   - to: axes ending value
    ///   - by: axes tick mark spacing
    public func yAxis(from: Double, to: Double, by: Double) {
        autoScaleY = false
        yLow = from
        yHigh = to
        yBy = by
    }
    
    /// Clear all plot data
    public func clearPlot() {
        // NSColor.windowBackgroundColor().setFill()
        // NSRectFill(self.bounds)
        plotData1.removeAll()
        plotData2.removeAll()
        plotData3.removeAll()
        prepareForReuse()
    }

    override public func draw(_: CGRect) {
        
        let paraRight = NSMutableParagraphStyle()
        paraRight.alignment = .right
        
        let paraCenter = NSMutableParagraphStyle()
        paraCenter.alignment = .center
        
        // Draw Labels
        drawTitles()
        
        // Draw graph border
        drawPlotBorder()
        drawTicks()
       
        if plotData1.count > 0 {
            // print("Drawing PlotLine 1")
            if plotLine1 {
                plotLine(plotData: plotData1, color: NSColor.blue)
            }
            
            if plotMarker1 {
                // print("ploting 1 markers")
                plotMarker(plotData: plotData1, color: NSColor.blue, marker: markerCross)
            }
        }
        
        if plotData2.count > 0 {
            // print("Drawing PlotLine 2")
            
            if plotLine2 {
                plotLine(plotData: plotData2, color: forestColor)
            }
                        
            if plotMarker2 {
                plotMarker(plotData: plotData2, color: NSColor.blue, marker: markerCross)
            }
        }
        
        // Plot Outliers
        if plotData3.count > 0 {
            if plotLine3 {
                plotLine(plotData: plotData3, color: NSColor.red)
            }
            
            if plotMarker3 {
                plotMarker(plotData: plotData3, color: NSColor.red, marker: markerCross)
            }
        }
    }
    
    func plotLine(plotData: [(Double, Double)], color: NSColor) {
        let plotPath = NSBezierPath()
        plotPath.move(to: XYPointToCoordinate(point: plotData[0]))
        var xLast = plotData[0].0

        // print("moved to (\(plotData[0].0), \(plotData[0].1))")
        for index in 0 ..< plotData.count {
            let plotPoint = XYPointToCoordinate(point: plotData[index])
            // Don't draw line across data slice
            if abs(plotData1[index].0 - xLast) > Double(segmentSize) {
                plotPath.move(to: plotPoint)
            } else {
                plotPath.line(to: plotPoint)
            }
            // print("line to (\(plotPoint.x), \(plotPoint.y))")
            xLast = plotData1[index].0

        }
        color.setStroke()
        plotPath.lineWidth = plotLineWidth
        plotPath.stroke()

    }
    
    func plotMarker(plotData: [(Double, Double)], color: NSColor, marker: (CGPoint) -> Void) {
        color.setStroke()
        for index in 0 ..< plotData.count {
            let pointPlot = XYPointToCoordinate(point: plotData[index])
            marker(pointPlot)
        }
    }
    
    
    func markerCircle(point: CGPoint) {
        let radius = markerSize / 2.0
        let path = NSBezierPath()
        path.appendArc(withCenter: point, radius: radius, startAngle: 0, endAngle: 360)
        path.lineWidth = plotLineWidth
        path.stroke()
    }
    
    func markerCross(point: CGPoint) {
        let path = NSBezierPath()
        path.move(to: CGPoint(x: point.x - markerSize / 2, y: point.y - markerSize / 2))
        path.line(to: CGPoint(x: point.x + markerSize / 2, y: point.y + markerSize / 2))
        path.move(to: CGPoint(x: point.x + markerSize / 2, y: point.y - markerSize / 2))
        path.line(to: CGPoint(x: point.x - markerSize / 2, y: point.y + markerSize / 2))
        path.lineWidth = plotLineWidth
        path.stroke()
    }

    func markerX(point: CGPoint) {
        let path = NSBezierPath()
        path.move(to: CGPoint(x: point.x, y: point.y - markerSize / 2))
        path.line(to: CGPoint(x: point.x, y: point.y + markerSize / 2))
        path.move(to: CGPoint(x: point.x - markerSize / 2, y: point.y))
        path.line(to: CGPoint(x: point.x + markerSize / 2, y: point.y))
        path.lineWidth = plotLineWidth
        path.stroke()
    }

      func drawPlotBorder() {
          // origin is inm lower left corner
          
          let borderPath = NSBezierPath()
          borderPath.move(to: CGPoint(x: leftMargin , y: bottomMargin))
          borderPath.line(to: CGPoint(x: width - rightMargin, y: bottomMargin))
          borderPath.line(to: CGPoint(x: width - rightMargin, y: height - topMargin))
          borderPath.line(to: CGPoint(x: leftMargin , y: height - topMargin))
          borderPath.close()
          
          lightestGray.setFill()
          borderPath.fill()
          
          borderColor.setStroke()
          borderPath.stroke()
      }
      
      func drawTicks() {
          var number: Double = xLow
          while number <= xHigh {
              drawXTick(value: number)
              number += xBy
          }
          
          number = yLow
          while number <= yHigh {
              drawYTick(value: number)
              number += yBy
          }
    }
      
      func drawXTick(value: Double) {
          let xFraction = (value - xLow) / (xHigh - xLow)
          let x = xFraction * Double(width - leftMargin - rightMargin)
          let tick = NSBezierPath()
          tick.move(to: CGPoint(x: leftMargin + CGFloat(x), y: bottomMargin - tickHeight / 2.0))
          tick.line(to: CGPoint(x: leftMargin + CGFloat(x), y: bottomMargin + tickHeight / 2.0))
          borderColor.setStroke()
          tick.stroke()

          let tickLabel = NSMutableAttributedString(string: String(format: labelFormatX, value))
          let attribute: [NSAttributedString.Key: Any] = [ NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): labelColor,
                                                          NSAttributedString.Key.font: labelFont]
          tickLabel.addAttributes(attribute, range: NSRange(location: 0, length: tickLabel.length))
          let size =  tickLabel.size()
          tickLabel.draw(in: CGRect(x: leftMargin + CGFloat(x) - size.width / 2, y:  bottomMargin - size.height - textSpacing, width: size.width, height: size.height) )
      }
      
      func drawYTick(value: Double) {
          let yFraction = (value - yLow) / (yHigh - yLow)
          let y = yFraction * Double(height - topMargin - bottomMargin)
          let tick = NSBezierPath()
          tick.move(to: CGPoint(x: leftMargin - tickHeight / 2.0, y: bottomMargin + CGFloat(y)))
          tick.line(to: CGPoint(x: leftMargin + tickHeight / 2.0, y: bottomMargin + CGFloat(y)))
          borderColor.setStroke()
          tick.stroke()
          
          let tickLabel = NSMutableAttributedString(string: String(format: labelFormatY, value))
          let attribute: [NSAttributedString.Key: Any] = [ NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): labelColor,
                                                          NSAttributedString.Key.font: labelFont]
          tickLabel.addAttributes(attribute, range: NSRange(location: 0, length: tickLabel.length))
          let size =  tickLabel.size()
          tickLabel.draw(in: CGRect(x: leftMargin - tickHeight - size.width - textSpacing * 0.5, y:   bottomMargin + CGFloat(y) - size.height / 2, width: size.width, height: size.height) )
      }
      
      func drawTitles() {

          labelTitle.addAttributes(attributeTitle, range: NSRange(location: 0, length: labelTitle.length))
          var size = labelTitle.size()

          var r = CGRect(x:(width - leftMargin - rightMargin - size.width)/2 + leftMargin,
                         y: height - topMargin + textSpacing,
                         width: width,
                         height: size.height)
          labelTitle.draw(in: r)
          
          // X-Axis Label
          labelXAxis.addAttributes(attributeLabel, range: NSRange(location: 0, length: labelXAxis.length))
          size = labelXAxis.size()
      
          r = CGRect(x: (width - leftMargin - rightMargin - size.width)/2 + leftMargin,
                     y: 0,
                     width: width,
                     height: size.height)
              labelXAxis.draw(in: r)
          
          
          // Y-Axis Label
          // labelYAxis.addAttributes(attribute, range: NSRange(location: 0, length: labelXAxis.length))
          labelYAxis.addAttributes(attributeLabel, range: NSRange(location: 0, length: labelYAxis.length))
          size = labelYAxis.size()
          r = CGRect(x: 0,
                     y: 0,
                     width: size.width,
                     height: size.height)
          
          // Save context
          let context = NSGraphicsContext.current?.cgContext
          context!.saveGState()
          
          // Rotate the context 90 degrees (convert to radians)
          let rotationTransform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2.0))
          context!.concatenate(rotationTransform)
          
          // Move the context back into the view
          var myX = -height + topMargin + (height - topMargin - bottomMargin) / 2
          myX = myX - size.width / 2
          context!.translateBy(x: myX, y: 0)
          
          labelYAxis.draw(in: r)
          
          // Restore Context
          context!.restoreGState()
      }

    // MARK: Plot Calculations

    func XYPointToCoordinate(point: (Double, Double)) -> CGPoint {
        let xFraction = (point.0 - xLow) / (xHigh - xLow)
        let yFraction = (point.1 - yLow) / (yHigh - yLow)
        let x = xFraction * Double(width - leftMargin - rightMargin) + Double(leftMargin)
        let y = yFraction * Double(height - topMargin - bottomMargin) + Double(bottomMargin)
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
    
    func CGToXY (point: CGPoint) -> (Double, Double) {
        let xCG = (point.x - leftMargin) / (width - leftMargin - rightMargin)
        let x = Double(xCG) * (xHigh - xLow) + xLow
        let yCG = (point.y - bottomMargin) / (height - bottomMargin - topMargin)
        let y = Double(yCG) * (yHigh - yLow) + yLow
        return (x, y)
    }
    
    func getAutoScale() {
        if plotData1.count > 0 {
            xMin = plotData1[0].0
            xMax = xMin
            yMin = plotData1[0].1
            yMax = yMin
        }
        
        for point in plotData1 {
            if point.0 > xMax {
                xMax = point.0
            }
            if point.0 < xMin {
                xMin = point.0
            }
            if point.1 > yMax {
                yMax = point.1
            }
            if point.1 < yMin {
                yMin = point.1
            }
        }
        for point in plotData2 {
            if point.0 > xMax {
                xMax = point.0
            }
            if point.0 < xMin {
                xMin = point.0
            }
            if point.1 > yMax {
                yMax = point.1
            }
            if point.1 < yMin {
                yMin = point.1
            }
        }
        
        if autoScaleX {
            // xLow = xLowTemp
            // xHigh = xHighTemp
            let axis = calcAxis(length: xLabelWidth, min: xMin, max: xMax)
            labelFormatX = labelFormat
            xLow = axis.from
            xHigh = axis.to
            xBy = axis.by
            // Swift.print("xLow: \(xLow)   xHigh: \(xHigh)")
        }
        
        if autoScaleY {
            // yLow = yLowTemp
            // yHigh = yHighTemp
            // Swift.print("calling calcAxis")
            let axis = calcAxis(length: labelHeight, min: yMin, max: yMax)
            labelFormatY = labelFormat
            // Swift.print("returned from calcAxis")
            yLow = axis.from
            yHigh = axis.to
            yBy = axis.by
            // Swift.print("yLow: \(yLow)   yHigh: \(yHigh)")
        }
    }

    private func calcAxis(length: CGFloat, min: Double, max: Double) -> (from: Double, to: Double, by: Double) {
        let maxTicks = 12
        let minTicks = 5
        
        var ticks = Int(width / (length * 2))
        if ticks > maxTicks {
            ticks = maxTicks
        }
        
        if ticks < minTicks {
            ticks = minTicks
        }
        let range = max - min
        var rMin = min
        var rMax = max
        
        let rawSpacing = range / Double(ticks)
        let maxSpacing = range / Double(minTicks)
        var spacing: Double
        
        
        let roundBys = [1000.0, 500.0, 200.0, 100.0, 50.0, 25.0, 20.0, 10.0, 5.0, 4.0, 2.0, 1.0, 0.5, 0.25, 0.2, 0.1, 0.05, 0.025, 0.02, 0.01, 0.001, 0.0001]
        // Swift.print("Getting Roundings")
        spacing = 0.0
        for n in roundBys {
            // Swift.print("\(n)")
            if n < maxSpacing {
                let newMin = roundDown(value: min, by: n)
                let newMax = roundUp(value: max, by: n)
                if (min - newMin <= rawSpacing) && (newMax - max <= rawSpacing) {
                    rMin = newMin
                    rMax = newMax
                    // roundBy = n
                    spacing = roundUp(value: rawSpacing, by: n)
                    break
                }
            }
        }
        // print()
        // print("axis spacing: \(spacing)")
        if spacing < 0.0001 {
            labelFormat = "%.5f"
        } else if spacing < 0.001 {
            labelFormat = "%.4f"
        } else if spacing < 0.01 {
            labelFormat = "%.3f"
        } else if spacing < 0.1 {
            labelFormat = "%.2f"
        } else if spacing <= 1.0 {
            labelFormat = "%.1f"
        } else {
            labelFormat = "%.0f"
        }
        
        let from = rMin
        let to = rMax
        let by = spacing
        // print("from: \(from), to: \(to), by: \(by)")
        return (from: from, to: to, by: by)
    }
    
    func roundUp(value: Double, by: Double) -> Double {
        return ceil(value / by) * by
    }
    
    
    func roundDown(value: Double, by: Double) -> Double {
        if value >= 0.0 {
            return Double(Int(value / by)) * by
        } else {
            return -ceil(-value / by) * by
        }
    }
  
    var bottomMargin: CGFloat {
        get {
            return titleHeight + labelHeight + textSpacing * 2
        }
    }
    
    var topMargin: CGFloat {
        get {
            return titleHeight + textSpacing
        }
    }
    
    var leftMargin: CGFloat {
        get {
            return titleHeight + yLabelWidth + textSpacing * 3
        }
    }
    
    var rightMargin: CGFloat {
        get {
            return xLabelWidth / 2 + textSpacing
        }
    }
    
    
    var titleHeight: CGFloat {
        return labelTitle.size().height
    }
    
    var labelHeight: CGFloat {
        return labelYHigh.size().height
    }
    
    var yLabelWidth: CGFloat {

        return labelYHigh.size().width
    }
    
    var xLabelWidth: CGFloat {
        return labelXHigh.size().width
    }
    
    var labelXHigh: NSMutableAttributedString {
        let aString: NSMutableAttributedString = NSMutableAttributedString(string:String(format: labelFormatX, xHigh))
        aString.addAttributes(attributeAxis, range: NSRange(location: 0, length: aString.length))
        return aString
    }
    
    var labelYHigh: NSMutableAttributedString {
        let aString: NSMutableAttributedString = NSMutableAttributedString(string:String(format: labelFormatY, yHigh))
        aString.addAttributes(attributeAxis, range: NSRange(location: 0, length: aString.length))
        return aString
    }
    
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    
    func getXAxis(low: Double, high: Double) -> (from: Double, to: Double, by: Double) {
        return calcAxis(length: xLabelWidth, min: low  , max: high)
    }
    
    override init(frame frameRect: NSRect) {
        attributeTitle = [ NSAttributedString.Key.foregroundColor: navy,
                                                             NSAttributedString.Key.font: NSFont(name: "HelveticaNeue-BoldItalic", size: 25)!]
        attributeLabel = [ NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): navy,
                                                            NSAttributedString.Key.font: NSFont(name: "Helvetica Neue", size: 20.0)!]
        attributeAxis = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): NSColor.black,
                                                          NSAttributedString.Key.font: NSFont(name: "Helvetica Neue", size: 15.0)!]

        super.init(frame:frameRect)
    }


    required init?(coder: NSCoder) {
        // titleFontSize = 25
        attributeTitle = [ NSAttributedString.Key.foregroundColor: navy,
                           NSAttributedString.Key.font: NSFont(name: "HelveticaNeue-BoldItalic", size: 25)!]
        attributeLabel = [ NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): navy,
                           NSAttributedString.Key.font: NSFont(name: "Helvetica Neue", size: 20.0)!]
        attributeAxis = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): NSColor.black,
                         NSAttributedString.Key.font: NSFont(name: "Helvetica Neue", size: 15.0)!]
        super.init(coder: coder)
    }
    
}
