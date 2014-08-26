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
#import "CloudPlugsRequest.h"
#import "CloudPlugsResponse.h"

@interface CloudPlugsRestClient : NSObject

/**
 Base url value for HTTP REST requests.
 */
@property (strong) NSURL *baseUrl;
/**
 The authentication id (plug-id or email) of the session.
 */
@property (strong) NSString* authId;
/**
 The authentication password of the session.
 */
@property (strong) NSString* authPass;
/**
 The authentication mode in the session.
 */
@property (assign) BOOL authMaster;
/**
 Timeout value for requests in the session.
 */
@property (assign) double timeout;


/**
 This function performs an HTTP request to the server for enrolling a new production device.
 
 @param model The device model's.
 @param hwid The serial number.
 @param password The password.
 @param props If not NULL, then initialize the custom properties.
  @param handler Callback function. If not NULL it will receive the Request and its Response 
 @param handler Callback function. If not NULL it will receive the Request and its Response 
 @return \c TRUE if the request succeeds, \c FALSE otherwise.
 */
-(CloudPlugsRequest*) enrollProductWithModel:(NSString*) model
                          hwid:(NSString*) hwid
                      password:(NSString*) password
                         props:(NSDictionary*) props
             completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler;

/**
 This function performs an HTTP request to the server for enrolling a prototype
 
 @param hwid If NULL, then it will be set as a random unique string.
 @param password If NULL, then set as the X-Plug-Master of the company
 @param name The name of the product.
 @param perm If NULL, then permit all.
 @param props If not NULL, then initialize the custom properties.
 @param handler Callback function. If not NULL it will receive the Request and its Response
 @return \c TRUE if the request succeeds,  \c FALSE otherwise.
 */
-(CloudPlugsRequest*) enrollPrototypeWithHWid:(NSString*) hwid
                       password:(NSString*) password
                           name:(NSString*) name
                           perm:(NSDictionary*) perm
                          props:(NSDictionary*) props
              completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler;

/**
 This function performs an HTTP request to the server for enrolling a new or already existent controller device.
 
 @param model The model id of the device to control.
 @param ctrl The serial number (hwid) of the device to control.
 @param password The device password's
 @param hwid If not NULL, then set unique string to identify this controller device
 @param name If not NULL, then set the name of this device
 @param handler Callback function. If not NULL it will receive the Request and its Response
 @return \c TRUE if the request succeeds,  \c FALSE otherwise.
 */
-(CloudPlugsRequest*) enrollCtrlWithModel:(NSString*) model
                       ctrl:(NSString*) ctrl
                   password:(NSString*) password
                       hwid:(NSString*) hwid
                       name:(NSString*) name
          completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler;

/**
 This function performs an HTTP request to the server for enrolling an already existent controller device
 
 @param model The model id of the device to control.
 @param ctrl The serial number (hwid) of the device to control.
 @param password The device password's
 @param handler Callback function. If not NULL it will receive the Request and its Response
 @return \c TRUE if the request succeeds,  \c FALSE otherwise.
 */
-(CloudPlugsRequest*) controlDeviceWithModel:(NSString*) model
                          ctrl:(NSString*) ctrl
                      password:(NSString*) password
             completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler;

/**
 This function performs an HTTP request to the server for uncontrolling a device
 
 @param plugid If NULL, then is the plug-id in the session.
 @param plugidControlled If not NULL, then the device(s) to uncontroll (default all associated devices).
 @param handler Callback function. If not NULL it will receive the Request and its Response 
 @return \c TRUE if the request succeeds,  \c FALSE otherwise.
 */
-(CloudPlugsRequest*) uncontrolDeviceWithPlugId:(NSString*) plugid
                plugid_controlled:(id) plugidControlled
                completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler;

/**
 This function performs an HTTP request to the server for reading a device.
 
 @param plugid The plug-id of the device.
 @param handler Callback function. If not NULL it will receive the Request and its Response
 @return \c TRUE if the request succeeds,  \c FALSE otherwise.
 */
-(CloudPlugsRequest*) getDevice:(NSString*) plugid
completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler;

/**
 This function performs an HTTP request to the server for reading the device properties 
 
 @param plugid The plug-id of the device.
 @param prop If NULL, then all properties value; otherwise the single property value.
 @param handler Callback function. If not NULL it will receive the Request and its Response
 @return \c TRUE if the request succeeds, \c FALSE otherwise.
 */
-(CloudPlugsRequest*) getDeviceProp:(NSString*) plugid
                 prop:(NSString*) prop
    completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler;

/**
 This function performs an HTTP request to the server for writing or deleting device properties
 
 @param plugid The plug-id of the device.
 @param prop If NULL, then value must be an object; otherwise the single property value is written.
 @param value A json value, use null to delete one or all device properties.
 @param handler Callback function. If not NULL it will receive the Request and its Response
 @return \c TRUE if the request succeeds, \c FALSE otherwise.
 */
-(CloudPlugsRequest*) setDeviceProp:(NSString*) plugid
                 prop:(NSString*) prop
                value:(id) value
    completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler;

/**
 This function performs an HTTP request to the server for deleting device property 
 
 @param plugid The plug-id of the device.
 @param prop The single property value to be remove.
 @param handler Callback function. If not NULL it will receive the Request and its Response
 @return \c TRUE if the request succeeds, \c FALSE otherwise.
 */
-(CloudPlugsRequest*) removeDeviceProp:(NSString*) plugid
                    prop:(NSString*) prop
       completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler;

/**
 This function performs an HTTP request to the server for modifying a device
 
 @param plugid The plug-id of the device.
 @param perm   : PERM_FILTER,	// optional, it contains just the sharing filters to modify
 @param name   : String,		// optional
 @param status : STATUS,		// optional
 @param props  : Object		// optional, it contains just the properties to modify
 @param handler Callback function. If not NULL it will receive the Request and its Response
 @return \c TRUE if the request succeeds, \c FALSE otherwise.
 */
-(CloudPlugsRequest*) setDevice:(NSString*) plugid
             perm:(NSDictionary*) perm
             name:(NSString*) name
           status:(NSString*) status
            props:(NSDictionary*) props
completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler;

/**
 This function performs an HTTP request to the server for removing any device (development, product or controller) 
 
 @param plugid The plug-ids csv of the device(s) to remove; if NULL then remove the device referenced in the session.
 @param handler Callback function. If not NULL it will receive the Request and its Response
 @return \c TRUE if the request succeeds, \c FALSE otherwise.
 */
-(CloudPlugsRequest*) unenroll:(id) plugid
completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler;

/**
 This function performs an HTTP request to the server for retrieving list channels/channels about already published data 
 
 @param channelMask The channel mask.
 @param before : TIMESTAMP || PLUG_ID, Optional, timestamp valid if greater than zero or OID of published data
 @param after  : TIMESTAMP || PLUG_ID, Optional, timestamp valid if greater than zero or OID of published data
 @param at     : TIMESTAMP_CSV || [TIMESTAMP,...], Optional, timestamp valid if greater than zero //TODO TIMESTAMP_CSV&?
 @param of     : "PLUG_ID_CSV" || ["PLUG_ID",...], Optional, plugid cvs
 @param offset : N
 @param limit  : N
 @param handler Callback function. If not NULL it will receive the Request and its Response
 @param handler Callback function. If not NULL it will receive the Request and its Response
 @return CP_SUCCESS if the request succeeds, CP_FAILED otherwise.
 */
-(CloudPlugsRequest*) getChannel:(NSString*) channelMask
            before:(id) before
             after:(id) after
                at:(id) at
                of:(id) of
            offset:(NSInteger) offset
             limit:(NSInteger) limit
 completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler;

/**
 This function performs an HTTP request to the server for retrieving already published data
 
 @param channelMask The channel mask.
 @param before: Optional, timestamp valid if greater than zero
 @param after: Optional, timestamp valid if greater than zero
 @param at: Optional, timestamp valid if greater than zero
 @param of: Optional, plugid cvs
 @param offset: Optional
 @param limit: Optional
 @param handler Callback function. If not NULL it will receive the Request and its Response
 @return \c TRUE if the request succeeds, \c FALSE otherwise.
 */
-(CloudPlugsRequest*) retrieveDataFrom:(NSString*)channelMask
                  before:(NSDate*) before
                   after:(NSDate*) after
                      at:(NSDate*) at
                      of:(id) of
                  offset:(NSInteger) offset
                   limit:(NSInteger) limit
       completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler;

/**
 This function performs an HTTP request to the server for publishing data
 
 @param channel A optional channel, if NULL data need to contain a couple "channel":"channel"
 @param body A json object or an array of objects like this:
 {	"id"        : “PLUG_ID”,
 "channel"     : “CHANNEL”,	// optional, to override the channel in the url
 "data"      : JSON,
 "at"        : TIMESTAMP,
 "of"        : "PLUG_ID",	// optional, check if the X-Plug-Id is authorized for setting this field
 "is_priv"   : BOOLean,	// optional, default false
 "expire_at" : TIMESTAMP,	// optional, expire date of this data entry
 "ttl"       : Number		// optional, how many *seconds* this data entry will live (if "expire_at" is present, then this field is ignored)
 }
 @param handler Callback function. If not NULL it will receive the Request and its Response
 @return \c TRUE if the request succeeds, \c FALSE otherwise.
 */
-(CloudPlugsRequest*) publishData:(NSString*) channel
               body:(id) body
  completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler;

/**
 This function performs an HTTP request to the server for deleting already published data
 
 @param channelMask The channel mask
 @param _id
 @param before
 @param after
 @param at
 @param of
 @param limit
 @param handler Callback function. If not NULL it will receive the Request and its Response
 @return \c TRUE if the request succeeds, \c FALSE otherwise.
 */
-(CloudPlugsRequest*) removeData:(NSString*) channelMask
            withId:(id) _id
            before:(id) before
             after:(id) after
                at:(id) at
                of:(id) of
             limit:(NSInteger) limit
 completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler;

/**
 This function performs an HTTP request to the server for writing or deleting device location
 
 @param plugid If not NULL, then the plug-id of the device, otherwise the device referenced in the session.
 @param longitude
 @param latitude
 @param altitude
 @param accuracy
 @param timestamp
 @param handler Callback function. If not NULL it will receive the Request and its Response 
 @return \c TRUE if the request succeeds, \c FALSE otherwise.
 */
-(CloudPlugsRequest*) setDeviceLocation:(NSString*) plugid
                longitude:(double) longitude
                 latitude:(double) latitude
                 altitude:(double) altitude
                 accuracy:(double) accuracy
                timestamp:(NSDate*) timestamp
        completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler;
/**
 This function performs an HTTP request to the server for writing or deleting device location
 
 @param plugid If not NULL, then the plug-id of the device, otherwise the device referenced in the session.
 @param handler Callback function. If not NULL it will receive the Request and its Response
 @return \c TRUE if the request succeeds, \c FALSE otherwise.
 */
-(CloudPlugsRequest*) getDeviceLocation:(NSString*) plugid
        completionHandler:(void (^)(CloudPlugsRequest*, CloudPlugsResponse*))handler;
@end
