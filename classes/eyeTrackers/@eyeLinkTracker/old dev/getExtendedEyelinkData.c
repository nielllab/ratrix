/*=================================================================
based on <matlabroot>\extern\examples\mx\mxcreatestructarray.c 
     and <matlabroot>\extern\examples\refbook\phonebook.c
     and eyelinkToolbox:EyeCreateDataStructs.c:CreateMXFSample()
         (...\PsychSourceGL\Source\Common\Eyelink\EyelinkCreateDataStructs.c)
         (http://svn.berlios.de/wsvn/osxptb/beta/PsychSourceGL/Source/Common/Eyelink/EyelinkCreateDataStructs.c?op=file&rev=0&sc=0)
         (older code at http://psychtoolbox.org/eyelinktoolbox/downloads/EyelinkToolbox_C_code_1.4.sit)
 *=================================================================*/

/* compile with: 
    mex -v -I"C:\Program Files\SR Research\EyeLink\Includes\eyelink"  getExtendedEyelinkData.c "C:\Program Files\SR Research\EyeLink\libs\eyelink_core.lib" "C:\Program Files\SR Research\EyeLink\libs\eyelink_exptkit20.lib" "C:\Program Files\SR Research\EyeLink\libs\eyelink_w32_comp.lib"
    mex -v -I"C:\Program Files\SR Research\EyeLink\Includes\eyelink"  getExtendedEyelinkData.c eyelink_core.lib eyelink_exptkit20.lib eyelink_w32_comp.lib
    mex -v -I"C:\Program Files\SR Research\EyeLink\Includes\eyelink"  getExtendedEyelinkData.c "C:\Program Files\SR Research\EyeLink\libs\eyelink_core.lib" -DELCALLTYPE=__stdcall

     mex -v -I"C:\Program Files\Microsoft Visual Studio 8\VC\include" -I"C:\Program Files\SR Research\EyeLink\Includes\eyelink" -L"C:\Program Files\Microsoft Platform SDK for Windows Server 2003 R2\Lib" getExtendedEyelinkData.c "C:\Program Files\SR Research\EyeLink\libs\eyelink_core.lib" -DELCALLTYPE=__stdcall
 //need-I"C:\Program Files\Microsoft Visual Studio 8\VC\include" for "stddef.h"
 //install vsc++ express and win sdk from http://msdn.microsoft.com/vstudio/express/visualc/
 //follow all additional instructions (modifying some configuration files by hand -- ugh)
 //class is not on path, nor is mspdb80.dll
 //so add ";C:\Program Files\Microsoft Visual Studio 8\VC\bin;C:\Program Files\Microsoft Visual Studio 8\Common7\IDE" to end of path
 //-L"C:\Program Files\Microsoft Platform SDK for Windows Server 2003 R2\Lib" for the many windows libs in the default mexopts.bat
 
    maybe add:
        -L"C:\Program Files\SR Research\EyeLink\libs"
 */

/* to use this function, you must send the following commands to the tracker, otherwise results are unknown: 
    "link_sample_data  = LEFT,RIGHT,PUPIL,HREF,GAZE,GAZERES,AREA,STATUS,INPUT,HMARKER"
    "inputword_is_window = ON"

            sol simpson (10/06) says "HMARKER was originally for EL2 to hold the IR marker
            positions for head tracking [but is now used] to hold extended raw
            data for EL1000. INPUT is used to hold status of TTL lines on the
            host, but is used to hold window positon when inputword_is_window is
            set, which it must be to get the extended raw data."

            -LEFT and RIGHT are only doc'ed for events.  what does it mean for samples?
            -each part of an FSAMPLE from eyelink_newest_float_sample() has separate fields for x and y; each is a length 2 vector for left and right eye data
                the FSAMPLE_RAW from eyelink_get_extra_raw_values() is a length 2 vector for x and y, so no info on eye of origin.  why?
                    - from sol:
                            Since EL1000 is/was monocular we only send extended data for one eye, which
                            is the active eye specified by the tracker. 
 */

/* from sol simpson in 10/06:  undoc'ed funtion for getting raw data including corneal reflection
   declared in core_expt.h, but not commented
   note the true type is void
    
     s is a ptr to the structure of the sample you want to get the extended data
          for that you received by calling eyelink_get_float_data or such.
     rv is a ptr to the FSAMPLE_RAW extended data structure you want populated
          with the extended data.
    
int ELCALLTYPE eyelink_get_extra_raw_values(FSAMPLE *s,FSAMPLE_RAW *rv);
*/

/*
Suganthan Subramaniam <suganthan@sr-research.com> sent a beta sdk:
http://www.sr-research.com/download/EyeLinkDevKit_win32_1.5.1.104.exe

Sol Simpson <sol@sr-research.com> said to use the sdk at:
https://www.sr-support.com/forums/showthread.php?t=6
but then Suganthan sent the beta above, we're using the beta.
*/

/*from eyetypes.h (should be included with core_expt.h)*/
//#ifndef BYTEDEF
//    #define BYTEDEF 1
//        typedef unsigned char  byte;
//        typedef signed short   INT16;
//        typedef unsigned short UINT16;
//        /* VC++ 6.0 defines these types already. mingw32 also defines this*/
//    #if !(defined(_BASETSD_H_) || defined (_BASETSD_H))
//        typedef signed long    INT32;
//        typedef unsigned long  UINT32;
//    #endif
//#endif

#include "mex.h"
#include "core_expt.h"
//#include <math.h>
#include <string.h> //for memcpy

// defs from eye_data.h:
//        typedef union {
//                FEVENT    fe;
//                IMESSAGE  im;
//                IOEVENT   io;
//                FSAMPLE   fs;
//        } ALLF_DATA ;
        
//        typedef struct {
//                UINT32 	time;          	/*!< time of sample */
//                INT16  	type;           /*!< always SAMPLE_TYPE */
//                UINT16 	flags;         	/*!< flags to indicate contents */
//                float  	px[2];			/*!< pupil x */
//                float     py[2];  		/*!< pupil y */
//                float  	hx[2]; 			/*!< headref x */
//                float 	hy[2];    		/*!< headref y */
//                float  	pa[2];         	/*!< pupil size or area */
//                float  	gx[2];			/*!< screen gaze x */
//                float     gy[2];        	/*!< screen gaze y */
//                float 	rx;				/*!< screen pixels per degree */
//                float     ry;            	/*!< screen pixels per degree */
//                UINT16 	status;        	/*!< tracker status flags    */
//                UINT16 	input;        	/*!< extra (input word)      */
//                UINT16 	buttons;       	/*!< button state & changes  */
//                INT16  	htype;         	/*!< head-tracker data type (0=none)   */
//                INT16  	hdata[8];      	/*!< head-tracker data (not prescaled) */
//        } FSAMPLE;

/* 
typedef struct {
 float raw_pupil[2];        // raw x, y sensor position of the pupil
 float raw_cr[2];           // raw x, y sensor position of the cr
 UINT32 pupil_area;         // raw pupil area
 UINT32 cr_area;            // raw CR area
 UINT32 pupil_dimension[2]; // w,h of raw pupil
 UINT32 cr_dimension[2];    // w,h of raw cr
 UINT32 window_position[2]; // position of tracking window on sensor
 float pupil_cr[2];         // calculated pupil-cr from the raw_pupil and raw_cr fields
} FSAMPLE_RAW;
*/

typedef struct {
    char *name;
    int type;
    int arity;
} extendedData_s;

void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]){
    int mrows,ncols,eyeUsed,i;
    mxArray *fieldVal;
    void *tmp;
    char buf[100];
    const extendedData_s extendedData[] = {
                       {"time",     mxUINT32_CLASS, 1},
                       {"type",     mxINT16_CLASS,  1},
                       {"flags",    mxUINT16_CLASS, 1},
                       {"px",       mxDOUBLE_CLASS, 1},
                       {"py",       mxDOUBLE_CLASS, 1},
                       {"hx",       mxDOUBLE_CLASS, 1},
                       {"hy",       mxDOUBLE_CLASS, 1},
                       {"pa",       mxDOUBLE_CLASS, 1},
                       {"gx",       mxDOUBLE_CLASS, 1},
                       {"gy",       mxDOUBLE_CLASS, 1},
                       {"rx",       mxDOUBLE_CLASS, 1},
                       {"ry",       mxDOUBLE_CLASS, 1},
                       {"status",   mxUINT16_CLASS, 1},
                       {"input",    mxUINT16_CLASS, 1},
                       {"buttons",  mxUINT16_CLASS, 1},
                       {"htype",    mxINT16_CLASS,  1},
                       {"hdata",    mxINT16_CLASS,  8},
                                    //extended data
                       {"raw_pupil_x",          mxDOUBLE_CLASS, 1},
                       {"raw_pupil_y",          mxDOUBLE_CLASS, 1},
                       {"raw_cr_x",             mxDOUBLE_CLASS, 1},
                       {"raw_cr_y",             mxDOUBLE_CLASS, 1},
                       {"pupil_area",           mxUINT32_CLASS, 1},
                       {"cr_area",              mxUINT32_CLASS, 1},
                       {"pupil_dimension_w",	mxUINT32_CLASS, 1},
                       {"pupil_dimension_h",    mxUINT32_CLASS, 1},
                       {"cr_dimension_w",       mxUINT32_CLASS, 1},
                       {"cr_dimension_h",       mxUINT32_CLASS, 1},
                       {"window_position_x",	mxUINT32_CLASS, 1},
                       {"window_position_y",	mxUINT32_CLASS, 1},
                       {"pupil_cr_x",           mxDOUBLE_CLASS, 1},
                       {"pupil_cr_y",           mxDOUBLE_CLASS, 1}};
    const int numFields = sizeof(extendedData)/sizeof(*extendedData);
    ALLF_DATA evt;          // buffer to hold sample and event data
    FSAMPLE_RAW evt_raw;    // buffer for raw data  
    char **fieldNames;
    
    /* Check for proper input and  output arguments */    
    if (nrhs !=1) {
        mexErrMsgTxt("single input argument required: eye_used (int8) 0 or 1.");
    } else {
        mrows = mxGetM(prhs[0]);
        ncols = mxGetN(prhs[0]);
        //eyeUsed=round(mxGetScalar(prhs[0]));  //probably won't work, how get int8 value directly?
        eyeUsed=*((int *)(mxGetData(prhs[0])));  //kosher, even though prhs is likely int8?
        if (!(eyeUsed==1 || eyeUsed==0) || !mxIsInt8(prhs[0]) || !(mrows==1 && ncols==1)) {
                mexErrMsgTxt("eye_used input argument must be (int8) 0 or 1.");
        }
    }
    if(nlhs > 1){
        mexErrMsgTxt("Too many output arguments.");
    }
    
    /* Create a 1x1 struct matrix for output */
    fieldNames=mxCalloc(numFields, sizeof(char *));
    if(fieldNames==NULL){
        mexErrMsgTxt("couldn't allocate field name memory");
    }
    for(i=0;i<numFields;i++){
        fieldNames[i]=extendedData[i].name;
    }
    plhs[0] = mxCreateStructMatrix(1, 1, numFields, fieldNames); // gives warning "assignment of pointer to pointer to const char to pointer to pointer to char"
                                                                 // but sig has const: 
                                                                 //   mxArray *mxCreateStructMatrix(mwSize m, mwSize n, int nfields, const char **fieldnames);
    if (plhs[0]==NULL){
        mexErrMsgTxt("could not allocate struct");
    }
    mxFree(fieldNames);
     
     /* get data */
     if(eyelink_is_connected() && !check_recording()){
         if(eyelink_newest_float_sample(NULL)>=0){// check for new sample update
            eyelink_newest_float_sample(&evt);    // get a copy of the sample
            eyelink_get_extra_raw_values(&(evt.fs), &evt_raw);  // get raw data
         }else{
            mexErrMsgTxt("no sample available");
         }
     } else {
         mexErrMsgTxt("no eyelink connection or recording stopped");
     }
    
    /* Populate the fields*/ 
	/* mxcreatestructarray.c example sez use mxSetFieldByNumber() instead of mxSetField() for efficiency */
    /* field numbers guaranteed to be in order from 0, so mxGetFieldNumber() unnecerssary */
    for(i=0;i<numFields;i++){    
        fieldVal = mxCreateNumericMatrix(1/*rows*/,extendedData[i].arity/*cols*/, extendedData[i].type, mxREAL);
        if(fieldVal==NULL){
            sprintf(buf,"could not allocate %s", extendedData[i].name);
            mexErrMsgTxt(buf);
        }else{
            switch (i){
                // *((<fieldtype> *)(mxGetData(fieldVal))) = evt.fs.<field>; //works, but not as good, cuz have to pre-know fieldtype  

/* wanted to do the following:
   do the assignment to tmp below, then after the switch, call:
   memcpy(mxGetData(fieldVal), tmp, sizeof(*tmp)*extendedData[i].arity);  //hmm, can't sizeof() on the void

   would be nicer cuz don't have to repeat the name of the field to size it, 
   but the above sizeof doesn't work because *tmp is type void

                case 0:  tmp = &(evt.fs.time);                  break;
                case 1:  tmp = &(evt.fs.type);                  break;
                case 2:  tmp = &(evt.fs.flags);                 break;
                case 3:  tmp = &(evt.fs.px[eyeUsed]);           break;
                case 4:  tmp = &(evt.fs.py[eyeUsed]);           break;
                case 5:  tmp = &(evt.fs.hx[eyeUsed]);           break;
                case 6:  tmp = &(evt.fs.hy[eyeUsed]);           break;
                case 7:  tmp = &(evt.fs.pa[eyeUsed]);           break;
                case 8:  tmp = &(evt.fs.gx[eyeUsed]);           break;
                case 9:  tmp = &(evt.fs.gy[eyeUsed]);           break;
                case 10: tmp = &(evt.fs.rx);                    break;
                case 11: tmp = &(evt.fs.ry);                    break;
                case 12: tmp = &(evt.fs.status);                break;
                case 13: tmp = &(evt.fs.input);                 break;
                case 14: tmp = &(evt.fs.buttons);               break;
                case 15: tmp = &(evt.fs.htype);                 break;
                // this guy's different cuz he's the only array
                case 16: tmp =   evt.fs.hdata;                  break;
                // the rest is extended data
                case 17: tmp = &(evt_raw.raw_pupil[0]);         break;
                case 18: tmp = &(evt_raw.raw_pupil[1]);         break;
                case 19: tmp = &(evt_raw.raw_cr[0]);            break;
                case 20: tmp = &(evt_raw.raw_cr[1]);            break;
                case 21: tmp = &(evt_raw.pupil_area);           break;
                case 22: tmp = &(evt_raw.cr_area);              break;
                case 23: tmp = &(evt_raw.pupil_dimension[0]);	break;
                case 24: tmp = &(evt_raw.pupil_dimension[1]);	break;
                case 25: tmp = &(evt_raw.cr_dimension[0]);      break;
                case 26: tmp = &(evt_raw.cr_dimension[1]);      break;
                case 27: tmp = &(evt_raw.window_position[0]);	break;
                case 28: tmp = &(evt_raw.window_position[1]);	break;
                case 29: tmp = &(evt_raw.pupil_cr[0]);          break;
                case 30: tmp = &(evt_raw.pupil_cr[1]);          break;                 
*/
                
                case 0:  memcpy(mxGetData(fieldVal), &evt.fs.time,                  sizeof(evt.fs.time));                   break;
                case 1:  memcpy(mxGetData(fieldVal), &evt.fs.type,                  sizeof(evt.fs.type));                   break;
                case 2:  memcpy(mxGetData(fieldVal), &evt.fs.flags,                 sizeof(evt.fs.flags));                  break;
                case 3:  memcpy(mxGetData(fieldVal), &(evt.fs.px[eyeUsed]),         sizeof(evt.fs.px[eyeUsed]));            break;
                case 4:  memcpy(mxGetData(fieldVal), &(evt.fs.py[eyeUsed]),         sizeof(evt.fs.py[eyeUsed]));            break;
                case 5:  memcpy(mxGetData(fieldVal), &(evt.fs.hx[eyeUsed]),         sizeof(evt.fs.hx[eyeUsed]));            break;
                case 6:  memcpy(mxGetData(fieldVal), &(evt.fs.hy[eyeUsed]),         sizeof(evt.fs.hy[eyeUsed]));            break;
                case 7:  memcpy(mxGetData(fieldVal), &(evt.fs.pa[eyeUsed]),         sizeof(evt.fs.pa[eyeUsed]));            break;
                case 8:  memcpy(mxGetData(fieldVal), &(evt.fs.gx[eyeUsed]),         sizeof(evt.fs.gx[eyeUsed]));            break;
                case 9:  memcpy(mxGetData(fieldVal), &(evt.fs.gy[eyeUsed]),         sizeof(evt.fs.gy[eyeUsed]));            break;
                case 10: memcpy(mxGetData(fieldVal), &(evt.fs.rx),                  sizeof(evt.fs.rx));                     break;
                case 11: memcpy(mxGetData(fieldVal), &(evt.fs.ry),                  sizeof(evt.fs.ry));                     break;
                case 12: memcpy(mxGetData(fieldVal), &(evt.fs.status),              sizeof(evt.fs.status));                 break;
                case 13: memcpy(mxGetData(fieldVal), &(evt.fs.input),               sizeof(evt.fs.input));                  break;
                case 14: memcpy(mxGetData(fieldVal), &(evt.fs.buttons),             sizeof(evt.fs.buttons));                break;
                case 15: memcpy(mxGetData(fieldVal), &(evt.fs.htype),               sizeof(evt.fs.htype));                  break;
                // this guy's different cuz he's the only array
                case 16: memcpy(mxGetData(fieldVal),   evt.fs.hdata,        sizeof(*evt.fs.hdata)*extendedData[i].arity);   break;
                // the rest is extended data
                case 17: memcpy(mxGetData(fieldVal), &(evt_raw.raw_pupil[0]),       sizeof(evt_raw.raw_pupil[0]));          break;
                case 18: memcpy(mxGetData(fieldVal), &(evt_raw.raw_pupil[1]),       sizeof(evt_raw.raw_pupil[1]));          break;
                case 19: memcpy(mxGetData(fieldVal), &(evt_raw.raw_cr[0]),          sizeof(evt_raw.raw_cr[0]));             break;
                case 20: memcpy(mxGetData(fieldVal), &(evt_raw.raw_cr[1]),          sizeof(evt_raw.raw_cr[1]));             break;
                case 21: memcpy(mxGetData(fieldVal), &(evt_raw.pupil_area),         sizeof(evt_raw.pupil_area));            break;
                case 22: memcpy(mxGetData(fieldVal), &(evt_raw.cr_area),            sizeof(evt_raw.cr_area));               break;
                case 23: memcpy(mxGetData(fieldVal), &(evt_raw.pupil_dimension[0]), sizeof(evt_raw.pupil_dimension[0]));	break;
                case 24: memcpy(mxGetData(fieldVal), &(evt_raw.pupil_dimension[1]), sizeof(evt_raw.pupil_dimension[1]));	break;
                case 25: memcpy(mxGetData(fieldVal), &(evt_raw.cr_dimension[0]),    sizeof(evt_raw.cr_dimension[0]));       break;
                case 26: memcpy(mxGetData(fieldVal), &(evt_raw.cr_dimension[1]),    sizeof(evt_raw.cr_dimension[1]));       break;
                case 27: memcpy(mxGetData(fieldVal), &(evt_raw.window_position[0]), sizeof(evt_raw.window_position[0]));    break;
                case 28: memcpy(mxGetData(fieldVal), &(evt_raw.window_position[1]), sizeof(evt_raw.window_position[1]));    break;
                case 29: memcpy(mxGetData(fieldVal), &(evt_raw.pupil_cr[0]),        sizeof(evt_raw.pupil_cr[0]));           break;
                case 30: memcpy(mxGetData(fieldVal), &(evt_raw.pupil_cr[1]),        sizeof(evt_raw.pupil_cr[1]));           break;
                default: mexErrMsgTxt("bad numFields");                                                                     break;
            }
            mxSetFieldByNumber(plhs[0],0/*struct ind*/,i/*fieldNum*/,fieldVal);
        }
    }
}
