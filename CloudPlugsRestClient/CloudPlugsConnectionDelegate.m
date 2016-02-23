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

#import "CloudPlugsConnectionDelegate.h"


@implementation CloudPlugsConnectionDelegate{
    void (^completionHandler)(CloudPlugsRequest*, CloudPlugsResponse*);
    //@property (strong, nonatomic) CloudPlugsRequest* request;
    NSURLResponse* response;
    NSMutableData* data;
}

@synthesize request;

- (id) initWithCompletionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*)) handler
{
    self = [super init];
    if(self){
        completionHandler = handler;
    }
    return self;
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)r
{
    data = [[NSMutableData alloc]init];
    response = r;
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)d
{
    [data appendData:d];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    CloudPlugsResponse* res = [[CloudPlugsResponse alloc] init];
    [res setError: error];
    if(completionHandler)
        completionHandler(request, res);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    CloudPlugsResponse* res = [[CloudPlugsResponse alloc] init];
    [res setStatus : [(NSHTTPURLResponse*) response statusCode]];
    res.success = res.status == 200 || res.status == 201;
    res.data = data;
    if(completionHandler)
        completionHandler(request, res);
}

@end

