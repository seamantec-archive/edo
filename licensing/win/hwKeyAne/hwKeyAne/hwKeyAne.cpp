#include "hwKeyAne.h"
#define _WIN32_DCOM
#include <iostream>
#include <string>
using namespace std;
#include <comdef.h>
#include <Wbemidl.h>
#include "HwKeyGenerator.h"

#include <windows.h>
#include <tchar.h>
#include <strsafe.h>
#define MAX_THREADS 1
#define BUF_SIZE 255
std::string hwKeyString = "";

DWORD WINAPI hwCalculatorThread(LPVOID lpParam){
	::CoInitialize(NULL);
	HwKeyGenerator hwKeyGenerator;
	hwKeyString = hwKeyGenerator.getHwKey();
	return 0;
}



void setHwKeyString(){
	HANDLE Array_Of_Thread_Handles[1];
	int Data_Of_Thread_1 = 1;
	HANDLE Handle_Of_Thread_1 = 0;

	Handle_Of_Thread_1 = CreateThread(NULL, 0,
		hwCalculatorThread, &Data_Of_Thread_1, 0, NULL);

	if (Handle_Of_Thread_1 == NULL)
		ExitProcess(Data_Of_Thread_1);

	Array_Of_Thread_Handles[0] = Handle_Of_Thread_1;
	WaitForMultipleObjects(1,
		Array_Of_Thread_Handles, TRUE, INFINITE);
	CloseHandle(Handle_Of_Thread_1);
	while (hwKeyString == ""){

	}
}
extern "C"
{
	uint32_t isSupportedInOS = 1;
	FREContext _ctx;
	

	FREObject isSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{

		FREObject result;
		FRENewObjectFromBool(isSupportedInOS, &result);
		return result;
	}

	FREObject getHwKey(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
	{
		FREObject result;
		if (hwKeyString == ""){
			setHwKeyString();
		}
		
		FRENewObjectFromUTF8((uint32_t)strlen(hwKeyString.c_str()) + 1, (const uint8_t *)hwKeyString.c_str(), &result);
		return result;
	}

	void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions)
	{
		*numFunctions = 2;
		FRENamedFunction* func = (FRENamedFunction*)malloc(sizeof(FRENamedFunction)* (*numFunctions));

		func[0].name = (const uint8_t*) "isSupported";
		func[0].functionData = NULL;
		func[0].function = &isSupported;

		func[1].name = (const uint8_t*) "getHwKey";
		func[1].functionData = NULL;
		func[1].function = &getHwKey;

		*functions = func;
		_ctx = ctx;
	}

	void contextFinalizer(FREContext ctx)
	{
		//delete hwKeyGenerator;
		return;
	}

	void initializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer)
	{
		*ctxInitializer = &contextInitializer;
		*ctxFinalizer = &contextFinalizer;
	}

	void finalizer(void* extData)
	{
		FREContext nullCTX;
		nullCTX = 0;

		contextFinalizer(nullCTX);
		return;
	}
}