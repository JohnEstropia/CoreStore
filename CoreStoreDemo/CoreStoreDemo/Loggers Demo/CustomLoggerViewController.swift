//
//  CustomLoggerViewController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/06/05.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreStore


// MARK: - CustomLoggerViewController

class CustomLoggerViewController: UIViewController, CoreStoreLogger {
    
    // MARK: NSObject
    
    deinit {
        
        CoreStore.logger = DefaultLogger()
    }
    
    let dataStack = DataStack()
    
    // MARK: UIViewController

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        try! self.dataStack.addStorageAndWait(SQLiteStore(fileName: "emptyStore.sqlite"))
        CoreStore.logger = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let alert = UIAlertController(
            title: "Logger Demo",
            message: "This demo shows how to plug-in any logging framework to CoreStore.\n\nThe view controller implements CoreStoreLogger and appends all logs to the text view.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    // MARK: CoreStoreLogger
    
    func log(level: LogLevel, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        DispatchQueue.main.async { [weak self] in
            
            let levelString: String
            switch level {
                
            case .trace: levelString = "Trace"
            case .notice: levelString = "Notice"
            case .warning: levelString = "Warning"
            case .fatal: levelString = "Fatal"
            }
            self?.textView?.insertText("\((String(describing: fileName) as NSString).lastPathComponent):\(lineNumber) \(functionName)\n  ↪︎ [Log:\(levelString)] \(message)\n\n")
        }
    }
    
    func log(error: CoreStoreError, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.textView?.insertText("\((String(describing: fileName) as NSString).lastPathComponent):\(lineNumber) \(functionName)\n  ↪︎ [Error] \(message): \(error)\n\n")
        }
    }
    
    func assert(_ condition: @autoclosure () -> Bool, message: @autoclosure () -> String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        if condition() {
            
            return
        }
        
        let messageString = message()
        DispatchQueue.main.async { [weak self] in
            
            self?.textView?.insertText("\((String(describing: fileName) as NSString).lastPathComponent):\(lineNumber) \(functionName)\n  ↪︎ [Assert] \(messageString)\n\n")
        }
    }
    
    
    // MARK: Private
    
    @IBOutlet dynamic weak var textView: UITextView?
    @IBOutlet dynamic weak var segmentedControl: UISegmentedControl?
    
    @IBAction dynamic func segmentedControlValueChanged(_ sender: AnyObject?) {
        
        switch self.segmentedControl?.selectedSegmentIndex {
            
        case 0?:
            let request = NSFetchRequest<NSFetchRequestResult>()
            Where(true).applyToFetchRequest(request)
            Where(false).applyToFetchRequest(request)
            
        case 1?:
            _ = try? dataStack.addStorageAndWait(
                SQLiteStore(
                    fileName: "emptyStore.sqlite",
                    configuration: "invalidStore"
                )
            )
            
        case 2?:
            DispatchQueue.global(qos: .background).async {
                
                _ = self.dataStack.fetchOne(From<Place>())
            }
            
        default:
            return
        }
    }
}
