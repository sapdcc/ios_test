//
//  HTTPRequestOperation.h
//  YakimbiTest
//
//  Created by Syed Arsalan Pervez on 2/16/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTTPRequestOperation;

@protocol HTTPRequestOperationDelegate <NSObject>

@optional

- (void)HTTPOperationStarted:(HTTPRequestOperation *)operation;

@required

- (void)HTTPOperationFinished:(HTTPRequestOperation *)operation;
- (void)HTTPOperationFailed:(HTTPRequestOperation *)operation withError:(NSError *)error;

@end

@interface HTTPRequestOperation : NSOperation <NSURLConnectionDelegate, NSURLConnectionDataDelegate, ParserResponseDelegate>
{
    int _tag;
    
    __weak id<HTTPRequestOperationDelegate> _delegate;
    
    BOOL _failed;
    BOOL _finished;
    BOOL _executing;
    BOOL _cancelled;
    BOOL _concurrent;
    
    NSURL *_requestURL;
    
    NSMutableData *_data;
    
    NSURLConnection *_urlConnection;
    
    Class _parserClass;
}

@property (nonatomic) int tag;
@property (weak, nonatomic) id<HTTPRequestOperationDelegate> delegate;
@property (readonly, nonatomic) NSURL *requestURL;

- (BOOL)isFailed;

- (void)startSynchronously;
- (void)startAsynchronously;

- (NSData *)responseData;
- (NSString *)responseString;

- (void)registerParserClass:(Class)class;

- (id)initWithRequestURL:(id)requestURL;
+ (HTTPRequestOperation *)requestWithURL:(id)requestURL;
+ (HTTPRequestOperation *)requestWithURL:(id)requestURL andDelegate:(id<HTTPRequestOperationDelegate>)delegate;

@end
