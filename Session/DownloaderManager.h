//
//  DownloaderManager.h
//  Session
//
//  Created by Mr.Q on 16/6/14.
//  Copyright © 2016年 QLS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloaderManager : NSObject
+ (instancetype)sharedManager;

- (void)download:(NSString *)urlString successBlock:(void(^)(NSString *path))successBlock processBlock:(void(^)(float process))processBlock errorBlock:(void(^)(NSError *error))errorBlock;

- (void)pauseDownload;

@end
