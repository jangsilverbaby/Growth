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
    
    let imageManager = ImageManager()
    
    lazy var contentlist: [ContentMO]! = {
        return self.record.content?.array as! [ContentMO]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        self.navigationItem.title = record.value(forKey: "name") as? String
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        contentlist = self.record.content?.array as? [ContentMO]
        contentlist.sort(by: {$0.regdate! > $1.regdate!})
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.contentlist.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = contentlist[indexPath.row]
        let cellId = object.value(forKey: "image") == nil ? "contentCell" : "contentwithImageCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ContentCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd E"
        cell.regdate.text = dateFormatter.string(from: object.value(forKey: "regdate") as! Date)
        cell.contents.text = object.value(forKey: "contents") as? String
        cell.contentImage?.image = imageManager.getSavedImage(named: object.value(forKey: "image") as! String)?.aspectFitImage(inRect: cell.contentImage.frame)
        cell.contentImage?.contentMode = .top
        
        return cell
    }
    
    @IBAction func contentAddBtn(_ sender: UIBarButtonItem) {
        let pvc = self.storyboard?.instantiateViewController(withIdentifier: "ContentFormVC") as! ContentFormVC
        pvc.record = self.record as ProfileMO
        
        self.show(pvc, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

// 게시물 이미지를 크키에 맞게 resizing
// 출처 : https://woongsios.tistory.com/106
extension UIImage {
    func aspectFitImage(inRect rect: CGRect) -> UIImage? {
        let width = self.size.width
        let height = self.size.height
        let aspectWidth = rect.width / width
        let aspectHeight = rect.height / height
        let scaleFactor = aspectWidth > aspectHeight ? rect.size.height / height : rect.size.width / width

        UIGraphicsBeginImageContextWithOptions(CGSize(width: width * scaleFactor, height: height * scaleFactor), false, 0.0)
        self.draw(in: CGRect(x: 0.0, y: 0.0, width: width * scaleFactor, height: height * scaleFactor))

        defer {
            UIGraphicsEndImageContext()
        }

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
