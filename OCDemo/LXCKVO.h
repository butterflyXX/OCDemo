//
//  LXCKVO.h
//  OCDemo
//
//  Created by 刘晓晨 on 2024/3/6.
//

#import <Foundation/Foundation.h>
#import "LXCObservationInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (LXCKVO)

- (void)lxc_addObserver:(NSObject *)observer forKey:(NSString *)key boolBlock:(AddObserverBoolBlock)block;
- (void)lxc_addObserver:(NSObject *)observer forKey:(NSString *)key block:(AddObserverBlock)block;

@end

NS_ASSUME_NONNULL_END
