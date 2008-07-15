
#ifndef __cvimport_h__
#define __cvimport_h__

#include "cvtypes.h"

#ifdef __cplusplus
extern "C" {
#endif

UINT8  DLLIMPORT CV_Startup (CV_VendorData_S *pVendorData);
UINT8  DLLIMPORT CV_GetRefreshRate (SINT32 *pRate);	//*** WUZ FLOAT32 ***
UINT8  DLLIMPORT CV_GetXYZ (UINT16 nFrames, SINT32 *pX, SINT32 *pY, SINT32 *pZ);	//*** WUZ FLOAT32 ***
UINT32 DLLIMPORT CV_GetDetailedError (UINT8 *systemError);
void   DLLIMPORT CV_Shutdown (void);
//UINT8  DLLIMPORT CV_ReadEEPROM (UINT16 address, UINT8* pByte);
//UINT8  DLLIMPORT CV_WriteEEPROM (UINT16 address, UINT8 byte);
//UINT8  DLLIMPORT CV_GetReadings (UINT32 duration, UINT32 *pCycles, UINT32 *pElapsed, UINT8 noTrigger);
//UINT8  DLLIMPORT CV_GetXYZEx (UINT16 nFrames, SINT32 *pX, SINT32 *pY, SINT32 *pZ, UINT8 doLevel2);	//*** WUZ FLOAT32 ***
//UINT8  DLLIMPORT CV_GetRawUnfiltered (UINT16 nFrames, UINT32 *pCycles);
UINT8  DLLIMPORT CV_UseCalibration ( UINT32 );

//UINT32   DLLIMPORT CV_GetXYZ_Start( UINT16, void* );
//UINT32 DLLIMPORT CV_GetXYZ_Values( SINT32*, SINT32*, SINT32*, UINT8* );

typedef UINT8 (DLLIMPORT* _CV_Startup)( CV_VendorData_S* );
typedef UINT8 (DLLIMPORT* _CV_GetRefreshRate)( SINT32* );	//*** WUZ FLOAT32 ***
typedef UINT8 (DLLIMPORT* _CV_GetXYZ)( UINT16, SINT32*, SINT32*, SINT32* );	//*** WUZ FLOAT32 ***
typedef UINT32 (DLLIMPORT* _CV_GetDetailedError)( UINT8* );
typedef void  (DLLIMPORT* _CV_Shutdown)( void );
//typedef UINT8 (DLLIMPORT* _CV_ReadEEPROM)( UINT16, UINT8* );
//typedef UINT8 (DLLIMPORT* _CV_WriteEEPROM)( UINT16, UINT8 );
//typedef UINT8 (DLLIMPORT* _CV_GetReadings)( UINT32, UINT32*, UINT32*, UINT8 );
//typedef UINT8 (DLLIMPORT* _CV_GetXYZEx)( UINT16, SINT32*, SINT32*, SINT32*, UINT8 );	//*** WUZ FLOAT32 ***
//typedef UINT8 (DLLIMPORT* _CV_GetRawUnfiltered)( UINT16, UINT32* );
//typedef UINT8 (DLLIMPORT* _CV_UseCalibration)( UINT32 );

//typedef UINT32 (DLLIMPORT* _CV_GetXYZ_Start)( UINT16, void* );
//typedef UINT32 (DLLIMPORT* _CV_GetXYZ_Values)( SINT32*, SINT32*, SINT32*, UINT8* );

#ifdef __cplusplus
}
#endif

#endif
