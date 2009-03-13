


%Calibrate.m
function out=calibrate()

screenNumber=1;
%choose calibration method:  allThree is better
type='allThree';  %'gray' or 'allThree'

try

    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=(white+black)/2;
    background=black;
    [w screenRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);
        %window=screen(screenNumber,'OpenWindow',0, [],8);
    priorityLevel=MaxPriority(w);
    %screen(w, 'SetClut', blank)    
    
    %setup params
    params.sizescreen=[40 29]; %width height (cm)
    params.viewdist=57; % viewer distance (cm)
    params.screenpix=[1024,768]; %pixel resolution
    params.degperpix=180/pi*mean(atan((params.sizescreen./params.screenpix)./params.viewdist));
    params.pixperdeg=1./params.degperpix;
    
    %stim params
    params.numStimFrames=5;        %for each gray value
    params.numIntertrialFrames=1;  %of background color in between each stim frame
    params.sizeSquarePix=256; %size of calibration square in pixels
    %params.sizeSquareDeg=4; %size of calibration square in degrees.
    params.side=0; %left (=0) or right (=1) 
    params.eccentricity=7; %ecc of center of calibration square in degrees
    params.verticalOffset=-4; %offset of center of calibration square in degrees

    %params.cpd=3;           %spatial frequency in cpd
    params.ppc=2;           %pix per cycle
    
    %create clut
    LUTBitDepth=8; 
    numColors=2^LUTBitDepth; maxColorID=numColors-1; fraction=1/(maxColorID);
    ramp=[0:fraction:1];
    rawCLUT=[ramp;ramp;ramp]';
    oldclut = Screen('LoadNormalizedGammaTable', w, rawCLUT,1);
    
    %create color sweeps
    bitDepth=6; 
    numColors=2^bitDepth; maxColorID=numColors-1; fraction=1/(maxColorID); 
    ramp=[0:fraction:1]; nada=zeros(1, 2^bitDepth);
    grayColors= [ramp;ramp;ramp]';
    redColors=  [ramp;nada;nada]';
    greenColors=[nada;ramp;nada]';
    blueColors= [nada;nada;ramp]';
    %ramp will also be used for the gammaCalculation
    
    %sz=round(params.sizeSquareDeg*params.pixperdeg);
    sz=params.sizeSquarePix;
    solid=ones(sz,sz);

    phase=0;
    waveform='square';
    grating=makeGrating(sz,params.ppc,phase,waveform);
    
	%spatial parameters
    ctrScreen=round(params.screenpix/2);
    ecc=((params.side*2)-1)*params.eccentricity*params.pixperdeg;
    offset=-params.verticalOffset*params.pixperdeg;
    vals=CenterRect([0 0 sz sz],[0 0 size(params.screenpix)]);
    patchRect=round([ctrScreen ctrScreen] + [ecc offset ecc offset] + vals)
    leftFlankRect= patchRect+ [-sz 0 -sz 0]; 
    rightFlankRect=patchRect+ [ sz 0  sz 0];  
    aboveFlankRect=patchRect+ [0 -sz 0 -sz];
    belowFlankRect=patchRect+ [0  sz 0  sz];
    distractorRect=round([ctrScreen ctrScreen] + [-ecc offset -ecc offset] + vals);

    Priority(priorityLevel);
    
    %calibrate
    linearizedRange=[0.05 0.8];
    bitDepthSent=4;
    LUTBitDepth=8;
    [g linearityError linearizedCLUT]=calibrateAndVerify(type,linearizedRange,bitDepthSent,LUTBitDepth,params.numStimFrames,params.numIntertrialFrames,grayColors,w,patchRect,black);
    
    doTests1=0;
    doTests2=0;
    
    if doTests1
        
        %find RF with linearity of optics assumption
        pixSz=16;
        GridSz=16;
        numIntertrialFrames=1;   
        colorIDs=[1 1 1];
        pulseSparseSequence(pixSz,GridSz,patchRect,params.numStimFrames,numIntertrialFrames,colorIDs,'sweepInOrder',black,gray,w);
        
        %%findStrongRespondingPixelsInRF
        %%roughly gaussian in center of 16 x 16 grid
        %%deviceRF is roughly 12*16=192 pixels tall, 11.5*16=184 pixels wide
        %%(zero response outside this window)
        %%manually done by inspecting spike2 trace
        targetPixelID=120;
        flankerPixIDs=[104,136,121,119]   % [left, right, up, down]
        targetColorIDs=[1 1 1];
        flankerColorIDs=[1 1 1];
        
        testLinearityOfPixels(targetPixelID,flankerPixIDs,pixSz,GridSz,patchRect,params.numStimFrames,numIntertrialFrames,targetColorIDs,flankerColorIDs,black,gray,w,1);
        
% %                  %target flanker both
% %         response=[0.0088,0.0076,0.0171; ...
% %                   0.0087,0.0081,0.0177; ...
% %                   0.0088,0.0072,0.0162; ...
% %                   0.0088,0.0087,0.0176];
%               
% % %         nonLinearity =
% % %                    -0.0409 %left
% % %                    -0.0508 %right
% % %                    -0.0123 %up
% % %                    -0.0057 %down

        %SWEEP PHASES
        colorIDs=[1 1 1];
        numStimFrames=1;
        numIntertrialFrames=1;      
        numFrames=100;
        ppc=params.ppc;
        numPausedFrames=10;
         
        for i=1:numFrames  
            phase=2*pi*(mod(i,ppc)/ppc);
            grating=makeGrating(sz,ppc,phase,waveform);
            targetIm=grating'; flankIm=grating; flankRect=leftFlankRect; %we know target horizontal is brighter
            sweepThroughContrasts(targetIm,sz,numStimFrames,numIntertrialFrames,colorIDs,w,patchRect,gray)
        end
        pauseMeanScreen(numPausedFrames,gray,w)
        
        for i=1:numFrames  %
            phase=2*pi*(mod(i,ppc)/ppc);
            grating=makeGrating(sz,ppc,phase,waveform);
            targetIm=grating; flankIm=grating; flankRect=leftFlankRect;  %switch target to vertical
            sweepThroughContrasts(targetIm,sz,numStimFrames,numIntertrialFrames,colorIDs,w,patchRect,gray)
        end
        pauseMeanScreen(numPausedFrames,gray,w)
        
        
        %TEST LINEARITY OF GRATINGS
        targetParams.colorIDs=[1 1 1];
        numStimFrames=5;
        targetParams.isHorizontal=[0 1];
        targetParams.phase=[0];
        targetParams.ppc=params.ppc;
        targetParams.waveform='square';
        targetParams.patchRect=patchRect;
        
        flankerParams.isHorizontal=[0 1];
        flankerParams.patchRect=[leftFlankRect;rightFlankRect;aboveFlankRect;belowFlankRect];
        flankerParams.colorIDs=[0 0 1];
        %all other target parameters same as target
        
        [nonLinearity response]=testLinearityOfGratings(targetParams,flankerParams,numStimFrames,numIntertrialFrames,gray,gray,w,1);
        
        %testInfluenceOfBigPatchOnPixels
        
    end
    
    if doTests2
        
        params.numStimFrames=1;
        
        %test on raw uncorrect
        colorIDs=grayColors;
        junkclut = Screen('LoadNormalizedGammaTable', w, rawCLUT,1);
        batteryOfSweeps(solid,grating,rightFlankRect,aboveFlankRect,sz,params.numStimFrames,params.numIntertrialFrames,colorIDs,w,patchRect,black,gray);

        %test on linearized
        junkclut = Screen('LoadNormalizedGammaTable', w, linearizedCLUT,1);
        batteryOfSweeps(solid,grating,rightFlankRect,aboveFlankRect,sz,params.numStimFrames,params.numIntertrialFrames,colorIDs,w,patchRect,black,gray);
        
        %confirm all channels the same on basic effect
        colorIDs=blueColors;
        batteryOfSweeps(solid,grating,rightFlankRect,aboveFlankRect,sz,params.numStimFrames,params.numIntertrialFrames,colorIDs,w,patchRect,black,gray);
        colorIDs=greenColors;
        batteryOfSweeps(solid,grating,rightFlankRect,aboveFlankRect,sz,params.numStimFrames,params.numIntertrialFrames,colorIDs,w,patchRect,black,gray);
        colorIDs=redColors;
        batteryOfSweeps(solid,grating,rightFlankRect,aboveFlankRect,sz,params.numStimFrames,params.numIntertrialFrames,colorIDs,w,patchRect,black,gray);
        
        %see the influence of Spatial Freq; based on videobandwidth
        colorIDs=grayColors;
        ppc=params.ppc;
        numFreqHalvings=3;
        for i=1:numFreqHalvings
            phase=0;
            grating=makeGrating(sz,ppc,phase,waveform);
            targetIm=grating'; flankIm=grating; flankRect=leftFlankRect;
            sweepThroughContrasts(targetIm,sz,params.numStimFrames,params.numIntertrialFrames,colorIDs,w,patchRect,black,flankIm,flankRect)
            targetIm=grating;  flankIm=grating; flankRect=leftFlankRect;
            sweepThroughContrasts(targetIm,sz,params.numStimFrames,params.numIntertrialFrames,colorIDs,w,patchRect,black,flankIm,flankRect)
            ppc=ppc*2;
        end



    end
    
    
    Priority(0);
    Screen('closeAll')
    out='done';
catch ex 
   disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
   Screen('CloseAll');
   Priority(0)
   rethrow(ex);
   out='used catch';
end

end % function



function [g linearityError linearizedCLUT oldCLUT]=calibrateAndVerify(type,linearizedRange,bitDepthSent,LUTBitDepth,numStimFrames,numIntertrialFrames,grayColors,w,patchRect,background)

    numColors=2^bitDepthSent; maxColorID=numColors-1; fraction=1/(maxColorID); 
    ramp=[0:fraction:1]; nada=zeros(1, 2^bitDepthSent);
    grayColors= [ramp;ramp;ramp]';
    redColors=  [ramp;nada;nada]';
    greenColors=[nada;ramp;nada]';
    blueColors= [nada;nada;ramp]';
    sent=ramp;
    
    sz=patchRect(3)-patchRect(1);
    solid=ones(sz,sz);
    switch type
        case 'loadDefault'

            %sample from lower left of triniton, gray values, pmm 070105
            %sent=    [ 0      16     32     48     64     80     96     112    128    144    160   176   192   208   224   240  ];
            %measured=[ 0.0032 0.0035 0.0039 0.0048 0.0064 0.0087 0.0117 0.0157 0.0208 0.0262 0.033 0.042 0.050 0.060 0.072 0.084];
            %[linearizedCLUT g]=fitGamma(sent, measured, linearizedRange, 2^LUTBitDepth,1);
            %linearizedCLUT=repmat(linearizedCLUT',1,3);

            %sample from lower left of triniton, pmm 070106
            sent=       [0      0.0667    0.1333    0.2000    0.2667    0.3333    0.4000    0.4667    0.5333  0.6000    0.6667    0.7333    0.8000    0.8667    0.9333    1.0000];
            measured_R= [0.0052 0.0058    0.0068    0.0089    0.0121    0.0167    0.0228    0.0304    0.0398  0.0510    0.065     0.080     0.097     0.117     0.139     0.1645];       
            measured_G= [0.0052 0.0053    0.0057    0.0067    0.0085    0.0113    0.0154    0.0208    0.0278  0.036     0.046     0.059     0.073     0.089     0.107     0.128 ];
            measured_B= [0.0052 0.0055    0.0065    0.0077    0.0102    0.0137    0.0185    0.0246    0.0325  0.042     0.053     0.065     0.081     0.098     0.116     0.138];  
  
            linearizedCLUT=zeros(2^LUTBitDepth,3);
            subplot([311]); [linearizedCLUT(:,1) g.R]=fitGamma(sent, measured_R, linearizedRange, 2^LUTBitDepth,1);
            subplot([312]);[linearizedCLUT(:,2) g.G]=fitGamma(sent, measured_G, linearizedRange, 2^LUTBitDepth,1);
            subplot([313]);[linearizedCLUT(:,3) g.B]=fitGamma(sent, measured_B, linearizedRange, 2^LUTBitDepth,1);

            oldCLUT = Screen('LoadNormalizedGammaTable', w, linearizedCLUT,1);

        case 'gray'  %not used anymore
            %sweep through gray values with an image patch
            sweepThroughContrasts(solid,sz,numStimFrames,params.numIntertrialFrames,grayColors,w,patchRect,background);
        case 'allThree'

            %sweep through color values with an image patch
            sweepThroughContrasts(solid,sz,numStimFrames,numIntertrialFrames,redColors,  w,patchRect,background)
            sweepThroughContrasts(solid,sz,numStimFrames,numIntertrialFrames,greenColors,w,patchRect,background)
            sweepThroughContrasts(solid,sz,numStimFrames,numIntertrialFrames,blueColors, w,patchRect,background)

            %measure values and enter them here
            
            %sample from lower left of triniton, pmm 070106
            sent=       [0      0.0667    0.1333    0.2000    0.2667    0.3333    0.4000    0.4667    0.5333  0.6000    0.6667    0.7333    0.8000    0.8667    0.9333    1.0000];
            measured_R= [0.0052 0.0058    0.0068    0.0089    0.0121    0.0167    0.0228    0.0304    0.0398  0.0510    0.065     0.080     0.097     0.117     0.139     0.1645];       
            measured_G= [0.0052 0.0053    0.0057    0.0067    0.0085    0.0113    0.0154    0.0208    0.0278  0.036     0.046     0.059     0.073     0.089     0.107     0.128 ];
            measured_B= [0.0052 0.0055    0.0065    0.0077    0.0102    0.0137    0.0185    0.0246    0.0325  0.042     0.053     0.065     0.081     0.098     0.116     0.138];  

            linearizedCLUT=zeros(2^LUTBitDepth,3);
            [linearizedCLUT(:,1) g.R]=fitGamma(sent, measured_R, linearizedRange, 2^LUTBitDepth,1);
            [linearizedCLUT(:,2) g.G]=fitGamma(sent, measured_G, linearizedRange, 2^LUTBitDepth,1);
            [linearizedCLUT(:,3) g.B]=fitGamma(sent, measured_B, linearizedRange, 2^LUTBitDepth,1);

            oldCLUT = Screen('LoadNormalizedGammaTable', w, linearizedCLUT,1);

            sweepThroughContrasts(solid,sz,numStimFrames,numIntertrialFrames,redColors,  w,patchRect,background)
            sweepThroughContrasts(solid,sz,numStimFrames,numIntertrialFrames,greenColors,w,patchRect,background)
            sweepThroughContrasts(solid,sz,numStimFrames,numIntertrialFrames,blueColors, w,patchRect,background)

            sweepThroughContrasts(solid,sz,numStimFrames,numIntertrialFrames,grayColors,w,patchRect,background); 

            
    end

    %run an RMS error for linearity (fit a line)
    linearityError=[];
    
end



function sweepThroughContrasts(im,sz,numStimFrames,numIntertrialFrames,colorIDs,w,patchRect,background,flankIm,flankRect)
        
        numColors=size(colorIDs,1);
        texWhiteVal=255;
        for i=1:numColors
            for stimFrame=1:numStimFrames
                
                Screen('FillRect',w,background);
                
                tex=makeRGBtexture(im,texWhiteVal,colorIDs(i,:),w);
                Screen('DrawTexture', w, tex, [0 0 sz sz], patchRect, 0)
                
                if exist('flankIm','var') && exist('flankRect','var')
                    tex=makeRGBtexture(flankIm,texWhiteVal,colorIDs(i,:),w);
                    Screen('DrawTexture', w, tex, [0 0 sz sz], flankRect, 0)
                end
                
                Screen('Flip', w);
            end
        
            for intertrialFrame=1:numIntertrialFrames
                Screen('FillRect',w,background);
                Screen('Flip', w);
            end   
        end
end


function tex=makeRGBtexture(im,texWhiteVal,colorIDs,w)

    if size(im,3)==1   %monochrome image
        imRGB(:,:,1)=im*texWhiteVal*colorIDs(1);
        imRGB(:,:,2)=im*texWhiteVal*colorIDs(2);
        imRGB(:,:,3)=im*texWhiteVal*colorIDs(3);    
    elseif size(im,3)==3  %RGB independant image channels
        imRGB(:,:,1)=im(:,:,1)*texWhiteVal*colorIDs(1);
        imRGB(:,:,2)=im(:,:,2)*texWhiteVal*colorIDs(2);
        imRGB(:,:,3)=im(:,:,3)*texWhiteVal*colorIDs(3);
    end

    tex=Screen('MakeTexture', w, imRGB);
end

function batteryOfSweeps(solid,grating,rightFlankRect,aboveFlankRect,sz,numStimFrames,numIntertrialFrames,colorIDs,w,patchRect,black,gray)
        
        sweepThroughContrasts(solid,sz,numStimFrames,numIntertrialFrames,colorIDs,w,patchRect,black)
        %sweepThroughContrasts(solid,sz,numStimFrames,numIntertrialFrames,colorIDs,w,patchRect,gray)
        targetIm=grating';
        %sweepThroughContrasts(targetIm,sz,numStimFrames,numIntertrialFrames,colorIDs,w,patchRect,gray)
        sweepThroughContrasts(targetIm,sz,numStimFrames,numIntertrialFrames,colorIDs,w,patchRect,black)
        targetIm=grating;
        sweepThroughContrasts(targetIm,sz,numStimFrames,numIntertrialFrames,colorIDs,w,patchRect,black)
        %targetIm=grating; flankIm=grating; flankRect=rightFlankRect;
        %sweepThroughContrasts(targetIm,sz,numStimFrames,numIntertrialFrames,colorIDs,w,patchRect,black,flankIm,flankRect)
        %targetIm=grating; flankIm=grating; flankRect=aboveFlankRect;
        %sweepThroughContrasts(targetIm,sz,numStimFrames,numIntertrialFrames,colorIDs,w,patchRect,black,flankIm,flankRect)
end

 function out=makeGrating(sz,ppc,phase,waveform)
    switch waveform
        case 'sine'
            f=sz/params.ppc;
            line=cos(phase+2*pi*f*[0:sz-1]/(sz));
            %line=sin(phase(i) + (0:biggest*2)*(2*pi)/pixPerCyc(i))/2;
        case 'square'
            %this makes a square grating
            line4sq=repmat(((-1).^([0:ceil(sz/(ppc/2))+1])>0)',1,ppc/2)';
            phaseAdv=floor(mod(phase,2*pi)*ppc/(2*pi));
            line=line4sq([1+phaseAdv:sz+phaseAdv]);
        otherwise
            error('waveform must be ''sine'' or ''square''');
    end    
    out=repmat(line,sz,1);
 end

 function pauseMeanScreen(numStimFrames,background,w)
    for stimFrame=1:numStimFrames
        Screen('FillRect',w,background);
        Screen('Flip', w);
    end
 end

 
function pulseSparseSequence(pixSz,GridSz,patchRect,numStimFrames,numIntertrialFrames,colorIDs,presentationType,background,pulseColor,w)

    sz=pixSz*GridSz;      
    switch presentationType
        case 'sweepInOrder'
            
            numPixs=GridSz^2;
            for i=1:numPixs
                miniIm=zeros(GridSz,GridSz);
                miniIm(i)=1;
                targetIm=imresize(miniIm,pixSz);
                sweepThroughContrasts(targetIm,sz,numStimFrames,numIntertrialFrames,colorIDs,w,patchRect,background)
                if mod(i,GridSz)==0
                    pauseMeanScreen(numStimFrames,pulseColor,w);
                end
 
            end
            
        otherwise
            error('no other defined method of presentationType')    
    end

end
 
function [nonLinearity response]=testLinearityOfPixels(targetPixelID,flankerPixIDs,pixSz,GridSz,patchRect,numStimFrames,numIntertrialFrames,targetColorIDs,flankerColorIDs,background,pulseColor,w,oscilateOn)
    
    numFlankers=size(flankerPixIDs,2);
    sz=pixSz*GridSz;
    for i=1:numFlankers 
        
        %empty baseline
        miniIm=background(ones(GridSz,GridSz));
        targetIm=imresize(miniIm,pixSz);
        sweepThroughContrasts(targetIm,sz,numStimFrames,numIntertrialFrames,targetColorIDs,w,patchRect,background)
        
        %target
        miniIm=zeros(GridSz,GridSz);
        miniIm(targetPixelID)=1;
        targetIm=imresize(miniIm,pixSz);
        sweepThroughContrasts(targetIm,sz,numStimFrames,numIntertrialFrames,targetColorIDs,w,patchRect,background)
        
        %flanker
        miniIm=zeros(GridSz,GridSz);
        miniIm(flankerPixIDs(i))=1;
        flankIm=imresize(miniIm,pixSz);
        sweepThroughContrasts(flankIm,sz,numStimFrames,numIntertrialFrames,flankerColorIDs,w,patchRect,background)
        
        %both
        miniIm=zeros(GridSz,GridSz,3);
        shift4rgbID=[0 sz 2*sz];
        miniIm(targetPixelID   +shift4rgbID)=targetColorIDs; 
        miniIm(flankerPixIDs(i)+shift4rgbID)=flankerColorIDs;
        bothIm=imresize(miniIm,pixSz);
        sweepThroughContrasts(bothIm,sz,numStimFrames,numIntertrialFrames,[1 1 1],w,patchRect,background)
        
        if oscilateOn  %not needed; just for visual clarity
            for j=1:4
                sweepThroughContrasts(targetIm,sz,numStimFrames,numIntertrialFrames,targetColorIDs,w,patchRect,background)
                sweepThroughContrasts(bothIm,sz,numStimFrames,numIntertrialFrames,[1 1 1],w,patchRect,background)
            end
        end
        
        pauseMeanScreen(numStimFrames,pulseColor,w);
       
    end
    response=zeros(flankerPixIDs,3)+10^-5; % [target flanker both]
    nonLinearity=testNonLinearityOfResponse(response)
end


function nonLinearity=testNonLinearityOfResponse(response)
    nonLinearity=(response(:,1)+response(:,2)-response(:,3))./(response(:,1)+response(:,2));
end

 
function [nonLinearity response]=testLinearityOfGratings(targetParams,flankerParams,numStimFrames,numIntertrialFrames,background,pulseColor,w,oscilateOn)
    
    numTargetTypes=size(targetParams.isHorizontal,2);
    numFlankerTypes=size(flankerParams.isHorizontal,2);
    numFlankerPositions=size(flankerParams.patchRect,1);
    response=zeros(numTargetTypes*numFlankerTypes*numFlankerPositions,3);
    sz=flankerParams.patchRect(3)-flankerParams.patchRect(1);
    
    grating=makeGrating(sz,targetParams.ppc,targetParams.phase,targetParams.waveform);
    %note: flanker ppc = target ppc
    %note: flanker phase = target phase
    
    for i=1:numTargetTypes
        
         if targetParams.isHorizontal(i)
                targetIm=grating';
            else
                targetIm=grating;
         end
            
        for j=1:numFlankerTypes
              
            if flankerParams.isHorizontal(j)
                flankIm=grating';
            else
                flankIm=grating;
            end
            
            for k=1:numFlankerPositions
           
                patchRect=targetParams.patchRect;
                flankRect=flankerParams.patchRect(k,:);
                
                %empty baseline
                sweepThroughContrasts(background(ones(sz,sz)),sz,numStimFrames,numIntertrialFrames,targetParams.colorIDs,w,patchRect,background)

                %target
                sweepThroughContrasts(targetIm,sz,numStimFrames,numIntertrialFrames,targetParams.colorIDs,w,patchRect,background)

                %flanker
                sweepThroughContrasts(flankIm,sz,numStimFrames,numIntertrialFrames,targetParams.colorIDs,w,flankRect,background)

                %both
                sweepThroughContrasts(targetIm,sz,numStimFrames,numIntertrialFrames,targetParams.colorIDs,w,patchRect,background,flankIm,flankRect)
                
                ID=(i-1)*numFlankerTypes*numFlankerPositions+(j-1)*numFlankerPositions+k;
                response(ID,:)=zeros(1,3)+10^-5;
                
                if oscilateOn  %not needed; just for visual clarity
                    for osc=1:8
                        sweepThroughContrasts(targetIm,sz,numStimFrames,numIntertrialFrames,targetParams.colorIDs,w,patchRect,background)
                        sweepThroughContrasts(targetIm,sz,numStimFrames,numIntertrialFrames,targetParams.colorIDs,w,patchRect,background,flankIm,flankRect)
                    end
                end
                
                pauseMeanScreen(numStimFrames,pulseColor,w)
                
            end
        end
    end
    nonLinearity=testNonLinearityOfResponse(response);
end

 