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

#define PLUG_AUTH_HEADER @"X-Plug-Auth"
#define PLUG_ID_HEADER @"X-Plug-Id"
#define PLUG_EMAIL_HEADER @"X-Plug-Email"
#define PLUG_MASTER_HEADER @"X-Plug-Master"
#define OVERRIDE_HEADER @"X-HTTP-Method-Override"
#define CONTENT_TYPE_HEADER @"Content-Type"
#define JSON_HEADER @"application/json"
#define CONTENT_LENGTH_HEADER @"Content-Length"

#define HTTP_GET @"GET"
#define HTTP_HEAD @"HEAD"
#define HTTP_POST @"POST"
#define HTTP_PUT @"PUT"
#define HTTP_DELETE @"DELETE"
#define HTTP_TRACE @"TRACE"
#define HTTP_OPTIONS @"OPTIONS"
#define HTTP_CONNECT @"CONNECT"
#define HTTP_PATCH @"PATCH"

#define PATH_DATA @"data"
#define PATH_DEVICE @"device"
#define PATH_CHANNEL @"channel"

#define _CTRL @"ctrl"
#define HWID @"hwid"
#define NAME @"name"
#define MODEL @"model"
#define PASS @"pass"
#define PERM @"perm"
#define PROPS @"props"
#define STATUS @"status"
#define DATA @"data"
#define BEFORE @"before"
#define AFTER @"after"
#define OF @"of"
#define OFFSET @"offset"
#define LIMIT @"limit"
#define AUTH @"auth"
#define ID @"id"
#define AT @"at"

#define LOCATION @"location"
#define LONGITUDE @"x"
#define LATITUDE @"y"
#define ACCURACY @"r"
#define ALTITUDE @"z"
#define TIMESTAMP @"t"
#define MAX_LONGITUDE 180.0
#define MIN_LONGITUDE -180.0
#define MAX_LATITUDE 90.0
#define MIN_LATITUDE -90.0


#define EXCEPTION_NAME @"CloudPlugsException"


#define DEFAULT_URL @"http://api.cloudplugs.com/iot/"


#import "CloudPlugsRestClient.h"
#import "CloudPlugsConnectionDelegate.h"
#import "CloudPlugsRequest.h"
#import "CloudPlugsResponse.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define TIMEOUT_INTERVAL 60.0

@implementation CloudPlugsRestClient

@synthesize baseUrl;
@synthesize authId;
@synthesize authPass;
@synthesize authMaster;

- (id) init
{
    self = [super init];
    if(self){
        self.baseUrl = [NSURL URLWithString:DEFAULT_URL];
    }
    self.timeout = TIMEOUT_INTERVAL;
    return self;
}

-(CloudPlugsRequest*) enrollProductWithModel:(NSString*) model
                          hwid:(NSString*) hwid
                      password:(NSString*) password
                         props:(NSDictionary*) props
             completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler
{
    if(!model || !hwid || !password) @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"INVALID PARAMETER" userInfo:nil];
    NSMutableDictionary* body = [NSMutableDictionary dictionaryWithDictionary:@{MODEL:model, HWID:hwid, PASS:password}];
    if(props)
       [body setObject:props forKey:PROPS];
    return [self request:HTTP_POST path:PATH_DEVICE headers:nil query:nil body:body completionHandler:^(CloudPlugsRequest* req, CloudPlugsResponse* res) {
        if(res.success){
            self.authId = [res.dictionary objectForKey:ID];
            self.authPass = [res.dictionary objectForKey:AUTH];
        }
        handler(req, res);
    }];
}

-(CloudPlugsRequest*) enrollPrototypeWithHWid:(NSString*) hwid
                       password:(NSString*) password
                           name:(NSString*) name
                           perm:(NSDictionary*) perm
                          props:(NSDictionary*) props
              completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler
{
    if(!name) @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"INVALID PARAMETER" userInfo:nil];
    if(!self.authMaster) @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"MASTER LOGIN IS REQUIRED" userInfo:nil];
    NSMutableDictionary* body = [NSMutableDictionary dictionaryWithDictionary:@{NAME:name}];
    if(hwid) [body setObject:hwid forKey:HWID];
    if(password) [body setObject:password forKey:PASS];
    if(props) [body setObject:props forKey:PROPS];
    if(perm) [body setObject:perm forKey:PERM];
    return [self request:HTTP_POST path:PATH_DEVICE headers:[self getMasterAuthHeaders] query:nil body:body completionHandler:handler];
}

-(CloudPlugsRequest*) enrollCtrlWithModel:(NSString*) model
                       ctrl:(NSString*) ctrl
                   password:(NSString*) password
                       hwid:(NSString*) hwid
                       name:(NSString*) name
          completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler
{
    if(!model || !ctrl || !password) @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"INVALID PARAMETER" userInfo:nil];
    NSMutableDictionary* body = [NSMutableDictionary dictionaryWithDictionary:@{MODEL:model, _CTRL:ctrl, PASS:password}];
    if(hwid) [body setObject:hwid forKey:PROPS];
    if(name) [body setObject:name forKey:NAME];
    return [self request:HTTP_PUT path:PATH_DEVICE headers:nil query:nil body:body completionHandler:^(CloudPlugsRequest* req, CloudPlugsResponse* res) {
        if(res.success && self.authId == nil){
            self.authId = [res.dictionary objectForKey:ID];
            self.authPass = [res.dictionary objectForKey:AUTH];
        }
        handler(req, res);
    }];
}

-(CloudPlugsRequest*) controlDeviceWithModel:(NSString*) model
                          ctrl:(NSString*) ctrl
                      password:(NSString*) password
             completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler;
{
    if(!model || !ctrl || !password) @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"INVALID PARAMETER" userInfo:nil];
    NSMutableDictionary* body = [NSMutableDictionary dictionaryWithDictionary:@{MODEL:model, _CTRL:ctrl, PASS:password}];
    return [self request:HTTP_PUT path:PATH_DEVICE headers:[self getAuthHeaders] query:nil body:body completionHandler:^(CloudPlugsRequest* req, CloudPlugsResponse* res) {
        if(res.success && self.authId == nil){
            self.authId = [res.dictionary objectForKey:ID];
            self.authPass = [res.dictionary objectForKey:AUTH];
        }
        handler(req, res);
    }];
}

-(CloudPlugsRequest*) uncontrolDeviceWithPlugId:(NSString*) plugid
                plugid_controlled:(id) plugidControlled
                completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler
{
    NSString* path = [NSString stringWithFormat:@"%@/%@", PATH_DEVICE, plugid ? plugid : self.authId];
    if([self checkStringOrArrayOfString:plugidControlled])
        @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"INVALID PARAMETER" userInfo:nil];
    
    return [self request:HTTP_DELETE path:path headers:[self getAuthHeaders] query:nil body:plugidControlled completionHandler:handler];
}

-(CloudPlugsRequest*) getDevice:(NSString*) plugid
completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler
{
    NSString* path = [NSString stringWithFormat:@"%@/%@", PATH_DEVICE, plugid ? plugid : self.authId];
    return [self request:HTTP_GET path:path headers:[self getAuthHeaders] query:nil body:nil completionHandler:handler];
}

-(CloudPlugsRequest*) getDeviceProp:(NSString*) plugid
                 prop:(NSString*) prop
    completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler
{
    NSString* path = [NSString stringWithFormat:@"%@/%@/%@", PATH_DEVICE, plugid ? plugid : self.authId, prop ? prop : @""];
    return [self request:HTTP_GET path:path headers:[self getAuthHeaders] query:nil body:nil completionHandler:handler];
}

-(CloudPlugsRequest*) setDeviceProp:(NSString*) plugid
                 prop:(NSString*) prop
                value:(id) value
    completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler
{
    if(!value) @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"INVALID PARAMETER" userInfo:nil];
    NSString* path = [NSString stringWithFormat:@"%@/%@/%@", PATH_DEVICE, plugid ? plugid : self.authId, prop ? prop : @""];
    return [self request:HTTP_PATCH path:path headers:[self getAuthHeaders] query:nil body:value completionHandler:handler];
}

-(CloudPlugsRequest*) removeDeviceProp:(NSString*) plugid
                    prop:(NSString*) prop
       completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler
{
    if(!prop) @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"INVALID PARAMETER" userInfo:nil];
    NSString* path = [NSString stringWithFormat:@"%@/%@/%@", PATH_DEVICE, plugid ? plugid : self.authId, prop];
    return [self request:HTTP_DELETE path:path headers:[self getAuthHeaders] query:nil body:nil completionHandler:handler];
}

-(CloudPlugsRequest*) setDevice:(NSString*) plugid
             perm:(NSDictionary*) perm
             name:(NSString*) name
           status:(NSString*) status //"ok" || "disabled" || "activate"
            props:(NSDictionary*) props
completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler
{
    if(!perm && !name && !status && !props) @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"INVALID PARAMETER" userInfo:nil];
    NSString* path = [NSString stringWithFormat:@"%@/%@", PATH_DEVICE, plugid ? plugid : self.authId];
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    if(perm) [body setObject:perm forKey:PERM];
    if(name) [body setObject:name forKey:NAME];
    if(status) [body setObject:status forKey:STATUS];
    if(props) [body setObject:props forKey:PROPS];
    return [self request:HTTP_PATCH path:path headers:[self getAuthHeaders] query:nil body:body completionHandler:handler];
}

-(CloudPlugsRequest*) unenroll:(id) plugid
completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler
{
    if([self checkStringOrArrayOfString:plugid])
        @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"INVALID PARAMETER" userInfo:nil];
    id body = plugid ? plugid : self.authId;
    return [self request:HTTP_DELETE path:PATH_DEVICE headers:[self getAuthHeaders] query:nil body:body completionHandler:handler];
}

-(CloudPlugsRequest*) getChannel:(NSString*) channelMask
            before:(id) before
             after:(id) after
                at:(id) at
                of:(id) of
            offset:(NSInteger) offset
             limit:(NSInteger) limit
 completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler
{
    NSString* path = channelMask ? [NSString stringWithFormat:@"%@/%@", PATH_CHANNEL, channelMask] : PATH_CHANNEL;
    
    NSMutableDictionary* query = [NSMutableDictionary dictionary];
   
    if(before){
        if([before isKindOfClass:[NSDate class]])
            [query setObject:[NSNumber numberWithDouble:[before timeIntervalSince1970]] forKey:BEFORE];
        if([before isKindOfClass:[NSString class]] || [before isKindOfClass:[NSNumber class]] || [before isKindOfClass:[NSArray class]] )
            [query setObject:before forKey:BEFORE];
    }
    if(after){
        if([after isKindOfClass:[NSDate class]])
            [query setObject:[NSNumber numberWithDouble:[after timeIntervalSince1970]] forKey:AFTER];
        if([after isKindOfClass:[NSString class]] || [after isKindOfClass:[NSNumber class]] || [after isKindOfClass:[NSArray class]] )
            [query setObject:before forKey:AFTER];
    }
    if(at){
        if([at isKindOfClass:[NSDate class]])
            [query setObject:[NSNumber numberWithDouble:[at timeIntervalSince1970]] forKey:AT];
        if([at isKindOfClass:[NSString class]] || [at isKindOfClass:[NSNumber class]] || [at isKindOfClass:[NSArray class]] )
            [query setObject:at forKey:AT];
    }
    
    if(of) [query setObject:of forKey:OF];
    if(offset>=0) [query setObject:[NSNumber numberWithInteger:offset] forKey:OFFSET];
    if(limit>=0) [query setObject:[NSNumber numberWithInteger:limit] forKey:LIMIT];
    
    return [self request:HTTP_GET path:path headers:[self getAuthHeaders] query:query body:nil completionHandler:handler];
    
}

-(CloudPlugsRequest*) retrieveDataFrom:(NSString*)channelMask
                  before:(NSDate*) before
                   after:(NSDate*) after
                      at:(NSDate*) at
                      of:(id) of
                  offset:(NSInteger) offset
                   limit:(NSInteger) limit
       completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler
{
    if([self checkStringOrArrayOfString:of])
        @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"INVALID PARAMETER" userInfo:nil];
    if(!channelMask) @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"INVALID PARAMETER" userInfo:nil];
    NSString* path = [NSString stringWithFormat:@"%@/%@", PATH_DATA, channelMask];
    NSMutableDictionary* query = [NSMutableDictionary dictionary];
    if(before) [query setObject:[NSNumber numberWithDouble:[before timeIntervalSince1970]] forKey:BEFORE];
    if(after) [query setObject:[NSNumber numberWithDouble:[after timeIntervalSince1970]] forKey:AFTER];
    if(at) [query setObject:[NSNumber numberWithDouble:[at timeIntervalSince1970]] forKey:AT];
    if(of) [query setObject:of forKey:OF];
    if(offset>=0) [query setObject:[NSNumber numberWithInteger:offset] forKey:OFFSET];
    if(limit>=0) [query setObject:[NSNumber numberWithInteger:limit] forKey:LIMIT];
    return [self request:HTTP_GET path:path headers:[self getAuthHeaders] query:query body:nil completionHandler:handler];
}

-(CloudPlugsRequest*) publishData:(NSString*) channel
               body:(id) body
  completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler
{
    if(!channel || !body) @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"INVALID PARAMETER" userInfo:nil];
    NSString* path = [NSString stringWithFormat:@"%@/%@", PATH_DATA, channel];
    return [self request:HTTP_PUT path:path headers:[self getAuthHeaders] query:nil body:body completionHandler:handler];
}


-(CloudPlugsRequest*) removeData:(NSString*) channelMask
            withId:(id) _id
            before:(id) before
             after:(id) after
                at:(id) at
                of:(id) of
             limit:(NSInteger) limit
 completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler
{
    if(!channelMask || (!_id && !before && !after && !at)) @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"INVALID PARAMETER" userInfo:nil];
    NSString* path = [NSString stringWithFormat:@"%@/%@", PATH_DATA, channelMask];
    
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    if(_id){
        if([_id isKindOfClass:[NSString class]] || [_id isKindOfClass:[NSArray class]] )
            [body setObject:_id forKey:ID];
    }
    if(before){
        if([before isKindOfClass:[NSDate class]])
            [body setObject:[NSNumber numberWithDouble:[before timeIntervalSince1970]] forKey:BEFORE];
        if([before isKindOfClass:[NSString class]] || [before isKindOfClass:[NSNumber class]] || [before isKindOfClass:[NSArray class]] )
            [body setObject:before forKey:BEFORE];
    }
    if(after){
        if([after isKindOfClass:[NSDate class]])
            [body setObject:[NSNumber numberWithDouble:[after timeIntervalSince1970]] forKey:AFTER];
        if([after isKindOfClass:[NSString class]] || [after isKindOfClass:[NSNumber class]] || [after isKindOfClass:[NSArray class]] )
            [body setObject:before forKey:AFTER];
    }
    if(at){
        if([at isKindOfClass:[NSDate class]])
            [body setObject:[NSNumber numberWithDouble:[at timeIntervalSince1970]] forKey:AT];
        if([at isKindOfClass:[NSString class]] || [at isKindOfClass:[NSNumber class]] || [at isKindOfClass:[NSArray class]] )
            [body setObject:at forKey:AT];
    }
        
    if(of) [body setObject:of forKey:OF];
    if(limit>=0) [body setObject:[NSNumber numberWithInteger:limit] forKey:LIMIT];
    
    return [self request:HTTP_DELETE path:path headers:[self getAuthHeaders] query:nil body:body completionHandler:handler];
}

-(CloudPlugsRequest*) setDeviceLocation:(NSString*) plugid
                longitude:(double) longitude
                 latitude:(double) latitude
                 altitude:(double) altitude
                 accuracy:(double) accuracy
                timestamp:(NSDate*) timestamp
        completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler
{
    if(longitude > MAX_LONGITUDE || longitude < MIN_LONGITUDE) @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"INVALID PARAMETER" userInfo:nil];
    if(latitude > MAX_LATITUDE || latitude < MIN_LATITUDE) @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"INVALID PARAMETER" userInfo:nil];
    NSMutableDictionary* body = [NSMutableDictionary dictionaryWithDictionary:@{LONGITUDE:[NSNumber numberWithDouble:longitude], LATITUDE: [NSNumber numberWithDouble:latitude]}];
    
    if(altitude>=0) [body setObject:[NSNumber numberWithDouble:altitude] forKey:ALTITUDE];
    if(accuracy>=0) [body setObject:[NSNumber numberWithDouble:accuracy] forKey:ACCURACY];
    if(timestamp) [body setObject:[NSNumber numberWithDouble:[timestamp timeIntervalSince1970]] forKey:TIMESTAMP];
    
    NSString* path = [NSString stringWithFormat:@"%@/%@/%@", PATH_DEVICE, plugid ? plugid : self.authId, LOCATION];
    return [self request:HTTP_PATCH path:path headers:[self getAuthHeaders] query:nil body:body completionHandler:handler];
    
}

-(CloudPlugsRequest*) getDeviceLocation:(NSString*) plugid
        completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler
{
    NSString* path = [NSString stringWithFormat:@"%@/%@/%@", PATH_DEVICE, plugid ? plugid : self.authId, LOCATION];
    return [self request:HTTP_GET path:path headers:[self getAuthHeaders] query:nil body:nil completionHandler:handler];
}




-(CloudPlugsRequest*)request:(NSString*) http_method
                       path:(NSString*) path
                    headers:(NSDictionary*)headers
                      query:(NSDictionary*)query
                       body:(id) body
          completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    if([HTTP_DELETE isEqualToString: http_method] && body){
        [request setHTTPMethod:HTTP_POST];
        [request setValue:HTTP_DELETE forHTTPHeaderField:OVERRIDE_HEADER];
    } else {
        [request setHTTPMethod:http_method];
    }

    if(headers) for(NSString *key in headers){
        [request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
    }

    NSURL *url;
    if(query){
        NSMutableString *qs = [NSMutableString stringWithFormat:@""];
        for(NSString *key in query){
            [qs appendFormat:@"%@=%@&", key, [query objectForKey:key]];
        }
        [qs deleteCharactersInRange:NSMakeRange([qs length]-1, 1)];
        NSString *qs2 = [qs stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", path, qs2] relativeToURL: self.baseUrl];
    } else {
        url = [NSURL URLWithString:path relativeToURL: self.baseUrl];
    }
    [request setURL:url];
    
    NSData* bodydata;
    if(body){
        if([body isKindOfClass:[NSDictionary class]] || [body isKindOfClass:[NSArray class]]) {
            NSError *theError;
            bodydata = [NSJSONSerialization dataWithJSONObject:body options:0 error:&theError];
            if(theError){
                NSLog(@"NSJSONSerialization error: %@", theError);
                @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"INVALID BODY DATA" userInfo:nil];
            }
        } else if([body isKindOfClass:[NSString class]])
            bodydata = [[NSString stringWithFormat:@"\"%@\"", body] dataUsingEncoding:NSUTF8StringEncoding];
        else if([body isKindOfClass:[NSNumber class]])
            bodydata = [[(NSNumber*)body stringValue] dataUsingEncoding:NSUTF8StringEncoding];
        else
            @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"INVALID BODY TYPE" userInfo:nil];
        
        long bodylen = [bodydata length];
        [request setHTTPBody:bodydata];
        [request setValue:JSON_HEADER forHTTPHeaderField:CONTENT_TYPE_HEADER];
        [request setValue:[NSString stringWithFormat:@"%ld", bodylen] forHTTPHeaderField:CONTENT_LENGTH_HEADER];
    }
    
    request.cachePolicy=NSURLRequestUseProtocolCachePolicy;
    [request setTimeoutInterval:self.timeout];
    
    CloudPlugsConnectionDelegate* delegate = [[CloudPlugsConnectionDelegate alloc] initWithCompletionHandler:handler];
    NSURLConnection * c = [NSURLConnection connectionWithRequest: request
                                                        delegate: delegate];
    
    CloudPlugsRequest* cpRequest = [[CloudPlugsRequest alloc] initWithNSURLConnection:c];
    [cpRequest setHttpMethod: http_method];
    [cpRequest setPath : path];
    [cpRequest setHeaders : headers];
    [cpRequest setQuery : query];
    [cpRequest setBody : bodydata];
    
    delegate.request = cpRequest;
    
    [c start];
    return cpRequest;
}

-(CloudPlugsRequest*) request:(CloudPlugsRequest*) cpRequest
          completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler
{
    return [self request:[cpRequest httpMethod]
                    path:[cpRequest path]
                 headers:[cpRequest headers]
                   query:[cpRequest query]
                    body:[cpRequest body]
       completionHandler:handler];
}

-(NSDictionary*) getMasterAuthHeaders
{
    if(!self.authMaster) @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"MASTER LOGIN IS REQUIRED" userInfo:nil];
    return [self getAuthHeaders:nil];
}

-(NSDictionary*) getAuthHeaders
{
    return [self getAuthHeaders:nil];
}

-(NSDictionary*) getAuthHeaders:(NSDictionary*) headers
{
    NSMutableDictionary* h = headers ? [NSMutableDictionary dictionaryWithDictionary:headers] : [NSMutableDictionary dictionary];
    if(!self.authId || !self.authPass){
        @throw [NSException exceptionWithName:EXCEPTION_NAME reason:@"INVALID LOGIN" userInfo:nil];
    }
    if ([self.authId rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]].location != NSNotFound)
        [h setValue:self.authId forKey:PLUG_EMAIL_HEADER];
    else
        [h setValue:self.authId forKey:PLUG_ID_HEADER];
    if(self.authMaster)
        [h setValue:self.authPass forKey:PLUG_MASTER_HEADER];
    else
        [h setValue:self.authPass forKey:PLUG_AUTH_HEADER];
    return [h copy];

}

- (BOOL) checkStringOrArrayOfString: (id) obj
{
    if(obj == nil) return NO;
    if([obj isKindOfClass:[NSString class]]) return NO;
    if([obj isKindOfClass:[NSArray class]]){
        for (id object in obj) {
            if(![object isKindOfClass:[NSString class]]) return YES;
        }
        return NO;
    }
    return YES;
}

@end
