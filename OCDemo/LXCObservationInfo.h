//
//  LXCObservationInfo.h
//  OCDemo
//
//  Created by 刘晓晨 on 2024/3/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AddObserverIntBlock)(int oldValue, int newValue);
typedef void(^AddObserverBoolBlock)(BOOL oldValue, BOOL newValue);
typedef void(^AddObserverBlock)(id oldValue, id newValue);

@interface LXCObservationInfo : NSObject

@property (nonatomic,assign)id observer;
@property (nonatomic,copy)NSString *key;
@property (nonatomic,copy)AddObserverBlock block;

@end
NS_ASSUME_NONNULL_END
