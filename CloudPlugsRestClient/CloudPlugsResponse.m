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

#import "CloudPlugsResponse.h"

@implementation CloudPlugsResponse{
    BOOL isParsed;
}

@synthesize error;
@synthesize data;
@synthesize object;
@synthesize dictionary;
@synthesize array;
@synthesize string;
@synthesize number;
@synthesize status;

-(NSObject*) object
{
    if(self.data && !isParsed){
        isParsed = YES;
        NSError *theError;
        object = [NSJSONSerialization JSONObjectWithData:data
                                                        options:kNilOptions
                                                          error:&theError];
        if(theError){
            //[res setError: theError];
        } else {
            if([object isKindOfClass:[NSDictionary class]])
                dictionary = (NSDictionary*) object;
            else if([self.object isKindOfClass:[NSArray class]])
                array = (NSArray*) object;
        }
        
    }
    return object;
}

-(NSDictionary*) dictionary
{
    if(data && !isParsed){
        [self object];
    }
    return dictionary;
}

-(NSArray*) array
{
    if(data && !isParsed){
        [self object];
    }
    return array;
}

-(NSString*) string
{
    if(string == nil)
        string = [[NSString alloc] initWithData:data
                                          encoding:NSUTF8StringEncoding];
    return string;
}

-(NSNumber*) number
{
    if(number == nil){
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        number = [f numberFromString:self.string];
    }
    return number;
}

@end
