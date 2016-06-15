//
//  ViewController.m
//  Session
//
//  Created by Mr.Q on 16/6/14.
//  Copyright © 2016年 QLS. All rights reserved.
//

#import "ViewController.h"
#import "DownloaderManager.h"
#import "ProcessView.h"
@interface ViewController ()


@property (nonatomic,strong) ProcessView *processView;


@end


#define kURLString @"http://sw.bos.baidu.com/sw-search-sp/software/bfe69c1ecac/QQ_4.2.1_mac.dmg"

@implementation ViewController

- (void)beginDownload:(UIButton *)sender{

    //@"http://sw.bos.baidu.com/sw-search-sp/software/bfe69c1ecac/QQ_4.2.1_mac.dmg"

    [[DownloaderManager sharedManager]download:kURLString  successBlock:^(NSString *path) {
        NSLog(@"下载完成%@",path);

    }  processBlock:^(float process) {

        self.processView.process = process;

    }errorBlock:^(NSError *error) {

        NSLog(@"下载出错 :%@",error);
    }];
}
- (void)pauseDownload:(UIButton *)sender{
    [[DownloaderManager sharedManager]pauseDownload:kURLString];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIButton *btnBegin = [[UIButton alloc]initWithFrame:CGRectMake(30, 50, 0, 0)];
    [btnBegin setTitle:@"开始下载" forState:UIControlStateNormal];
    [btnBegin setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnBegin sizeToFit];

    [self.view addSubview:btnBegin];

    [btnBegin addTarget:self action:@selector(beginDownload:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btnPause = [[UIButton alloc]initWithFrame:CGRectMake(30, 100, 0, 0)];

    [btnPause setTitle:@"暂停下载" forState:UIControlStateNormal];
    [btnPause setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    [btnPause sizeToFit];

    [self.view addSubview:btnPause];

    [btnPause addTarget:self action:@selector(pauseDownload:) forControlEvents:UIControlEventTouchUpInside];


    self.processView = [[ProcessView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.processView.center = self.view.center;

    [self.view addSubview:self.processView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
