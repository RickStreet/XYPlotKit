//
//  XYPlot.swift
//  XYGraph
//
//  Created by Rick Street on 10/12/15.
//  Copyright © 2015 Rick Street. All rights reserved.
//
//  Revisions:

import Cocoa
import NSStringKit

/// Allows selection of points by dragging a rectable or selecting  a point
public protocol UserSelected: AnyObject {
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
    
    // MARK: Histogram Methods

    // Bar Graph Data
    public var binRange = 1.0
    // public var numberBins = 0
    public var data: [Double] = []
    public var bins = [Int]()
    
    // MARK: Histogram Methods
    
    /// Draw Histogram with set humber of bins for data
    /// - Parameters:
    ///   - numberBins: Number of bins for histogram
    ///   - data: data for histogram
    public func histogram(numberBins: Int, data: [Double]) {
        // self.numberBins = numberBins
        self.data = data
        let histogram = data.histogram(numberBins: bins.count)
        bins = histogram.bins
        binRange = histogram.binRange
        yMin = 0.0
        if let max = bins.max() {
            yMax = Double(max)
        }
        
        if let min = data.min() {
            xMin = min
        }
        if let max = data.max() {
            xMax = max
        }
        // print("x: min \(xMin)  max \(xMax)")
        // print("y: min \(yMin)  max \(yMax)")
        
        let xAxis = calcAxis(length: xLabelWidth, min: xMin - binRange, max: xMax + binRange)
        labelFormatX = labelFormat
        xLow = xAxis.from
        xHigh = xAxis.to
        xBy = xAxis.by
        // print("xLow \(xLow)  xHigh \(xHigh)  xBy \(xBy)")
        
        let yAxis = calcAxis(length: labelHeight, min: yMin, max: yMax)
        labelFormatY = labelFormat
        yLow = yAxis.from
        yHigh = yAxis.to
        yBy = yAxis.by
        
        // print("bins \(bins)")
        // print("binRange \(binRange)")
    }
    
    /// Histogram with bin size from data
    /// - Parameters:
    ///   - binRange: bin width
    ///   - data: data for histogram
    public func histogram(binRange: Double, data: [Double]) {
        // print("range histogram...")
        self.binRange = binRange
        self.data = data
        bins = data.histogram(binRange: binRange)
        // print("no bins \(bins.count)")
        // print(bins)
        // numberBins = bins.count
        updateHistogram(binRange: binRange)
        // print("range histogram complete")
    }
    
    /// Redraw histogram with new range using last data
    /// - Parameter binRange: New bin width
    public func updateHistogram(binRange: Double) {
        // print("updating histogram...")
        self.binRange = binRange
        bins = data.histogram(binRange: binRange)
        // print("number bins \(bins.count)")
        // print(bins)
        // numberBins = bins.count
        // print("number bins \(bins.count)")
        if let min = data.min() {
            xMin = min
        }
        if let max = data.max() {
            xMax = max
        }
        
        yMin = 0.0
        if let max = bins.max() {
            yMax = Double(max)
        }
        // print("x: \(xMin) to \(xMax)")
        // print("y: \(yMin) to \(yMax)")
        
        // Histogram
        let xAxis = calcAxis(length: 20.0, min: xMin - binRange, max: xMax + binRange, minTicks: 5, maxTicks: 20)
        labelFormatX = labelFormat
        xLow = xAxis.from - binRange / 2
        xHigh = xAxis.to
        xBy = xAxis.by
        // print("xLow \(xLow)  xHigh \(xHigh)  xBy \(xBy)")
        
        let yAxis = calcAxis(length: labelHeight, min: yMin, max: yMax)
        labelFormatY = labelFormat
        yLow = yAxis.from
        yHigh = yAxis.to
        yBy = yAxis.by
        // print("x: \(xMin) to \(xMax)")
        // print("y: \(yMin) to \(yMax)")
        
        // print("self.needsDisplay...")
        self.needsDisplay = true
        // print("updating histogram complete")
    }
    
    /// Suggest asthetic bin width
    /// - Parameters:
    ///   - min: Min value in data
    ///   - max: Max value ijn data
    /// - Returns: suggested bin width
    public func suggestedHistogramSpacing(min: Double, max: Double) -> Double {
        let roundBys = [1000.0, 500.0, 200.0, 100.0, 50.0, 25.0, 20.0, 10.0, 5.0, 4.0, 2.0, 1.0, 0.5, 0.25, 0.2, 0.1, 0.05, 0.025, 0.02, 0.01, 0.001, 0.0001]
        let maxSegments = 15
        let minSegments = 5
        let range = max - min
        var spacing = 0.0
        let maxSpacing = range / Double(minSegments)
        let rawSpacing = range / Double(maxSegments)
        // var rMin = min
        // var rMax = max
        for n in roundBys {
            // Swift.print("\(n)")
            if n < maxSpacing {
                let newMin = roundDown(value: min, by: n)
                let newMax = roundUp(value: max, by: n)
                if (min - newMin <= rawSpacing) && (newMax - max <= rawSpacing) {
                    //rMin = newMin
                    //rMax = newMax
                    // roundBy = n
                    spacing = roundUp(value: rawSpacing, by: n)
                    break
                }
            }
        }
        return spacing
    }
    
    
    // MARK: XYPlot Properties
    
    private struct PlotDrawProperties {
        static let borderLineWidth: CGFloat = 3.0
        static let borderColor = NSColor.black
        static let slectedColor = NSColor.red
        static let textSpacing: CGFloat = 5
        static let tickHeight: CGFloat = 10
        static let markerSize: CGFloat = 10.0
        static let minTicks: Int = 5
        static let maxTicks: Int = 12
        
    }
    
    // MARK: Properties
    
    
    
    // Add data compression for ploting.  Raw plot data is in data1, data2, data3,
    /// Raw data for plot trace 1, will be compressed for faster ploting
    public var data1: [(Double, Double)] = [] {
        didSet {
            print("plotXY: data1 set")
            if !data1.isEmpty {
                if autoScaleX || autoScaleY {
                    print("plotXY: data1 AutoScale")
                    getAutoScale()
                }
                plot1Data = getPlotPoints(dataPoints: data1)
                print("plot data1 set (compressed)")
            }
        }
    }
    
    /// Raw data for plot trace 2, will be compressed for faster ploting
    public var data2: [(Double, Double)] = [] {
        didSet {
            print("PlotXY: data2 set")
            if !data2.isEmpty {
                if autoScaleX || autoScaleY {
                    print("plotXY: data2 AutoScale")
                    getAutoScale()
                }
                plot2Data = getPlotPoints(dataPoints: data2)
                print("plot data2 set (compressed)")
            }
        }
    }
    
    /// Raw data for plot trace 3, will not be compressed
    public var data3: [(Double, Double)] = [] {
        didSet {
            print("PlotXY: data3 set")
            plot3Data = data3
        }
    }

    var plot1Data = [(Double, Double)]()
    var plot2Data = [(Double, Double)]()
    var plot3Data = [(Double, Double)]() // for outliers

    /*
    /// Set data for plot 1 trace.  If data set is large, use data1 to copress it for quicker plot
    var plot1Data: [(Double, Double)] = [] {
        didSet {
            if !plot1Data.isEmpty {
                if autoScaleX || autoScaleY {
                    getAutoScale()
                }
            }
        }
    }
    
    /// Set data for plot 2 trace.  If data set is large, use data2 to copress it for quicker plot
    var plot2Data: [(Double, Double)] = [] {
        didSet {
            if !plot2Data.isEmpty {
                if autoScaleX || autoScaleY {
                    getAutoScale()
                }
            }
        }
    }
    */
    /// Third plot trace used for outliers for exampole
    
    
    
    
    
    // Plot Colors
    public var barColor = mediumBlue
    public var plot1Color = NSColor.blue
    public var plot2Color = forestGreen
    public var plot3Color = NSColor.red
    
    // Plot Markers
    public lazy var plot1Marker: ((CGPoint) -> Void) = markerCross
    public lazy var plot2Marker: ((CGPoint) -> Void) = markerCross
    public lazy var plot3Marker: ((CGPoint) -> Void) = markerCross
    
    // Plot Lines Check for Slices
    public var plot1Line1Slices = false
    public var plot2Line1Slices = false
    public var plot3Line1Slices = false
    
    // Draw lines and markers
    public var plot1DrawLine = false
    public var plot1DrawMarker = true
    
    public var plot2DrawLine = true
    public var plot2DrawMarker: Bool = false {
        didSet {
            if plot2DrawLine {
                // print("Plot 2: Draw Line")
            } else {
                // print("Plot 2: No Line!")
            }
        }
    }
    
    public var plot3DrawLine = false
    public var plot3DrawMarker = true
    
    
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
    
    // Plot Compression Properties
    public var maxPlotPoints = 3000 // max points to plot without compression
    public var plotSegments = 100.0 // used to compress points for plotting, (axis length / plotSegments for compression)
    
    
    // Colors
    let borderColor = NSColor.black
    // let forestColor = NSColor(red: 0.0/255.0, green: 153.0/255.0, blue: 76.0/255.0, alpha: 1.0)
    let slectedColor = NSColor.red
    
    
    let borderLineWidth: CGFloat = PlotDrawProperties.borderLineWidth
    
    let textSpacing: CGFloat = PlotDrawProperties.textSpacing
    let tickHeight: CGFloat = PlotDrawProperties.tickHeight
    let markerSize: CGFloat = PlotDrawProperties.markerSize
    public var segmentSize = 1 // Max distance to detect data slce (eng units) when drawing a lline
    
    
    public var yBy = 10.0
    public var xBy = 10.0
    
    public var titleFontSize = 15.0
    public var axesTitleFontSize = 12.0
    public var labelFontSize = 15.0
    public var plotLineWidth: CGFloat = 2.0
    public var markerLineWidth: CGFloat = 2.0
    
    
    var labelColor = NSColor.black
    lazy var labelFont = NSFont(name: "Helvetica Neue", size: CGFloat(labelFontSize))! // Axes number label size
    lazy var titleFont = NSFont(name: "Helvetica Neue", size: CGFloat(titleFontSize))! // Axes number label size
    lazy var axesTitleFont = NSFont(name: "Helvetica Neue", size: CGFloat(axesTitleFontSize))! // Axes number label size


    var labelXLow: NSMutableAttributedString = NSMutableAttributedString(string:"0.0")
    // var labelXHigh: NSMutableAttributedString = NSMutableAttributedString(string:"100.0")
    var labelYLow: NSMutableAttributedString = NSMutableAttributedString(string:"0.0")
    // var labelYHigh: NSMutableAttributedString = NSMutableAttributedString(string:"100.0")
    
    
    var titleColor = NSColor.black
    // var titleFontSize: Int
    
    @IBInspectable
    /// Title for Plot.  Use customTitle for attributed string.
    public var title: String {
        get {
            return String(describing: labelTitle)
        }
        set {
            labelTitle = NSMutableAttributedString(string: newValue)
            
        }
    }
    
    @IBInspectable
    /// Title for x-axis.  Use customXAxisTitle for attributed string.
    public var xAxisTitle: String {
        get {
            return String(describing: labelXAxis)
        }
        set {
            labelXAxis = NSMutableAttributedString(string: newValue)
        }
    }
    
    @IBInspectable
    /// Title for y-axis, String.  Use customYAxisTitle for attributed string.
    public var yAxisTitle: String {
        get {
            return String(describing: labelYAxis)
        }
        set {
            labelYAxis = NSMutableAttributedString(string: newValue)
        }
    }
    /// Custom plot title, allows user to set attributes
    public var customTitle: NSMutableAttributedString?
    
    /// Custom x-asis title, allows user to set attributes
    public var customXAxisTitle: NSMutableAttributedString?
    
    /// Custom y-axis title, allows user to set attributes
    public var customYAxisTitle: NSMutableAttributedString?
    
    var labelTitle: NSMutableAttributedString = NSMutableAttributedString(string:"")
    var labelXAxis: NSMutableAttributedString = NSMutableAttributedString(string:"")
    var labelYAxis: NSMutableAttributedString = NSMutableAttributedString(string:"")
    
    /// Attributes fo title
    public var attributeTitle: [NSAttributedString.Key: Any]
    
    /// Attributes for label
    public var attributeLabel: [NSAttributedString.Key: Any]
    
    /// Attributes for Axis
    public var attributeAxis: [NSAttributedString.Key: Any]
    // let attributeTitle: [NSAttributedStringKey: Any] = [ NSAttributedStringKey.foregroundColor: navy,
    //NSAttributedStringKey.font: NSFont(name: "HelveticaNeue-BoldItalic", size: titleFontSize)!]
    // let attributeLabel: [NSAttributedStringKey: Any] = [ NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): navy,
    // NSAttributedStringKey.font: NSFont(name: "Helvetica Neue", size: 20.0)!]
    // let attributeAxis: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): NSColor.black,
    //  NSAttributedStringKey.font: NSFont(name: "Helvetica Neue", size: 15.0)!]
    // var toolTipText: String
    
    // toolTip = "(x, y)"
    
    
    
    
    
    
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
    // public var pwlPoint: (Double, Double)? = nil
    
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
    
    /// Generates pdf data for plot
    /// - Returns: pdf data
    public func pdfData() -> Data {
        return dataWithPDF(inside: bounds)
    }
    
    
    /// Compress Plot Data for faster drawing (remove points on top of each other)
    /// - Parameter dataPoints: Raw data points, [(Double, Double)]
    /// - Returns: compressed points to plot, , [(Double, Double)]
    func getPlotPoints(dataPoints: [(Double, Double)]) -> [(Double, Double)] {
        print("data.getPlotPoints........")
        // get plot segment sizes
        print("x: max \(xMax) min \(xMin)")
        print("y: max \(yMax) min \(yMin)")
        let xStep = abs(xMax - xMin) / plotSegments
        let yStep = abs(yMax - yMin) / plotSegments
        
        print("xStep \(xStep)  yStep \(yStep)")
        
        print("data values.count \(dataPoints.count)")
        print("max plot points before compress \(maxPlotPoints)")
        var plotPoints = [(Double, Double)]()
        
        // compress if count over maxPlotPoints
        if dataPoints.count > maxPlotPoints {
            for point in dataPoints {
                // print(point)
                var found = false
                for plotPoint in plotPoints {
                    found = abs(plotPoint.0 - point.0) < xStep && abs(plotPoint.1 - point.1) < yStep
                }
                if !found {
                    plotPoints.append(point)
                    // print("Appended:",plotPoints.count, point)
                } else {
                    // print("Rejecting:", point)
                }
            }
        } else {
            plotPoints = dataPoints
        }
        print("XYPlot: Points to plot:", plotPoints.count)
        return plotPoints
    }
    
    
    
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
        data1.removeAll()
        data2.removeAll()
        data3.removeAll()
        plot1Data.removeAll()
        plot2Data.removeAll()
        plot3Data.removeAll()
        prepareForReuse()
        needsDisplay = true
    }
    
    override public func draw(_: CGRect) {
        // Swift.print("draw() starting...")
        
        // Swift.print("bin count \(bins.count)")
        
                
        
        let paraRight = NSMutableParagraphStyle()
        paraRight.alignment = .right
        
        let paraCenter = NSMutableParagraphStyle()
        paraCenter.alignment = .center
        
        // Draw Labels
        // Swift.print("drawing labels..")
        drawTitles()
        
        // Draw graph border
        // Swift.print("drawing border...")
        drawPlotBorder()
        
        // Swift.print("drawing tics")
        drawTicks()
        if bins.count > 2 {
            // Swift.print("Drawing Histogram from Draw()")
            plotBars(color: barColor, marker: plot1Marker)
        }
        
        if data1.isEmpty {
            plot1Data.removeAll()
        }
        
        if data2.isEmpty {
            plot2Data.removeAll()
        }
        
        if data3.isEmpty {
            plot3Data.removeAll()
        }

        
        if plot1Data.count > 0 {
            // Swift.print("Drawing PlotLine 1")
            if plot1DrawLine {
                plotLine(plotData: plot1Data, color: plot1Color, checkForSlices: plot1Line1Slices)
            }
            if plot1DrawMarker {
                // if let marker = plot1Marker {
                plotMarker(plotData: plot1Data, color: plot1Color, marker: plot1Marker)
                // }
            }
        }
        
        if plot2Data.count > 0 {
            Swift.print("Drawing PlotLine 2")
            if plot2DrawLine {
                plotLine(plotData: plot2Data, color: plot2Color, checkForSlices: plot2Line1Slices)
            }
            if plot2DrawMarker {
                // if let marker = plot2Marker {
                plotMarker(plotData: plot2Data, color: plot2Color, marker: plot2Marker)
                //}
            }
        }
        
        // Plot Outliers
        if plot3Data.count > 0 {
            Swift.print("Drawing PlotLine 3")
            if plot3DrawLine {
                plotLine(plotData: plot3Data, color: plot3Color, checkForSlices: plot3Line1Slices )
            }
            if plot3DrawMarker {
                // if let marker = plot3Marker {
                plotMarker(plotData: plot3Data, color: plot3Color, marker: plot3Marker)
                
                // }
            }
        }
        // Swift.print("finished drawing!")
    }
    
    func plotLine(plotData: [(Double, Double)], color: NSColor, checkForSlices: Bool) {
        let plotPath = NSBezierPath()
        plotPath.move(to: XYPointToCoordinate(point: plotData[0]))
        var xLast = plotData[0].0
        
        // print("moved to (\(plotData[0].0), \(plotData[0].1))")
        for index in 0 ..< plotData.count {
            let plotPoint = XYPointToCoordinate(point: plotData[index])
            // Don't draw line across data slice
            if abs(plotData[index].0 - xLast) > Double(segmentSize) && checkForSlices{
                plotPath.move(to: plotPoint)
            } else {
                plotPath.line(to: plotPoint)
            }
            // print("line to (\(plotPoint.x), \(plotPoint.y))")
            xLast = plotData[index].0
            
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
    
    func plotBars(color: NSColor, marker: (CGPoint) -> Void) {
        // Swift.print("plotBars()...")
        color.setStroke()
        for (i, count) in bins.enumerated() {
            // Swift.print()
            // Swift.print("drawing bin \(i)")
            // Swift.print("xMin \(xMin)")
            // Swift.print("x: \(xMin + Double(i) * binRange) to y: \(0.0)")
            // Swift.print("x: \(xMin + Double(i) * binRange) to y: \(Double(count))")
            // Swift.print("x: \(xMin + Double(i + 1) * binRange) to y: \(Double(count))")
            // Swift.print("x: \(xMin + Double(i + 1) * binRange) to y: \(0.0)")
            let borderPath = NSBezierPath()
            // color.setStroke()
            borderPath.move(to: CGPoint(x: xPointCoordinate(xMin + Double(i) * binRange), y: yPointCoordinate(0.0)))
            borderPath.line(to: CGPoint(x: xPointCoordinate(xMin + Double(i) * binRange), y: yPointCoordinate(Double(count))))
            borderPath.line(to: CGPoint(x: xPointCoordinate(xMin + Double(i + 1) * binRange), y: yPointCoordinate(Double(count))))
            borderPath.line(to: CGPoint(x: xPointCoordinate(xMin + Double(i + 1) * binRange) , y: yPointCoordinate(0.0)))
            borderPath.close()
            NSColor.black.setStroke()
            borderPath.stroke()
            
            color.setFill()
            borderPath.fill()
            
            // color.setStroke()
            // borderPath.stroke()
            
        }
        // Swift.print("finished plotBars()")
    }
    
    public func markerCircle(point: CGPoint) {
        let radius = markerSize / 2.0
        let path = NSBezierPath()
        path.appendArc(withCenter: point, radius: radius, startAngle: 0, endAngle: 360)
        path.lineWidth = markerLineWidth
        path.stroke()
    }
    
    public func markerX(point: CGPoint) {
        let path = NSBezierPath()
        path.move(to: CGPoint(x: point.x - markerSize / 2, y: point.y - markerSize / 2))
        path.line(to: CGPoint(x: point.x + markerSize / 2, y: point.y + markerSize / 2))
        path.move(to: CGPoint(x: point.x + markerSize / 2, y: point.y - markerSize / 2))
        path.line(to: CGPoint(x: point.x - markerSize / 2, y: point.y + markerSize / 2))
        path.lineWidth = markerLineWidth
        path.stroke()
    }
    
    public func markerCross(point: CGPoint) {
        let path = NSBezierPath()
        path.move(to: CGPoint(x: point.x, y: point.y - markerSize / 2))
        path.line(to: CGPoint(x: point.x, y: point.y + markerSize / 2))
        path.move(to: CGPoint(x: point.x - markerSize / 2, y: point.y))
        path.line(to: CGPoint(x: point.x + markerSize / 2, y: point.y))
        path.lineWidth = markerLineWidth
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
        // Swift.print("drawTics()...")
        var number: Double = xLow
        // Swift.print("xLow \(number)")
        // Swift.print("draw x tics")
        while number <= xHigh {
            drawXTick(value: number)
            number += xBy
        }
        
        number = yLow
        // Swift.print("yLow \(number)")
        // Swift.print("draw y tics")
        while number <= yHigh {
            drawYTick(value: number)
            number += yBy
        }
    }
    
    func drawXTick(value: Double) {
        // Swift.print("")
        // Swift.print("drawXTick()...")
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
        // Swift.print("")
        // Swift.print("drawYTick()...")
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
        
        if let customTitle = customTitle {
            labelTitle = customTitle
        } else {
            labelTitle.addAttributes(attributeTitle, range: NSRange(location: 0, length: labelTitle.length))
        }
        
        var size = labelTitle.size()
        
        var r = CGRect(x:(width - leftMargin - rightMargin - size.width)/2 + leftMargin,
                       y: height - topMargin + textSpacing,
                       width: width,
                       height: size.height)
        labelTitle.draw(in: r)
        
        // X-Axis Label
        if let customXAxisTitle = customXAxisTitle {
            labelXAxis = customXAxisTitle
        } else {
            labelXAxis.addAttributes(attributeLabel, range: NSRange(location: 0, length: labelXAxis.length))
        }
        size = labelXAxis.size()
        
        r = CGRect(x: (width - leftMargin - rightMargin - size.width)/2 + leftMargin,
                   y: 0,
                   width: width,
                   height: size.height)
        labelXAxis.draw(in: r)
        
        
        // Y-Axis Label
        // labelYAxis.addAttributes(attribute, range: NSRange(location: 0, length: labelXAxis.length))
        if let customYAxisTitle = customYAxisTitle {
            labelYAxis = customYAxisTitle
        } else {
            labelYAxis.addAttributes(attributeLabel, range: NSRange(location: 0, length: labelYAxis.length))
        }
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
    
    func xPointCoordinate(_ x: Double) -> CGFloat {
        let xFraction = (x - xLow) / (xHigh - xLow)
        let xDouble = xFraction * Double(width - leftMargin - rightMargin) + Double(leftMargin)
        return CGFloat(xDouble)
    }
    
    func yPointCoordinate(_ y: Double) -> CGFloat {
        let yFraction = (y - yLow) / (yHigh - yLow)
        let yDouble = yFraction * Double(height - topMargin - bottomMargin) + Double(bottomMargin)
        return CGFloat(yDouble)
    }
    
    
    func CGToXY (point: CGPoint) -> (Double, Double) {
        let xCG = (point.x - leftMargin) / (width - leftMargin - rightMargin)
        let x = Double(xCG) * (xHigh - xLow) + xLow
        let yCG = (point.y - bottomMargin) / (height - bottomMargin - topMargin)
        let y = Double(yCG) * (yHigh - yLow) + yLow
        return (x, y)
    }
    
    func getAutoScale() {
        print("plot autoscaling...")
        print("data1 count \(data1.count)")
        if data1.count > 0 {
            xMin = data1[0].0
            xMax = data1[0].0
            yMin = data1[0].1
            yMax = data1[0].1
        }
        print("Start autoscale")
        print("x: max \(xMax) min \(xMin)")
        print("y: max \(yMax) min \(yMin)")

        for point in data1 {
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
        print("data1")
        print("x: max \(xMax) min \(xMin)")
        print("y: max \(yMax) min \(yMin)")

        for point in data2 {
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
        print("data2")
        print("x: max \(xMax) min \(xMin)")
        print("y: max \(yMax) min \(yMin)")

        
        if autoScaleX {
            print("auto scale x")
            // xLow = xLowTemp
            // xHigh = xHighTemp
            let axis = calcAxis(length: xLabelWidth, min: xMin, max: xMax)
            labelFormatX = labelFormat
            xLow = axis.from
            xHigh = axis.to
            xBy = axis.by
            Swift.print("Axes xLow: \(xLow)   xHigh: \(xHigh)")
            print("x: max \(xMax) min \(xMin)")
            print("y: max \(yMax) min \(yMin)")
        }
        
        if autoScaleY {
            print("auto scale y")
            // yLow = yLowTemp
            // yHigh = yHighTemp
            // Swift.print("calling calcAxis")
            var axis = (from: -0.01, to: 0.01, by: 0.001)
            if yMax - yMin < 0.001 {
                axis = calcAxis(length: labelHeight, min: -0.01, max: 0.01)
            } else {
                axis = calcAxis(length: labelHeight, min: yMin, max: yMax)
            }
            labelFormatY = labelFormat
            // Swift.print("returned from calcAxis")
            yLow = axis.from
            yHigh = axis.to
            yBy = axis.by
            Swift.print("Axes yLow: \(yLow)   yHigh: \(yHigh)")
            print("x: max \(xMax) min \(xMin)")
            print("y: max \(yMax) min \(yMin)")

        }
    }
    
    private func calcAxis(length: CGFloat, min: Double, max: Double) -> (from: Double, to: Double, by: Double) {
        return calcAxis(length: length, min: min, max: max, minTicks: PlotDrawProperties.minTicks, maxTicks: PlotDrawProperties.maxTicks)
    }
    
    /// Calc axis min, max and tick distance
    /// - Parameters:
    ///   - length: length of label for tick, CGFloat
    ///   - min: Min value for axis, Double
    ///   - max: Max value for axix, Double
    /// - returns
    /// - tuple where
    /// - from: start of axis, Double
    /// - to: end of axis, Double
    /// - by: distance between ticks, Double
    private func calcAxis(length: CGFloat, min: Double, max: Double, minTicks: Int, maxTicks: Int) -> (from: Double, to: Double, by: Double) {
        print()
        print("calcAxis()")
        print("min \(min)")
        print("max \(max)")
        print("minTicks \(minTicks)")
        print("maxTicks \(maxTicks)")
        // let maxTicks = 12
        // let minTicks = 5
        
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
        print("from: \(from), to: \(to), by: \(by)")
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
    
    public func getXAxis(low: Double, high: Double) -> (from: Double, to: Double, by: Double) {
        return calcAxis(length: xLabelWidth, min: low  , max: high)
    }
    
    
    override init(frame frameRect: NSRect) {
        /*
         attributeTitle = [ NSAttributedString.Key.foregroundColor: navy,
         NSAttributedString.Key.font: NSFont(name: "HelveticaNeue-BoldItalic", size: 25)!]
         */
        
        attributeTitle = [.foregroundColor: navy,
                          .font: fontLargeBoldItalic]
        
        /*
         attributeLabel = [ NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): navy,
         NSAttributedString.Key.font: NSFont(name: "Helvetica Neue", size: 20.0)!]
         */
        
        attributeLabel = [.foregroundColor: navy,
                          .font: fontLabel]
        
        /*
         attributeAxis = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): NSColor.black,
         NSAttributedString.Key.font: NSFont(name: "Helvetica Neue", size: 15.0)!]
         */
        
        attributeAxis = [.foregroundColor: black,
                         .font: fontAxis]
        
        super.init(frame:frameRect)
        
    }
    
    
    required init?(coder: NSCoder) {
        // titleFontSize = 25
        attributeTitle = [.foregroundColor: navy,
                          .font: fontLargeBoldItalic]
        
        attributeLabel = [.foregroundColor: navy,
                          .font: fontLabel]
        
        attributeAxis = [.foregroundColor: black,
                         .font: fontAxis]
        
        super.init(coder: coder)
    }
    
    
    
}

