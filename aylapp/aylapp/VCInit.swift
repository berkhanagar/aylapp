//
//  VCInit.swift
//  aylapp
//
//  Created by Berkhan Ağar on 25.04.2026.
//

import UIKit

class VCInit: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
    override var prefersStatusBarHidden: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.backgroundColor = .white
        
        let imageView = UIImageView(frame: CGRect(x: 0.0, y: (view.frame.height - 180.0) / 2.0, width: view.frame.width, height: 180.0))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logo")
        view.addSubview(imageView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.refresh()
        }
    }
    
    func refresh() {
        let vc = mainViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    func mainViewController() -> UIViewController {
        let tabBarController = UITabBarController()

        let haberler = makeNavigationController(rootViewController: VCHome(), title: "Haberler", imageName: "newspaper")
        let etkinlikler = makeNavigationController(rootViewController: VCEvents(), title: "Etkinlikler", imageName: "calendar")
        let bul = makeNavigationController(rootViewController: VCDiscover(), title: "Bul", imageName: "magnifyingglass")
        let gruplar = makeNavigationController(rootViewController: VCGroups(), title: "Sosyal", imageName: "person.3")
        let profil = makeNavigationController(rootViewController: VCProfile(), title: "Menü", imageName: "line.3.horizontal.circle")

        tabBarController.viewControllers = [haberler, etkinlikler, bul, gruplar, profil]

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithTransparentBackground()
        tabAppearance.backgroundColor = .clear
        tabAppearance.shadowColor = .clear

        let selectedColor = UIColor(hex: "#9D0040")
        let normalColor = UIColor(hex: "#8E8E93")

        tabAppearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]

        tabAppearance.stackedLayoutAppearance.normal.iconColor = normalColor
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]

        tabBarController.tabBar.standardAppearance = tabAppearance
        tabBarController.tabBar.scrollEdgeAppearance = tabAppearance
        tabBarController.tabBar.backgroundImage = UIImage()
        tabBarController.tabBar.shadowImage = UIImage()
        tabBarController.tabBar.backgroundColor = .clear
        tabBarController.tabBar.tintColor = selectedColor
        tabBarController.tabBar.unselectedItemTintColor = normalColor
        tabBarController.tabBar.isTranslucent = true

        return tabBarController
    }

    private func makeNavigationController(rootViewController: UIViewController, title: String, imageName: String) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: imageName), selectedImage: UIImage(systemName: imageName + ".fill"))

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = .white
        navAppearance.shadowColor = UIColor(hex: "#E5E5E5")
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor(hex: "#9D0040")]

        navigationController.navigationBar.standardAppearance = navAppearance
        navigationController.navigationBar.scrollEdgeAppearance = navAppearance
        navigationController.navigationBar.tintColor = UIColor(hex: "#9D0040")
        navigationController.navigationBar.isTranslucent = false

        return navigationController
    }

}
