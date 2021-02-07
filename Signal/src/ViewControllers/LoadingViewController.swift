//
//  Copyright (c) 2021 SKYTECH. All rights reserved.
//

import Foundation
import PromiseKit

// The initial presentation is intended to be indistinguishable from the Launch Screen.
// After a delay we present some "loading" UI so the user doesn't think the app is frozen.

final public class LoadingViewController: UIViewController {

    @IBOutlet private var subtitle: UILabel! {
        didSet {
            subtitle.text = NSLocalizedString("ONBOARDING_SPLASH_TITLE_new",
                                              comment: "Title of the 'onboarding splash' view.")
        }
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

}
