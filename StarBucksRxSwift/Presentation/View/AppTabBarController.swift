import UIKit

final class AppTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        setViewControllers(makeViewControllers(), animated: false)
    }

    private func configureAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.stackedLayoutAppearance.selected.iconColor = StarbucksPalette.primaryGreen
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: StarbucksPalette.primaryGreen
        ]
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = StarbucksPalette.primaryGreen
    }

    private func makeViewControllers() -> [UIViewController] {
        [
            makeNavigationController(
                rootViewController: HomeViewController(),
                title: "Home",
                imageName: "house.fill"
            ),
            makeNavigationController(
                rootViewController: MenuViewController(),
                title: "Menu",
                imageName: "cup.and.saucer.fill"
            ),
            makeNavigationController(
                rootViewController: EventViewController(),
                title: "Event",
                imageName: "sparkles.rectangle.stack.fill"
            )
        ]
    }

    private func makeNavigationController(
        rootViewController: UIViewController,
        title: String,
        imageName: String
    ) -> UIViewController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        configureNavigationBarAppearance(for: navigationController)
        navigationController.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: imageName),
            selectedImage: UIImage(systemName: imageName)
        )
        return navigationController
    }

    private func configureNavigationBarAppearance(for navigationController: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]

        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        navigationController.navigationBar.prefersLargeTitles = false
        navigationController.navigationBar.tintColor = StarbucksPalette.primaryGreen
    }
}
