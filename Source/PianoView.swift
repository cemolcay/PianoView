//
//  PianoView.swift
//  PianoView
//
//  Created by Cem Olcay on 19/01/2017.
//  Copyright © 2017 prototapp. All rights reserved.
//

#if os(OSX)
  import AppKit
#elseif os(iOS)
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
#elseif os(iOS)
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
  public var keyCornerRadius = 5

  public var maskLayer = CAShapeLayer()
  public var highlightLayer = CALayer()
  public var textLayer = CATextLayer()

  public var type: PianoKeyType {
    return note.type.pianoKeyType
  }

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
    #if os(OSX)
      textLayer.contentsScale = NSScreen.main()?.backingScaleFactor ?? 1
    #elseif os(iOS)
      textLayer.contentsScale = UIScreen.main.scale
    #endif
  }

  public override func draw(in ctx: CGContext) {
    super.draw(in: ctx)
  }

  public var keyImage: PVImage {
    var size: CGSize = bounds.size

    #if os(OSX)
      let scale = NSScreen.main()?.backingScaleFactor ?? 1
    #elseif os(iOS)
      let scale = UIScreen.main.scale
    #endif

    size.width *= scale
    size.height *= scale

    #if os(OSX)
      let image = NSImage(size: NSSize(width: size.width, height: size.height))
      image.lockFocus()
      guard let context = NSGraphicsContext.current()?.cgContext else { return PVImage() }
    #elseif os(iOS)
      UIGraphicsBeginImageContext(size)
      guard let context = UIGraphicsGetCurrentContext() else { return PVImage() }
    #endif

    let colorSpace = CGColorSpaceCreateDeviceRGB()

    if case .black = note.type.pianoKeyType {
      let fillColor = PVColor(red: 0.379, green: 0.379, blue: 0.379, alpha: 1)
      let strokeColor = PVColor(red: 0, green: 0, blue: 0, alpha: 0.951)
      let gradient1Colors = [strokeColor.cgColor, fillColor.cgColor]
      let gradient1Locations: [CGFloat] = [0.11, 1.0]

      guard let gradient1 = CGGradient(
        colorsSpace: colorSpace,
        colors: gradient1Colors as CFArray,
        locations: gradient1Locations)
        else { return PVImage() }

      let frame = CGRect(
        x: 0,
        y: 0,
        width: size.width,
        height: size.height)

      let rectanglePath = PVBezierPath(
        rect: CGRect(
          x: frame.minX,
          y: frame.minY,
          width: size.width,
          height: size.height))

      strokeColor.setFill()
      rectanglePath.fill()

      let border = size.width * 0.15
      let width = size.width * 0.7
      #if os(OSX)
        var topRectHeight = size.height * 0.225
        var bottomRectOffset = size.height * 0.25
        let bottomRectHeight = size.height * 0.86
      #elseif os(iOS)
        var topRectHeight = size.height * 0.86
        var bottomRectOffset = size.height * 0.875
        let bottomRectHeight = size.height * 0.225
      #endif

      if isSelected {
        #if os(OSX)
          topRectHeight = size.height * 1
          bottomRectOffset = size.height * 0.925
        #elseif os(iOS)
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

      context.saveGState()

      roundedRectanglePath.addClip()

      context.drawLinearGradient(
        gradient1,
        start: CGPoint(
          x: roundedRectangleRect.midX,
          y: roundedRectangleRect.minY),
        end: CGPoint(
          x: roundedRectangleRect.midX,
          y: roundedRectangleRect.maxY),
        options: [])

      context.restoreGState()

      let roundedRectangle2Rect = CGRect(
        x: frame.minX +  border,
        y: frame.minY + bottomRectOffset,
        width: width,
        height: bottomRectHeight)

      let roundedRectangle2Path = PVBezierPath(
        roundedRect: roundedRectangle2Rect,
        cornerRadius: cornerRadius)

      context.saveGState()

      roundedRectangle2Path.addClip()

      context.drawLinearGradient(
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
        colorsSpace: colorSpace,
        colors: gradient1Colors as CFArray, locations: gradient1Locations)
        else { return PVImage() }

      let rectanglePath = PVBezierPath(
        rect: CGRect(
          x: 0,
          y: 0,
          width: size.width, 
          height: size.height))

      context.saveGState()

      rectanglePath.addClip()

      context.drawRadialGradient(
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

    context.restoreGState()

    #if os(OSX)
      image.unlockFocus()
      return image
    #elseif os(iOS)
      if let image = UIGraphicsGetImageFromCurrentImageContext() {
        return image
      }
    #endif
    return PVImage()
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

  @IBInspectable public var whiteKeyBackgroundColor: PVColor = .white { didSet{ draw() }}
  @IBInspectable public var blackKeyBackgroundColor: PVColor = .black { didSet{ draw() }}
  @IBInspectable public var whiteKeySelectedColor: PVColor = .lightGray { didSet{ draw() }}
  @IBInspectable public var blackKeySelectedColor: PVColor = .darkGray { didSet{ draw() }}
  @IBInspectable public var whiteKeyHighlightedColor: PVColor = .green { didSet{ draw() }}
  @IBInspectable public var blackKeyHighlightedColor: PVColor = .green { didSet{ draw() }}
  @IBInspectable public var whiteKeyBorderColor: PVColor = .black { didSet{ draw() }}
  @IBInspectable public var blackKeyBorderColor: PVColor = .black { didSet{ draw() }}
  @IBInspectable public var whiteKeyBorderWidth: CGFloat = 0.5 { didSet{ draw() }}
  @IBInspectable public var blackKeyBorderWidth: CGFloat = 0 { didSet{ draw() }}
  @IBInspectable public var whiteKeyTextColor: PVColor = .black { didSet{ draw() }}
  @IBInspectable public var blackKeyTextColor: PVColor = .white { didSet{ draw() }}
  @IBInspectable public var whiteKeySelectedTextColor: PVColor = .white { didSet{ draw() }}
  @IBInspectable public var blackKeySelectedTextColor: PVColor = .black { didSet{ draw() }}
  @IBInspectable public var whiteKeyFontSize: CGFloat = 15 { didSet{ draw() }}
  @IBInspectable public var blackKeyFontSize: CGFloat = 15 { didSet{ draw() }}
  @IBInspectable public var whiteKeyTextTreshold: CGFloat = 5 { didSet{ draw() }}
  @IBInspectable public var blackKeyTextTreshold: CGFloat = 5 { didSet{ draw() }}
  @IBInspectable public var drawNoteText: Bool = false { didSet{ draw() }}
  @IBInspectable public var drawNoteOctave: Bool = true { didSet{ draw() }}
  @IBInspectable public var drawGradient: Bool = true { didSet{ draw() }}
  @IBInspectable public var blackKeyCornerRadius: CGFloat = 3 { didSet{ draw() }}
  @IBInspectable public var whiteKeyCornerRadius: CGFloat = 5 { didSet{ draw() }}
  private var pianoKeys = [PianoKeyLayer]()

  #if os(OSX)
    public override func draw(_ dirtyRect: NSRect) {
      super.draw(dirtyRect)
      draw()
    }
  #elseif os(iOS)
    public override func draw(_ rect: CGRect) {
      super.draw(rect)
      draw()
    }
  #endif

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

  private func draw() {
    if keyCount > 0, pianoKeys.isEmpty {
      setup()
    }
    
    let whiteKeyCount = pianoKeys.filter({ $0.type == .white }).count
    let whiteKeyWidth = frame.size.width / CGFloat(whiteKeyCount)
    let blackKeyWidth = whiteKeyWidth / 2
    var currentX: CGFloat = 0
    for key in pianoKeys {
      switch key.type {
      case .black:
        // Setup frame
        #if os(OSX)
          key.frame = CGRect(
            x: currentX - blackKeyWidth / 2,
            y: frame.size.height - (frame.size.height / 5 * 3),
            width: key == pianoKeys.last ? blackKeyWidth / 2 : blackKeyWidth,
            height: frame.size.height / 5 * 3)
        #elseif os(iOS)
          key.frame = CGRect(
            x: currentX - blackKeyWidth / 2,
            y: 0,
            width: key == pianoKeys.last ? blackKeyWidth / 2 : blackKeyWidth,
            height: frame.size.height / 5 * 3)
        #endif

        // Draw background
        key.backgroundColor = key.isSelected ? blackKeySelectedColor.cgColor : blackKeyBackgroundColor.cgColor
        key.highlightLayer.frame = key.bounds
        key.highlightLayer.backgroundColor = key.isHighlighted ? blackKeyHighlightedColor.cgColor : PVColor.clear.cgColor

        // Draw image or color
        if !drawGradient {
          key.borderWidth = blackKeyBorderWidth
          key.borderColor = blackKeyBorderColor.cgColor
          key.contents = nil
        } else {
          key.mask = key.maskLayer
          key.maskLayer.frame = key.bounds
          key.contents = key.keyImage.cgImage

          #if os(OSX)
            key.maskLayer.path = NSBezierPath(
              roundedRect: key.maskLayer.frame,
              byRoundingCorners: [.topLeft, .topRight],
              cornerRadii: NSSize(width: blackKeyCornerRadius, height: blackKeyCornerRadius))
              .cgPath
          #elseif os(iOS)
            key.maskLayer.path = UIBezierPath(
              roundedRect: key.maskLayer.frame,
              byRoundingCorners: [.bottomLeft, .bottomRight],
              cornerRadii: CGSize(width: blackKeyCornerRadius, height: blackKeyCornerRadius))
              .cgPath
          #endif

        }

        // Draw text
        if drawNoteText {
          let text = drawNoteOctave ? "\(key.note)" : "\(key.note.type)"
          let textColor = key.isSelected ? blackKeySelectedTextColor : blackKeyTextColor
          let font = PVFont.systemFont(ofSize: blackKeyFontSize)
          key.textLayer.alignmentMode = kCAAlignmentCenter
          key.textLayer.string = NSAttributedString(
            string: text,
            attributes: [
              NSForegroundColorAttributeName: textColor,
              NSFontAttributeName: font
            ])

          #if os(OSX)
            key.textLayer.frame = CGRect(
              x: 0,
              y: blackKeyTextTreshold,
              width: key.frame.size.width,
              height: blackKeyFontSize)
          #elseif os(iOS)
            key.textLayer.frame = CGRect(
              x: 0,
              y: key.frame.size.height - blackKeyFontSize - blackKeyTextTreshold,
              width: key.frame.size.width,
              height: blackKeyFontSize)
          #endif

        } else {
          key.textLayer.string = nil
        }

      case .white:
        // Setup frame
        #if os(OSX)
          key.frame = CGRect(
            x: currentX,
            y: 0,
            width: whiteKeyWidth,
            height: frame.size.height)
          currentX += whiteKeyWidth
        #elseif os(iOS)
          key.frame = CGRect(
            x: currentX,
            y: 0,
            width: whiteKeyWidth,
            height: frame.size.height)
          currentX += whiteKeyWidth
        #endif

        // Draw backgorund
        key.backgroundColor = drawGradient ? whiteKeyBackgroundColor.cgColor : (key.isSelected ? whiteKeySelectedColor.cgColor : whiteKeyBackgroundColor.cgColor)
        key.highlightLayer.frame = key.bounds
        key.highlightLayer.backgroundColor = key.isHighlighted ? blackKeyHighlightedColor.cgColor : PVColor.clear.cgColor

        // Draw image or color
        if !drawGradient {
          key.borderWidth = whiteKeyBorderWidth
          key.borderColor = whiteKeyBorderColor.cgColor
          key.contents = nil
        } else {
          key.mask = key.maskLayer
          key.maskLayer.frame = key.bounds.insetBy(dx: 1, dy: 0)
          key.contents = key.keyImage.cgImage

          #if os(OSX)
            key.maskLayer.path = NSBezierPath(
              roundedRect: key.maskLayer.bounds,
              byRoundingCorners: [.topLeft, .topRight],
              cornerRadii: NSSize(width: whiteKeyCornerRadius, height: whiteKeyCornerRadius))
              .cgPath
          #elseif os(iOS)
            key.maskLayer.path = UIBezierPath(
              roundedRect: key.maskLayer.bounds,
              byRoundingCorners: [.bottomLeft, .bottomRight],
              cornerRadii: CGSize(width: whiteKeyCornerRadius, height: whiteKeyCornerRadius))
              .cgPath
          #endif
        }

        // Draw text
        if drawNoteText {
          let text = drawNoteOctave ? "\(key.note)" : "\(key.note.type)"
          let textColor = key.isSelected ? whiteKeySelectedTextColor : whiteKeyTextColor
          let font = PVFont.systemFont(ofSize: whiteKeyFontSize)
          key.textLayer.alignmentMode = kCAAlignmentCenter
          key.textLayer.string = NSAttributedString(
            string: text,
            attributes: [
              NSForegroundColorAttributeName: textColor,
              NSFontAttributeName: font
            ])

          #if os(OSX)
            key.textLayer.frame = CGRect(
              x: 0,
              y: whiteKeyTextTreshold,
              width: key.frame.size.width,
              height: whiteKeyFontSize)
          #elseif os(iOS)
            key.textLayer.frame = CGRect(
              x: 0,
              y: key.frame.size.height - whiteKeyFontSize - whiteKeyTextTreshold,
              width: key.frame.size.width,
              height: whiteKeyFontSize)
          #endif

        } else {
          key.textLayer.string = nil
        }
      }
    }
  }
}
