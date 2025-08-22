//
//  PortOneLauncher.swift
//  rawgraphy
//
//  Created by 이동호 on 8/22/25.
//

import UIKit
import PortOneSdk

final class MyPortOneLauncher {
    typealias Completion = (Result<PaymentSuccess, PaymentError>) -> Void

    static func present(from presenter: UIViewController,
                        params: [String: Any],
                        onCompletion: @escaping Completion) {

        let vc = PortOneSdk.PaymentViewController(
            data: params,
            onCompletion: { result in  // result: Result<PaymentSuccess, PaymentError>
                DispatchQueue.main.async {
                    presenter.dismiss(animated: true) {
                        onCompletion(result)
                    }
                }
            }
        )
        vc.modalPresentationStyle = .fullScreen
        presenter.present(vc, animated: true)
    }
}
