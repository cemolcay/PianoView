//
//  PianoView.swift
//  PianoView
//
//  Created by Cem Olcay on 19/01/2017.
//  Copyright © 2017 prototapp. All rights reserved.
//

#if os(OSX)
  import AppKit
#elseif os(iOS) || os(tvOS)
  import UIKit
#endif
import MusicTheorySwift

// MARK: - NSBezierPath Extension
#if os(OSX)
  public struct NSRectCorner: OptionSet {
    public let rawValue: UInt

    public static let none = NSRectCorner(rawValue: 0)
    public static let topLeft = NSRectCorner(rawValue: 1 << 0)
    public static let topRight = NSRectCorner(rawValue: 1 << 1)
    public static let bottomLeft = NSRectCorner(rawValue: 1 << 2)
    public static let bottomRight = NSRectCorner(rawValue: 1 << 3)
    public static var all: NSRectCorner {
      return [.topLeft, .topRight, .bottomLeft, .bottomRight]
    }

    public init(rawValue: UInt) {
      self.rawValue = rawValue
    }
  }

  public extension NSBezierPath {
    public var cgPath: CGPath {
      let path = CGMutablePath()
      var points = [CGPoint](repeating: .zero, count: 3)
      for i in 0 ..< self.elementCount {
        let type = self.element(at: i, associatedPoints: &points)
        switch type {
        case .moveToBezierPathElement:
          path.move(to: CGPoint(x: points[0].x, y: points[0].y))
        case .lineToBezierPathElement:
          path.addLine(to: CGPoint(x: points[0].x, y: points[0].y))
        case .curveToBezierPathElement:
          path.addCurve(
            to: CGPoint(x: points[2].x, y: points[2].y),
            control1: CGPoint(x: points[0].x, y: points[0].y),
            control2: CGPoint(x: points[1].x, y: points[1].y))
        case .closePathBezierPathElement:
          path.closeSubpath()
        }
      }
      return path
    }

    public convenience init(roundedRect: CGRect, cornerRadius: CGFloat) {
      self.init(
        roundedRect: NSRect(
          x: roundedRect.origin.x,
          y: roundedRect.origin.y,
          width: roundedRect.size.width,
          height: roundedRect.size.height),
        xRadius: cornerRadius,
        yRadius: cornerRadius)
    }

    public convenience init(roundedRect rect: NSRect, byRoundingCorners corners: NSRectCorner, cornerRadii: NSSize) {
      self.init()

      let topLeft = rect.origin
      let topRight = NSPoint(x: rect.maxX, y: rect.minY);
      let bottomRight = NSPoint(x: rect.maxX, y: rect.maxY);
      let bottomLeft = NSPoint(x: rect.minX, y: rect.maxY);

      if corners.contains(.topLeft) {
        move(to: CGPoint(
          x: topLeft.x + cornerRadii.width,
          y: topLeft.y))
      } else {
        move(to: topLeft)
      }

      if corners.contains(.topRight) {
        line(to: CGPoint(
          x: topRight.x - cornerRadii.width,
          y: topRight.y))
        curve(
          to: topRight,
          controlPoint1: CGPoint(
            x: topRight.x,
            y: topRight.y + cornerRadii.height),
          controlPoint2: CGPoint(
            x: topRight.x,
            y: topRight.y + cornerRadii.height))
      } else {
        line(to: topRight)
      }

      if corners.contains(.bottomRight) {
        line(to: CGPoint(
          x: bottomRight.x,
          y: bottomRight.y - cornerRadii.height))
        curve(
          to: bottomRight,
          controlPoint1: CGPoint(
            x: bottomRight.x - cornerRadii.width,
            y: bottomRight.y),
          controlPoint2: CGPoint(
            x: bottomRight.x - cornerRadii.width,
            y: bottomRight.y))
      } else {
        line(to: bottomRight)
      }

      if corners.contains(.bottomLeft) {
        line(to: CGPoint(
          x: bottomLeft.x + cornerRadii.width,
          y: bottomLeft.y))
        curve(
          to: bottomLeft,
          controlPoint1: CGPoint(
            x: bottomLeft.x,
            y: bottomLeft.y - cornerRadii.height),
          controlPoint2: CGPoint(
            x: bottomLeft.x,
            y: bottomLeft.y - cornerRadii.height))
      } else {
        line(to: bottomLeft)
      }

      if corners.contains(.topLeft) {
        line(to: CGPoint(
          x: topLeft.x,
          y: topLeft.y + cornerRadii.height))
        curve(
          to: topLeft,
          controlPoint1: CGPoint(
            x: topLeft.x + cornerRadii.width,
            y: topLeft.y),
          controlPoint2: CGPoint(
            x: topLeft.x + cornerRadii.width,
            y: topLeft.y))
      } else {
        line(to: topLeft)
      }
      
      close()
    }
  }
  
  public extension NSImage {
    public var cgImage: CGImage? {
      return cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
  }
#endif

// MARK: - NoteType Extension
internal extension NoteType {
  internal var pianoKeyType: PianoKeyType {
    switch self {
    case .c, .d, .e, .f, .g, .a, .b:
      return .white
    default:
      return .black
    }
  }
}

// MARK: - Typealiases
#if os(OSX)
public typealias PVColor = NSColor
public typealias PVFont = NSFont
public typealias PVView = NSView
public typealias PVImage = NSImage
public typealias PVBezierPath = NSBezierPath
#elseif os(iOS) || os(tvOS)
public typealias PVColor = UIColor
public typealias PVFont = UIFont
public typealias PVView = UIView
public typealias PVImage = UIImage
public typealias PVBezierPath = UIBezierPath
#endif

// MARK: - PianoKeyType
public enum PianoKeyType {
  case white
  case black
}

// MARK: - PianoKeyLayer
public class PianoKeyLayer: CALayer {
  public var note: Note

  public var isSelected = false
  public var isHighlighted = false

  public var isDrawText = false
  public var isDrawGradient = true
  public var isDrawMask = true

  public var keyCornerRadius: CGFloat = 5
  public var highlightedColor = PVColor.white
  public var selectedColor = PVColor.white

  public var textColor = PVColor.white
  public var selectedTextColor = PVColor.white
  public var highlightedTextColor = PVColor.white

  public var textSize: CGFloat = 15
  public var textTreshold: CGFloat = 5
  public var text = ""

  public var maskLayer = CAShapeLayer()
  public var highlightLayer = CALayer()
  public var textLayer = CATextLayer()

  public var type: PianoKeyType {
    return note.type.pianoKeyType
  }

  // MARK: Init

  public init(note: Note) {
    self.note = note
    super.init()
    commonInit()
  }

  public required init?(coder aDecoder: NSCoder) {
    note = Note(midiNote: 0)
    super.init(coder: aDecoder)
    commonInit()
  }

  public override init(layer: Any) {
    note = Note(midiNote: 0)
    super.init(layer: layer)
    commonInit()
  }

  private func commonInit() {
    addSublayer(highlightLayer)
    addSublayer(textLayer)
    textLayer.alignmentMode = kCAAlignmentCenter
    #if os(OSX)
      textLayer.contentsScale = NSScreen.main()?.backingScaleFactor ?? 1
    #elseif os(iOS) || os(tvOS)
      textLayer.contentsScale = UIScreen.main.scale
    #endif
  }

  // MARK: Draw

  public override func draw(in ctx: CGContext) {
    super.draw(in: ctx)

    // Background
    backgroundColor = isSelected ? selectedColor.cgColor : backgroundColor
    highlightLayer.backgroundColor = isHighlighted ? highlightedColor.cgColor : PVColor.clear.cgColor
    highlightLayer.frame = bounds

    // Text
    if isDrawText {
      let textColor = isHighlighted ? highlightedTextColor : isSelected ? selectedTextColor : self.textColor
      let font = PVFont.systemFont(ofSize: textSize)
      textLayer.string = NSAttributedString(
        string: text,
        attributes: [
          NSForegroundColorAttributeName: textColor,
          NSFontAttributeName: font
        ])

      #if os(OSX)
        textLayer.frame = CGRect(
          x: 0,
          y: textTreshold,
          width: frame.size.width,
          height: textSize)
      #elseif os(iOS) || os(tvOS)
        textLayer.frame = CGRect(
          x: 0,
          y: frame.size.height - textSize - textTreshold,
          width: frame.size.width,
          height: textSize)
      #endif

    } else {
      textLayer.string = nil
    }

    // Gradient
    if isDrawGradient {
      drawGradient(in: ctx)
    }

    // Mask
    if isDrawMask {
      mask = maskLayer
      maskLayer.frame = bounds

      #if os(OSX)
        maskLayer.path = NSBezierPath(
          roundedRect: maskLayer.frame,
          byRoundingCorners: [.topLeft, .topRight],
          cornerRadii: NSSize(width: keyCornerRadius, height: keyCornerRadius))
          .cgPath
      #elseif os(iOS) || os(tvOS)
        maskLayer.path = UIBezierPath(
          roundedRect: maskLayer.frame,
          byRoundingCorners: [.bottomLeft, .bottomRight],
          cornerRadii: CGSize(width: keyCornerRadius, height: keyCornerRadius))
          .cgPath
      #endif
    }
  }

  private func drawGradient(in ctx: CGContext) {
    let size: CGSize = bounds.size

    if case .black = note.type.pianoKeyType {
      let fillColor = PVColor(red: 0.379, green: 0.379, blue: 0.379, alpha: 1)
      let strokeColor = PVColor(red: 0, green: 0, blue: 0, alpha: 0.951)
      let gradient1Colors = [strokeColor.cgColor, fillColor.cgColor]
      let gradient1Locations: [CGFloat] = [0.11, 1.0]

      guard let gradient1 = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: gradient1Colors as CFArray,
        locations: gradient1Locations)
        else { return }

      let frame = CGRect(
        x: 0,
        y: 0,
        width: size.width,
        height: size.height)

      let rectanglePath = CGRect(
          x: frame.minX,
          y: frame.minY,
          width: size.width,
          height: size.height)

      ctx.setFillColor(strokeColor.cgColor)
      ctx.fill(rectanglePath)

      let border = size.width * 0.15
      let width = size.width * 0.7
      #if os(OSX)
        var topRectHeight = size.height * 0.125
        var bottomRectOffset = size.height * 0.15
        let bottomRectHeight = size.height * 0.86
      #elseif os(iOS) || os(tvOS)
        var topRectHeight = size.height * 0.86
        var bottomRectOffset = size.height * 0.875
        let bottomRectHeight = size.height * 0.225
      #endif

      if isSelected {
        #if os(OSX)
          topRectHeight = size.height * 1
          bottomRectOffset = size.height * 0.925
        #elseif os(iOS) || os(tvOS)
          topRectHeight = size.height * 0.91
          bottomRectOffset = size.height * 0.925
        #endif
      }

      let roundedRectangleRect = CGRect(
        x: frame.minX + border,
        y: frame.minY,
        width: width,
        height: topRectHeight)

      let roundedRectanglePath = PVBezierPath(
        roundedRect:roundedRectangleRect,
        cornerRadius: cornerRadius)

      ctx.saveGState()
      ctx.addPath(roundedRectanglePath.cgPath)
      ctx.clip(using: .evenOdd)

      ctx.drawLinearGradient(
        gradient1,
        start: CGPoint(
          x: roundedRectangleRect.midX,
          y: roundedRectangleRect.minY),
        end: CGPoint(
          x: roundedRectangleRect.midX,
          y: roundedRectangleRect.maxY),
        options: [])

      ctx.restoreGState()

      let roundedRectangle2Rect = CGRect(
        x: frame.minX +  border,
        y: frame.minY + bottomRectOffset,
        width: width,
        height: bottomRectHeight)

      let roundedRectangle2Path = PVBezierPath(
        roundedRect: roundedRectangle2Rect,
        cornerRadius: cornerRadius)

      ctx.saveGState()
      ctx.addPath(roundedRectangle2Path.cgPath)
      ctx.clip(using: .evenOdd)

      ctx.drawLinearGradient(
        gradient1,
        start: CGPoint(
          x: roundedRectangle2Rect.midX,
          y: roundedRectangle2Rect.maxY),
        end: CGPoint(
          x: roundedRectangle2Rect.midX,
          y: roundedRectangle2Rect.minY),
        options: [])

    } else {
      var fillColor = PVColor(red:0.1, green: 0.1, blue: 0.1, alpha: 0.20)
      var strokeColor = PVColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.0)

      if isSelected {
        fillColor = PVColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.50)
        strokeColor = PVColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.0)
      }

      let gradient1Colors = [strokeColor.cgColor, fillColor.cgColor]
      let gradient1Locations: [CGFloat] = [0.1, 1.0]

      guard let gradient1 = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: gradient1Colors as CFArray, locations: gradient1Locations)
        else { return }

      let rectanglePath = CGRect(
        x: 0,
        y: 0,
        width: size.width,
        height: size.height)

      ctx.saveGState()
      ctx.clip(to: rectanglePath)

      ctx.drawRadialGradient(
        gradient1,
        startCenter: CGPoint(
          x: size.width / 2.0,
          y: size.height / 2.0),
        startRadius: size.height * 0.01,
        endCenter: CGPoint(
          x: size.width / 2.0,
          y: size.height / 2.0),
        endRadius: size.height * 0.6,
        options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    }
    
    ctx.restoreGState()
  }
}

// MARK: - PianoView
@IBDesignable
public class PianoView: PVView {
  @IBInspectable public var startOctave: Int = 0 {
    didSet {
      if startOctave < 0 {
        startOctave = 0
      }
      setup()
      draw()
    }
  }

  @IBInspectable public var keyCount: Int = 25 {
    didSet {
      if keyCount < 0 {
        keyCount = 0
      }
      setup()
      draw()
    }
  }

  #if os(OSX)
    @IBInspectable public var whiteKeyBackgroundColor: NSColor = .white { didSet{ redraw() }}
    @IBInspectable public var blackKeyBackgroundColor: NSColor = .black { didSet{ redraw() }}
    @IBInspectable public var whiteKeySelectedColor: NSColor = .lightGray { didSet{ redraw() }}
    @IBInspectable public var blackKeySelectedColor: NSColor = .darkGray { didSet{ redraw() }}
    @IBInspectable public var whiteKeyHighlightedColor: NSColor = .green { didSet{ redraw() }}
    @IBInspectable public var blackKeyHighlightedColor: NSColor = .green { didSet{ redraw() }}

    @IBInspectable public var whiteKeyBorderColor: NSColor = .black { didSet{ redraw() }}
    @IBInspectable public var blackKeyBorderColor: PVColor = .black { didSet{ redraw() }}
  #elseif os(iOS) || os(tvOS)
    @IBInspectable public var whiteKeyBackgroundColor: UIColor = .white { didSet{ redraw() }}
    @IBInspectable public var blackKeyBackgroundColor: UIColor = .black { didSet{ redraw() }}
    @IBInspectable public var whiteKeySelectedColor: UIColor = .lightGray { didSet{ redraw() }}
    @IBInspectable public var blackKeySelectedColor: UIColor = .darkGray { didSet{ redraw() }}
    @IBInspectable public var whiteKeyHighlightedColor: UIColor = .green { didSet{ redraw() }}
    @IBInspectable public var blackKeyHighlightedColor: UIColor = .green { didSet{ redraw() }}

    @IBInspectable public var whiteKeyBorderColor: UIColor = .black { didSet{ redraw() }}
    @IBInspectable public var blackKeyBorderColor: UIColor = .black { didSet{ redraw() }}
  #endif

  @IBInspectable public var whiteKeyBorderWidth: CGFloat = 0.5 { didSet{ redraw() }}
  @IBInspectable public var blackKeyBorderWidth: CGFloat = 0 { didSet{ redraw() }}

  #if os(OSX)
    @IBInspectable public var whiteKeyTextColor: NSColor = .black { didSet{ redraw() }}
    @IBInspectable public var blackKeyTextColor: NSColor = .white { didSet{ redraw() }}
    @IBInspectable public var whiteKeySelectedTextColor: NSColor = .white { didSet{ redraw() }}
    @IBInspectable public var blackKeySelectedTextColor: NSColor = .black { didSet{ redraw() }}
    @IBInspectable public var blackKeyHighlightedTextColor: NSColor = .black { didSet{ redraw() }}
    @IBInspectable public var whiteKeyHighlightedTextColor: NSColor = .black { didSet{ redraw() }}
  #elseif os(iOS) || os(tvOS)
    @IBInspectable public var whiteKeyTextColor: UIColor = .black { didSet{ redraw() }}
    @IBInspectable public var blackKeyTextColor: UIColor = .white { didSet{ redraw() }}
    @IBInspectable public var whiteKeySelectedTextColor: UIColor = .white { didSet{ redraw() }}
    @IBInspectable public var blackKeySelectedTextColor: UIColor = .black { didSet{ redraw() }}
    @IBInspectable public var blackKeyHighlightedTextColor: UIColor = .black { didSet{ redraw() }}
    @IBInspectable public var whiteKeyHighlightedTextColor: UIColor = .black { didSet{ redraw() }}
  #endif

  @IBInspectable public var whiteKeyFontSize: CGFloat = 15 { didSet{ redraw() }}
  @IBInspectable public var blackKeyFontSize: CGFloat = 11 { didSet{ redraw() }}
  @IBInspectable public var whiteKeyTextTreshold: CGFloat = 5 { didSet{ redraw() }}
  @IBInspectable public var blackKeyTextTreshold: CGFloat = 5 { didSet{ redraw() }}

  @IBInspectable public var drawNoteText: Bool = true { didSet{ redraw() }}
  @IBInspectable public var drawNoteOctave: Bool = false { didSet{ redraw() }}
  @IBInspectable public var drawGradient: Bool = true { didSet{ redraw() }}
  @IBInspectable public var drawMask: Bool = true { didSet{ redraw() }}

  @IBInspectable public var blackKeyCornerRadius: CGFloat = 3 { didSet{ redraw() }}
  @IBInspectable public var whiteKeyCornerRadius: CGFloat = 5 { didSet{ redraw() }}

  private var pianoKeys = [PianoKeyLayer]()
  private var shouldRedraw = true

  // MARK: Select

  public func selectNote(note: Note) {
    pianoKeys.filter({ $0.note == note }).first?.isSelected = true
    draw()
  }

  public func deselectNote(note: Note) {
    pianoKeys.filter({ $0.note == note }).first?.isSelected = false
    draw()
  }

  public func deselectAll() {
    pianoKeys.filter({ $0.isSelected }).forEach({ $0.isSelected = false })
    draw()
  }

  // MARK: Highlight

  public func highlightNote(note: Note) {
    pianoKeys.filter({ $0.note == note }).first?.isHighlighted = true
    draw()
  }

  public func unhighlightNote(note: Note) {
    pianoKeys.filter({ $0.note == note }).first?.isHighlighted = false
    draw()
  }

  public func highlightNoteType(noteType: NoteType) {
    pianoKeys.filter({ $0.note.type == noteType }).forEach({ $0.isHighlighted = true })
  }

  public func unhighlightAll() {
    pianoKeys.filter({ $0.isHighlighted }).forEach({ $0.isHighlighted = false })
    draw()
  }

  // MARK: Setup

  private func setup() {
    #if os(OSX)
      wantsLayer = true
      guard let layer = self.layer else { return }
    #endif

    pianoKeys.forEach({ $0.removeFromSuperlayer() })
    let startNote = Note(type: .c, octave: startOctave)
    pianoKeys = Array(0..<keyCount).map({ PianoKeyLayer(note: startNote + $0) })
    pianoKeys.filter({ $0.type == .white }).forEach({ layer.addSublayer($0) })
    pianoKeys.filter({ $0.type == .black }).forEach({ layer.addSublayer($0) })
  }

  // MARK: Draw

  #if os(OSX)
    public override func draw(_ dirtyRect: NSRect) {
      super.draw(dirtyRect)
      draw()
    }
  #elseif os(iOS) || os(tvOS)
    public override func draw(_ rect: CGRect) {
      super.draw(rect)
      draw()
    }
  #endif

  private func draw() {
    // Setup if needed
    if keyCount > 0, pianoKeys.isEmpty {
      setup()
    }

    // Draw keys
    let whiteKeyCount = pianoKeys.filter({ $0.type == .white }).count
    let whiteKeyWidth = frame.size.width / CGFloat(whiteKeyCount)
    let blackKeyWidth = whiteKeyWidth / 2
    var currentX: CGFloat = 0
    for key in pianoKeys {

      // Setup frame
      switch key.type {
      case .black:
        #if os(OSX)
          key.frame = CGRect(
            x: currentX - blackKeyWidth / 2,
            y: frame.size.height - (frame.size.height / 5 * 3),
            width: key == pianoKeys.last ? blackKeyWidth / 2 : blackKeyWidth,
            height: frame.size.height / 5 * 3)
        #elseif os(iOS) || os(tvOS)
          key.frame = CGRect(
            x: currentX - blackKeyWidth / 2,
            y: 0,
            width: key == pianoKeys.last ? blackKeyWidth / 2 : blackKeyWidth,
            height: frame.size.height / 5 * 3)
        #endif
      case .white:
        #if os(OSX)
          key.frame = CGRect(
            x: currentX,
            y: 0,
            width: whiteKeyWidth,
            height: frame.size.height)
          currentX += whiteKeyWidth
        #elseif os(iOS) || os(tvOS)
          key.frame = CGRect(
            x: currentX,
            y: 0,
            width: whiteKeyWidth,
            height: frame.size.height)
          currentX += whiteKeyWidth
        #endif
      }

      // Setup background colors
      key.backgroundColor = key.type == .black ? blackKeyBackgroundColor.cgColor : whiteKeyBackgroundColor.cgColor
      key.selectedColor = key.type == .black ? blackKeySelectedColor : whiteKeySelectedColor
      key.highlightedColor = key.type == .black ? blackKeyHighlightedColor : whiteKeyHighlightedColor

      // Setup borders
      key.borderColor = key.type == .black ? blackKeyBorderColor.cgColor : whiteKeyBorderColor.cgColor
      key.borderWidth = key.type == .black ? blackKeyBorderWidth : whiteKeyBorderWidth
      key.keyCornerRadius = key.type == .black ? blackKeyCornerRadius : whiteKeyCornerRadius

      // Setup text
      key.textColor = key.type == .black ? blackKeyTextColor : whiteKeyTextColor
      key.selectedTextColor = key.type == .black ? blackKeySelectedTextColor : whiteKeySelectedTextColor
      key.highlightedTextColor = key.type == .black ? blackKeyHighlightedTextColor : whiteKeyHighlightedTextColor
      key.textSize = key.type == .black ? blackKeyFontSize : whiteKeyFontSize
      key.text = key.type == .black ? (drawNoteOctave ? "\(key.note)" : "\(key.note.type)") : (drawNoteOctave ? "\(key.note)" : "\(key.note.type)")

      // Setup options
      key.isDrawText = drawNoteText
      key.isDrawGradient = drawGradient
      key.isDrawMask = drawMask

      // Draw key
      key.setNeedsDisplay()
    }
  }

  // MARK: Redraw

  public func update(with block: @escaping (PianoView) -> Void) {
    shouldRedraw = false
    block(self)
    shouldRedraw = true
    redraw()
  }

  private func redraw() {
    guard shouldRedraw else { return }
    #if os(OSX)
      needsDisplay = true
    #elseif os(iOS) || os(tvOS)
      setNeedsDisplay()
    #endif
  }
}
