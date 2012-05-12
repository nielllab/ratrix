function out=computeGabors(params,mean,width,height,waveform,normalizeMethod,cornerMarkerOn,normalize)

% params = [.3 16 0 pi/6 1 0.001 1/2 1/2 ];
% grating=computeGabors(params,0.5,200,200,'square','normalizeVertical',1);

%change log
%070403 fixed rounding problem with square grating
%070403 added ability to skip mask, when radius==Inf pmm
%080216 noticed problem in upper left corner when no mask (this exists in all versions)-- unfixed pmm
%
% params=[Inf,4, 0,-99,1, 0.001,0.5,0.5];
% orients=[0:pi/20:pi];
% for i=1:length(orients)
%     params(4)=orients(i)
%     grating=computeGabors(params,0.5,100,100,'square','normalizeVertical',1);
%     figure; imagesc(grating)
% end

%%080218 added waveform = 'none' pmm
%080218 confirmed in-sync with svnErik ratrix pmm
%080419  got rid of oldMethod that uses imrotate, we now have no aliasing   pmm
%   phases defined from center of mask
%   emperically everything is fine with integer pixPerCyc. Non-integer looks bad.(Especialy weird wrapping effect for horizontal or vertical)
%   2ppc looks okay (Didn't see rounding problems). Negative phases appear okay. (No thorough test/animation)

if ~exist('waveform','var')
    waveform='sine';
end

if ~exist('normalizeMethod','var')
    normalizeMethod='normalizeVertical';
end

if ~exist('cornerMarkerOn','var')
    cornerMarkerOn=0;
end

if ~exist('normalize','var')
    normalize=true;
end

radius=params(:,1);
pixPerCyc=params(:,2);
phase=params(:,3);
orientation=params(:,4);
contrast=params(:,5);
thresh=params(:,6);
xPosPct=params(:,7);
yPosPct=params(:,8);

if any(pixPerCyc<2)
    pixPerCyc
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
    
    oldMethod=0;
    if oldMethod
        
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
                % here is the problem you are trying to avoid -> 
                % doubles fall at unreliable places wrt sin's zero crossings
                % plot(sign(sin((0:40)*pi)))
                sqPhase = phase(i) + (ceil(abs(phase(i)/(2*pi)))+1)*2*pi;
                
                % POSSIBLE Error!!!!! Do we need this? It has never been used
                % -pmm 080714
                % sqPixPerCycs=pixPerCyc*2;
                line = rem(([0:biggest*2]+sqPhase*pixPerCyc(i)/(2*pi)+pixPerCyc(i)/2)/pixPerCyc(i),1)>=.5;
                line=line-.5;
                
                %if you'd like to try for yourself, here are some ideas:
                % phase = phase + (ceil(abs(phase/(2*pi)))+1)*2*pi;
                % a=rem(([0:len]+phase*pixPerCyc/(2*pi)+pixPerCyc/2)/pixPerCyc,1)>=.5;
                % a=2*a-1;
                % b=sin(phase  + (0:len)*(2*pi)/pixPerCyc);
                % plot([a;b]')
            case 'none'
                line=ones(1,(biggest*2)+1);
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
        
        %     subplot(131); imagesc(sin(xChange))
        %     subplot(132); imagesc(sin(yChange))
        %     subplot(133); imagesc(r2)
        %
        %     figure
        %     diff=rotated-r2;
        %     max(max(r2))
        %     max(max(rotated))
        %     max(max(diff))
        %     subplot(131); imagesc(r2)
        %     subplot(132); imagesc(rotated)
        %     subplot(133); imagesc(diff)
        %
        %     figure
        %     subplot(121); plot(rotated(end,:),'r'); hold on; plot(r2(end,:))
        %     subplot(122); plot(rotated(:,end),'r'); hold on; plot(r2(:,end))
        
        
        
        
    else %currentMethod
        
        
        
        %%
        
        %calculate the effective frequency in the vertical and horizontal directions
        %instead of frequency use pixPerCyc
        xPPC=pixPerCyc(i)/cos(orientation(i));
        yPPC=pixPerCyc(i)/sin(orientation(i));
        xChange=repmat(([1:width] -(.5+xPosPct(i)*width))  *(2*pi)/xPPC,height,1);
        yChange=repmat(([1:height]-(.5+yPosPct(i)*height))'*(2*pi)/yPPC,1, width);
        phases=(xChange+yChange+phase(i))';
        
        
        switch waveform
            case 'sine'
                rotated=sin(phases)/2;
            case 'square'
                %this may not right but really close
                rotated=sign(sin(phases))/2;
                
                %Emperically the remainder method may not be needed
                % b=-min([0 min(phases(:))]); %add this to get rid of negative phases
                %b=ceil(b/(2*pi))*(2*pi);  %b should end up being larger than the min value but also mulitiple of 2pi
                %     r2=sign(sin(phases+b))/2;
                %
                %     r3=(rem(phases+b,2*pi)>=pi)-.5;
                %
                %     dif=r1-r3;
                %     subplot(131); imagesc(r1)
                %     subplot(132); imagesc(r3)
                %     subplot(133); imagesc(dif)
                %     sum(dif(:))
                %     phases(find(dif~=0))'
            case 'none'
                rotated=ones(size(phases)); %Could be sped up by not calculating phases
            otherwise
                error('waveform must be ''sine'' or ''square'' or ''none''');
        end
        rotated = contrast(i)*rotated;
    end
    
    %%
    
    
    if radius(i)~=Inf  %only compute gaussian mask if you need to
        mask=zeros(ySize,xSize);
        %gaussian mask
        %mask(1:xSize*ySize)=mvnpdf([reshape(repmat((-ySize/2:(-ySize/2 + ySize -1))',1,xSize),xSize*ySize,1) reshape(repmat(-xSize/2:(-xSize/2+xSize-1),ySize,1),xSize*ySize,1)],[yPosPct(i)*ySize-ySize/2 xPosPct(i)*xSize-xSize/2],(radius(i)*diag([normalizedLength normalizedLength])).^2);
       
        %hard circular mask
        xcoords =  reshape(repmat(-xSize/2:(-xSize/2+xSize-1),ySize,1),xSize*ySize,1);     
        ycoords = reshape(repmat((-ySize/2:(-ySize/2 + ySize -1))',1,xSize),xSize*ySize,1);
        
        xcenter = xPosPct(i)*xSize-xSize/2;
        ycenter = yPosPct(i)*ySize-ySize/2;
        
        mask(1:xSize*ySize)=double(((xcoords - xcenter).^2 + (ycoords - ycenter).^2)<((radius(i)*normalizedLength)^2));
        
        %THIS IS AN OLD LINE OF CODE  - used to send sigma as co-std rather than co-variance
        %mask(1:xSize*ySize)=mvnpdf([reshape(repmat((-ySize/2:(-ySize/2 +
        %ySize -1))',1,xSize),xSize*ySize,1) reshape(repmat(-xSize/2:(-xSize/2+xSize-1),ySize,1),xSize*ySize,1)],[yPosPct(i)*ySize-ySize/2 xPosPct(i)*xSize-xSize/2],(radius(i)*diag([normalizedLength normalizedLength])));
        
        mask=mask/max(max(mask));
        masked = rotated'.*mask;
    else
        masked = rotated';
    end
    
    %     mask=zeros(ySize,xSize);
    %     mask(1:xSize*ySize)=mvnpdf([reshape(repmat((-ySize/2:(-ySize/2 + ySize -1))',1,xSize),xSize*ySize,1) reshape(repmat(-xSize/2:(-xSize/2+xSize-1),ySize,1),xSize*ySize,1)],[yPosPct(i)*ySize-ySize/2 xPosPct(i)*xSize-xSize/2],(radius(i)*diag([normalizedLength normalizedLength])).^2);
    %
    %     %THIS IS AN OLD LINE OF CODE  - used to send sigma as co-std rather than co-variance
    %     %mask(1:xSize*ySize)=mvnpdf([reshape(repmat((-ySize/2:(-ySize/2 +
    %     %ySize -1))',1,xSize),xSize*ySize,1) reshape(repmat(-xSize/2:(-xSize/2+xSize-1),ySize,1),xSize*ySize,1)],[yPosPct(i)*ySize-ySize/2 xPosPct(i)*xSize-xSize/2],(radius(i)*diag([normalizedLength normalizedLength])));
    %
    %     mask=mask/max(max(mask));
    %
    %     masked = rotated'.*mask;
    
    masked(abs(masked)<thresh(i))=0;
    img(i,:,:)=masked;
end

out=mean+squeeze(sum(img,1));

if normalize %note this is not what normalize means -- should be called clip!
    out(out<0)=0;
    out(out>1)=1;
end

if cornerMarkerOn
    out(1)=0;
    out(2)=1;
end