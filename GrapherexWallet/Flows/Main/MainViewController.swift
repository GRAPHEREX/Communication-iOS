//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

class MainViewController: NiblessViewController {
    
    //MARK: - Properties
    let headerView: MainHeaderView = {
       let view = MainHeaderView()
        return view
    }()
    
    let tableView: UITableView = {
       let tableView = UITableView()
        return tableView
    }()
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}
