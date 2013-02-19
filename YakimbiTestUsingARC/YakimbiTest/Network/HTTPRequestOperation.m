//
//  HTTPRequestOperation.m
//  YakimbiTest
//
//  Created by Syed Arsalan Pervez on 2/16/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

#import "HTTPRequestOperation.h"

@implementation HTTPRequestOperation

#pragma mark - Init Methods

- (id)initWithRequestURL:(id)requestURL
{
    self = [super init];
    if (self)
    {
        if ([requestURL isKindOfClass:[NSURL class]])
        {
            _requestURL = [requestURL copy];
        }
        else
            if ([requestURL isKindOfClass:[NSString class]])
            {
                _requestURL = [NSURL URLWithString:requestURL];
            }
    }
    return self;
}

+ (HTTPRequestOperation *)requestWithURL:(id)requestURL
{
    return [[HTTPRequestOperation alloc] initWithRequestURL:requestURL];
}

+ (HTTPRequestOperation *)requestWithURL:(id)requestURL andDelegate:(id<HTTPRequestOperationDelegate>)delegate
{
    HTTPRequestOperation *operation = [HTTPRequestOperation requestWithURL:requestURL];
    [operation setDelegate:delegate];
    return operation;
}

#pragma mark - Method To Execute Operation Either Synchronously or Asynchronously

- (void)startSynchronously
{
    [self start];
}

- (void)startAsynchronously
{
    [self performSelectorInBackground:@selector(start) withObject:nil];
}

#pragma mark - NSOperation Overridden Methods

- (void)start
{
    if ([self isExecuting])
        return;
    
    [self setIsCancelled:NO];
    [self setIsFailed:NO];
    [self setIsFinished:NO];
    
    if (!_requestURL)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Request URL is not specified." userInfo:nil];
    }
    else
    {
        if ([self isConcurrent])
        {
            [self main];
        }
        else
        {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Can't be started right now as it dependeds on another operation." userInfo:nil];
        }
    }
}

- (void)main
{
    _urlConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:_requestURL] delegate:self];
    
    if (!_urlConnection)
    {
        [self setIsExecuting:NO];
        [self setIsFailed:YES];
    }
    else
    {
        [self setIsExecuting:YES];
        [self HTTPOperationStarted];
    }
    
    while ([self isExecuting])
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
}

- (void)cancel
{
    if (_executing)
    {
        [_urlConnection cancel];
        
        [self setIsExecuting:NO];
        [self setIsCancelled:YES];
    }
}

- (BOOL)isFailed
{
    return _failed;
}

- (BOOL)isFinished
{
    return _finished;
}

- (BOOL)isCancelled
{
    return _cancelled;
}

- (BOOL)isExecuting
{
    return _executing;
}

- (BOOL)isConcurrent
{
    if ([[self dependencies] count] > 0)
    {
        for (HTTPRequestOperation *operation in [self dependencies])
        {
            if (!([operation isFinished] || [operation isCancelled] || [operation isFailed]))
            {
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self setIsExecuting:NO];
    [self setIsFailed:YES];
    [self HTTPOperationFailedWithError:error];
}

#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (!_parserClass)
    {
        [self setIsExecuting:NO];
        [self setIsFinished:YES];
        [self HTTPOperationFinished];
    }
    else
    {
        id object = [_parserClass new];
        if (object && [object conformsToProtocol:@protocol(ParserDelegate)])
        {
            [object setDelegate:self];
            [object parseData:_data inBackground:[NSThread isMainThread]];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _data = [NSMutableData new];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    return request;
}

#pragma mark - Setters

- (void)setIsFailed:(BOOL)failed
{
    [self willChangeValueForKey:@"isFailed"];
    _failed = failed;
    [self didChangeValueForKey:@"isFailed"];
}

- (void)setIsFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setIsExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setIsCancelled:(BOOL)cancelled
{
    [self willChangeValueForKey:@"isCancelled"];
    _cancelled = cancelled;
    [self didChangeValueForKey:@"isCancelled"];
}

- (void)setIsConcurrent:(BOOL)concurrent
{
    [self willChangeValueForKey:@"isConcurrent"];
    _concurrent = concurrent;
    [self didChangeValueForKey:@"isConcurrent"];
}

#pragma mark - HTTPOperationDelegate Methods

- (void)HTTPOperationStarted
{
    if (_delegate && [_delegate respondsToSelector:@selector(HTTPOperationStarted:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate performSelector:@selector(HTTPOperationStarted:) withObject:self];
        });
    }
}

- (void)HTTPOperationFinished
{
    if (_delegate && [_delegate respondsToSelector:@selector(HTTPOperationFinished:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate performSelector:@selector(HTTPOperationFinished:) withObject:self];
        });
    }
}

- (void)HTTPOperationFailedWithError:(NSError *)error
{
    if (_delegate && [_delegate respondsToSelector:@selector(HTTPOperationFailed:withError:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate performSelector:@selector(HTTPOperationFailed:withError:) withObject:self withObject:error];
        });
    }
}

#pragma mark - Getters

- (NSData *)responseData
{
    return _data ? [NSData dataWithData:_data] : nil;
}

- (NSString *)responseString
{
    return _data ? [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding] : nil;
}

#pragma mark - Parser

- (void)registerParserClass:(Class)class
{
    _parserClass = class;
}

#pragma mark - ParserDelegate Methods

- (void)parsingFinished:(Parser *)parser
{
    [self setIsExecuting:NO];
    [self setIsFinished:YES];
    [self HTTPOperationFinished];
}

- (void)parsingFailed:(Parser *)parser withError:(NSError *)error
{
    [self setIsExecuting:NO];
    [self setIsFailed:YES];
    [self HTTPOperationFailedWithError:error];
}

@end
