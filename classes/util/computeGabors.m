function out=computeGabors(params,mean,width,height,waveform,normalizeMethod,cornerMarkerOn)

% params = [1 16 0 pi 1 0.001 1/2 1/2 ];
% grating=computeGabors(params,0.5,200,200,'square','normalizeVertical',1);

%change log
%070403 fixed rounding problem with square grating

if ~exist('waveform','var')
    cornerMarkerOn='sine';
end

if ~exist('normalizeMethod','var')
    normalizeMethod='normalizeVertical';
end

if ~exist('cornerMarkerOn','var')
    waveform=1;
end

radius=params(:,1);
pixPerCyc=params(:,2);
phase=params(:,3);
orientation=params(:,4);
contrast=params(:,5);
thresh=params(:,6);
xPosPct=params(:,7);
yPosPct=params(:,8);

if any(pixPerCyc<2.0)
    error('pixPerCyc must be >= 2.0')
end

numGabors = size(params,1);

xSize=width;
ySize=height;

img = zeros(numGabors,ySize,xSize);
biggest=max(xSize,ySize);

switch normalizeMethod
    case 'normalizeVertical'
        normalizedLength=ySize/2;
    case 'normalizeHorizontal'
        normalizedLength=xSize/2;
    case 'normalizeDiagonal'  % erik's diag method
        normalizedLength=sqrt((xSize/2)^2 + (ySize/2)^2);
    case 'none'
        normalizedLength=1;  % in this case the radius is the std in number of pixels
    otherwise
        error('normalizeMethod must be ''normalizeVertical'', ''normalizeHorizontal'', or ''normalizeDiagonal''.')
end


for i=1:numGabors

    %tiny=10^(-10); % with this value, its safe with biggest<166,000 but not biggest>167,000
    %line=contrast(i)*sin(phase(i)-tiny + (0:biggest*2)*(2*pi)/pixPerCyc(i))/2;


    switch waveform
        case 'sine'
            line = sin(phase(i)  + (0:biggest*2)*(2*pi)/pixPerCyc(i))/2;
        case 'square'
            %this may look crazy to you, but i defy you to find a
            %simpler solution.  make sure it works for negative phases!
            % and it should match the phase of the sine version.  we
            % couldn't just sign(sin()) cuz of numerical instability.
            %                               -the management
            sqPhase = phase(i) + (ceil(abs(phase(i)/(2*pi)))+1)*2*pi;

            line = rem(([0:biggest*2]+sqPhase*pixPerCyc(i)/(2*pi)+pixPerCyc(i)/2)/pixPerCyc(i),1)>=.5;
            line=line-.5;

            %if you'd like to try for yourself, here are some ideas:
            % phase = phase + (ceil(abs(phase/(2*pi)))+1)*2*pi;
            % a=rem(([0:len]+phase*pixPerCyc/(2*pi)+pixPerCyc/2)/pixPerCyc,1)>=.5;
            % a=2*a-1;
            % b=sin(phase  + (0:len)*(2*pi)/pixPerCyc);
            % plot([a;b]')


        otherwise
            error('waveform must be ''sine'' or ''square''');
    end
    line = contrast(i)*line;


    %if biggest>166000
    %    error('there could be rounding errors in your grating.  effects square garting value.')
    %end

    %OLD
    %line=contrast(i)*sin(phase(i) +(0:biggest*2)*(2*pi)/pixPerCyc(i))/2;

    % if you do this (above) with a value that devides evenly into biggest,
    % then errors occur b/c rounding errors in the wrapping phase cause
    % a switch in sign for sin(near zero)  -pmm 070304
    % here is a good test that would not pass the old method:
    %if pixPerCyc(i)==2
    %     %one day could make this check general for any pixperCyc...
    %     if any(diff(line>0)==0)
    %         line>0
    %         disp('this could be a real problem, esp if using square grating')
    %         error('found two repeating values next to one another!')
    %     else
    %         %you are okay
    %     end
    %end


    %switch waveform
    %    case 'sine'
    %        %do nothing; you're done.
    %    case 'square'
    %        line=contrast(i)*((line>0)-0.5);
    %    otherwise
    %        error('waveform must be ''sine'' or ''square''');
    %end

    grating=repmat(line',1,biggest*2);
    %grating=repmat(line',1,xSize*2);

    %pmm hates calling imrotate which is slow, even though the fuction
    %says it shouldn't be for 90 deg rotations...
    if abs(orientation(i)) <0.00001  %check if vertical
        rotated=grating;
    elseif abs(mod((orientation(i)-pi*[1:10])/(pi/2),2)-1) < 0.00001  % check if horizontal
        rotated=grating';
    else
        rotated=imrotate(grating,orientation(i)*360/(2*pi),'bilinear','crop');
    end

    xStart = ceil(.25*xSize);
    yStart = ceil(.25*ySize);
    rotated = rotated(xStart:xStart+xSize-1,yStart:yStart+ySize-1);

    mask=zeros(ySize,xSize);
    mask(1:xSize*ySize)=mvnpdf([reshape(repmat((-ySize/2:(-ySize/2 + ySize -1))',1,xSize),xSize*ySize,1) reshape(repmat(-xSize/2:(-xSize/2+xSize-1),ySize,1),xSize*ySize,1)],[yPosPct(i)*ySize-ySize/2 xPosPct(i)*xSize-xSize/2],(radius(i)*diag([normalizedLength normalizedLength])).^2);

    %THIS IS AN OLD LINE OF CODE  - used to send sigma as co-std rather than co-variance
    %mask(1:xSize*ySize)=mvnpdf([reshape(repmat((-ySize/2:(-ySize/2 +
    %ySize -1))',1,xSize),xSize*ySize,1) reshape(repmat(-xSize/2:(-xSize/2+xSize-1),ySize,1),xSize*ySize,1)],[yPosPct(i)*ySize-ySize/2 xPosPct(i)*xSize-xSize/2],(radius(i)*diag([normalizedLength normalizedLength])));

    mask=mask/max(max(mask));

    masked = rotated'.*mask;

    masked(abs(masked)<thresh(i))=0;
    img(i,:,:)=masked;
end

out=mean+squeeze(sum(img,1));

out(out<0)=0;
out(out>1)=1;

if cornerMarkerOn
    out(1)=0;
    out(2)=1;
end