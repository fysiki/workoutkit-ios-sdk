//
//  MonVideoGoController.swift
//  SampleApp
//

import Combine
import Foundation
import FZWorkoutKit
import UIKit

class MonVideoGoController: GoVideoController {
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .landscapeLeft
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .landscape
    }

    var saveProm: AnyPublisher<Void, Never>?
    private var subscriptions = Set<AnyCancellable>()

    override func saveSession(state: SaveWorkoutState) {
        super.saveSession(state: state)

        saveProm = Future<Void, Never> { promise in
            // Simulate 5sec delay for workout save.
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
}
