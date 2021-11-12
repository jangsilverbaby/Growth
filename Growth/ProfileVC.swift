//
//  ProfileVC.swift
//  Growth
//
//  Created by eunae on 2021/09/25.
//
import UIKit
import CoreData

class ProfileVC : UITableViewController, UINavigationControllerDelegate{
    @IBOutlet weak var profileImg: UIImageView! // 프로필 이미지
    @IBOutlet weak var profileImgEditBtn: UIButton! // 프로필 이미지 수정 버튼
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var startDate: UITextField! // 시작 날짜
    @IBOutlet weak var isAlert: UISwitch! // 기록 알림 유무
    @IBOutlet weak var alertCycle: UITextField! // 알림 주기
    @IBOutlet weak var alertTime: UITextField! // 알림 시간
    @IBOutlet weak var deleteBtn: UIButton! // 삭제 버튼
    @IBOutlet weak var cycleLabel: UILabel! // 알림 주기 라벨
    @IBOutlet weak var timeLabel: UILabel! // 알림 시간 라벨
    
    var record = NSManagedObject()
    var profileSegue = ""
    let imageManager = ImageManager()
    var frontlist = [NSManagedObject()]
    
    var cycleList = ["매일", "일주일에 한 번", "일 년에 한 번"]
    
    let datePicker = UIDatePicker() // 시작 날짜 피커뷰
    let cyclePicker = UIPickerView() // 알림 주기 피커뷰
    let timePicker = UIDatePicker() // 알림 시간 피커뷰
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if profileSegue == "editProfile" {
            // 프로필 수정 화면
            // 이미지 불러오기
            self.profileImg.image = imageManager.getSavedImage(named: record.value(forKey: "profileImg") as! String)
            self.name.text = record.value(forKey: "name") as? String
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd E"
            self.startDate.text = dateFormatter.string(from: record.value(forKey: "startDate") as? Date ?? Date())
            self.datePicker.date = record.value(forKey: "startDate") as? Date ?? Date()
            self.isAlert.isOn = record.value(forKey: "isAlert") as? Bool ?? false
            isAlertColor(self.isAlert)
            self.alertCycle.text = record.value(forKey: "alertCycle") as? String
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            self.alertTime.text = timeFormatter.string(from: record.value(forKey: "alertTime") as? Date ?? Date())
            self.timePicker.date = record.value(forKey: "alertTime") as? Date ?? Date()
        } else { // 프로필 추가 화면
            self.profileImg.image = UIImage(named: "account.jpg")
            self.name.text = ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd E"
            self.startDate.text = dateFormatter.string(from: Date())
            self.isAlert.isOn = false
            isAlertColor(self.isAlert)
            self.alertCycle.text = "매일"
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            self.alertTime.text = timeFormatter.string(from: Date())
            
            self.deleteBtn.isHidden = true
        }
        
        // 시작 날짜
        startDateVDL()
        
        // 알림 주기
        alertCycleVDL()
        
        // 알림 시간
        alertTimeVDL()
        
        // 탭하면 피커뷰 닫음
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 선택된 row 보이기
        if profileSegue == "editProfile" {
            self.cyclePicker.selectRow(cycleList.firstIndex(of: record.value(forKey: "alertCycle") as? String ?? "매일")!, inComponent: 0, animated: false)
        }
    }
    
    @objc func viewTapped(_ sender : UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // 완료 버튼
    @IBAction func done(_ sender: Any) {
        var namelist: [String] = []
        for i in frontlist {
            if i == record {
                continue
            }
            namelist.append(i.value(forKey: "name") as! String)
        }
        
        name.text = name.text!.trimmingCharacters(in: .whitespaces)
        
        if self.name.text == "" {
            nameAlert("이름을 빈칸으로 둘 수 없습니다.\n이름을 입력해주세요")
        } else if namelist.contains(self.name.text!) {
            nameAlert("중복된 이름은 사용할 수 없습니다.\n다른 이름을 입력해 주세요")
        } else {
            // 앱 델리게이트 객체 참조
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            // 관리 객체 컨텍스트 참조
            let context = appDelegate.persistentContainer.viewContext
            if profileSegue == "addProfile" {
                // 관리 객체 생성 & 값을 설정
                record = NSEntityDescription.insertNewObject(forEntityName: "Profile", into: context)
            }
            let image = self.profileImg.image
            let profileImg = imageManager.saveImage(name: self.name.text!, image: image!)!
            record.setValue(profileImg, forKey: "profileImg")
            record.setValue(self.name.text, forKey: "name")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd E"
            let startDate = dateFormatter.date(from: self.startDate.text!)!
            record.setValue(startDate, forKey: "startDate")
            record.setValue(self.isAlert.isOn, forKey: "isAlert")
            record.setValue(self.alertCycle.text, forKey: "alertCycle")
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            let alertTime = timeFormatter.date(from: self.alertTime.text!)
            record.setValue(alertTime, forKey: "alertTime")
            
            do {
                try context.save()
            } catch {
                context.rollback()
                print("save fail")
            }
            
            if self.isAlert.isOn {
                cancelAlert(self.name.text!)
                alert(startDate, alertTime, self.name.text!)
            } else {
                cancelAlert(self.name.text!)
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 삭제 버튼
    @IBAction func deleteBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "프로필을 삭제하시겠습니까?", message: "OK 버튼을 누르면 프로필이 완전히 삭제됩니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
            // 앱 델리게이트 객체 참조
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            // 관리 객체 컨텍스트 참조
            let context = appDelegate.persistentContainer.viewContext
            // 컨텍스트로부터 해당 객체 삭제
            context.delete(self.record)
            // 영구 저장소에 커밋한다
            do {
                try context.save()
            } catch {
                context.rollback()
                print("delete fail")
            }
            
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: false, completion: nil)
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
            self.profileImg.image = img
        }
        // 이 구문을 누락하면 이미지 피커 컨트롤러 창은 닫히지 않는다.
        picker.dismiss(animated: true)
    }
}
//MARK: - 이름
extension ProfileVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 { // 두 번째 셀이 클릭되었을 때에만
            nameAlert("이름을 입력해주세요")
        }
    }
    
    func nameAlert(_ alertMessage: String) {
        let alert = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
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

//MARK: - 시작 날짜
extension ProfileVC {
    func startDateVDL() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        startDate.inputView = datePicker
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd E"
        startDate.text = dateFormatter.string(from: sender.date)
        view.endEditing(true)
    }
}

//MARK: - 알림 여부
extension ProfileVC {
    @IBAction func isAlertChanged(_ sender: UISwitch) {
        if sender.isOn {
            self.cycleLabel.textColor = .label
            self.timeLabel.textColor = .label
            self.alertCycle.textColor = .label
            self.alertTime.textColor = .label
            self.alertCycle.isEnabled = true
            self.alertTime.isEnabled = true
        } else {
            self.cycleLabel.textColor = .opaqueSeparator
            self.timeLabel.textColor = .opaqueSeparator
            self.alertCycle.textColor = .opaqueSeparator
            self.alertTime.textColor = .opaqueSeparator
            self.alertCycle.isEnabled = false
            self.alertTime.isEnabled = false
        }
    }
    
    func isAlertColor(_ sender: UISwitch) {
        if sender.isOn {
            self.cycleLabel.textColor = .label
            self.timeLabel.textColor = .label
            self.alertCycle.textColor = .label
            self.alertTime.textColor = .label
            self.alertCycle.isEnabled = true
            self.alertTime.isEnabled = true
        } else {
            self.cycleLabel.textColor = .opaqueSeparator
            self.timeLabel.textColor = .opaqueSeparator
            self.alertCycle.textColor = .opaqueSeparator
            self.alertTime.textColor = .opaqueSeparator
            self.alertCycle.isEnabled = false
            self.alertTime.isEnabled = false
        }
    }
    
    func alert(_ startDate: Date?, _ alertTime: Date?, _ identifier: String){
        let notificationContent = UNMutableNotificationContent()
        notificationContent.body = "\(self.name.text!)을(를) 기록해주세요!"
        //notificationContent.userInfo = ["targetScene" : "sqlash"] // 푸쉬 받을 때 오는 데이터
        
        let calendar = Calendar.current
        var components : DateComponents
        let trigger : UNNotificationTrigger
        
        switch self.alertCycle.text! {
        case "매일":
            components = calendar.dateComponents([.hour, .minute], from: alertTime!)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            print(components)
        case "일주일에 한 번":
            let weekday = calendar.component(.weekday, from: startDate!)
            components = calendar.dateComponents([.hour, .minute], from: alertTime!)
            components.weekday = weekday
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            print(components)
        case "일 년에 한 번":
            let month = calendar.component(.month, from: startDate!)
            let day = calendar.component(.day, from: startDate!)
            components = calendar.dateComponents([.hour, .minute], from: alertTime!)
            components.month = month
            components.day = day
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            print(components)
        default:
            components = calendar.dateComponents([.hour, .minute], from: alertTime!)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            print("error")
        }
        
        let request = UNNotificationRequest(identifier: identifier,
                                            content: notificationContent,
                                            trigger: trigger)
        
        userNotificationCenter.add(request) { error in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    
    func cancelAlert(_ identifier: String) {
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
}

//MARK: - 알림 주기
extension ProfileVC : UIPickerViewDelegate, UIPickerViewDataSource {
    func alertCycleVDL() {
        cyclePicker.delegate = self
        cyclePicker.dataSource = self
        self.alertCycle.inputView = cyclePicker
        
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
}

//MARK: - 알림 시간
extension ProfileVC {
    func alertTimeVDL() {
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
    }
    
    @objc func timeChanged() {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        alertTime.text = timeFormatter.string(from: timePicker.date)
        view.endEditing(true)
    }
}
