
#ifndef __cvtypes_h__
#define __cvtypes_h__

#ifdef __cplusplus
extern "C" {
#endif

/*
// Define types
*/ 

#ifdef __MACOS__
typedef unsigned char UINT8;
typedef unsigned short UINT16;
typedef unsigned long UINT32; 
typedef signed long SINT32; 
typedef float FLOAT32;
#define DLLEXPORT 
#define DLLIMPORT
#define BAD_HANDLE (UINT32)0
#define Sleep(a)
#endif

#ifdef _WIN32
#include "windows.h"

typedef unsigned char UINT8;
typedef unsigned short UINT16;
typedef unsigned long UINT32; 
typedef signed long SINT32; 
typedef float FLOAT32;

//DAG 010501
//change to using .DEF file for more control, use _stdcall for VB compatibility
//#define DLLEXPORT __declspec(dllexport)
//#define DLLIMPORT __declspec(dllimport)

#define DLLEXPORT __stdcall
#define DLLIMPORT __stdcall

#define BAD_HANDLE (UINT32)INVALID_HANDLE_VALUE
#endif

/*
// Define Error Codes
*/
#define CV_STATUS_SUCCESS                   ((UINT8)0x01)
#define CV_STATUS_FAILURE                   ((UINT8)0x00)

#define CV_ERROR_API                        ((UINT8)0x00)
#define CV_ERROR_SYSTEM                     ((UINT8)0x01)

#define CV_ERROR_NOT_INITIALIZED		  	((UINT32)0x00010001)
#define CV_ERROR_INVALID_PARAMETER			((UINT32)0x00010002)
#define CV_ERROR_REFRESH_UNDETERMINED		((UINT32)0x00010003)
#define CV_ERROR_TRANSMISSION_ERROR   		((UINT32)0x00010004)
#define CV_ERROR_XLNX_NOT_CONFIGURED    	((UINT32)0x00010005)
#define CV_ERROR_TIMEOUT			    	((UINT32)0x00010006)
#define CV_LAST_FATAL_ERROR                 ((UINT32)0x0001FFFF)

#define CV_WARNING_ALREADY_INITIALIZED		((UINT32)0x00020001)
#define CV_WARNING_TRIGGER_TIMEOUT			((UINT32)0x00020002)
#define CV_WARNING_OVERALL_TIMEOUT			((UINT32)0x00020003)
#define CV_WARNING_APPARENTLY_NOT_CRT		((UINT32)0x00020004)
#define CV_WARNING_NO_CRT_CALIBRATION		((UINT32)0x00020005)
#define CV_WARNING_NO_LCD_CALIBRATION		((UINT32)0x00020006)
#define CV_WARNING_NO_TOK_CALIBRATION		((UINT32)0x00020007)

#define CV_XILINX_CONFIGURED           0x00
#define CV_XILINX_READY_FOR_DOWNLOAD   0x01
#define CV_XILINX_UNCONFIGURED         0x02
#define CV_XILINX_QUERY_ERROR          0x03

/*
// Define external use structures, function headers and globals
*/ 
#define CV_SERIAL_NUMBER_LEN 8
typedef struct {
    UINT16 DriverVersion;
    UINT16 HardwareVersion;
	UINT8  SerialNumber[CV_SERIAL_NUMBER_LEN];
} CV_VendorData_S;


#ifdef __cplusplus
}
#endif

#endif
