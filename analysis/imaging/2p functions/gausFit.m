function [a b c result] = gausFit(pts,vals,startPoints)
    clear a b c
    result = {};
    for i = 1:size(vals,1)
        clear xs ys
        ys = vals(i,:)';
        xs = pts';
        gaussEqn = 'a*exp(-(x/b)^2)+c';
        result{i} = fit(xs, ys, gaussEqn, 'Start', startPoints);
        coeffs = coeffvalues(result{i});
        a(i) = coeffs(1);
        b(i) = coeffs(2);
        c(i) = coeffs(3);
        
%         fitdata = a(i)*exp(-(xs/b(i)).^2)+c(i);
%         figure
%         hold on
%         plot(xs,ys,'k');plot(xs,fitdata,'b')
    end
end