//
//  FrontListVC.swift
//  Growth
//
//  Created by eunae on 2021/09/09.
//

import UIKit

// UICollectionViewDataSource : 컬렉션 뷰의 셀은 총 몇 개?
// UICollectionViewDelegate : 컬렉션 뷰를 어떻게 보여줄 것인가?
class FrontListVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var defaultPList : NSDictionary!
    var frontlist = [Int]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let addProfile = "addProfile"
    let editProfile = "editProfile"

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let plist = UserDefaults.standard
        if let list = plist.array(forKey: "frontlist") as? [Int]{
            self.frontlist = list
        } else {
            plist.setValue(self.frontlist, forKey: "frontlist")
        }
        
        
        if let defaultPListPath = Bundle.main.path(forResource: "ProfileInfo", ofType: "plist") {
            self.defaultPList = NSDictionary(contentsOfFile: defaultPListPath)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let plist = UserDefaults.standard
        if let list = plist.array(forKey: "frontlist") as? [Int]{
            self.frontlist = list
        } else {
            plist.setValue(self.frontlist, forKey: "frontlist")
        }
        collectionView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == addProfile {
            let vc = segue.destination as! ProfileVC
            vc.profileSegue = addProfile
            self.appDelegate.index = self.frontlist.count
        }
        
        if segue.identifier == editProfile {
            let vc = segue.destination as! ProfileVC
            vc.profileSegue = editProfile
        }
    }
    
    // 컬렉션 뷰에 총 몇개의 벳울 표시할 것인가
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.frontlist.count
    }
    
    // 해당 cell에 무슨 셀을 표시할 지 결정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "frontCell", for: indexPath) as! FrontCell
        
        let customPlist = "\(indexPath.row).plist" // 읽어올 파일명
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0] as NSString
        let plist = path.strings(byAppendingPaths: [customPlist]).first!
        let data = NSMutableDictionary(contentsOfFile: plist) ?? NSMutableDictionary(dictionary: self.defaultPList)
        
        cell.frontImgView.image = UIImage(data: (data["profileImg"] as? Data ?? UIImage(named: "account.jpg")?.pngData())!)
        cell.frontImgView.contentMode = .scaleAspectFill
        cell.frontImgView.layer.cornerRadius = 5.0
        cell.nameLabel.text = data["name"] as? String
        cell.editBtn.tag = indexPath.item
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = collectionView.frame.width
            let height = collectionView.frame.height
            
            let itemsPerRow: CGFloat = 2
            let widthPadding = sectionInsets.left * (itemsPerRow + 1)
            let itemsPerColumn: CGFloat = 3
            let heightPadding = sectionInsets.top * (itemsPerColumn + 1)
            
            let cellWidth = (width - widthPadding) / itemsPerRow
            let cellHeight = (height - heightPadding) / itemsPerColumn
        
            return CGSize(width: cellWidth, height: cellHeight)
        }
    
    func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            insetForSectionAt section: Int) -> UIEdgeInsets {
          return sectionInsets
        }
        
    func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
        
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
}


