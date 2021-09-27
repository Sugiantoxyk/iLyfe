//
//  SpeechSynthesizer.swift
//  Speech1
//
//  Created by homework on 2/7/17.
//  Copyright © 2017 homework. All rights reserved.
//

import UIKit
import AVFoundation

class SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate {

    private var synth: AVSpeechSynthesizer?
    
    private var onStoppedSpeaking: (() -> Void)?
    
    deinit {
        stop()
    }
    
    // Speaks the given text and calls the onStoppedSpeaking closure
    // when the spoken utterance is complete.
    //
    func speak(text: String, onStoppedSpeaking: @escaping (() -> Void))
    {
        self.stop()
        
        DispatchQueue.main.async {
            self.synth = AVSpeechSynthesizer()
       
            // Gets the audio session for playing back an audio
            // clip.
            //
            let audioSession = AVAudioSession.sharedInstance()
            do {
                
                try audioSession.setCategory(AVAudioSession.Category.playback)
                try audioSession.setMode(AVAudioSession.Mode.default)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                
                
            } catch {
                print("audioSession properties weren't set because of an error.")
                return
            }
            
            // Creates a new speech utterance with the given
            // text and the specified voice. You can change it
            // to a female voice if you want.
            //
            let myUtterance = AVSpeechUtterance(string: text)
            myUtterance.rate = 0.4
            myUtterance.volume = 1.0
            myUtterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_en-US_compact")
            
            // Sets the function to call when the audio
            // for the synthesized text finishes playing
            //
            self.onStoppedSpeaking = onStoppedSpeaking
            
            // Finally, generate the audio for the synthesized
            // text and play it back.
            //
            self.synth!.delegate = self
            self.synth!.speak(myUtterance)
        }
    }
    
    // Speaks the given text.
    //
    func speak(text: String)
    {
        speak(text: text, onStoppedSpeaking: {})
    }
    
    
    // Stops speaking immediately.
    //
    func stop()
    {
        DispatchQueue.main.async {

            if self.synth != nil && self.synth!.isSpeaking
            {
                self.synth!.stopSpeaking(at: .immediate)
                
            }
            
        }
       
    }
    
    // Delegate function that will be triggered when the
    // utterance completes.
    //
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance)
    {
        synth!.delegate = nil
        synth = nil
        onStoppedSpeaking?()

    }
    
    
    // Delegate function that will be triggered when the
    // utterance is cancelled midway.
    //
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance)
    {
        synth!.delegate = nil
        synth = nil
        onStoppedSpeaking?()

    }
}
