import UIKit

protocol LoginDelegate: AnyObject {
    func continueFlow()
    func openRegister()
}

protocol LoginCoordinating: AnyObject {
    var viewController: UIViewController? { get set }
    func continueFlow()
    func openRegister()
}

final class LoginCoordinator: LoginCoordinating {
    var viewController: UIViewController?
    private var delegate: LoginDelegate
   
    init(delegate: LoginDelegate) {
        self.delegate = delegate
    }
    
    func continueFlow() {
        //
    }
    
    func openRegister() {
        delegate.openRegister()
    }
}