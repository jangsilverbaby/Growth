//
//  ProfileVC.swift
//  Growth
//
//  Created by eunae on 2021/09/25.
//
import UIKit

class ProfileVC : UITableViewController, UINavigationControllerDelegate{
    @IBOutlet weak var profileImg: UIImageView! // 프로필 이미지
    @IBOutlet weak var profileImgEditBtn: UIButton! // 프로필 이미지 수정 버튼
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var startDate: UITextField! // 시작 날짜
    @IBOutlet weak var isAlert: UISwitch! // 기록 알림 유무
    @IBOutlet weak var alertCycle: UITextField! // 알림 주기
    @IBOutlet weak var alertTime: UITextField! // 알림 시간
    
    // 메인 번들에 정의된 PList 내용을 정리할 딕셔너리
    var defaultPList : NSDictionary!
    var frontlist = UserDefaults.standard.array(forKey: "frontlist") as? [Int] ?? [Int]()
    var profileSegue = ""
    let index = 0
    
    var cycleList = ["하루", "삼 일", "일주일", "한 달", "일 년", "삼 년"]
    
    let datePicker = UIDatePicker() // 시작 날짜 피커뷰
    let cyclePicker = UIPickerView() // 알림 주기 피커뷰
    let timePicker = UIDatePicker() // 알림 시간 피커뷰
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 메인 번들 ProfileInfo.plist가 포함되어 있으면 이를 읽어와 딕셔너리에 담는다.
        if let defaultPListPath = Bundle.main.path(forResource: "ProfileInfo", ofType: "plist") {
            self.defaultPList = NSDictionary(contentsOfFile: defaultPListPath)
        }
        
        let customPlist = "\(index).plist" // 읽어올 파일명
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0] as NSString
        let clist = path.strings(byAppendingPaths: [customPlist]).first!
        let data = NSMutableDictionary(contentsOfFile: clist) ?? NSMutableDictionary()
        
        self.profileImg.image = UIImage(named: data["profileImg"] as? String ?? "account.jpg")
        self.name.text = data["name"] as? String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        self.startDate.text = dateFormatter.string(from: data["startDate"] as? Date ?? Date())
        self.isAlert.isOn = data["isAlert"] as? Bool ?? false
        self.alertCycle.text = data["alertCycle"] as? String
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        self.alertTime.text = timeFormatter.string(from: data["alertTime"] as? Date ?? Date())
        
        
        // 추가
        if profileSegue == "addProfile" {
            self.profileImg.image = UIImage(named: "account.jpg")
            self.name.text = ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd"
            self.startDate.text = dateFormatter.string(from: Date())
            self.isAlert.isOn = true
            self.alertCycle.text = "하루"
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            self.alertTime.text = timeFormatter.string(from: Date())
        }
        
        // 시작 날짜
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        startDate.inputView = datePicker
        
        // 알림 주기
        alertCycleVDL()
        
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
        
        // 알림 시간
        // 알림 시간 피커뷰
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        alertTime.inputView = timePicker
        
        // 알림 시간 피커뷰의 툴 바
        let toolbar1 = UIToolbar()
        toolbar1.frame = CGRect(x: 0, y: 0, width: 0, height: 36)
        toolbar1.barTintColor = .lightGray
        self.alertTime.inputAccessoryView = toolbar1
        let done1 = UIBarButtonItem()
        done1.title = "Done"
        done1.target = self
        done1.action = #selector(timeChanged)
        let flexSpace1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar1.setItems([flexSpace1, done1], animated: true)
        
        // 탭하면 피커뷰 닫음
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func viewTapped(_ sender : UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 { // 두 번째 셀이 클릭되었을 때에만
            let alert = UIAlertController(title: nil, message: "이름을 입력하세요", preferredStyle: .alert)
            // 입력 필드 추가
            alert.addTextField() {
                $0.text = self.name.text // name 레이블의 텍스트를 입력폼에 기본값으로 넣어준다.
            }
            // 버튼 및 액션 추가
            alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
                let value = alert.textFields?[0].text
                self.name.text = value
            })
            // 알림창 띄움
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        startDate.text = dateFormatter.string(from: sender.date)
        view.endEditing(true)
    }
    
    @objc func timeChanged() {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        alertTime.text = timeFormatter.string(from: timePicker.date)
        view.endEditing(true)
    }
    
    @IBAction func done(_ sender: Any) {
        let i = self.frontlist.count
        self.frontlist.append(i)
        
        let plist = UserDefaults.standard
        plist.set(self.frontlist, forKey: "frontlist")
        plist.synchronize()
        
        let customPlist = "\(i).plist" // 읽어올 파일명
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0] as NSString
        let clist = path.strings(byAppendingPaths: [customPlist]).first!
        let data = NSMutableDictionary(contentsOfFile: clist) ?? NSMutableDictionary(dictionary: self.defaultPList)
        
        let image = self.profileImg.image
        let profileData = image?.pngData()
        data.setValue(profileData, forKey: "profileImg")
        data.setValue(self.name.text, forKey: "name")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let startDate = dateFormatter.date(from: self.startDate.text!)!
        data.setValue(startDate, forKey: "startDate")
        data.setValue(self.isAlert.isOn, forKey: "isAlert")
        data.setValue(self.alertCycle.text, forKey: "alertCycle")
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        timeFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let alertTime = timeFormatter.date(from: self.alertTime.text!)
        data.setValue(alertTime, forKey: "alertTime")
        data.write(toFile: clist, atomically: true)
        
        print("custom plist=\(clist)")
        
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - 프로필 이미지
extension ProfileVC : UIImagePickerControllerDelegate {
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
            
            /* 데이터에 저장하는 부분을 구현할 예정*/
            
            self.profileImg.image = img
        }
        // 이 구문을 누락하면 이미지 피커 컨트롤러 창은 닫히지 않는다.
        picker.dismiss(animated: true)
    }
}

//MARK: - 알림 주기
extension ProfileVC : UIPickerViewDelegate, UIPickerViewDataSource {
    func alertCycleVDL() {
        cyclePicker.delegate = self
        self.alertCycle.inputView = cyclePicker
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
        
        /* 데이터에 저장하는 부분을 구현할 예정*/
    }
}
