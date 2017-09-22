function [RD RS sigmaD sigmaS m result] = sizeCurveFit(szs,scurves)
    clear RD RS sigmaD sigmaS m
    result = {};
    for i = 1:size(scurves,1)
        clear xs ys
        xs = szs';
        ys = scurves(i,:)';

        maxM = 5;
        maxRD = 5*max(ys);
        maxRS = 100*max(ys);
        maxsigD = max(xs)/2;
        maxsigS = 4*max(xs);
        maxdsig = 4*max(xs);

        initM = 2.5;
        initsigD = xs(2);
        initsigS = 2*xs(2);
        initdsig = 2*xs(2);
        initRD = ys(2)/(erf(xs(2)/sqrt(2)/initsigD))^initM;
        initRS = (-1 + initRD/max(.001*max(ys), ys(end)))/(erf(xs(2)/sqrt(2)/initsigS))^initM;


        Dsigma = 0;%0 or 1, determines the possible paramterization cases
        %Lower = [0.001*max(ys), 0, 0, 0, 0,1];
        Lower = [0.001*maxRD, 0, 0.1*xs(2), 0.1*xs(2), 1];
        if ~Dsigma
            Upper = [maxRD,maxRS,maxsigD,maxsigS,maxM];
            Init = [initRD,initRS,initsigD,initsigS,initM];
            carndini_form = '(RD * (erf(d/sqrt(2)/sigmaD))^m) / (1 + RS * (erf(d/sqrt(2)/sigmaS))^m )' ;%Ayaz-Carandini form
            cform = fittype( carndini_form , 'independent', {'d'}, 'coefficient', {'RD', 'RS', 'sigmaD', 'sigmaS', 'm'});
            options = fitoptions('Method', 'NonlinearLeastSquares', 'Lower', Lower, 'Upper',Upper,'StartPoint',Init);
            try
                result{i} = fit(xs, ys, cform, options);
                coeffs = coeffvalues(result{i});
                RD(i) = coeffs(1);
                RS(i) = coeffs(2);
                sigmaD(i) = coeffs(3);
                sigmaS(i) = coeffs(4) + Dsigma * coeffs(3);
                m(i) = coeffs(5);
            catch
                result{i}=NaN;
                RD(i) = NaN;
                RS(i) = NaN;
                sigmaD(i) = NaN;
                sigmaS(i) = NaN;
                m(i) = NaN;
            end
        else
            Upper = [maxRD,maxRS,maxsigD,maxdsig,maxM];
            Init = [initRD,initRS,initsigD,initdsig,initM];
            carndini_form = '(RD * (erf(d/sqrt(2)/sigmaD))^m) / (1 + RS * (erf(d/sqrt(2)/(sigmaD + dsigma)))^m )' ;%Ayaz-Carandini form
            cform = fittype( carndini_form , 'independent', {'d'}, 'coefficient', {'RD', 'RS', 'sigmaD', 'dsigma', 'm'});
            options = fitoptions('Method', 'NonlinearLeastSquares', 'Lower', Lower, 'Upper',Upper,'StartPoint',Init);
            try
                result{i} = fit(xs, ys, cform, options);
                coeffs = coeffvalues(result{i});
                RD(i) = coeffs(1);
                RS(i) = coeffs(2);
                sigmaD(i) = coeffs(3);
                sigmaS(i) = coeffs(4) + Dsigma * coeffs(3);
                m(i) = coeffs(5);
            catch
                result{i}=NaN;
                RD(i) = NaN;
                RS(i) = NaN;
                sigmaD(i) = NaN;
                sigmaS(i) = NaN;
                m(i) = NaN;
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