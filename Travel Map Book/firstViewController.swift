//
//  firstViewController.swift
//  Travel Map Book
//
//  Created by MAC-DIN-002 on 22/05/2019.
//  Copyright © 2019 MAC-DIN-002. All rights reserved.
//

import UIKit
import CoreData

class firstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var titleArray = [String]()
    var subtitleArray = [String]()
    var longitudeArray = [Double]()
    var latitudeArray = [Double]()
    
    var chosenTitle = ""
    var chosenSubtitle = ""
    var chosenLatitude : Double = 0
    var chosenLongitude : Double = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(firstViewController.fetchData), name: NSNotification.Name("newLocationCreated"), object: nil)
    }
    
    
    @objc func fetchData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
        request.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(request)
            if results.count > 0 {
                self.titleArray.removeAll(keepingCapacity: false)
                self.subtitleArray.removeAll(keepingCapacity: false)
                self.longitudeArray.removeAll(keepingCapacity: false)
                self.latitudeArray.removeAll(keepingCapacity: false)
                for result in results as! [NSManagedObject]{
                    if let title = result.value(forKey: "title") as? String{
                        self.titleArray.append(title)
                    }
                    if let subtitle = result.value(forKey: "subtitle") as? String{
                        self.subtitleArray.append(subtitle)
                    }
                    if let longitude = result.value(forKey: "longitude") as? Double{
                        self.longitudeArray.append(longitude)
                    }
                    if let latitude = result.value(forKey: "latitude") as? Double{
                        self.latitudeArray.append(latitude)
                    }
                    
                    self.tableView.reloadData()
                }
            }
        }catch{
            print ("fail to fetch data")
        }
        
    }
    
    /*retourne le nombre de lignes de la tableView*/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    /*remplit les cellues de la table view*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    /*quand on click sur une cellule*/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenTitle = titleArray[indexPath.row]
        chosenSubtitle = subtitleArray[indexPath.row]
        chosenLongitude = longitudeArray[indexPath.row]
        chosenLatitude = latitudeArray[indexPath.row]
        
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapVC"{
            let destinationVC = segue.destination as! ViewController
            destinationVC.transmittedTitle = chosenTitle
            destinationVC.transmittedSubtitle = chosenSubtitle
            destinationVC.transmittedLatitude = chosenLatitude
            destinationVC.transmittedLongitude = chosenLongitude
        }
    }

    @IBAction func addBtnClicked(_ sender: Any) {
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }

}
