function [edgeImage] = WFK_sobel(X)

%X input color image
% Obtained from MATLAB Answers 108868-edge-detection-using-sobel-operator
% Modified for a 2-D grayscale image array -- WFK 7-19-2016

height = size(X, 1); 
width = size(X, 2); 
% channel = size(X, 3);

edgeImage = X;

Gx = [1 +2 +1; 0 0 0; -1 -2 -1]; 
Gy = Gx';

for i = 2 : height-1
   for j = 2 : width-1  
       % for k = 1 : channel
           % tempLena = X(i - 1 : i + 1, j - 1 : j + 1, k);
           tempVal = X(i-1:i+1,j-1:j+1);
           a=(sum(Gx.* tempVal));
           x = sum(a);
           b= (sum(Gy.* tempVal));
           y = sum(b);
           pixValue =sqrt(x.^2+ y.^2);
          % pixValue =(x-y);
          % edgeImage(i, j, k) = pixValue;
           edgeImage(i,j) = pixValue;
       % end; 
   end;
end;
end

