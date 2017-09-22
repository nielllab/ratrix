function [RD RS result] = sizeCurveFitRdRs(szs,scurves,sigD,sigS,M)
    clear RD RS
    result = {};
    for i = 1:size(scurves,1)
        clear xs ys
        xs = szs';
        ys = scurves(i,:)';
        sigmaD = sigD(i);
        sigmaS = sigS(i);
        m = M(i);
        
        maxRD = 5*max(ys);
        maxRS = 100*max(ys);

        initM = 2.5;
        initsigD = xs(2);
        initsigS = 2*xs(2);
        initRD = ys(2)/(erf(xs(2)/sqrt(2)/initsigD))^initM;
        initRS = (-1 + initRD/max(.001*max(ys), ys(end)))/(erf(xs(2)/sqrt(2)/initsigS))^initM;


        Dsigma = 0;%0 or 1, determines the possible paramterization cases
        Lower = [0.001*maxRD, 0];
        if ~Dsigma
            Upper = [maxRD,maxRS];
            Init = [initRD,initRS];
            carndini_form = sprintf('(RD * (erf(d/sqrt(2)/%f))^%f) / (1 + RS * (erf(d/sqrt(2)/%f))^%f )',sigmaD,m,sigmaS,m);
            cform = fittype( carndini_form , 'independent', {'d'}, 'coefficient', {'RD', 'RS'});
            options = fitoptions('Method', 'NonlinearLeastSquares', 'Lower', Lower, 'Upper',Upper,'StartPoint',Init);
            try
                result{i} = fit(xs, ys, cform, options);
                coeffs = coeffvalues(result{i});
                RD(i) = coeffs(1);
                RS(i) = coeffs(2);
            catch
                result{i}=NaN;
                RD(i) = NaN;
                RS(i) = NaN;
            end
        else
            Upper = [maxRD,maxRS];
            Init = [initRD,initRS];
            carndini_form = sprintf('(RD * (erf(d/sqrt(2)/%f))^%f) / (1 + RS * (erf(d/sqrt(2)/%f))^%f )',sigmaD,m,sigmaS,m);%Ayaz-Carandini form
            cform = fittype( carndini_form , 'independent', {'d'}, 'coefficient', {'RD', 'RS'});
            options = fitoptions('Method', 'NonlinearLeastSquares', 'Lower', Lower, 'Upper',Upper,'StartPoint',Init);
            try
                result{i} = fit(xs, ys, cform, options);
                coeffs = coeffvalues(result{i});
                RD(i) = coeffs(1);
                RS(i) = coeffs(2);
            catch
                result{i}=NaN;
                RD(i) = NaN;
                RS(i) = NaN;
            end
        end

%         figure;
%         plot(result{i});
%         hold on; 
%         plot(xs,ys,'ob');
%         hold off;


%         coeffs = coeffvalues(result{i});
% 
%         RD(i) = coeffs(1);
%         RS(i) = coeffs(2);
%         sigmaD(i) = coeffs(3);
%         sigmaS(i) = coeffs(4) + Dsigma * coeffs(3);
%         m(i) = coeffs(5);
    end
end