function s=fillLUT(s,method,linearizedRange,plotOn);
%function s=fillLUT(s,method,linearizedRange [,plotOn]);
%stim=fillLUT(stim,'linearizedDefault');
%note: this calculates and fits gamma with finminsearch each time
%might want a fast way to load the default which is the same each time
%edf wants to migrate this to a ststion method  - this code is redundant
%for each stim -- ACK!


if ~exist('plotOn','var')
    plotOn=0;
end

useUncorrected=0;

switch method
    case 'mostRecentLinearized'    
        method
        error('that method for getting a LUT is not defined');
    case 'tempLinearRedundantCode'   
        LUTBitDepth=8;
        numColors=2^LUTBitDepth; maxColorID=numColors-1; fraction=1/(maxColorID); 
        ramp=[0:fraction:1];
        grayColors= [ramp;ramp;ramp]';
        %maybe ask for red / green / blue gun only
        linearizedCLUT=grayColors;
    case '2009Trinitron255GrayBoxInterpBkgnd.5'
         
        conn=dbConn();
        mac='0018F35DFAC0'  % from the phys rig
        timeRange=[datenum('06-09-2009 23:01','mm-dd-yyyy HH:MM') datenum('06-11-2009 23:59','mm-dd-yyyy HH:MM')];
        cal=getCalibrationData(conn,mac,timeRange);
        closeConn(conn)

        LUTBitDepth=8;
        spyderCdPerMsquared=cal.measuredValues;
        stim=cal.details.method{2};
        vals=double(reshape(stim(:,:,1,:),[],size(stim,4)));
        if all(diff(spyderCdPerMsquared)>0) && length(spyderCdPerMsquared)==length(vals)
            range=diff(spyderCdPerMsquared([1 end]));
            floor=spyderCdPerMsquared(1);
            desiredVals=linspace(floor+range*linearizedRange(1),floor+range*linearizedRange(2),2^LUTBitDepth);
            newLUT = interp1(spyderCdPerMsquared,vals,desiredVals,'linear')/vals(end); %consider pchip
            linearizedCLUT = repmat(newLUT',1,3);
        else
            error('vals not monotonic -- should fit parametrically or check that data collection OK')
        end
    case 'calibrateNow'
        %[measured_R measured_G measured_B] measureRGBscale()
        method
        error('that method for getting a LUT is not defined');
    otherwise
        method
        error('that method for getting a LUT is not defined');
end


s.LUT=linearizedCLUT;
