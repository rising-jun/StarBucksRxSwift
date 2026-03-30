import SnapKit
import UIKit

final class EventViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var items: [StoreEventItemDTO] = MockStarbucksData.events

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureNavigation()
        configureLayout()
    }

    private func configureView() {
        view.backgroundColor = .systemBackground

        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EventItemCell.self, forCellReuseIdentifier: EventItemCell.reuseIdentifier)
    }

    private func configureNavigation() {
        navigationItem.title = "Event"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func configureLayout() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension EventViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EventItemCell.reuseIdentifier,
            for: indexPath
        ) as? EventItemCell else {
            return UITableViewCell()
        }

        cell.configure(with: items[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let eventCode = items[indexPath.row].eventCode else { return }
        let viewController = EventDetailViewController(eventCode: eventCode)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
