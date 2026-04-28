//
//  AppDelegate.swift
//  aylapp
//
//  Created by Berkhan Ağar on 25.04.2026.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().delegate = self
        NotificationScheduler.shared.configureOnLaunch()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.tintColor = UIColor(hex: "#9D0040")
        window?.overrideUserInterfaceStyle = .light
        
        self.window?.rootViewController = VCInit()
        window!.makeKeyAndVisible()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        window?.endEditing(true)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        NotificationScheduler.shared.syncPendingNotifications()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge, .list])
    }

}

extension UIApplication {
    static var version: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String? ?? ""
    }
    static var build: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String? ?? ""
    }
}

func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let nav = base as? UINavigationController {
        return getTopViewController(base: nav.visibleViewController)

    } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
        return getTopViewController(base: selected)

    } else if let presented = base?.presentedViewController {
        return getTopViewController(base: presented)
    }
    return base
}

func getimage(url: String, completion: @escaping (UIImage) -> ()) -> UIImage {
    let fileManager = FileManager()
    let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    if docs.count > 0 {
        let doc = docs[0]
        let newdoc = doc.appendingPathComponent(url.replacingOccurrences(of: "/", with: "_"))
        if fileManager.fileExists(atPath: newdoc.path) {
            if let data = fileManager.contents(atPath: newdoc.path) {
                if let image = UIImage(data: data) {
                    return image
                }
            }
        } else {
            if let _ = URL(string: url) {
                URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in
                    DispatchQueue.main.async {
                        guard
                            let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                            let data = data, error == nil
                        else { return }
                        do {
                            if fileManager.fileExists(atPath: newdoc.path) {
                            try fileManager.removeItem(atPath: newdoc.path)
                        }
                            fileManager.createFile(atPath: newdoc.path, contents: data, attributes: nil)
                        } catch {}
                        completion(UIImage(data: data) ?? UIImage())
                    }
                }).resume()
            }
        }
    }
    return UIImage(named: "loading") ?? UIImage()
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
