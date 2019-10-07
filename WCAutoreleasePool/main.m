//
//  main.m
//  WCAutoreleasePool
//
//  Created by Frank on 2019/10/7.
//  Copyright © 2019 Frank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "AppDelegate.h"
#import "WCAutoreleasePool.h"

@interface AObject : NSObject

@end

@implementation AObject

- (void)dealloc {
    NSLog(@"AObject is be destroyed");
    [super dealloc];
}

@end

static id AllocateWCAutoreleasePool(id self, SEL _cmd) {
    return [WCAutoreleasePool alloc];
}

int main(int argc, char * argv[]) {
    SEL allocSelector = @selector(alloc);
    Method allocMethod = class_getClassMethod([NSAutoreleasePool class], allocSelector);
    class_replaceMethod(object_getClass([NSAutoreleasePool class]), allocSelector, (IMP)AllocateWCAutoreleasePool, method_getTypeEncoding(allocMethod));

    SEL autoReleaseSelector = @selector(autorelease);
    Method autoReleaseMethod = class_getInstanceMethod([NSObject class], autoReleaseSelector);
    IMP wcAutoReleaseIMP = [NSObject instanceMethodForSelector:@selector(wcAutoRelease)];
    class_replaceMethod([NSObject class], autoReleaseSelector, wcAutoReleaseIMP, method_getTypeEncoding(autoReleaseMethod));

    NSAutoreleasePool *autoreleasePool = [[NSAutoreleasePool alloc] init];

    NSMutableArray *objects = [NSMutableArray array];  // Implied autorelease
    [objects addObject:[[[AObject alloc] init] autorelease]];

    [autoreleasePool release];  // Dealloc it


//    @autoreleasepool {
//        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
//    }

    return 0;
}
