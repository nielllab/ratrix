function err= compute2xsftfTuningErr(p, params,data);

y = (p(1:2)*params(:,1:2)') .* (p(3:8) * params(:,3:8)') .* (p(9:11)*params(:,9:11)') ...
    .*(1+p(12)*params(:,11)') + p(13);
err = sum((y'-data).^2);
