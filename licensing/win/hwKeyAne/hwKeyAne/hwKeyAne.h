#include "FlashRuntimeExtensions.h"
#include <iostream>
#include <string>
extern "C"
{
	__declspec(dllexport) void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions);
	__declspec(dllexport) void initializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);

	__declspec(dllexport) void finalizer(void* extData);
	__declspec(dllexport) FREObject isSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	__declspec(dllexport) FREObject getHwKey(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	//__declspec(dllexport) std::string getHwKeyString();
}
