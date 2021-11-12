//
//  ContentListVC.swift
//  Growth
//
//  Created by eunae on 2021/11/09.
//

import UIKit
import CoreData

class ContentListVC: UITableViewController {
    
    var record: ProfileMO!
    
    lazy var contentlist: [ContentMO]! = {
        return self.record.content?.array as! [ContentMO]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = record.value(forKey: "name") as? String
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        contentlist = self.record.content?.array as? [ContentMO]
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.contentlist.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = contentlist[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as! ContentCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd E"
        cell.regdate.text = dateFormatter.string(from: object.value(forKey: "regdate") as! Date)
        cell.contents.text = object.value(forKey: "contents") as? String
        // Configure the cell...
        
        return cell
    }
    
    @IBAction func contentAddBtn(_ sender: UIBarButtonItem) {
        let pvc = self.storyboard?.instantiateViewController(withIdentifier: "ContentFormVC") as! ContentFormVC
        pvc.record = self.record as ProfileMO
        
        self.show(pvc, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(110)
    }    
}
