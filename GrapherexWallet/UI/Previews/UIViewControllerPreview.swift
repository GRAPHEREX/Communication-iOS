//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import SwiftUI

#if DEBUG

@available(iOS 13, *)
struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewController: ViewController

    init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }

    func makeUIViewController(context: Context) -> ViewController { viewController }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}

@available(iOS 13, *)
struct ViewControllerPreviews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            CoinsCoordinator.coinsViewControllerPreview()
        }
        .previewDevice("iPhone SE (2nd generation)")
    }
}

#endif
