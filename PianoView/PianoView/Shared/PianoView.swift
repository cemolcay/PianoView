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

#if os(OSX)
public typealias PVColor = NSColor
public typealias PVFont = NSFont
public typealias PVView = NSView
#elseif os(iOS)
public typealias PVColor = UIColor
public typealias PVFont = UIFont
public typealias PVView = UIView
#endif

public enum PianoKeyType {
  case white
  case black
}

public class PianoKeyLayer: CALayer {
  public var note: Note
  public var isSelected = false
  public var isHighlighted = false

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
}

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
  @IBInspectable public var whiteKeyBorderWidth: CGFloat = 1 { didSet{ draw() }}
  @IBInspectable public var blackKeyBorderWidth: CGFloat = 0 { didSet{ draw() }}
  @IBInspectable public var whiteKeyTextColor: PVColor = .black { didSet{ draw() }}
  @IBInspectable public var blackKeyTextColor: PVColor = .white { didSet{ draw() }}
  @IBInspectable public var whiteKeySelectedTextColor: PVColor = .white { didSet{ draw() }}
  @IBInspectable public var blackKeySelectedTextColor: PVColor = .black { didSet{ draw() }}
  @IBInspectable public var whiteKeyFontSize: CGFloat = 15 { didSet{ draw() }}
  @IBInspectable public var blackKeyFontSize: CGFloat = 15 { didSet{ draw() }}
  @IBInspectable public var whiteKeyTextTreshold: CGFloat = 5 { didSet{ draw() }}
  @IBInspectable public var blackKeyTextTreshold: CGFloat = 5 { didSet{ draw() }}
  @IBInspectable public var drawNoteText: Bool = true { didSet{ draw() }}
  @IBInspectable public var drawNoteOctave: Bool = true { didSet{ draw() }}

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

    public override func layoutSubviews() {
      super.layoutSubviews()
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
        key.backgroundColor = key.isSelected ? blackKeySelectedColor.cgColor : blackKeyBackgroundColor.cgColor
        key.highlightLayer.backgroundColor = key.isHighlighted ? blackKeyHighlightedColor.cgColor : PVColor.clear.cgColor
        key.borderWidth = blackKeyBorderWidth
        key.borderColor = blackKeyBorderColor.cgColor

        #if os(OSX)
          key.frame = CGRect(
            x: currentX - blackKeyWidth / 2,
            y: frame.size.height / 2,
            width: key == pianoKeys.last ?  blackKeyWidth / 2 : blackKeyWidth,
            height: frame.size.height / 2)
          key.highlightLayer.frame = key.bounds
        #elseif os(iOS)
          key.frame = CGRect(
            x: currentX - blackKeyWidth / 2,
            y: 0,
            width: key == pianoKeys.last ?  blackKeyWidth / 2 : blackKeyWidth,
            height: frame.size.height / 2)
        #endif

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
        key.backgroundColor = key.isSelected ? whiteKeySelectedColor.cgColor : whiteKeyBackgroundColor.cgColor
        key.highlightLayer.backgroundColor = key.isHighlighted ? blackKeyHighlightedColor.cgColor : PVColor.clear.cgColor
        key.borderWidth = whiteKeyBorderWidth
        key.borderColor = whiteKeyBorderColor.cgColor

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

        key.highlightLayer.frame = key.bounds

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
