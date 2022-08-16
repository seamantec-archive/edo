//
//  main.m
//  hwKey
//
//  Created by Peter Varga on 2013.12.12..
//  Copyright (c) 2013 Péter Varga. All rights reserved.
//
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/network/IOEthernetInterface.h>
#include <IOKit/network/IONetworkInterface.h>
#include <IOKit/network/IOEthernetController.h>
#include <CommonCrypto/CommonDigest.h>

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
static kern_return_t FindEthernetInterfaces(io_iterator_t *matchingServices);
static kern_return_t GetMACAddress(io_iterator_t intfIterator, UInt8 *MACAddress, UInt8 bufferSize);

// Returns an iterator containing the primary (built-in) Ethernet interface. The caller is responsible for
// releasing the iterator after the caller is done with it.
static kern_return_t FindEthernetInterfaces(io_iterator_t *matchingServices)
{
    kern_return_t           kernResult;
    CFMutableDictionaryRef  matchingDict;
    CFMutableDictionaryRef  propertyMatchDict;
    matchingDict = IOServiceMatching(kIOEthernetInterfaceClass);
    if (NULL == matchingDict) {
        printf("IOServiceMatching returned a NULL dictionary.\n");
    }
    else {
             
        propertyMatchDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0,
                                                      &kCFTypeDictionaryKeyCallBacks,
                                                      &kCFTypeDictionaryValueCallBacks);
        
        if (NULL == propertyMatchDict) {
            printf("CFDictionaryCreateMutable returned a NULL dictionary.\n");
        }
        else {
            CFDictionarySetValue(propertyMatchDict, CFSTR(kIOPrimaryInterface), kCFBooleanTrue);
            CFDictionarySetValue(matchingDict, CFSTR(kIOPropertyMatchKey), propertyMatchDict);
            CFRelease(propertyMatchDict);
        }
    }
    kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, matchingServices);
    if (KERN_SUCCESS != kernResult) {
        printf("IOServiceGetMatchingServices returned 0x%08x\n", kernResult);
    }
    
    return kernResult;
}

// Given an iterator across a set of Ethernet interfaces, return the MAC address of the last one.
// If no interfaces are found the MAC address is set to an empty string.
// In this sample the iterator should contain just the primary interface.
static kern_return_t GetMACAddress(io_iterator_t intfIterator, UInt8 *MACAddress, UInt8 bufferSize)
{
    io_object_t     intfService;
    io_object_t     controllerService;
    kern_return_t   kernResult = KERN_FAILURE;
    
    // Make sure the caller provided enough buffer space. Protect against buffer overflow problems.
    if (bufferSize < kIOEthernetAddressSize) {
        return kernResult;
    }
    
    // Initialize the returned address
    bzero(MACAddress, bufferSize);
    
    // IOIteratorNext retains the returned object, so release it when we're done with it.
    while ((intfService = IOIteratorNext(intfIterator)))
    {
        CFTypeRef   MACAddressAsCFData;
        
        // IONetworkControllers can't be found directly by the IOServiceGetMatchingServices call,
        // since they are hardware nubs and do not participate in driver matching. In other words,
        // registerService() is never called on them. So we've found the IONetworkInterface and will
        // get its parent controller by asking for it specifically.
        
        // IORegistryEntryGetParentEntry retains the returned object, so release it when we're done with it.
        kernResult = IORegistryEntryGetParentEntry(intfService,
                                                   kIOServicePlane,
                                                   &controllerService);
        
        if (KERN_SUCCESS != kernResult) {
            printf("IORegistryEntryGetParentEntry returned 0x%08x\n", kernResult);
        }
        else {
            // Retrieve the MAC address property from the I/O Registry in the form of a CFData
            MACAddressAsCFData = IORegistryEntryCreateCFProperty(controllerService,
                                                                 CFSTR(kIOMACAddress),
                                                                 kCFAllocatorDefault,
                                                                 0);
            if (MACAddressAsCFData) {
                CFShow(MACAddressAsCFData); // for display purposes only; output goes to stderr
                
                // Get the raw bytes of the MAC address from the CFData
                CFDataGetBytes(MACAddressAsCFData, CFRangeMake(0, kIOEthernetAddressSize), MACAddress);
                CFRelease(MACAddressAsCFData);
            }
            
            // Done with the parent Ethernet controller object so we release it.
            (void) IOObjectRelease(controllerService);
        }
        
        // Done with the Ethernet interface object so we release it.
        (void) IOObjectRelease(intfService);
    }
    
    return kernResult;
}

NSString *md5HexDigest(char* str){
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

NSString *getUUID(){
    NSString *serialNumber = @"";
    io_service_t    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                                 IOServiceMatching("IOPlatformExpertDevice"));
    if (platformExpert) {
        CFTypeRef serialNumberAsCFString =
        IORegistryEntryCreateCFProperty(platformExpert,
                                        CFSTR(kIOPlatformSerialNumberKey),
                                        kCFAllocatorDefault, 0);
        
        CFTypeRef IOPlatformUUID =
        IORegistryEntryCreateCFProperty(platformExpert,
                                        CFSTR(kIOPlatformUUIDKey),
                                        kCFAllocatorDefault, 0);
        //kIOBootDeviceSizeKey
        CFTypeRef IOBootDeviceSizeKey =
        IORegistryEntryCreateCFProperty(platformExpert,
                                        CFSTR(kIOBootDeviceSizeKey),
                                        kCFAllocatorDefault, 0);

        serialNumber = (__bridge NSString*) serialNumberAsCFString;
    }

    
    return serialNumber;
}

NSString * md5( NSString *str )
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString
            stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1],
            result[2], result[3],
            result[4], result[5],
            result[6], result[7],
            result[8], result[9],
            result[10], result[11],
            result[12], result[13],
            result[14], result[15]
            ];
}
NSString *getMacAddress()
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
        else
        {
            // Get the size of the data available (store in len)
            if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
                errorFlag = @"sysctl mgmtInfoBase failure";
            else
            {
                // Alloc memory based on above call
                if ((msgBuffer = malloc(length)) == NULL)
                    errorFlag = @"buffer allocation failure";
                else
                {
                    // Get system information, store in buffer
                    if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                        errorFlag = @"sysctl msgBuffer failure";
                }
            }
        }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    NSLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}
void *macAddressChar(NSString *target){
    kern_return_t   kernResult = KERN_SUCCESS;
    io_iterator_t   intfIterator;
    unsigned char   MACAddress[kIOEthernetAddressSize];
    
    kernResult = FindEthernetInterfaces(&intfIterator);

    if (KERN_SUCCESS != kernResult) {
        printf("FindEthernetInterfaces returned 0x%08x\n", kernResult);
    }
    else {
        kernResult = GetMACAddress(intfIterator, MACAddress, sizeof(MACAddress));
        
        if (KERN_SUCCESS != kernResult) {
            printf("GetMACAddress returned 0x%08x\n", kernResult);
        }
        else {
            target = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                      MACAddress[0], MACAddress[1], MACAddress[2],
                      MACAddress[3], MACAddress[4], MACAddress[5]];
            NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                          MACAddress[0], MACAddress[1], MACAddress[2],
                                          MACAddress[3], MACAddress[4], MACAddress[5]];
            NSLog(@"Mac Address: %@", macAddressString);

        }
    }
    (void) IOObjectRelease(intfIterator);   // Release the iterator.
    return 0;
}
NSString *hwkey;
bool hasHwKey = false;
void setHwKey(){
    if(!hasHwKey){
        //char const *dash = "-";
        NSString *macAddress = getMacAddress();
        NSString *macMd5 = md5(macAddress);
        NSString *uuid = getUUID();
        NSString *uuidMd5 =  md5(uuid);
        NSString *macPart1 = [[uuidMd5 substringWithRange:NSMakeRange(0,4)] lowercaseString];
        NSString *macPart2 = [[uuidMd5 substringWithRange:NSMakeRange(4,4)] lowercaseString];
        NSString *uuidPart1 = [[uuidMd5 substringWithRange:NSMakeRange(8,4)] lowercaseString];
        NSString *uuidPart2 = [[uuidMd5 substringWithRange:NSMakeRange(12,4)] lowercaseString];
        hwkey =  [NSString stringWithFormat:@"%@-%@-%@-%@",macPart1,macPart2,uuidPart1,uuidPart2];
    }
 
}
int main(int argc, const char * argv[])
{
   
    
    
   //NSString *hello = doSha1(string);
    
    //SHA_CTX context;
    //SHA_Init(&context);
    //MD5_Update(&context, string, strlen(string));
    //MD5_Final(digest, &context);
    setHwKey();
        const char *allDatas = [hwkey UTF8String];
    printf(allDatas);
    printf("\n---------");
    
    return 0;
}

