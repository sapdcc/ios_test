//
//  YakimbiTestTests.m
//  YakimbiTestTests
//
//  Created by Syed Arsalan Pervez on 2/16/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

#import "YakimbiTestTests.h"

@implementation YakimbiTestTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.

    _parser = [Parser new];
    [_parser setDelegate:self];
}

- (void)tearDown
{
    // Tear-down code here.
    
    SAFE_RELEASE(_parser);

    [super tearDown];
}

// ****************************************************
// Test Parser
// ****************************************************

- (void)testParser
{
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"]];
    if (!data)
    {
        STFail(@"Failed to load data.");
        return;
    }
    [_parser parseData:data];
}

- (void)parsingFinished:(Parser *)parser
{
    NSArray *users = [DBHandler fetchObjectsOfEntity:USER_TABLE];
    if ([users count] == 0)
        STFail(@"Database insertion failed.");
    if ([[[users objectAtIndex:0] folders] count] != 2)
        STFail(@"Database insertion failed.");
    if ([[[[[[users objectAtIndex:0] folders] allObjects] objectAtIndex:0] files] count] != 17 && [[[[[[users objectAtIndex:0] folders] allObjects] objectAtIndex:0] files] count] != 63)
        STFail(@"Database insertion failed.");
    if ([[[[[[users objectAtIndex:0] folders] allObjects] objectAtIndex:1] files] count] != 17 && [[[[[[users objectAtIndex:0] folders] allObjects] objectAtIndex:1] files] count] != 63)
        STFail(@"Database insertion failed.");
}

- (void)parsingFailed:(Parser *)parser withError:(NSError *)error
{
    STFail(@"%@", error);
}

// ****************************************************
// Test Byte Formatter
// ****************************************************

- (void)testByteFormatter
{
    int bytes = 100;
    if (![FORMAT_BYTES(bytes) isEqual:@"100 Bytes"])
        STFail(@"Check byte formatter.");bytes = 100;
    
    bytes = KB;
    if (![FORMAT_BYTES(bytes) isEqual:@"1.00 KB"])
        STFail(@"Check byte formatter as %@ != 1.00 KB", FORMAT_BYTES(bytes));

    bytes = MB;
    if (![FORMAT_BYTES(bytes) isEqual:@"1.00 MB"])
        STFail(@"Check byte formatter as %@ != 1.00 MB", FORMAT_BYTES(bytes));
    
    bytes = GB;
    if (![FORMAT_BYTES(bytes) isEqual:@"1.00 GB"])
        STFail(@"Check byte formatter as %@ != 1.00 GB", FORMAT_BYTES(bytes));
}

// ****************************************************
// Test HTTP Request
// ****************************************************

- (void)testHTTPRequest
{
    HTTPRequestOperation *operation = [HTTPRequestOperation requestWithURL:@"http://ww.google.com" andDelegate:self];
    [operation startSynchronously];
}

- (void)HTTPOperationFinished:(HTTPRequestOperation *)operation
{
    if ([operation responseData].length == 0)
    {
        STFail(@"Response data is empty.");
    }
    if ([operation tag] == 2)
    {
        NSArray *users = [DBHandler fetchObjectsOfEntity:USER_TABLE];
        if ([users count] == 0)
            STFail(@"Database insertion failed.");
        if ([[[users objectAtIndex:0] folders] count] != 2)
            STFail(@"Database insertion failed.");
        if ([[[[[[users objectAtIndex:0] folders] allObjects] objectAtIndex:0] files] count] != 17 && [[[[[[users objectAtIndex:0] folders] allObjects] objectAtIndex:0] files] count] != 63)
            STFail(@"Database insertion failed.");
        if ([[[[[[users objectAtIndex:0] folders] allObjects] objectAtIndex:1] files] count] != 17 && [[[[[[users objectAtIndex:0] folders] allObjects] objectAtIndex:1] files] count] != 63)
            STFail(@"Database insertion failed.");
    }
}

- (void)HTTPOperationFailed:(HTTPRequestOperation *)operation withError:(NSError *)error
{
    STFail(@"%@", [error description]);
}

// ****************************************************
// Test HTTP Request With Parser
// ****************************************************

- (void)testHTTPRequestWithParser
{
    HTTPRequestOperation *operation = [HTTPRequestOperation requestWithURL:SAMPLE_JSON_URL andDelegate:self];
    [operation registerParserClass:[Parser class]];
    [operation setTag:2];
    [operation startSynchronously];
}

@end
