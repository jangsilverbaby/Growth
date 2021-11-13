//
//  ContentFormVC.swift
//  Growth
//
//  Created by eunae on 2021/11/09.
//

import UIKit
import CoreData

class ContentFormVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var preview: UIImageView!
    @IBOutlet weak var contents: UITextView!
    var record: ProfileMO!
    let imageManeger = ImageManager()
    
    var contentlist: [ContentMO]!
    
    override func viewDidLoad() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd E"
        self.navigationItem.title = dateFormatter.string(from: Date())
    }
    
    // 저장 버튼을 클릭했을 때 호출되는 메소드
    @IBAction func save(_ sender: Any) {
        // 내용을 입력하지 않았을 경우, 경고한다.
        guard self.contents.text?.isEmpty == false else {
            let alert = UIAlertController(title: nil, message: "내용을 입력해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        // 앱 델리게이트 객체 참조
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // 관리 객체 컨텍스트 참조
        let context = appDelegate.persistentContainer.viewContext
        // 관리 객체 생성 & 값을 설정
        let object = NSEntityDescription.insertNewObject(forEntityName: "Content", into: context) as! ContentMO
        object.contents = self.contents.text
        object.regdate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmssE"
        let dateString = dateFormatter.string(from: object.regdate!)
        if let preview = self.preview.image {
            object.image = imageManeger.saveImage(name: dateString, image: preview)
        }
        record.addToContent(object)
        
        do {
            try context.save()
        } catch {
            context.rollback()
            print("save fail")
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // 카메라 버튼을 클릭했을 때 호출되는 메소드
    @IBAction func pick(_ sender: Any) {
        // 이미지 피커 인스턴스를 생성한다.
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        // 이미지 피커 화면을 표시한다.
        self.present(picker, animated: false)
    }
    
    // 사용자가 이미지를 선택하면 자동으로 이 메소드가 호출된다.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.preview.image = info[.editedImage] as? UIImage
        
        // 이미지 피커 컨트롤러를 닫는다.
        picker.dismiss(animated: false)
    }
}