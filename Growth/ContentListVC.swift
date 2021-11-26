//
//  ContentListVC.swift
//  Growth
//
//  Created by eunae on 2021/11/09.
//

import UIKit
import CoreData

class ContentListVC: UITableViewController {
    
    var record: ProfileMO! // 선택된 프로필
    
    let imageManager = ImageManager()
    
    // 게시물 리스트
    lazy var contentlist: [ContentMO]! = {
        return self.record.content?.array as! [ContentMO]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 게시물에 따라 행 높이가 달라짐
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        self.navigationItem.title = record.value(forKey: "name") as? String
    }
    
    override func viewWillAppear(_ animated: Bool) {
        contentlist = self.record.content?.array as? [ContentMO]
        // 게시물 최신순으로 정렬
        contentlist.sort(by: {$0.regdate! > $1.regdate!})
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        cell.setting.tag = indexPath.row
        
        return cell
    }
    
    // 게시물에 따라 행 높이가 달라짐
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - Button
    
    // 게시물 등록 버튼
    @IBAction func contentAddBtn(_ sender: UIBarButtonItem) {
        let pvc = self.storyboard?.instantiateViewController(withIdentifier: "ContentFormVC") as! ContentFormVC
        pvc.record = self.record as ProfileMO
        pvc.contentSegue = "contentAdd"
        self.show(pvc, sender: self)
    }
    
    // 게시물 설정 버튼 -> 삭제, 수정
    @IBAction func settingBtn(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { (_) in
            let alert = UIAlertController(title: "게시물을 삭제하시겠습니까?", message: "OK 버튼을 누르면 게시물이 완전히 삭제됩니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
                // 앱 델리게이트 객체 참조
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                // 관리 객체 컨텍스트 참조
                let context = appDelegate.persistentContainer.viewContext
                let record = self.contentlist[sender.tag]
                // 컨텍스트로부터 해당 객체 삭제
                context.delete(record)
                // 영구 저장소에 커밋한다
                do {
                    try context.save()
                    self.contentlist.remove(at: sender.tag)
                    self.tableView.reloadData()
                } catch {
                    context.rollback()
                    print("delete fail")
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: false, completion: nil)
        })
        
        alert.addAction(UIAlertAction(title: "수정", style: .default) { (_) in
            let pvc = self.storyboard?.instantiateViewController(withIdentifier: "ContentFormVC") as! ContentFormVC
            pvc.record = self.record as ProfileMO
            pvc.object = self.contentlist[sender.tag]
            pvc.contentSegue = "contentEdit"
            self.show(pvc, sender: self)
        })
        
        self.present(alert, animated: true)
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
