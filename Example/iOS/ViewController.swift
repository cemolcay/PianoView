//
//  ViewController.swift
//  iOS
//
//  Created by Cem Olcay on 31/01/2017.
//
//

import UIKit
import PianoView
import MusicTheorySwift

class ViewController: UIViewController {
  @IBOutlet weak var pianoView: PianoView?

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    let notes = NoteType.all.map({ Note(type: $0, octave: 0) })
    let randomNote = notes[Int(arc4random_uniform(UInt32(notes.count)))]
    pianoView?.deselectAll()
    pianoView?.selectNote(note: randomNote)
  }
}

