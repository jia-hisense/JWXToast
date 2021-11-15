//
//  JWXViewController.m
//  JWXToast
//
//  Created by FUJIA JIA on 11/15/2021.
//  Copyright (c) 2021 FUJIA JIA. All rights reserved.
//

#import "JWXViewController.h"
#import <JWXToast/JWXToast.h>

@interface JWXViewController ()

@end

@implementation JWXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [JWXToast.sharedInstance show:@"Hello"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
