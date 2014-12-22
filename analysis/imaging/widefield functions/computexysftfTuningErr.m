function err= computexysftfTuningErr(p, params,data);

y = (p(1:4)*params(:,1:4)') .* (p(5:7) * params(:,5:7)') .* (p(8:13)*params(:,8:13)') .* (p(14:16)*params(:,14:16)')...
    .*(1+p(17)*params(:,17)') + p(18);
err = sum((y'-data).^2);
