//
//  WCAutoreleasePool.m
//  WCAutoreleasePool
//
//  Created by Frank on 2019/10/7.
//  Copyright © 2019 Frank. All rights reserved.
//

#import "WCAutoreleasePool.h"

@interface WCAutoreleasePool () {
    CFMutableArrayRef _objects;
}
@end

static NSString * const kWCAutoreleasePoolKey = @"kWCAutoreleasePoolKey";

@implementation WCAutoreleasePool

- (id)init {
    self = [super init];
    if (self) {
        _objects = CFArrayCreateMutable(NULL, 0, NULL);
        CFArrayAppendValue([self class]._poolStackPerThread, (__bridge const void *)(self));
    }
    return self;
}

+ (CFMutableArrayRef)_poolStackPerThread {
    NSMutableDictionary *threadInfo = [NSThread currentThread].threadDictionary;
    CFMutableArrayRef pools = (__bridge CFMutableArrayRef)[threadInfo objectForKey:kWCAutoreleasePoolKey];
    if (pools == nil) {
        pools = CFArrayCreateMutable(NULL, 0, NULL);
        [threadInfo setObject:(__bridge id _Nonnull)(pools) forKey:kWCAutoreleasePoolKey];
        CFRelease(pools);
    }
    return pools;
}

+ (void)addObject:(id)anObject {
    CFArrayRef pools = [self _poolStackPerThread];
    CFIndex count = CFArrayGetCount(pools);
    if (0 == count) {
        NSAssert(NO, @"No pool stack found.");
    } else {
        WCAutoreleasePool *pool = CFArrayGetValueAtIndex(pools, count - 1);
        [pool addObject:anObject];
    }
}

- (void)addObject:(id)anObject {
    CFArrayAppendValue(_objects, (__bridge const void *)(anObject));
}

- (void)dealloc {
    // Clean all objects if them exist
    if (_objects) {
        for (id object in (__bridge id)_objects) {
            [object release];
        }
        CFRelease(_objects);
    }

    // Get pool stack in current thread
    CFMutableArrayRef pools = [self class]._poolStackPerThread;
    CFIndex count = CFArrayGetCount(pools);

    while (count > 0) {
        WCAutoreleasePool *pool = CFArrayGetValueAtIndex(pools, count - 1);
        if (pool == self) {
            // At bottom of stack and should be done
            CFArrayRemoveValueAtIndex(pools, count);
            break;
        } else {
            // In other pool case, it will call its dealloc method when sending release
            [pool release];
        }
        count--;
    }

    // Of course
    [super dealloc];
}

@end

@implementation NSObject (WCAutoreleasePool)

- (id)wcAutoRelease {
    [WCAutoreleasePool addObject:self];
    return self;
}

@end
