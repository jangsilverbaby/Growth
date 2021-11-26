//
//  FrontListVC.swift
//  Growth
//
//  Created by eunae on 2021/09/09.
//

import UIKit
import CoreData

// UICollectionViewDataSource : 데이터를 관리하고 컬렉션 뷰에 셀을 제공하기 위해 사용
// UICollectionViewDelegate : 컬렉션 뷰의 항목과 사용자 상호 작용을 관리하는 데 사용
class FrontListVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    // 프로필 리스트
    lazy var frontlist: [NSManagedObject] = {
        return self.fetch()
    }()
    
    let imageManager = ImageManager()
    
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
        // 뷰가 나타날 떄 마다 프로필 리스트를 다시 불러온 후에 컬렉션뷰 리로드
        frontlist = {
            return self.fetch()
        }()
        collectionView.reloadData()
    }
    
    // 프로필 추가 버튼
    @IBAction func addBtn(_ sender: Any) {
        let pvc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        pvc.profileSegue = "addProfile"
        pvc.frontlist = frontlist
        
        self.show(pvc, sender: self)
    }
    
    // 프로필 수정 버튼
    @objc func editBtn(sender: UIButton) {
        let object = self.frontlist[sender.tag]
        let pvc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        pvc.record = object
        pvc.profileSegue = "editProfile"
        pvc.frontlist = frontlist
        
        self.show(pvc, sender: self)
    }
    
    // 해당 프로필의 게시물 등록 버튼
    @objc func contentAddBtn(sender: UIButton) {
        let object = self.frontlist[sender.tag] as? ProfileMO
        let pvc = self.storyboard?.instantiateViewController(withIdentifier: "ContentFormVC") as! ContentFormVC
        pvc.record = object
        pvc.contentSegue = "contentAdd"
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
        cell.contentAddBtn.addTarget(self, action: #selector(contentAddBtn), for: .touchUpInside)
        cell.contentAddBtn.tag = indexPath.item
        
        return cell
    }
    
    // cell을 클릭했을 때 하는 일
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let object = self.frontlist[indexPath.item] as! ProfileMO
        let pvc = self.storyboard?.instantiateViewController(withIdentifier: "ContentListVC") as! ContentListVC
        pvc.record = object
        
        self.show(pvc, sender: self)
    }
}

// UICollectionViewDelegateFlowLayout : 흐름 레이아웃 개체를 조정하여 그리드 기반 레이아웃을 구현
extension FrontListVC: UICollectionViewDelegateFlowLayout {
    // cell의 크기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        
        let itemsPerRow: CGFloat = 2
        let widthPadding = sectionInsets.left * (itemsPerRow + 1)
        
        let cellWidth = (width - widthPadding) / itemsPerRow
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    // cell의 margin
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // cell의 행과 열 사이의 간격
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
    
