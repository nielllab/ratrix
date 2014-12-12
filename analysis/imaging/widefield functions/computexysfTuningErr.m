function err= computexysfTuningErr(p, params,data);

y = (p(1:5)*params(:,1:5)') .* (p(6:8) * params(:,6:8)') .* (p(9:10)*params(:,9:10)') ...
    .*(1+p(11)*params(:,11)') + p(12);
err = sum((y'-data).^2);
