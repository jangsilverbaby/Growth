//
//  ProfileVC.swift
//  Growth
//
//  Created by eunae on 2021/09/25.
//
import UIKit

class ProfileVC : UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var profileImg: UIImageView! // 프로필 이미지
    @IBOutlet weak var profileImgEditBtn: UIButton! // 프로필 이미지 수정 버튼
    @IBOutlet weak var name: UITextField! // 이름
    @IBOutlet weak var startDate: UITextField! // 시작 날짜
    @IBOutlet weak var isAlert: UISwitch! // 기록 알림 유무
    @IBOutlet weak var alertCycle: UITextField! // 알림 주기
    @IBOutlet weak var alertTime: UITextField! // 알림 시간
    
    var cycleList = ["하루", "삼 일", "일주일", "한 달", "일 년", "4년"]
    
    override func viewDidLoad() {
        self.navigationItem.title = "프로필"
        
        // 프로필 이미지
        let image = UIImage(named: "account.jpg")
        self.profileImg.image = image
        self.profileImg.contentMode = .scaleAspectFill
        
        // 알림 주기 피커뷰
        let picker = UIPickerView()
        picker.delegate = self
        self.alertCycle.inputView = picker
        
        // 알림 주기 피커뷰의 툴 바
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 36)
        toolbar.barTintColor = .lightGray
        self.alertCycle.inputAccessoryView = toolbar
        let done = UIBarButtonItem()
        done.title = "Done"
        done.target = self
        done.action = #selector(alertCycleDone)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, done], animated: true)
    }
    
    // 생성할 컴포넌트 개수 정의
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // 지정된 컴포넌트가 가길 목록의 길이 정의
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.cycleList.count
    }
    
    // 지정된 컴포넌트의 목록 각 행에 출력될 내용 정의
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.cycleList[row]
    }
    
    // 지정된 컴포넌트 목록 각 행을 사용자가 선택했을 때 실행할 액션 정의
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let cycle = self.cycleList[row]
        self.alertCycle.text = cycle
    }
    
    // 주기 입력 후에 실행될 코드
    @objc func alertCycleDone(_ sender : Any) {
        self.view.endEditing(true)
    }
    
    func imgPicker(_ source : UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true)
    }
    
    @IBAction func profile(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "사진을 가져올 곳을 선택해 주세요", preferredStyle: .actionSheet)
        
        // 카메라를 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "카메라", style: .default) { (_) in
                self.imgPicker(.camera)
            })
        }
        // 저장된 앨범을 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            alert.addAction(UIAlertAction(title: "저장된 앨범", style: .default) { (_) in
                self.imgPicker(.savedPhotosAlbum)
            })
        }
        // 포토 라이브러리를 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "포토 라이브러리", style: .default) { (_) in
                self.imgPicker(.photoLibrary)
            })
        }
        // 취소 버튼 추가
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        // 액션 시트 창 실행
        self.present(alert, animated: true)
    }
            
    // 이미지를 선택하면 이 메소드가 자동으로 호출된다.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImg.image = img
        }
        // 이 구문을 누락하면 이미지 피커 컨트롤러 창은 닫히지 않는다.
        picker.dismiss(animated: true)
    }
}
