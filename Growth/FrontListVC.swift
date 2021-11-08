//
//  FrontListVC.swift
//  Growth
//
//  Created by eunae on 2021/09/09.
//

import UIKit
import CoreData

// UICollectionViewDataSource : 컬렉션 뷰의 셀은 총 몇 개?
// UICollectionViewDelegate : 컬렉션 뷰를 어떻게 보여줄 것인가?
class FrontListVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    lazy var frontlist: [NSManagedObject] = {
        return self.fetch()
    }()
    
    let imageManager = ImageManager()
    
    let addProfile = "addProfile"
    let editProfile = "editProfile"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    func fetch() -> [NSManagedObject] {
        // 앱 델리게이트 객체 참조
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // 관리 객체 컨텍스트 참조
        let context = appDelegate.persistentContainer.viewContext
        // 요청 객체 생성
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Profile")
        // 데이터 가져오기
        let result = try! context.fetch(fetchRequest)
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // 사용자에게 알림 권한 요청
        let authOptions = UNAuthorizationOptions(arrayLiteral: .alert, .badge, .sound)
        userNotificationCenter.requestAuthorization(options: authOptions) { success, error in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        frontlist = {
            return self.fetch()
        }()
        collectionView.reloadData()
    }
    
    @IBAction func addBtn(_ sender: Any) {
        // 앱 델리게이트 객체 참조
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // 관리 객체 컨텍스트 참조
        let context = appDelegate.persistentContainer.viewContext
        // 관리 객체 생성 & 값을 설정
        let object = NSEntityDescription.insertNewObject(forEntityName: "Profile", into: context)
        let pvc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        pvc.record = object
        pvc.profileSegue = addProfile
        pvc.frontlist = frontlist
        
        self.show(pvc, sender: self)
    }
    
    // 컬렉션 뷰에 총 몇개의 셀을 표시할 것인가
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.frontlist.count
    }
    
    // 해당 cell에 무슨 셀을 표시할 지 결정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "frontCell", for: indexPath) as! FrontCell
        
        // 해당하는 데이터 가져오기
        let record = self.frontlist[indexPath.item]
        let name = record.value(forKey: "name") as? String
        if let profileImg = record.value(forKey: "profileImg") as? String {
            cell.frontImgView.image = imageManager.getSavedImage(named: profileImg)
        }
        
        cell.frontImgView.contentMode = .scaleAspectFill
        cell.frontImgView.layer.cornerRadius = 5.0
        cell.nameLabel.text = name
        cell.editBtn.addTarget(self, action: #selector(editBtn), for: .touchUpInside)
        cell.editBtn.tag = indexPath.item
        
        return cell
    }
    
    @objc func editBtn(sender: UIButton) {
        let object = self.frontlist[sender.tag]
        let pvc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        pvc.record = object
        pvc.profileSegue = editProfile
        pvc.frontlist = frontlist
        
        self.show(pvc, sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        
        let itemsPerRow: CGFloat = 2
        let widthPadding = sectionInsets.left * (itemsPerRow + 1)
        
        let cellWidth = (width - widthPadding) / itemsPerRow
        
        return CGSize(width: cellWidth, height: cellWidth)
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
        print(frontlist[indexPath.item])
    }
}

