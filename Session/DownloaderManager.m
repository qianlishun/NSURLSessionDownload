
//
//  DownloaderManager.m
//  Session
//
//  Created by Mr.Q on 16/6/14.
//  Copyright © 2016年 QLS. All rights reserved.
//

#import "DownloaderManager.h"


@interface DownloaderManager () <NSURLSessionDataDelegate>
@property (nonatomic,strong)NSURLSession *session;
@property (nonatomic,strong)NSURLSessionDownloadTask *task;
@property (nonatomic, strong) NSData *resumeData;

@property (nonatomic, copy) NSString *resumePath;

@property (nonatomic, copy) void (^successBlock)(NSString *path);
@property (nonatomic, copy) void (^processBlock)(float process);
@property (nonatomic, copy) void (^errorBlock)(NSError *error);

@property (nonatomic, copy) NSString *urlString;

@property (nonatomic,strong) NSMutableDictionary *downloaderCache;

@end

@implementation DownloaderManager


+ (instancetype)sharedManager {
    static id instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });

    return instance;
}

- (NSMutableDictionary *)downloaderCache {
    if (_downloaderCache == nil) {
        _downloaderCache = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return _downloaderCache;
}



- (NSURLSession *)session {
    if (_session == nil) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

#pragma mark - 控制下载的状态

-(void)pauseDownload{

        [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            self.resumeData = resumeData;
            NSLog(@"暂停");
            self.task = nil;
            [self.resumeData writeToFile:self.resumePath atomically:YES];
        }];
    [self.downloaderCache removeObjectForKey:self.urlString];
}
- (void)resumeDownload:(NSString *)urlString{

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.resumePath]) {
        self.resumeData = [NSData dataWithContentsOfFile:self.resumePath];
        NSLog(@"续传");
    }
    if (self.resumeData == nil) {
        NSLog(@"无下载任务");
        return;
    }

    self.task = [self.session downloadTaskWithResumeData:self.resumeData];

    [self.downloaderCache setObject:self.task forKeyedSubscript:urlString];

    [self.task resume];
    self.resumeData = nil;
}

- (void)download:(NSString *)urlString{

    self.resumeData = [NSData dataWithContentsOfFile:self.resumePath];

    if (self.resumeData.length > 0) {
        [self resumeDownload:urlString];
        return;
    }

    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:url];

    self.task = task;

    [self.downloaderCache setObject:task forKeyedSubscript:urlString];

    [task resume];

    self.resumeData = nil;
}

- (void)download:(NSString *)urlString successBlock:(void (^)(NSString *))successBlock processBlock:(void (^)(float))processBlock errorBlock:(void (^)(NSError *))errorBlock{

    if (self.downloaderCache[urlString]) {
        NSLog(@"正在拼命的下载..");
        return;
    }
    NSLog(@"_________");
    self.resumePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"resume.plist"];

    [self download:urlString];

    self.successBlock = successBlock;
    self.errorBlock = errorBlock;
    self.processBlock = processBlock;
    self.urlString = urlString;
}

//下载完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {

    NSLog(@"temp : %@",location.path);
    NSString *caches = @"/Users/qianlishun/desktop";
    NSString *filePath = [caches stringByAppendingPathComponent:downloadTask.response.suggestedFilename];

    // 将临时文件剪切或者复制Caches文件夹
    NSFileManager *mgr = [NSFileManager defaultManager];

    [mgr moveItemAtPath:location.path toPath:filePath error:nil];

    [mgr removeItemAtPath:self.resumePath error:nil];

    if (self.successBlock) {
        [self.downloaderCache removeObjectForKey:self.urlString];
        self.successBlock(filePath);
    }

}

//下载进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {

    float progress = totalBytesWritten*1.0 / totalBytesExpectedToWrite;

    if (self.processBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.processBlock(progress);
        });
   }

}

//续传
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {

}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
    if (self.errorBlock) {
        [self.downloaderCache removeObjectForKey:self.urlString];
        self.errorBlock(error);
    }

}

@end
