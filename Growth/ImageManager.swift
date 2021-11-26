//
//  ImageManager.swift
//  Growth
//
//  Created by eunae on 2021/11/05.
//
import UIKit

// 출처 : https://velog.io/@ezidayzi/iOS-FileManager%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%B4-Local%EC%97%90-%EC%9D%B4%EB%AF%B8%EC%A7%80%EB%A5%BC-%EC%A0%80%EC%9E%A5%ED%95%B4%EB%B3%B4%EC%9E%90
class ImageManager {
    
    // local에 이미지 저장학기
    func saveImage(name: String, image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return nil
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return nil
        }
        do {
            try data.write(to: directory.appendingPathComponent("\(name).png")!)
            return "\(name).png"
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    // local에서 이미지 불러오기
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
}
