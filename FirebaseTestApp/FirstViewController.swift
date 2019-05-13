//
//  FirstViewController.swift
//  FirebaseTestApp
//
//  Created by developer on 5/9/19.
//  Copyright © 2019 napify. All rights reserved.
//

import UIKit
import Firebase
import ObjectMapper

class FirstViewController: UIViewController {
    
    @IBOutlet weak var nameFieldOne: UITextField!
    @IBOutlet weak var clasificationFieldOne: UITextField!
    @IBOutlet weak var usesFieldOne: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    
    let FirebaseReference = Database.database().reference()
    
    var ref: DatabaseReference!
    var models = [ModelOne]()
    var databaseHandle: DatabaseHandle?
    var selectedModel = ModelOne()
    var selectedIndex = Int()
    var isEditingData = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let nibName = UINib(nibName: GeneralTableViewCell.identifier, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: GeneralTableViewCell.identifier)
        getData()
    }
    
    func getData() {
        FirebaseReference.child("CrudPrincipal").observe(.childAdded, with:  { (snapshot) in
            var data = snapshot.value as! [String:Any]
            data["id"] = snapshot.key
            if let data = Mapper<ModelOne>().map(JSON: data) {
                self.models.insert(data, at: 0)
                self.tableView.reloadData()
            }
        })
    }
    
    func removeObjectFromFirebase(model: ModelOne) {
        FirebaseReference.child("CrudPrincipal").child(model.id).removeValue()
    }
    
    func updateData() {
        if nameFieldOne.text != "" && clasificationFieldOne.text != "" && usesFieldOne.text != "" {
            FirebaseReference.child("CrudPrincipal").child(selectedModel.id).setValue(["Name": nameFieldOne.text, "Clasification": clasificationFieldOne.text, "Uses": usesFieldOne.text])
            models[selectedIndex].name = nameFieldOne.text ?? ""
            models[selectedIndex].uses = usesFieldOne.text ?? ""
            models[selectedIndex].clasification = clasificationFieldOne.text ?? ""
            nameFieldOne.text = ""
            clasificationFieldOne.text = ""
            usesFieldOne.text = ""
            isEditingData = false
            cancelButton.isHidden = true
            tableView.reloadData()
        } else {
            print("Missing fields")
        }
    }
    
    @IBAction func posData(_ sender: Any) {
        if isEditingData {
            updateData()
        } else {
            if nameFieldOne.text != "" && clasificationFieldOne.text != "" && usesFieldOne.text != "" {
                FirebaseReference.child("CrudPrincipal").childByAutoId().setValue(["Name": nameFieldOne.text, "Clasification": clasificationFieldOne.text, "Uses": usesFieldOne.text])
                nameFieldOne.text = ""
                clasificationFieldOne.text = ""
                usesFieldOne.text = ""
            } else {
                print("Missing fields")
            }
        }
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        isEditingData = false
        cancelButton.isHidden = true
        nameFieldOne.text = ""
        clasificationFieldOne.text = ""
        usesFieldOne.text = ""
    }
}

extension FirstViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: GeneralTableViewCell.identifier, for: indexPath) as? GeneralTableViewCell {
            cell.titleLabel.text = models[indexPath.row].name
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isEditingData = true
        cancelButton.isHidden = false
        selectedModel = models[indexPath.row]
        selectedIndex = indexPath.row
        nameFieldOne.text = selectedModel.name
        clasificationFieldOne.text = selectedModel.clasification
        usesFieldOne.text = selectedModel.uses
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            removeObjectFromFirebase(model: models[indexPath.row])
            models.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
}
