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


#import <Foundation/Foundation.h>
#import <CloudPlugsRestClient/CloudPlugsRestClient.h>


int getTemp() {
    return arc4random() % 100;
}

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        CloudPlugsRestClient* cp = [[CloudPlugsRestClient alloc] init];
        [cp setAuthId:@"dev-xxxxxxxxxxxxxxxxxx"];
        [cp setAuthPass:@"your-password"];
        [cp setAuthMaster:YES];
            [cp publishData:@"temperature"
                       body:@{@"data":[NSNumber numberWithInt:getTemp()]}
          completionHandler:^(CloudPlugsRequest *req, CloudPlugsResponse *res) {
              NSLog(@"publish %@", res ? (res.object ? res.object : res.string) : @"");
              CFRunLoopStop([[NSRunLoop currentRunLoop] getCFRunLoop]);
          }];
    }
    CFRunLoopRun();
    return 0;
}
