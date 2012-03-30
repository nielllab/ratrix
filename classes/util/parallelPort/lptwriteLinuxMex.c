/*
 * ppLinuxMex.c
 *
 * Compile in MATLAB with mex ppLinuxMex.c [-O] [-g] [-v]
 * For documentation see ppLinux.m
 *
 * following: http://as6edriver.sourceforge.net/Parallel-Port-Programming-HOWTO/accessing.html
 * http://people.redhat.com/twaugh/parport/html/parportguide.html
 *
 * Copyright (C) 2011 Erik Flister, University of Oregon, erik.flister@gmail.com
 * modified from lptwrite by Andreas Widmann
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "mex.h"

#include <sys/io.h>
#include <string.h>
#include <errno.h>

#include <math.h>

#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <sys/ioctl.h>
#include <linux/parport.h>
#include <linux/ppdev.h>

#define NUM_ADDRESS_COLS 2
#define NUM_DATA_COLS 3

#define NUM_REGISTERS 3
#define NUM_BITS 8

#define ADDR_BASE "/dev/parport"

#define DEBUG true
#define USE_PPDEV false

#define ECR_OFFSET 0x402

#define CONTROL_BIT_0 PARPORT_CONTROL_STROBE
#define CONTROL_BIT_1 PARPORT_CONTROL_AUTOFD
#define CONTROL_BIT_2 PARPORT_CONTROL_INIT
#define CONTROL_BIT_3 PARPORT_CONTROL_SELECT

#define STATUS_BIT_3 PARPORT_STATUS_ERROR
#define STATUS_BIT_4 PARPORT_STATUS_SELECT
#define STATUS_BIT_5 PARPORT_STATUS_PAPEROUT
#define STATUS_BIT_6 PARPORT_STATUS_ACK
#define STATUS_BIT_7 PARPORT_STATUS_BUSY

void doPort(const void *addr, const bool mask[][NUM_BITS], const bool vals[][NUM_BITS], const bool writing, const uint8_T *out, const int i) {
    unsigned char b;
    int result, size = sizeof(b);
    
    if DEBUG printf("size: %d\n",size);
    if (size != 1) mexErrMsgTxt("supplied value wasn't one byte");
    
    if USE_PPDEV {
        /*PPDEV doesn't require root, is supposed to be faster, and is address-space safe, but only available in later kernels >=2.4?*/
        /*however, i seem to need to sudo matlab in order to open eg /dev/parport0 */
        
        /* note our design here is not as intended -- we should really keep some persistant state of the port for future calls instead of acquiring and releasing it for every call */
        
        int parportfd = open(addr, O_RDWR);
        if (parportfd == -1) {
            printf("%s %s\n",addr,strerror(errno));
            mexErrMsgTxt("couldn't access port");
        }
        
        /*bug: if the following error out, we won't close parportfd or free addrStr -- need some exception like error handling */
        
        /* PPEXCL call succeeds, but causes following calls to fail!?!
         * then dmesg has: parport0: cannot grant exclusive access for device ppdev0
         *                 ppdev0: failed to register device!
         *
         * web search suggests this is because lp is loaded -- implications of removing it?
         */
        /*
         * result = ioctl(parportfd,PPEXCL);
         * if (result != 0) {
         * printf("ioctl PPEXCL: %d (%s)\n",result,strerror(errno));
         * mexErrMsgTxt("couldn't get exclusive access to pport");
         * }
         */
        
        result = ioctl(parportfd,PPCLAIM);
        if (result != 0) {
            printf("ioctl PPCLAIM: %d (%s)\n",result,strerror(errno));
            mexErrMsgTxt("couldn't claim pport");
        }
        
        int mode = IEEE1284_MODE_BYTE; /* or would we want COMPAT? */
        result = ioctl(parportfd,PPSETMODE,&mode);
        if (result != 0) {
            printf("ioctl PPSETMODE: %d (%s)\n",result,strerror(errno));
            mexErrMsgTxt("couldn't set byte mode");
        }
        
        result = ioctl(parportfd,PPWDATA,&b); /*PPWCONTROL(2),PPRCONTROL(2),PPRSTATUS(1),PPRDATA,PPDATADIR*/
        if (result != 0) {
            printf("ioctl PPWDATA: %d (%s)\n",result,strerror(errno));
            mexErrMsgTxt("couldn't write to pport");
        }
        
        result = ioctl(parportfd,PPRELEASE);
        if (result != 0) {
            printf("ioctl PPRELEASE: %d (%s)\n",result,strerror(errno));
            mexErrMsgTxt("couldn't release pport");
        }
        
        result = close(parportfd);
        if (result != 0) {
            printf("close: %d (%s)\n",result,strerror(errno));
            mexErrMsgTxt("couldn't close port");
        }
        
    } else {
        
        result = iopl(3); /* requires sudo, allows access to the entire address space with the associated risks.
         * required for ECR. safer alternative: ioperm */
        
        if (result != 0) {
            printf("iopl: %d (%s)\n",result,strerror(errno));
            mexErrMsgTxt("couldn't claim address space");
        }
        outb(b,*(uint64_T *)addr); /*requires >= -O2 compiler optimization to inline this macro from io.h*/
        
        printf("in: %d %d %d",inb(*(uint64_T *)addr),inb(*(uint64_T *)addr+1),inb(*(uint64_T *)addr+2));
        /* frob = (old & ~mask) | new; */
    }
    
if (!writing && out!=NULL) {
	out[2+i*NUM_REGISTERS]=31; /*find the bits in .m*/
}

    /*
mwIndex mxCalcSingleSubscript(const mxArray *pm, mwSize nsubs, mwIndex *subs)
     */
}

/*
 * ppLinuxMex([ports(:) addr(:)],[bitSpecs(:,1:2) vals(:)])
 */
void mexFunction(const int nlhs, const mxArray *plhs[], const int nrhs, const mxArray *prhs[])
{
    int numAddresses, numVals, i, j, result, addrStrLen;
    
    uint64_T *addresses;
    uint8_T *data,out;
    
    uint64_T address, port;
    uint8_T bitNum, regOffset, value;
    
    bool writing, mask[NUM_REGISTERS][NUM_BITS], vals[NUM_REGISTERS][NUM_BITS];
    
    char *addrStr;
    void *addr;
        
        numAddresses = mxGetM(prhs[0]);
    
    switch (nrhs) {
        case 1:
            writing = false;
            if (nlhs != 1) {
                mexErrMsgTxt("exactly 1 output argument required when reading.");
            }
            *plhs = mxCreateNumericMatrix(NUM_REGISTERS,numAddresses,mxUINT8_CLASS,mxREAL);
		out = mxGetData(plhs);
            break;
        case 2:
            writing = true;
            if (nlhs != 0) {
                mexErrMsgTxt("exactly 0 output arguments required when reading.");
            }
            if (mxGetN(prhs[1]) != NUM_DATA_COLS || !mxIsUint8(prhs[1])) {
                mexErrMsgTxt("Second argument must be uint8 with three columns (bitNum, regOffset, value).");
            }
            
            numVals = mxGetM(prhs[1]);
            data = mxGetData(prhs[1]);
            
            if DEBUG printf("\n\ndata:\n");
            
            for (i = 0; i < NUM_BITS; i++) {
                for (j = 0; j < NUM_REGISTERS; j++) {
                    mask[j][i] = false; /* is this necessary? */
                }
            }
            
            for (i = 0; i < numVals; i++) {
                bitNum    = data[i          ];
                regOffset = data[i+  numVals];
                value     = data[i+2*numVals];
                
                if DEBUG printf("\t%d, %d, %d\n", bitNum, regOffset, value);
                
                if (bitNum>8 || bitNum<1 || regOffset>2 || value>1) {
                    mexErrMsgTxt("bitNum must be 1-8, regOffset must be 0-2, value must be 0-1.");
                }
                
                mask[regOffset][bitNum] = true;
                vals[regOffset][bitNum] = value;
            }
            out = NULL;
            break;
        default:
            mexErrMsgTxt("exactly 1-2 input arguments required.");
            break;
    }
    
    for (i = 0; i < nrhs; i++) {
        if (mxGetNumberOfDimensions(prhs[i])!=2 || mxIsComplex(prhs[i]) || !mxIsNumeric(prhs[i]) || mxGetM(prhs[i])<1) {
            mexErrMsgTxt("Input must be real numeric matrices with at least one row.");
        }
    }
    
    if (mxGetN(prhs[0])!=NUM_ADDRESS_COLS || !mxIsUint64(prhs[0])) {
        mexErrMsgTxt("First argument must be uint64 two columns (portNum, address).");
    }
    
    addresses = mxGetData(prhs[0]);
    
    for (i = 0; i < numAddresses; i++) {
        port    = addresses[i];
        address = addresses[i+numAddresses];
        
        if DEBUG printf("addr %d: %" FMT64 "u, %" FMT64 "u\n", i, address, port);
        
        if USE_PPDEV {
            addrStrLen = strlen(ADDR_BASE) + (port == 0 ? 1 : 1 + floor(log10(port))); /* number digits in port */
            addrStr = (char *)mxMalloc(addrStrLen);
            if (addrStr==NULL) {
                mexErrMsgTxt("couldn't allocate addrStr");
            }
            
            result = snprintf(addrStr,addrStrLen+1,"%s%" FMT64 "u",ADDR_BASE,port); /* +1 for null terminator */
            if (result != addrStrLen) {
                printf("%d\t%d\t%s\n",result,addrStrLen,addrStr);
                mexErrMsgTxt("bad addrStr snprintf");
            }
            
            if DEBUG printf("%d\t%s.\n",addrStrLen,addrStr);
            
            addr = addrStr;
        } else {
            addr = &address;
        }
        
        doPort(addr,mask,vals,writing,out,i);
        
        if USE_PPDEV {
            mxFree(addrStr);
        }
    }
}