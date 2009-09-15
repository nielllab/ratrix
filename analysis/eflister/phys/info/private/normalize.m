%adding this caused a conflict w/ ratrix\classes\util\matlaby\normalize, so moving it to private
%http://www.mathworks.com/access/helpdesk/help/techdoc/matlab_prog/f7-58170.html#bresuvu-6
%note setupEnvironment's genpath won't add private directories

%note this assumes v is one dimensional

function out=normalize(v)
    out=(v-min(v))/(max(v)-min(v));
    out=out-mean(out);
    %out=(v-mean(v))/std(v);