//
//  CoreStoreBridge.m
//  CoreStore
//
//  Copyright © 2016 John Rommel Estropia
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

#import "CoreStoreBridge.h"
#import <CoreStore/CoreStore-Swift.h>


CS_OBJC_OVERLOADABLE
CSFrom *_Nonnull From(Class _Nonnull entityClass) {
    
    return [CSFrom entityClass:entityClass];
}

CS_OBJC_OVERLOADABLE
CSFrom *_Nonnull From(Class _Nonnull entityClass, NSArray<id> *_Nonnull configurations) {
    
    return [CSFrom entityClass:entityClass configurations:configurations];
}



// MARK: - Where

CS_OBJC_OVERLOADABLE
CSWhere *_Nonnull Where(BOOL value) {
    
    return [CSWhere value:value];
}

CS_OBJC_OVERLOADABLE
CSWhere *_Nonnull Where(NSString *_Nonnull format, ...) {
    
    CSWhere *where;
    va_list args;
    va_start(args, format);
    where = [CSWhere predicate:[NSPredicate predicateWithFormat:format arguments:args]];
    va_end(args);
    return where;
}

CS_OBJC_OVERLOADABLE
CSWhere *_Nonnull Where(NSPredicate *_Nonnull predicate) {
    
    return [CSWhere predicate:predicate];
}


// MARK: - GroupBy

CS_OBJC_OVERLOADABLE
CSGroupBy *_Nonnull GroupBy(NSArray<NSString *> *_Nonnull keyPaths) {
 
    return [CSGroupBy keyPaths:keyPaths];
}
