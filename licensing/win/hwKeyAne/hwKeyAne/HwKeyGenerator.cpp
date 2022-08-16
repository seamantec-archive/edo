#include "HwKeyGenerator.h"
#include <comutil.h>
#include <iostream>
#include <string>
#include "conio.h"
#include "wincrypt.h"
#include <stdio.h>
#include <sstream>
using namespace std;
HwKeyGenerator::HwKeyGenerator(){
	pSvc = NULL;
	pLoc = NULL;
  
	initialized = true;
	setGeneralComsecurity();
	cout << "com sec ready" << endl;
	
}

HwKeyGenerator::~HwKeyGenerator(){
	pSvc->Release();
	pLoc->Release();
	CoUninitialize();
}





std::string HwKeyGenerator::getHwKey(){
	std::string returnString = hwKeyCache;

	if (!initialized){
		return "invalid hw key";
	}
	if (hwKeyCache == ""){
		string mainboardSerial = getMainBoardSerial();
		string logicalDiskSerial = getLogicalDiskSerial();
		//string networkMacAddress = getNetworkAdapterMacAddress();
		string memorySerial = getMemorySerialNumber();
		string mainboardHash = md5sum(mainboardSerial.c_str(), strlen(mainboardSerial.c_str()));
		string logicalDiskHash = md5sum(logicalDiskSerial.c_str(), strlen(logicalDiskSerial.c_str()));
		string memoryHash = md5sum(memorySerial.c_str(), strlen(memorySerial.c_str()));
		returnString = mainboardHash.substr(0, 4) + "-" + mainboardHash.substr(4, 4);
		returnString += "-" + logicalDiskHash.substr(0, 4);
		returnString += "-" + memoryHash.substr(0, 4);
		cout << mainboardHash << endl;
		cout << logicalDiskHash << endl;
		cout << memoryHash << endl;
		hwKeyCache = returnString;
	}

	return returnString;
}

string HwKeyGenerator::getMainBoardSerial(){
	std::string returnString = getItemFromWMI("Win32_BaseBoard", "SerialNumber");
	return returnString;
}

string HwKeyGenerator::getLogicalDiskSerial(){
	std::string returnString = getItemFromWMI("Win32_LogicalDisk", "VolumeSerialNumber");
	return returnString;
}


string HwKeyGenerator::getNetworkAdapterMacAddress(){
	std::string returnString = getItemFromWMI("Win32_NetworkAdapter", "MACAddress");
	return returnString;
}

string HwKeyGenerator::getMemorySerialNumber(){
	std::string returnString = getItemFromWMI("Win32_PhysicalMemory", "SerialNumber");
	return returnString;
}


std::wstring s2ws(const std::string& s)
{
	int len;
	int slength = (int)s.length() + 1;
	len = MultiByteToWideChar(CP_ACP, 0, s.c_str(), slength, 0, 0);
	wchar_t* buf = new wchar_t[len];
	MultiByteToWideChar(CP_ACP, 0, s.c_str(), slength, buf, len);
	std::wstring r(buf);
	delete[] buf;
	return r;
}
string HwKeyGenerator::getItemFromWMI(std::string table, std::string parameter){
	std::string returnString = "";
	IEnumWbemClassObject* pEnumerator = NULL;
	string queryString = "SELECT " + parameter + " FROM " + table;
	hres = pSvc->ExecQuery(
		bstr_t("WQL"),
		//bstr_t("SELECT * FROM Win32_LogicalDisk"), Win32_NetworkAdapter(MACAddress), Win32_PhysicalMemory(SerialNumber)

		bstr_t(queryString.c_str()),
		WBEM_FLAG_FORWARD_ONLY | WBEM_FLAG_RETURN_IMMEDIATELY,
		NULL,
		&pEnumerator);

	IWbemClassObject *pclsObj;
	ULONG uReturn = 0;

	while (pEnumerator)
	{
		HRESULT hr = pEnumerator->Next(WBEM_INFINITE, 1,
			&pclsObj, &uReturn);

		if (0 == uReturn)
		{
			break;
		}

		VARIANT vtProp;
		wstring tparameter = s2ws(parameter);
		hr = pclsObj->Get(tparameter.c_str(), 0, &vtProp, 0, 0);
		if (vtProp.bstrVal){
			try
			{
				if (vtProp.vt != 1){
					char *p;
					p = _com_util::ConvertBSTRToString(vtProp.bstrVal);

					returnString = string(p);
				}
				else{
					//cout << "An exception occured " << table << ":" << parameter << endl;
				}
			}
			catch (int e){
				//cout << "An exception occured";
			}

			VariantClear(&vtProp);
		}


		pclsObj->Release();
		if (returnString != ""){
			//cout << "value for " << table << ":" << parameter << ":" << returnString << endl;
			break;
		}
	}
	if (returnString == ""){
		//cout << "data not found for " << table << ":" << parameter << endl;
	}
	return returnString;
}









void HwKeyGenerator::setGeneralComsecurity(){
//	hres = CoInitializeSecurity(
//		NULL,
//		-1,                          // COM authentication
//		NULL,                        // Authentication services
//		NULL,                        // Reserved
//		RPC_C_AUTHN_LEVEL_DEFAULT,   // Default authentication 
//		RPC_C_IMP_LEVEL_IMPERSONATE, // Default Impersonation  
//		NULL,                        // Authentication info
//		EOAC_NONE,                   // Additional capabilities 
//		NULL                         // Reserved
//		);
//	if (FAILED(hres))
//	{
//		cout << "Failed to initialize security. Error code = 0x"
//			<< hex << hres << endl;
//		CoUninitialize();
//		initialized = false;                    // Program has failed.
//		return;
//	}


	//step3
	hres = CoCreateInstance(
		CLSID_WbemLocator,
		0,
		CLSCTX_INPROC_SERVER,
		IID_IWbemLocator, (LPVOID *)&pLoc);
	if (FAILED(hres))
	{
		cout << "Failed to create IWbemLocator object."
			<< " Err code = 0x"
			<< hex << hres << endl;
		CoUninitialize();
		initialized = false;                 // Program has failed.
		return;
	}


	// Step 4: -----------------------------------------------------
	// Connect to WMI through the IWbemLocator::ConnectServer method


	// Connect to the root\cimv2 namespace with
	// the current user and obtain pointer pSvc
	// to make IWbemServices calls.
	hres = pLoc->ConnectServer(
		_bstr_t(L"root\\cimv2"), // Object path of WMI namespace
		NULL,                    // User name. NULL = current user
		NULL,                    // User password. NULL = current
		0,                       // Locale. NULL indicates current
		WBEM_FLAG_CONNECT_USE_MAX_WAIT,                    // Security flags.
		0,                       // Authority (for example, Kerberos)
		0,                       // Context object 
		&pSvc                    // pointer to IWbemServices proxy
		);
	if (FAILED(hres))
	{
		cout << "Could not connect. Error code = 0x"
			<< hex << hres << endl;
		pLoc->Release();
		CoUninitialize();
		initialized = false;               // Program has failed.
		return;
	}

	// Step 5: --------------------------------------------------
	// Set security levels on the proxy -------------------------

	hres = CoSetProxyBlanket(
		pSvc,                        // Indicates the proxy to set
		RPC_C_AUTHN_WINNT,           // RPC_C_AUTHN_xxx
		RPC_C_AUTHZ_NONE,            // RPC_C_AUTHZ_xxx
		NULL,                        // Server principal name 
		RPC_C_AUTHN_LEVEL_CALL,      // RPC_C_AUTHN_LEVEL_xxx 
		RPC_C_IMP_LEVEL_IMPERSONATE, // RPC_C_IMP_LEVEL_xxx
		NULL,                        // client identity
		EOAC_NONE                    // proxy capabilities 
		);

	if (FAILED(hres))
	{
		cout << "Could not set proxy blanket. Error code = 0x"
			<< hex << hres << endl;
		pSvc->Release();
		pLoc->Release();
		CoUninitialize();
		initialized = false;             // Program has failed.
		return;
	}
}


