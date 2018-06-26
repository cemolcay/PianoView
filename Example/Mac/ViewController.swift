//
//  ViewController.swift
//  Mac
//
//  Created by Cem Olcay on 31/01/2017.
//
//

import Cocoa
import PianoView
import MusicTheorySwift

class ViewController: NSViewController {
  @IBOutlet weak var pianoView: PianoView?

  override func viewDidLoad() {
    super.viewDidLoad()
    pianoView?.layer?.backgroundColor = NSColor.black.cgColor

    NSEvent.addLocalMonitorForEvents(matching: .keyUp, handler: { self.keyUp(with: $0); return nil })
    NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { self.keyDown(with: $0); return nil })
  }

  override func keyDown(with event: NSEvent) {
    //let notes = NoteType.all.map({ Note(type: $0, octave: 0) })
    //let randomNote = notes[Int(arc4random_uniform(UInt32(notes.count)))]
    pianoView?.deselectAll()
    pianoView?.selectNote(note: Pitch(key: Key(type: .d, accidental: .flat), octave: 0))
  }

  override func keyUp(with event: NSEvent) {
    pianoView?.deselectAll()
  }
}
