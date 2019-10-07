//
//  WCAutoreleasePool.h
//  WCAutoreleasePool
//
//  Created by Frank on 2019/10/7.
//  Copyright © 2019 Frank. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCAutoreleasePool : NSObject

+ (void)addObject:(id)anObject;
- (void)addObject:(id)anObject;

@end

@interface NSObject (WCAutoreleasePool)

- (id)wcAutoRelease;

@end

NS_ASSUME_NONNULL_END
