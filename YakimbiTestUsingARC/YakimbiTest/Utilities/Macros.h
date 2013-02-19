//
//  Macros.h
//  YakimbiTest
//
//  Created by Syed Arsalan Pervez on 2/16/13.
//  Copyright (c) 2013 SAPLogix. All rights reserved.
//

//******************************************************************************
// Logging
//******************************************************************************

#define IS_DEBUG 1

#define Log(fmt, ...) if (IS_DEBUG == 1) { NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }

//******************************************************************************
// Release & Set Pointer To Nil
//******************************************************************************

#define SAFE_RELEASE(a) if (a) { [a release]; a = nil; }

//******************************************************************************
// Device Detection
//******************************************************************************

#define DEVICE_iPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

//******************************************************************************
// Byte Formatting
//******************************************************************************

#define KB (1024)
#define MB (1024*1024)
#define GB (1024*1024*1024)

#define FORMAT_BYTES(bytes) bytes >= GB ? [NSString stringWithFormat:@"%.2f GB", (float)bytes/(float)GB] : \
bytes >= MB ? [NSString stringWithFormat:@"%.2f MB", (float)bytes/(float)MB] : \
bytes >= KB ? [NSString stringWithFormat:@"%.2f KB", (float)bytes/(float)KB] : \
[NSString stringWithFormat:@"%.0f Bytes", (float)bytes]
