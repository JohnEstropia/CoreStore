//
//  NSProgress+Convenience.swift
//  CoreStore
//
//  Copyright (c) 2015 John Rommel Estropia
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
import GCDKit


// MARK: - NSProgress

public extension NSProgress {
    
    // MARK: Public
    
    public func setProgressHandler(closure: ((progress: NSProgress) -> Void)?) {
        
        self.progressObserver.progressHandler = closure
    }
    
    
    // MARK: Private
    
    private struct PropertyKeys {
        
        static var progressObserver: Void?
    }
    
    private var progressObserver: ProgressObserver {
        
        get {
            
            let object: AnyObject? = getAssociatedObjectForKey(&PropertyKeys.progressObserver, inObject: self)
                
            if let observer = object as? ProgressObserver {
                
                return observer
            }
            
            let observer = ProgressObserver(self)
            setAssociatedRetainedObject(
                observer,
                forKey: &PropertyKeys.progressObserver,
                inObject: self
            )
            
            return observer
        }
    }
}


@objc private final class ProgressObserver: NSObject {
    
    private weak var progress: NSProgress?
    private var progressHandler: ((progress: NSProgress) -> Void)?
    
    private init(_ progress: NSProgress) {
        
        self.progress = progress
        super.init()
        
        progress.addObserver(
            self,
            forKeyPath: "fractionCompleted",
            options: .New,
            context: nil
        )
    }
    
    deinit {
        
        progress?.removeObserver(self, forKeyPath: "fractionCompleted")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        guard let progress = self.progress where object as? NSProgress == progress && keyPath == "fractionCompleted" else {
            
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        GCDQueue.Main.async { [weak self] () -> Void in
            
            if let strongSelf = self, let progress = strongSelf.progress {
                
                strongSelf.progressHandler?(progress: progress)
            }
        }
    }
}
