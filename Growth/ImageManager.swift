//
//  ImageManager.swift
//  Growth
//
//  Created by eunae on 2021/11/05.
//
import UIKit

class ImageManager {
    static let shared = ImageManager()

    func saveImage(name: Int16, image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return nil
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return nil
        }
        do {
            try data.write(to: directory.appendingPathComponent("\(profileId).png")!)
            return "\(profileId).png"
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
}
