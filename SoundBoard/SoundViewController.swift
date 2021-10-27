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
    @IBOutlet weak var viewCard2: UIView!
    @IBOutlet weak var Slider: UISlider!
    @IBOutlet weak var lblDispay: UILabel!
    @IBOutlet weak var btnPausar: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var controlVolumen: UISlider!
    
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
        
        viewCard2.layer.cornerRadius = 15.0
        
        agregarButton.layer.cornerRadius = 20.0
        
        btnPausar.backgroundColor = UIColor.white
        btnPausar.layer.cornerRadius = 20.0
        btnPausar.isEnabled = false
        
        btnStop.backgroundColor = UIColor.white
        btnStop.layer.cornerRadius = 20.0
        btnStop.isEnabled = false
        
        reproducirButton.backgroundColor = UIColor.white
        reproducirButton.layer.cornerRadius = 20.0
        reproducirButton.isEnabled = false
        
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        Slider.isEnabled = false
        controlVolumen.isHidden = true
        
        
        controlVolumen.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            //detener grabacion
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
            controlVolumen.isHidden = false
        }
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.prepareToPlay()
            reproducirAudio!.currentTime = 0
            let audioAsset = AVURLAsset.init(url: audioURL!, options: nil)
            let duracion = audioAsset.duration
            let duracionSecond = CMTimeGetSeconds(duracion)
            print("Duracion del audio: \(duracionSecond)")
            
            Slider.maximumValue = Float(reproducirAudio!.duration)
            Timer.scheduledTimer(timeInterval: 0.1, target:self,selector: Selector(("updateSlider")), userInfo: nil, repeats: true)
           lblDispay.text = "\(reproducirAudio!.currentTime)"
           Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
               self.lblDispay.text = "\(round(self.reproducirAudio!.currentTime*10)/10)"
             })
            reproducirAudio!.play()
            print("Reproduciendo")
            btnPausar.isEnabled = true
            btnStop.isEnabled = true
            Slider.isEnabled = true
        } catch {}
    }
    
    
    @IBAction func pausarTapped(_ sender: Any) {
        if reproducirAudio!.isPlaying{
            reproducirAudio!.pause()
        }else{
            reproducirAudio?.play()       }
    }
    
    @IBAction func stopTapped(_ sender: Any) {
        if reproducirAudio!.isPlaying{
            reproducirAudio!.stop()
            reproducirAudio!.currentTime = 0
        }else{
            reproducirAudio?.prepareToPlay()
            reproducirAudio!.currentTime = 0
        }
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        let audioAsset = AVURLAsset.init(url: audioURL!, options: nil)
        let duracion = audioAsset.duration
        let duracionSecond = (CMTimeGetSeconds(duracion)/60.0)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        grabacion.duracion = Float(duracionSecond)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    @IBAction func controlReproduccion(_ sender: Any) {
        
        reproducirAudio!.pause();
        reproducirAudio!.currentTime = TimeInterval(Slider.value)
        reproducirAudio!.pause()
        reproducirAudio!.play()
    }
    
    @objc func updateSlider(){
        Slider.value = Float(reproducirAudio!.currentTime)
        //NSLog("HI")
    }
    
    //Control del volumen
    
    @IBAction func controlVolumen(_ sender: UISlider) {
        reproducirAudio!.volume = sender.value
        print(sender.value)
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

}
