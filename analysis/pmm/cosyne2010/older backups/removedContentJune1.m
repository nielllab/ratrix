        function [p, muS muN sigmaS sigmaN shapeS shapeN]=getLinearMuSigma(p,x,tcs,fcs);
            
            %default if not defined
            shapeS=[];
            shapeN=[];
            switch p.sdtDistributionType
                case 'eqVarGaussian'
                    tm=x(2); fm=x(3);
                    muS=tcs*tm+fcs*fm;
                    muN=fcs*fm;
                    sigmaS=ones(1,length(tcs));
                    sigmaN=ones(1,length(tcs));
                case 'gaussian'
                    tm=x(2); fm=x(3); ts=x(4); fs=x(5);
                    if length(x)==6
                        %same contrast exponent
                        gammaT=x(6);
                        gammaF=x(6);
                    elseif length(x)>6
                        %independant exponent
                        gammaT=x(6);
                        gammaF=x(7);
                    else
                        %linear
                        gammaT=1;
                        gammaF=1;
                    end
                    
                    muS=tcs.^gammaT*tm+fcs.^gammaF*fm;
                    muN=fcs.^gammaF*fm;
                    sigmaS=max(1+tcs.^gammaT*ts+fcs.^gammaF*fs,0.001);
                    sigmaN=max(1+fcs.^gammaF*fs,0.001);
                case 'gev'
                    tm=x(2); fm=x(3); ts=x(4); fs=x(5);
                    %shape is bounded between -1 and 1
                    %should be... bounded, but isnt.
                    
                    if length(x)>=6
                        kappa=x(6);
                    else
                        kappa=-0.3;
                    end
                    
                    if length(x)>=7
                        tk=x(7);
                    else
                        tk=0;
                    end
                    
                    if length(x)>=8
                        fk=x(8);
                    else
                        fk=0;
                    end
                    
                    if length(x)==9
                        %same contrast exponent
                        gammaT=x(9);
                        gammaF=x(9);
                    elseif length(x)>9
                        %independant exponent
                        gammaT=x(9);
                        gammaF=x(10);
                    else
                        %linear
                        gammaT=1;
                        gammaF=1;
                    end
                    
                    
                    
                otherwise
                    error('bad')
            end
        end
        
        
        
        %         function [p, muS muN sigmaS sigmaN shapeS shapeN]=getNonLinearMuSigma(p,x,tcs,fcs);
%             %default if not defined
%             shapeS=[];
%             shapeN=[];
%             switch p.sdtDistributionType
%                 case 'gaussian'
%                     tm=x(2); fm=x(3);
%                     
%                     if length(x)>=4
%                         p.relativeMissCost=x(4);
%                     end
%                     
%                     if length(5)>=5
%                         c50=x(5);
%                     else
%                         c50=1;
%                     end
%                     
%                     if length(x)>=6
%                         %same contrast exponent
%                         gammaT=x(6);
%                         
%                     else
%                         gammaT=1;
%                         gammaF=1;
%                     end
%                     
%                     if length(x)>=7
%                         fallOff=exp(x(7));
%                     else
%                         fallOff=1; %1= no falloff, normalize to full screen, not locally
%                     end
%                     
%                     if length(x)>=8
%                         gammaF=x(8);
%                     else
%                         gammaF=gammaT;
%                     end
%                     
%                     if  length(x)>=9
%                         ts=x(9);
%                     else
%                         ts=0;
%                     end
%                     
%                     if  length(x)>=10
%                         fs=x(10);
%                     else
%                         fs=0;
%                     end
%                     
%                     effective flanker and target contrast,
%                     first gamma'd,
%                     then normalized by local contrast
%                     tce=tcs.^gammaT./(c50+(fcs + 2*fallOff*tcs).^((gammaT+gammaF)/2));
%                     fce=fcs.^gammaF./(c50+(fcs + fallOff*tcs).^((gammaT+gammaF)/2)); % ignoring the effect of the other flanker
%                     
%                     
%                     tce=tcs.^gammaT./(c50+(fcs + 2*fallOff*tcs).^(gammaT));
%                     fce=fcs.^gammaF./(c50+(fcs + fallOff*tcs).^(gammaF)); % ignoring the effect of the other flanker
%                     
%                     
%                     close all; figure; plot(tce,'g'); hold on; plot(fce,'r')
%                     
%                     
%                     THIS IS AN INTERESTING OPTION I NEVER TESTED:
%                     fcb=fcs+baseline;
%                     fce=fcb.^gammaF./(c50+(fcs + fallOff*tcs).^((gammaT+gammaF)/2));
%                     is  enables ZERO CONTRAST FLANKERS to still have a noise floor signal (mu>0) that targets can modify
%                     could also consider a small reduction in the sigma...
%                     but thats complicated and should link about variane
%                     going with mean and effects to combat it
%                     noSigNoiseStd=1; % crazy variance changing: ones(1,length(tce))./(c50+(tcs + 2*fallOff*fcs).^((gammaT+gammaF)/2));  % maybe this should be learned in the dn mode, bc all signal (muN) changes are with respect to it.. curvature under 1...
%                     
%                     
%                     muS=tce*tm+fce*fm;
%                     muN=fce*fm;
%                     noSigNoiseStd=1; % crazy variance changing: ones(1,length(tce))./(c50+(tcs + 2*fallOff*fcs).^((gammaT+gammaF)/2));  % maybe this should be learned in the dn mode, bc all signal (muN) changes are with respect to it.. curvature under 1...
%                     sigmaS=max(noSigNoiseStd+tce*ts+fce*fs,0.001);
%                     sigmaN=max(noSigNoiseStd+fce*fs,0.001);
%                 otherwise
%                     p.sdtDistributionType
%                     error('never defined other sdtDistributionType for non gaussian')
%             end
%         end



   tic
            switch p.sdtDistributionType  % maybe the model name sets the other params?
                case 'eqVarGaussian'
                    if ~exist('x0','var') || isempty(x0)
                        x0=[.7 1.4 2.4];  % good for learning
                    end
                    
                    [x er]=fminsearch(@(x)gaussLinearSimpleMLErrorFun(p,x,data,params),x0); %get trapped with
                    p=p.setGaussDistParamsFromModelFit(x);
                case 'gaussian'
                    if ~exist('x0','var') || isempty(x0)
                        x0= [0  1 .1 -0.2 0 ];  % when no learning
                        x0= [.7 2 4 -0.2 1.6 ];  % good for learning'
                        
                        x0= [.81 1.96 5.67 -0.35 3.17 0.99 2.36];  % good for learning..include gamma
                        x0= [.81 1.96 5.67 -0.35 3.17 0.99 2.36 3 3 3 3 1 1];  % 2 rat model
                    end
                    [x er]=fminsearch(@(x)gaussLinearSimpleMLErrorFun(p,x,data,params),x0); %
                    %lb=[-100  -100 -100 -100 -100];
                    %ub=[100  100  100  100  100];
                    %[x er]=fminbnd(@(x)gaussMLErrorFun(p,x,data,params),lb,ub);
                    %%sometimes way left of the whole distibution
                    p=p.setGaussDistParamsFromModelFit(x);
                case 'gev'
                    if ~exist('x0','var') || isempty(x0)
                        x0=[.5 2.7 38 0.6 2 .6 .2]
                        %x0=[.5 2.7 38 0.6 2 0.01 0.01 -0.3] plus kappa0
                    end
                    
                    [x er]=fminsearch(@(x)gevLinearSimpleMLErrorFun(p,x,data,params),x0); %get trapped with
                    p=p.setDistParamsFromModelFit(x);
            end