//
//  ViewController.swift
//  SoundBoard
//
//  Created by Cesar Augusto Acjota Merma on 10/20/21.
//  Copyright © 2021 deah. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tablaGrabaciones: UITableView!
    
    var grabaciones:[Grabacion] = []
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaGrabaciones.dataSource = self
        tablaGrabaciones.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            grabaciones = try context.fetch(Grabacion.fetchRequest())
            tablaGrabaciones.reloadData()
        } catch{}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grabaciones.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grabacion = grabaciones[indexPath.row]
        do {
            reproducirAudio = try AVAudioPlayer(data: grabacion.audio! as Data)
            reproducirAudio?.play()
            print("Reproduciendo audio: \(String(grabacion.nombre!))")
        } catch{}
        tablaGrabaciones.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let grabacion = grabaciones[indexPath.row]
        
//        let audioAsset = AVURLAsset.init(url: audioURL!, options: nil)
//        let duracion = audioAsset.duration
//        let duracionSecond = CMTimeGetSeconds(duracion)
        //reproducirAudio?.currentTime = 0
        cell.textLabel?.text = grabacion.nombre
        //cell.detailTextLabel?.text = String(duracionSecond)
        
        cell.detailTextLabel?.text = String(format: "%.2f",(grabacion.duracion))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let grabacion = grabaciones[indexPath.row]
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(grabacion)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do {
                grabaciones = try context.fetch(Grabacion.fetchRequest())
                tablaGrabaciones.reloadData()
            } catch {}
        }
    }
    
//    @objc func updateSlider(){
//        Slider.value = Float(reproducirAudio!.currentTime)
//        //NSLog("HI")
//    }

}
