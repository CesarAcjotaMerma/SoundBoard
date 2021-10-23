//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by Cesar Augusto Acjota Merma on 10/20/21.
//  Copyright © 2021 deah. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {
    
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextLabel: UILabel!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var viewCard: UIView!
    
    var grabarAudio: AVAudioRecorder?
    
    var reproducirAudio:AVAudioPlayer?
    
    var audioURL:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configurarGrabacion()
        viewCard.layer.cornerRadius = 15.0
        viewCard.layer.shadowColor = UIColor.gray.cgColor
        viewCard.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        viewCard.layer.shadowRadius = 6.0
        viewCard.layer.shadowOpacity = 0.9
        nombreTextField.layer.cornerRadius = 20.0
        agregarButton.layer.cornerRadius = 15.0
        agregarButton.layer.shadowColor = UIColor.gray.cgColor
        agregarButton.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        agregarButton.layer.shadowRadius = 6.0
        agregarButton.layer.shadowOpacity = 0.7
        
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            //detener grabcaion
            grabarAudio?.stop()
            //cambiar text del boton grabar
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        }else{
            //empezar a grabar
            grabarAudio?.record()
            //cambiar el texto del boton grabar a detener
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
        }
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        } catch {}
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    func configurarGrabacion(){
        do {
            let session = AVAudioSession.sharedInstance()
            
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            //
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            
            let pathComponents = [basePath,"audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            print("*****************")
            print(audioURL!)
            print("*****************")
            
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            //
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        } catch let error as NSError {
            print(error)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
