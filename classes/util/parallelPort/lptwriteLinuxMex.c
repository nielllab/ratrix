/*
 * lptwriteLinux.c
 *
 * Compile in MATLAB with mex lptwriteLinuxMex.c [-O] [-g] [-v]
 * For documentation see lptwriteLinux.m
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

#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <sys/ioctl.h>
#include <linux/parport.h>
#include <linux/ppdev.h>

#define NUM_ADDRESS_COLS 2
#define NUM_DATA_COLS 3

/*
 * lptwriteLinuxMex([ports(:) addr(:)],[bitSpecs(:,1:2) vals(:)])
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int numAddresses, numVals, i, result;
    
    uint64_T *addresses; /* mxUINT64_CLASS */
    uint8_T *data; /* mxUINT8_CLASS */
    
    uint64_T address, port;
    uint8_T bitNum, regOffset, value;
    
    /* Check for proper number of arguments. */
    if (nrhs != 2) {
        mexErrMsgTxt("Two input arguments required.");
    } else if (nlhs > 0) {
        mexErrMsgTxt("Too many output arguments.");
    }
    
    /* The input must be real numeric matrices with at least one row.*/
    for (i = 0; i < 2; i++) {        
        if (mxGetNumberOfDimensions(prhs[i])!=2 || mxIsComplex(prhs[i]) || !mxIsNumeric(prhs[i]) || mxGetM(prhs[i])<1) {
            mexErrMsgTxt("Input must be real numeric matrices with at least one row.");
        }
    }
    
    if (mxGetN(prhs[0])!=NUM_ADDRESS_COLS || !mxIsUint64(prhs[0])) {
        mexErrMsgTxt("First argument must be uint64 two columns (portNum, address).");
    }
    
    if (mxGetN(prhs[1])!=NUM_DATA_COLS || !mxIsUint8(prhs[1])) {
        mexErrMsgTxt("Second argument must be uint8 with three columns (bitNum, regOffset, value).");
    }    
    
    numAddresses = mxGetM(prhs[0]);
    numVals = mxGetM(prhs[1]);
    
    /* mxGetElementSize */
            
    /* Assign pointers to each input. */
    addresses = mxGetData(prhs[0]);
    data = mxGetData(prhs[1]);
    
    /*  */
    
    for (i = 0; i < numAddresses; i++) {
        port      = addresses[NUM_ADDRESS_COLS*i];
        address   = addresses[NUM_ADDRESS_COLS*i+1];
        bitNum    = data[NUM_DATA_COLS*i];
        regOffset = data[NUM_DATA_COLS*i+1];
        value     = data[NUM_DATA_COLS*i+2];
        
        if (bitNum>8 || binNum<1 || regOffset>2 || value>1) {
            mexErrMsgTxt("bitNum must be 1-8, regOffset must be 0-2, value must be 0-1.");
        }
        
        printf("addr %d: %d, %d\n", i, address, port);
        printf("\tdata: %d, %d, %d\n", bitNum, regOffset, value);
        printf("%s\n\n",sprintf("/dev/parport%d",address));
    }
}    

void tmp(int result)    
    /*PPDEV doesn't require root, is supposed to be faster, and is address-space safe, but only available in later kernels >=2.4?*/
    int parportfd = open("/dev/parport0", O_RDWR); /* check this agrees with port address argument? */
    if (parportfd == -1) mexErrMsgTxt("couldn't access /dev/parport0");
    
    result = ioctl(parportfd,PPEXCL);
    printf("ioctl PPEXCL: %d\n",result);
    if (result != 0) mexErrMsgTxt("couldn't get exclusive access to pport");
    
    result = ioctl(parportfd,PPCLAIM);
    printf("ioctl PPCLAIM: %d\n",result);
    /*  if (result != 0) mexErrMsgTxt("couldn't claim pport"); */
    
    int mode = IEEE1284_MODE_BYTE;
    result = ioctl(parportfd,PPSETMODE,&mode);
    printf("ioctl PPSETMODE: %d\n",result);
    if (result != 0) mexErrMsgTxt("couldn't set byte mode");
    
    int size = sizeof(*value);
    printf("size: %d\n",size);
    /*  if (size != 1) mexErrMsgTxt("supplied value wasn't one byte"); */
    
    /*  int bytes_written = write(parportfd,value,size);
    printf("bytes_written: %d\n",bytes_written);
    if (bytes_written != size) mexErrMsgTxt("written size not correct"); */
    
    result = ioctl(parportfd,PPWDATA,value);
    printf("ioctl PPWDATA: %d\n",result);
    /*  if (result != 0) mexErrMsgTxt("couldn't write to pport"); */
    
    result = ioctl(parportfd,PPRELEASE);
    printf("ioctl PPRELEASE: %d\n",result);
    /*  if (result != 0) mexErrMsgTxt("couldn't release pport"); */
    
    close(parportfd);
}

void tmp2(double *port, double*value, int result)
{
    /* Assign pointers to each input and output. */
    port = mxGetData(prhs[0]);
    value = mxGetData(prhs[1]); /* what ensures that this is only one byte?  why is it a double? */
    
    int size = sizeof(*value);
    printf("size: %d\n",size);
    /*  if (size != 1) mexErrMsgTxt("supplied value wasn't one byte"); */
    
    result = iopl(3); /* requires root access, allows access to the entire address space with the associated risks.
     * required for ECR. alternative: ioperm */
    printf("iopl: %d\n",result);
    if (result != 0) mexErrMsgTxt("couldn't claim address space");
    outb(*value,*port);
}