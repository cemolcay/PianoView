//
//  PianoView.swift
//  PianoView
//
//  Created by Cem Olcay on 19/01/2017.
//  Copyright © 2017 prototapp. All rights reserved.
//

import AppKit
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

public typealias UIColor = NSColor
public typealias UIFont = NSFont
public typealias UIView = NSView

public enum PianoKeyType {
  case white
  case black
}

public class PianoKeyLayer: CALayer {
  public var note: Note
  public var isSelected = false
  public var selectedColor = UIColor.lightGray
  public var textLayer = CATextLayer()

  public var type: PianoKeyType {
    return note.type.pianoKeyType
  }

  public init(note: Note) {
    self.note = note
    super.init()
    addSublayer(textLayer)
    textLayer.contentsScale = NSScreen.main()?.backingScaleFactor ?? 1
  }

  public required init?(coder aDecoder: NSCoder) {
    note = Note(midiNote: 0)
    super.init(coder: aDecoder)
    addSublayer(textLayer)
    textLayer.contentsScale = NSScreen.main()?.backingScaleFactor ?? 1
  }
}

@IBDesignable
public class PianoView: UIView {
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

  @IBInspectable public var whiteKeyBackgroundColor: UIColor = .white { didSet{ draw() }}
  @IBInspectable public var blackKeyBackgroundColor: UIColor = .black { didSet{ draw() }}
  @IBInspectable public var whiteKeySelectedColor: UIColor = .lightGray { didSet{ draw() }}
  @IBInspectable public var blackKeySelectedColor: UIColor = .darkGray { didSet{ draw() }}
  @IBInspectable public var whiteKeyBorderColor: UIColor = .black { didSet{ draw() }}
  @IBInspectable public var blackKeyBorderColor: UIColor = .black { didSet{ draw() }}
  @IBInspectable public var whiteKeyBorderWidth: CGFloat = 1 { didSet{ draw() }}
  @IBInspectable public var blackKeyBorderWidth: CGFloat = 0 { didSet{ draw() }}
  @IBInspectable public var whiteKeyTextColor: UIColor = .black { didSet{ draw() }}
  @IBInspectable public var blackKeyTextColor: UIColor = .white { didSet{ draw() }}
  @IBInspectable public var whiteKeySelectedTextColor: UIColor = .lightGray { didSet{ draw() }}
  @IBInspectable public var blackKeySelectedTextColor: UIColor = .darkGray { didSet{ draw() }}
  @IBInspectable public var whiteKeyFontSize: CGFloat = 15 { didSet{ draw() }}
  @IBInspectable public var blackKeyFontSize: CGFloat = 15 { didSet{ draw() }}
  @IBInspectable public var whiteKeyTextTreshold: CGFloat = 5 { didSet{ draw() }}
  @IBInspectable public var blackKeyTextTreshold: CGFloat = 5 { didSet{ draw() }}
  @IBInspectable public var drawNoteText: Bool = true { didSet{ draw() }}
  @IBInspectable public var drawNoteOctave: Bool = true { didSet{ draw() }}

  private var pianoKeys = [PianoKeyLayer]()

  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    if keyCount > 0, pianoKeys.isEmpty {
      setup()
    }
    draw()
  }

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
    wantsLayer = true
    pianoKeys.forEach({ $0.removeFromSuperlayer() })
    let startNote = Note(type: .c, octave: startOctave)
    pianoKeys = Array(0..<keyCount).map({ PianoKeyLayer(note: startNote + $0) })
    pianoKeys.filter({ $0.type == .white }).forEach({ layer?.addSublayer($0) })
    pianoKeys.filter({ $0.type == .black }).forEach({ layer?.addSublayer($0) })
  }

  private func draw() {
    let whiteKeyCount = pianoKeys.filter({ $0.type == .white }).count
    let whiteKeyWidth = frame.size.width / CGFloat(whiteKeyCount)
    let blackKeyWidth = whiteKeyWidth / 2
    var currentX: CGFloat = 0
    for key in pianoKeys {
      switch key.type {
      case .black:
        key.backgroundColor = key.isSelected ? blackKeySelectedColor.cgColor : blackKeyBackgroundColor.cgColor
        key.borderWidth = blackKeyBorderWidth
        key.borderColor = blackKeyBorderColor.cgColor

        key.frame = CGRect(
          x: currentX - blackKeyWidth / 2,
          y: frame.size.height / 2,
          width: key == pianoKeys.last ?  blackKeyWidth / 2 : blackKeyWidth,
          height: frame.size.height / 2)

        if drawNoteText {
          let text = drawNoteOctave ? "\(key.note)" : "\(key.note.type)"
          let textColor = key.isSelected ? blackKeySelectedTextColor : blackKeyTextColor
          let font = UIFont.systemFont(ofSize: blackKeyFontSize)
          key.textLayer.alignmentMode = kCAAlignmentCenter
          key.textLayer.string = NSAttributedString(
            string: text,
            attributes: [
              NSForegroundColorAttributeName: textColor,
              NSFontAttributeName: font
            ])

          key.textLayer.frame = CGRect(
            x: 0,
            y: blackKeyTextTreshold,
            width: key.frame.size.width,
            height: blackKeyFontSize)
        } else {
          key.textLayer.string = nil
        }

      case .white:
        key.backgroundColor = key.isSelected ? whiteKeySelectedColor.cgColor : whiteKeyBackgroundColor.cgColor
        key.borderWidth = whiteKeyBorderWidth
        key.borderColor = whiteKeyBorderColor.cgColor

        key.frame = CGRect(
          x: currentX,
          y: 0,
          width: whiteKeyWidth,
          height: frame.size.height)
        currentX += whiteKeyWidth

        if drawNoteText {
          let text = drawNoteOctave ? "\(key.note)" : "\(key.note.type)"
          let textColor = key.isSelected ? whiteKeySelectedTextColor : whiteKeyTextColor
          let font = UIFont.systemFont(ofSize: whiteKeyFontSize)
          key.textLayer.alignmentMode = kCAAlignmentCenter
          key.textLayer.string = NSAttributedString(
            string: text,
            attributes: [
              NSForegroundColorAttributeName: textColor,
              NSFontAttributeName: font
            ])

          key.textLayer.frame = CGRect(
            x: 0,
            y: whiteKeyTextTreshold,
            width: key.frame.size.width,
            height: whiteKeyFontSize)
        } else {
          key.textLayer.string = nil
        }
      }
    }
  }
}
