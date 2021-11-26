//
//  ContentFormVC.swift
//  Growth
//
//  Created by eunae on 2021/11/09.
//

import UIKit
import CoreData

class ContentFormVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var preview: UIImageView! // 게시 이미지
    @IBOutlet weak var contents: UITextView! // 게시글
    var record: ProfileMO! // 선택된 프로필
    var object: ContentMO! // 선책된 게시글
    var contentSegue: String = "" // 게시물 등록인지 수정인지 구분
    let imageManeger = ImageManager()
    
    var contentlist: [ContentMO]! // 게시물 리스트
    
    override func viewDidLoad() {
        if contentSegue == "contentAdd" { // 게시물 등록이면
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd E"
            self.navigationItem.title = dateFormatter.string(from: Date())
            contents.delegate = self
            contents.text = "내용 입력을 입력해주세요..."
            contents.textColor = UIColor.darkGray
        } else { // 게시물 수정이면
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd E"
            self.navigationItem.title = dateFormatter.string(from: object.value(forKey: "regdate") as! Date)
            contents.delegate = self
            contents.text = object.value(forKey: "contents") as? String
            if let name = object.value(forKey: "image") {
                let preview = imageManeger.getSavedImage(named: name as! String)
                self.preview.image = preview!.aspectFitImage(inRect: self.preview.frame)
                self.preview.contentMode = .top
            }
        }
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
        
        guard self.contents.text != "내용 입력을 입력해주세요..." else {
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
        if contentSegue == "contentAdd" { // 게시글 등록이면
            object = NSEntityDescription.insertNewObject(forEntityName: "Content", into: context) as? ContentMO
            object.contents = self.contents.text
            object.regdate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmssE"
            let dateString = dateFormatter.string(from: object.regdate!)
            if let preview = self.preview.image {
                object.image = imageManeger.saveImage(name: dateString, image: preview)
            }
            record.addToContent(object)
        } else { // 게시글 수정이면
            object.setValue(self.contents.text, forKey: "contents")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmssE"
            let dateString = dateFormatter.string(from: object.value(forKey: "regdate") as! Date)
            if let preview = self.preview.image {
                object.setValue(imageManeger.saveImage(name: dateString, image: preview), forKey: "image")
            }
        }
        
        
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
        picker.dismiss(animated: false) {
            if let preview = self.preview.image {
                self.preview.image = preview.aspectFitImage(inRect: self.preview.frame)
                self.preview.contentMode = .top
            }
        }
    }
}

// 내용을 입력하라는 안내 메세지 
extension ContentFormVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.darkGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "내용을 입력해주세요..."
            textView.textColor = UIColor.darkGray
        }
    }
}
