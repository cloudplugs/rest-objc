/*
 Copyright 2014 CloudPlugs Inc.
 
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
*/

#import "ViewController.h"
#import <CloudPlugsRestClient/CloudPlugsRestClient.h>

@interface ViewController ()

@end

@implementation ViewController{
    CloudPlugsRestClient* cp;
    __weak IBOutlet UITextView *textView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    cp = [[CloudPlugsRestClient alloc] init];
    [cp setAuthId:@"dev-xxxxxxxxxxxxxxxxxx"];
    [cp setAuthPass:@"your-password"];		
    [cp setAuthMaster:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)test:(id)sender {
    [cp publishData:@"temperature"
               body:@{@"data":[self getTemp]}
  completionHandler:^(CloudPlugsRequest *req, CloudPlugsResponse *res) {
      [self log:@"publish" request:req response:res];
  }];
}

- (void) log:(NSString*) tag
    request:(CloudPlugsRequest*) req
    response:(CloudPlugsResponse*) res
{
    NSString* log = [NSString stringWithFormat:@"%@: %@", tag, res ? (res.object ? res.object : res.string) : @""];
    NSLog(@"%@", log);
    textView.text = [textView.text stringByAppendingString:log];
    textView.text = [textView.text stringByAppendingString:@"\n"];
}

- (NSNumber*) getTemp {
    int r = arc4random() % 100;
    return [NSNumber numberWithInt:r];
}
@end
