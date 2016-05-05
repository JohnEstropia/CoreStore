//
//  NSProgress+Convenience.swift
//  CoreStore
//
//  Copyright © 2015 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
#if USE_FRAMEWORKS
    import GCDKit
#endif


// MARK: - NSProgress

public extension NSProgress {
    
    /**
     Sets a closure that the `NSProgress` calls whenever its `fractionCompleted` changes. You can use this instead of setting up KVO.
     
     - parameter closure: the closure to execute on progress change
     */
    @nonobjc
    public func setProgressHandler(closure: ((progress: NSProgress) -> Void)?) {
        
        self.progressObserver.progressHandler = closure
    }
    
    
    // MARK: Private
    
    private struct PropertyKeys {
        
        static var progressObserver: Void?
    }
    
    @nonobjc
    private var progressObserver: ProgressObserver {
        
        get {
            
            let object: ProgressObserver? = cs_getAssociatedObjectForKey(&PropertyKeys.progressObserver, inObject: self)
            if let observer = object {
                
                return observer
            }
            
            let observer = ProgressObserver(self)
            cs_setAssociatedRetainedObject(
                observer,
                forKey: &PropertyKeys.progressObserver,
                inObject: self
            )
            
            return observer
        }
    }
}


// MARK: - ProgressObserver

@objc
private final class ProgressObserver: NSObject {
    
    private unowned let progress: NSProgress
    private var progressHandler: ((progress: NSProgress) -> Void)? {
        
        didSet {
            
            let progressHandler = self.progressHandler
            if (progressHandler == nil) == (oldValue == nil) {
                
                return
            }
            
            if let _ = progressHandler {
                
                self.progress.addObserver(
                    self,
                    forKeyPath: "fractionCompleted",
                    options: [.Initial, .New],
                    context: nil
                )
            }
            else {
                
                self.progress.removeObserver(self, forKeyPath: "fractionCompleted")
            }
        }
    }
    
    private init(_ progress: NSProgress) {
        
        self.progress = progress
        super.init()
    }
    
    deinit {
        
        if let _ = self.progressHandler {
            
            self.progressHandler = nil
            self.progress.removeObserver(self, forKeyPath: "fractionCompleted")
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        guard let progress = object as? NSProgress where progress == self.progress && keyPath == "fractionCompleted" else {
            
            return
        }
        
        GCDQueue.Main.async { [weak self] () -> Void in
            
            self?.progressHandler?(progress: progress)
        }
    }
}
