//
//  CustomLoggerViewController.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2015/06/05.
//  Copyright © 2015 John Rommel Estropia. All rights reserved.
//

import UIKit
import CoreStore
import GCDKit


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
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let alert = UIAlertController(
            title: "Logger Demo",
            message: "This demo shows how to plug-in any logging framework to CoreStore.\n\nThe view controller implements CoreStoreLogger and appends all logs to the text view.",
            preferredStyle: .Alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    // MARK: CoreStoreLogger
    
    func log(level level: LogLevel, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        GCDQueue.Main.async { [weak self] in
            
            let levelString: String
            switch level {
                
            case .Trace: levelString = "Trace"
            case .Notice: levelString = "Notice"
            case .Warning: levelString = "Warning"
            case .Fatal: levelString = "Fatal"
            }
            self?.textView?.insertText("\((fileName.stringValue as NSString).lastPathComponent):\(lineNumber) \(functionName)\n  ↪︎ [Log:\(levelString)] \(message)\n\n")
        }
    }
    
    func log(error error: CoreStoreError, message: String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        GCDQueue.Main.async { [weak self] in
            
            self?.textView?.insertText("\((fileName.stringValue as NSString).lastPathComponent):\(lineNumber) \(functionName)\n  ↪︎ [Error] \(message): \(error)\n\n")
        }
    }
    
    func assert(@autoclosure condition: () -> Bool, @autoclosure message: () -> String, fileName: StaticString, lineNumber: Int, functionName: StaticString) {
        
        if condition() {
            
            return
        }
        
        let messageString = message()
        GCDQueue.Main.async { [weak self] in
            
            self?.textView?.insertText("\((fileName.stringValue as NSString).lastPathComponent):\(lineNumber) \(functionName)\n  ↪︎ [Assert] \(messageString)\n\n")
        }
    }
    
    
    // MARK: Private
    
    @IBOutlet dynamic weak var textView: UITextView?
    @IBOutlet dynamic weak var segmentedControl: UISegmentedControl?
    
    @IBAction dynamic func segmentedControlValueChanged(sender: AnyObject?) {
        
        switch self.segmentedControl?.selectedSegmentIndex {
            
        case 0?:
            self.dataStack.beginAsynchronous { (transaction) -> Void in
                
                transaction.create(Into(Palette))
            }
            
        case 1?:
            _ = try? dataStack.addStorageAndWait(
                SQLiteStore(
                    fileName: "emptyStore.sqlite",
                    configuration: "invalidStore"
                )
            )
            
        case 2?:
            self.dataStack.beginAsynchronous { (transaction) -> Void in
                
                transaction.commit()
                transaction.commit()
            }
            
        default:
            return
        }
    }
}
