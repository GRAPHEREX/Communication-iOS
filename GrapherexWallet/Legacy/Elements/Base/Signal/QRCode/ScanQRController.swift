//
//  Copyright (c) 2020 SkyTech. All rights reserved.
//

import Foundation

final class ScanQRController: WLTViewController {
    private let qrScanner = WLTQRCodeScanningViewController()
    public var result: ((String) -> Void)?
    public weak var returnScreen: UIViewController!
    
    private var scannedString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        qrScanner.view.backgroundColor = .wlt_black
        self.navigationController?.navigationBar.backgroundColor = .clear
        //        qrScanner.bottomSpaceSize = STPrimaryButton.Constant.height
        self.title = "Scan QR code"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "NavBarBack"),
            style: .plain,
            target: self,
            action: #selector(close)
        )
        
        qrScanner.askForCameraPermission { [weak self] isEnabled in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if isEnabled {
                    self.qrScanner.startCapture()
                } else {
                    self.close()
                }
            }
        }
    }
    
    @objc private
    func close() {
        if self.navigationController?.viewControllers.contains(self.returnScreen) == true {
            self.navigationController?.popToViewController(self.returnScreen, animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //        qrScanner.stopCapture()
    }
    
    override func setup() {
        qrScanner.scanDelegate = self
        view.addSubview(qrScanner.view)
        qrScanner.view.autoPinEdgesToSuperviewEdges()
    }
}

extension ScanQRController: WLTQRScannerDelegate {
    func controller(_ controller: WLTQRCodeScanningViewController, didDetectQRCodeWith string: String) {
        //Logger.debug("qr scan: \(string)")
        scannedString = string
        result?(scannedString)
        close()
    }
}
