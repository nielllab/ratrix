
function v=normalize(v)
v=double(v);
v=v-min(v(:));
v=v/max(v(:));
end