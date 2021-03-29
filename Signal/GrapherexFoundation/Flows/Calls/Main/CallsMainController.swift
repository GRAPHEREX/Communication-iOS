import UIKit

final class CallsMainController: UIViewController {
    typealias VoidHandler = () -> Void
    @IBOutlet private var emptyStateView: EmptyStateView!
    @IBOutlet private var tableViewHolder: UIView!

    private let tableViewController = OWSTableViewController()
    private let segmentedControl = UISegmentedControl()
    private let callManager = AppEnvironment.shared.callService
    private let outboundCallInitiator = AppEnvironment.shared.outboundIndividualCallInitiator
    
    private var calls: [TSCall] = []
    
    private var filteredCalls: [TSCall] = [] {
        didSet {
            makeCells()
        }
    }
    
    private lazy var editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
    private lazy var cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.backgroundColor
        setupTableView()
        setupEmptyState()
        setupNavigationBar()
        AppEnvironment.shared.callService.addObserverAndSyncState(observer: self)
        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .ThemeDidChange, object: nil)
    }
}

fileprivate extension CallsMainController {
    @objc func applyTheme() {
        view.backgroundColor = Theme.backgroundColor
        makeCells()
    }
    
    func setupEmptyState() {
        emptyStateView.set(image: UIImage(imageLiteralResourceName: "Calls"),
                                  title: NSLocalizedString("CALLS_VIEW_EMPTY_TITLE", comment: ""),
                                  subtitle: NSLocalizedString("CALLS_VIEW_EMPTY_SUBTITLE", comment: ""),
                                  buttonTitle: NSLocalizedString("CALLS_VIEW_EMPTY_BUTTON_TITLE", comment: ""),
                                  action: { [weak self] in
                                   self?.startNewCall()
               })
    }
    
    func setupTableView() {
        tableViewHolder.addSubview(tableViewController.view)
        tableViewController.view.autoPinEdgesToSuperviewEdges()
        tableViewController.tableView.backgroundColor = .clear
        tableViewController.tableView.allowsSelection = false
        self.definesPresentationContext = false
    }
    
    func makeCells() {
        setEmptyState(isEmpty: calls.isEmpty)
        let contents: OWSTableContents = .init()
        let mainSection = OWSTableSection()
        
        filteredCalls.forEach({
            makeCell(call: $0, section: mainSection)
        })
        
        contents.addSection(mainSection)
        tableViewController.contents = contents
    }
    
    func makeCell(call: TSCall, section: OWSTableSection) {
        let callCell = ContactTableViewCell()
        callCell.configure(with: call, shouldUseShortName: true)
        callCell.configureCallAction({ [weak self] address in
            self?.outboundCallInitiator.initiateCall(address: address, isVideo: call.offerType == .video)
        })

        let item = OWSTableItem(customCell: callCell,
                                customRowHeight: UITableView.automaticDimension)
        item.deleteAction = OWSTableItemEditAction(title: "Delete") { [weak self] in
            self?.removeCall(call)
        }
        section.add(item)
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        segmentedControl.insertSegment(withTitle: NSLocalizedString("MAIN_ALL", comment: ""), at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: NSLocalizedString("CALL_VIEW_MISSED", comment: ""), at: 1, animated: false)
        segmentedControl.addTarget(self, action: #selector(didMenuTap), for: .valueChanged)
        navigationController?.navigationBar.topItem?.titleView = segmentedControl
        segmentedControl.selectedSegmentIndex = 0
        navigationController?.navigationBar.topItem?.leftBarButtonItem = editButton
    }
    
    func setEmptyState(isEmpty: Bool) {
        emptyStateView.isHidden = !isEmpty
        setupEmptyState()
    }
    
    func setupData() {
        calls = callManager.getCallsList()
        calls.sort(by: { ($0 as TSInteraction).sortId > ($1 as TSInteraction).sortId })
        filteredCalls = calls
        didMenuTap()
    }
    
    @objc func didMenuTap() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            didAllButtonTap()
        case 1:
            didMissedButtonTap()
        default:
            break
        }
    }
    
    @objc func didAllButtonTap() {
        tableViewHolder.isHidden = false
        emptyStateView.isHidden = true
        filteredCalls = calls
    }
    
    @objc func didMissedButtonTap() {
        filteredCalls = calls.filter { (item: TSCall) -> Bool in
            switch item.callType {
            case .incomingMissedBecauseOfChangedIdentity,
                 .incomingMissed:
                return true
            default:
                return false
            }
        }
        
        if filteredCalls.isEmpty {
            tableViewHolder.isHidden = true
            emptyStateView.isHidden = false
            emptyStateView.set(image: UIImage(imageLiteralResourceName: "Calls"),
                               title: NSLocalizedString("CALLS_VIEW_EMPTY_MISSED_TITLE", comment: ""),
                               subtitle: "",
                               buttonTitle: "",
                               action: {})
        }
    }
    
    func startNewCall() {
        let controller = CallPickerController()
        let modal = OWSNavigationController(rootViewController: controller)
        navigationController?.presentFormSheet(modal, animated: true)
    }
}

extension CallsMainController: CallServiceObserver {
    func didUpdateCall(from oldValue: SignalCall?, to newValue: SignalCall?) {
        setupData()
    }
}

extension CallsMainController {
    @objc func editButtonTapped() {
        navigationController?.navigationBar.topItem?.leftBarButtonItem = cancelButton
        tableViewController.tableView.setEditing(true, animated: true)
    }
    
    @objc func cancelButtonTapped() {
        navigationController?.navigationBar.topItem?.leftBarButtonItem = editButton
        tableViewController.tableView.setEditing(false, animated: true)
    }
    
    private func removeCall(_ call: TSCall) {
        if let index = filteredCalls.firstIndex(of: call) {
            filteredCalls.remove(at: index)
            callManager.removeCall(call)
            if filteredCalls.count == 0 {
                cancelButtonTapped()
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.setupData()
            }
        }
    }
}
