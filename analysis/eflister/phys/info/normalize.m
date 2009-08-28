function out=normalize(v)
    out=(v-min(v))/(max(v)-min(v));
    out=out-mean(out);
    %out=(v-mean(v))/std(v);