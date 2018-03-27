//
//  ViewController.swift
//  Speech-To-Text
//
//  Created by Naren on 27/03/18.
//  Copyright © 2018 naren. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController,SFSpeechRecognizerDelegate {
  @IBOutlet weak var txtView: UITextView!
  @IBOutlet weak var btnStartRecording: UIButton!
  private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  private let audioEngine = AVAudioEngine()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    btnStartRecording.isEnabled = false
    speechRecognizer?.delegate = self
    userAutorization()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func userAutorization(){
    SFSpeechRecognizer.requestAuthorization { (authStatus) in
      var isButtonEnabled = false
      switch authStatus {
      case .authorized:
        isButtonEnabled = true
      case .denied:
        isButtonEnabled = false
        print("User denied access to speech recognition")
      case .restricted:
        isButtonEnabled = false
        print("Speech recognition restricted on this device")
      case .notDetermined:
        isButtonEnabled = false
        print("Speech recognition not yet authorized")
      }
      OperationQueue.main.addOperation() {
        self.btnStartRecording.isEnabled = isButtonEnabled
      }
    }
  }
  
  func startRecording() {
    if recognitionTask != nil {
      recognitionTask?.cancel()
      recognitionTask = nil
    }
    
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(AVAudioSessionCategoryRecord)
      try audioSession.setMode(AVAudioSessionModeMeasurement)
      try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
    } catch {
      print("audioSession properties weren't set because of an error.")
    }
    
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    
     let inputNode = audioEngine.inputNode
    
    guard let recognitionRequest = recognitionRequest else {
      fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
    }
    
    recognitionRequest.shouldReportPartialResults = true
    
    recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
      
      var isFinal = false
      
      if result != nil {
        
        self.txtView.text = result?.bestTranscription.formattedString
        isFinal = (result?.isFinal)!
      }
      
      if error != nil || isFinal {
        self.audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = nil
        self.recognitionTask = nil
        
        self.btnStartRecording.isEnabled = true
      }
    })
    
    let recordingFormat = inputNode.outputFormat(forBus: 0)
    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
      self.recognitionRequest?.append(buffer)
    }
    
    audioEngine.prepare()
    
    do {
      try audioEngine.start()
    } catch {
      print("audioEngine couldn't start because of an error.")
    }
    
    txtView.text = "Say something, I'm listening!"
  }
  
  func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    if available {
      btnStartRecording.isEnabled = true
    } else {
      btnStartRecording.isEnabled = false
    }
  }
  
  
  @IBAction func startRecordingFunc(_ sender: Any) {
    if audioEngine.isRunning {
      audioEngine.stop()
      recognitionRequest?.endAudio()
      btnStartRecording.isEnabled = false
      btnStartRecording.setTitle("Start Recording", for: .normal)
    } else {
      startRecording()
      btnStartRecording.setTitle("Stop Recording", for: .normal)
    }
  }
  
}

