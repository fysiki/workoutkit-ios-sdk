//
//  ListViewController.swift
//  SampleApp
//

import Apollo
import DemoCloud
import Foundation
import UIKit

class ListViewController: UIViewController {
    enum Section {
        case playlist
        case main
    }

    var dataSource: UICollectionViewDiffableDataSource<Section, WorkoutPreviewItem>! = nil
    var collectionView: UICollectionView! = nil

    var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute]
        formatter.unitsStyle = .positional // Ensures HH:MM:SS or MM:SS format
        formatter.zeroFormattingBehavior = .pad // Ensures two-digit formatting

        return formatter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("list_title", comment: "")
        configureHierarchy()
        configureDataSource()

        DemoCloudClient.shared.fetch(query: GetSessionsQuery(), cachePolicy: .returnCacheDataAndFetch) { [weak self] result in
            switch result {
            case let .failure(error):
                let alert = UIAlertController(title: NSLocalizedString("common_error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("common_ok", comment: ""), style: .cancel, handler: nil))
                DispatchQueue.main.async { [weak self] in
                    self?.present(alert, animated: true)
                }

            case let .success(response):
                let items = response.data?.publicWorkouts.edges.compactMap(\.node.fragments.workoutPreviewItem)
                if let items, items.isEmpty == false {
                    var snapshot = NSDiffableDataSourceSnapshot<Section, WorkoutPreviewItem>()
                    snapshot.appendSections([.playlist])
                    snapshot.appendItems(items, toSection: .playlist)

                    self?.dataSource.apply(snapshot, animatingDifferences: false)

                } else {
                    let alert = UIAlertController(title: NSLocalizedString("common_error", comment: ""), message: NSLocalizedString("error_empty_list", comment: ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("common_ok", comment: ""), style: .cancel, handler: nil))
                    DispatchQueue.main.async { [weak self] in
                        self?.present(alert, animated: true)
                    }
                }
            }
        }
    }
}

extension ListViewController {
    /// - Tag: List
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension ListViewController {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }

    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, WorkoutPreviewItem> { [weak self] cell, _, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.name
            content.secondaryText = "\(self?.formatter.string(from: TimeInterval(item.duration)) ?? "-") min - \(item.format.rawValue)"
            content.image = UIImage(systemName: item.format == .play ? "ipad.gen2.landscape.badge.play" : "iphone.gen3.badge.play")
            cell.contentConfiguration = content
        }

        dataSource = UICollectionViewDiffableDataSource<Section, WorkoutPreviewItem>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: WorkoutPreviewItem) -> UICollectionViewCell? in

            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
    }
}

extension ListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        fetchWorkoutSession(at: indexPath)
    }

    private func fetchWorkoutSession(at indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        print("Selected \(item.name). Fetching workout preview...")

        DemoCloudClient.shared.fetch(query: GetSessionQuery(id: item.id), cachePolicy: .fetchIgnoringCacheData) { [weak self] result in
            switch result {
            case let .failure(error):
                let alert = UIAlertController(title: NSLocalizedString("common_error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("common_ok", comment: ""), style: .cancel, handler: nil))
                DispatchQueue.main.async { [weak self] in
                    self?.present(alert, animated: true)
                }

            case let .success(response):
                if let preview = response.data?.publicWorkout.fragments.workoutPreviewItem {
                    let alert = UIAlertController(title: preview.name,
                                                  message: String(format: NSLocalizedString("common_workout_fetch_info", comment: ""), item.id),
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("common_cancel", comment: ""), style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("common_continue", comment: ""), style: .default, handler: { [weak self] _ in
                        self?.fetchWorkoutContents(at: indexPath)
                    }))

                    DispatchQueue.main.async { [weak self] in
                        self?.present(alert, animated: true)
                    }

                } else {
                    let alert = UIAlertController(title: NSLocalizedString("common_error", comment: ""),
                                                  message: String(format: NSLocalizedString("error_cannot_fetch_info", comment: ""), item.id),
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("common_ok", comment: ""), style: .cancel, handler: nil))
                    DispatchQueue.main.async { [weak self] in
                        self?.present(alert, animated: true)
                    }
                }
            }
        }
    }

    private func fetchWorkoutContents(at indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        print("Selected \(item.name). Fetching workout contents...")

        DemoCloudClient.shared.fetch(query: GetSessionContentQuery(id: item.id), cachePolicy: .fetchIgnoringCacheData) { [weak self] result in
            switch result {
            case let .failure(error):
                let alert = UIAlertController(title: NSLocalizedString("common_error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("common_ok", comment: ""), style: .cancel, handler: nil))
                DispatchQueue.main.async { [weak self] in
                    self?.present(alert, animated: true)
                }

            case let .success(response):
                guard let wk = response.extensions?["workoutkit"] as? [String: String], let token = wk["token"] else { return }

                if let session = response.data?.publicWorkoutSession.asWorkoutBlockSession {
                    guard let data = try? JSONSerialization.data(withJSONObject: convert(value: session.__data)) else { return }
                    Task {
                        do {
                            let controller = try await MonGoModeController(data: data, token: token)
                            controller.modalPresentationStyle = .fullScreen
                            self?.present(controller, animated: true)
                        } catch {
                            print(error)
                        }
                    }

                } else if let session = response.data?.publicWorkoutSession.asWorkoutVideoSession {
                    guard let data = try? JSONSerialization.data(withJSONObject: convert(value: session.__data)) else { return }
                    Task {
                        do {
                            let controller = try await MonVideoGoController(data: data, token: token)
                            controller.modalPresentationStyle = .fullScreen
                            self?.present(controller, animated: true)
                        } catch {
                            print(error)
                        }
                    }

                } else {
                    let alert = UIAlertController(title: NSLocalizedString("common_error", comment: ""),
                                                  message: String(format: NSLocalizedString("error_cannot_open", comment: ""), item.id),
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("common_ok", comment: ""), style: .cancel, handler: nil))
                    DispatchQueue.main.async { [weak self] in
                        self?.present(alert, animated: true)
                    }
                }
            }
        }
    }
}

private func convert(value: Any) -> Any {
    if let value = value as? ApolloAPI.DataDict {
        return convert(value: value._data)
    } else if let value = value as? [String: Any] {
        return value.mapValues(convert)
    } else if let value = value as? [Any] {
        return value.map(convert)
    } else if let value = value as? CustomScalarType {
        return value._jsonValue
    }
    return value
}

extension GraphQLResult {
    func asDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        if let data { dict["data"] = convert(value: data.__data) }
        return dict
    }
}
