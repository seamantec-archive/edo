//
//  hwKeyAne.h
//  hwKeyAne
//
//  Created by Peter Varga on 2013.12.14..
//  Copyright (c) 2013 Péter Varga. All rights reserved.
//
/*
#ifndef hwKeyAne_hwKeyAne_h
#define hwKeyAne_hwKeyAne_h

#define EXPORT __attribute__((visibility("default")))


FREObject isSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject getHwKey(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions);
void contextFinalizer(FREContext ctx);
void macAddressChar(char *target);
EXPORT
NSString *getUUID();
EXPORT
NSString *md5HexDigest(char* str);
EXPORT
void initializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);

EXPORT
void finalizer(void* extData);

#endif
 
 */
#define EXPORT __attribute__((visibility("default")))

#include <Adobe AIR/Adobe AIR.h>

EXPORT
FREObject getHwKey(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

FREObject isSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject getHwKey(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions);
void contextFinalizer(FREContext ctx);
void macAddressChar(char *target);