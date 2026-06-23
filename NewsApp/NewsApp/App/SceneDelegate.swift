//
//  SceneDelegate.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 16.06.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        let remoteURL = URL(
            string: "https://newsdata.io/api/1/latest?apikey=pub_22cc7687e25c45a4ab473d264a213bc2&country=tr"
        )!
        
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        
        let loader = RemoteFeedLoader(
            baseURL: remoteURL,
            client: client
        )
        
        let store = UserDefaultsReadingListStore(userDefaults: .standard)
        
        let viewModel = HomeViewModel(
            loader: loader,
            store: store
        )
        
        let homeVC = HomeViewController(
            viewModel: viewModel
        )
        let navigationController = UINavigationController(rootViewController: homeVC)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
    }

}

