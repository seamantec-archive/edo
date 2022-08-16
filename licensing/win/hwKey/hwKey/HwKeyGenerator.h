#define _WIN32_DCOM
#include <Windows.h>
#include <iostream>
#include <comdef.h>
#include <Wbemidl.h>
#include "md5.hh"
# pragma comment(lib, "wbemuuid.lib")


class HwKeyGenerator{
	HRESULT hres;
	bool initialized;
	IWbemServices *pSvc = NULL;
	IWbemLocator *pLoc = NULL;

public:
	HwKeyGenerator();
	~HwKeyGenerator();
	std::string getHwKey();
private:
	void setGeneralComsecurity();
	std::string getMainBoardSerial();
	std::string getLogicalDiskSerial();
	std::string getNetworkAdapterMacAddress();
	std::string getMemorySerialNumber();
	std::string getItemFromWMI(std::string table, std::string parameter);

};


