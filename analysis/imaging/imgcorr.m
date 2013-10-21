function c_img = imgcorr(x,img);
if size(x,2)>1
    x = x';
end

squeeze_mat = reshape(img,size(img,1)*size(img,2),size(img,3));
c = corr(x,squeeze_mat');
c_img = reshape(c,size(img,1),size(img,2));
