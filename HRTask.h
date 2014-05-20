//
//  HRTask.h
//  Huddle
//
//  Created by Harry Richardson on 20/05/2014.
//
//

#import <Foundation/Foundation.h>

@class HRSubscriber;
typedef void (^HRSubscriberBlock)(HRSubscriber* subscriber);
typedef void (^HRNextBlock)(id next);
typedef void (^HRCompletedBlock)(void);
typedef void (^HRErrorBlock)(NSError *error);

@interface HRTask : NSObject

+ (HRTask *)taskWithBlock:(HRSubscriberBlock)block;

- (void)subscribeNext:(HRNextBlock)nextBlock;
- (void)subscribeCompleted:(HRCompletedBlock)completedBlock;
- (void)subscribeError:(HRErrorBlock)errorBlock;

@end

@interface HRSubscriber : NSObject
- (void)sendNext:(id)next;
- (void)sendCompleted;
- (void)sendError:(NSError *)error;
@end


