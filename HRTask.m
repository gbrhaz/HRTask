//
//  HRTask.m
//  Huddle
//
//  Created by Harry Richardson on 20/05/2014.
//
//

#import "HRTask.h"

@interface HRSubscriber()
@property (nonatomic, copy) HRNextBlock nextBlock;
@property (nonatomic, copy) HRCompletedBlock completedBlock;
@property (nonatomic, copy) HRErrorBlock errorBlock;

+ (instancetype)subscriberWithNext:(HRNextBlock)nextBlock completedBlock:(HRCompletedBlock)completedBlock errorBlock:(HRErrorBlock)errorBlock;

@end

@implementation HRSubscriber

+ (instancetype)subscriberWithNext:(HRNextBlock)nextBlock
                    completedBlock:(HRCompletedBlock)completedBlock
                        errorBlock:(HRErrorBlock)errorBlock
{
    HRSubscriber *subscriber = [HRSubscriber new];
    subscriber->_completedBlock = [completedBlock copy];
    subscriber->_nextBlock = [nextBlock copy];
    subscriber->_errorBlock = [errorBlock copy];
    
    return subscriber;
}

- (void)sendNext:(id)next {
    @synchronized (self) {
		void (^nextBlock)(id) = [self.nextBlock copy];
		if (nextBlock == nil) return;
        
		nextBlock(next);
	}
}

- (void)sendCompleted {
    @synchronized(self) {
        void (^completedBlock)(void) = [self.completedBlock copy];
        if (completedBlock == nil) return;
        completedBlock();
    }
}

- (void)sendError:(NSError *)error {
    @synchronized(self) {
        void (^errorBlock)(NSError*) = [self.errorBlock copy];
        if (errorBlock == nil) return;
        errorBlock(error);
    }
}


@end

@interface HRTask()
@property (nonatomic, copy) HRSubscriberBlock actionBlock;
@property (nonatomic, strong) NSMutableArray *subscribers;
@end

@implementation HRTask

- (id)init {
    if (self = [super init]) {
        _subscribers = [NSMutableArray array];
    }
    return self;
}

+ (HRTask *)taskWithBlock:(HRSubscriberBlock)block {
    HRTask *task = [HRTask new];
    task.actionBlock = block;
    return task;
}

- (void)subscribeNext:(HRNextBlock)nextBlock {
    HRSubscriber *subscriber = [HRSubscriber subscriberWithNext:nextBlock
                                                 completedBlock:nil
                                                     errorBlock:nil];
    self.actionBlock(subscriber);
}

- (void)subscribeCompleted:(HRCompletedBlock)completedBlock {
    HRSubscriber *subscriber = [HRSubscriber subscriberWithNext:nil
                                                 completedBlock:completedBlock
                                                     errorBlock:nil];
    self.actionBlock(subscriber);
}

- (void)subscribeError:(HRErrorBlock)errorBlock {
    HRSubscriber *subscriber = [HRSubscriber subscriberWithNext:nil completedBlock:nil errorBlock:errorBlock];
    self.actionBlock(subscriber);
}

@end


