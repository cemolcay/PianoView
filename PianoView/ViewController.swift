//
//  ViewController.swift
//  PianoView
//
//  Created by Cem Olcay on 19/01/2017.
//  Copyright © 2017 prototapp. All rights reserved.
//

import UIKit
import MusicTheorySwift

class ViewController: UIViewController {
  @IBOutlet weak var pianoView: PianoView?

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    pianoView?.selectNote(note: Note(type: .c, octave: 2))
  }
}

