function [ numPixels ] = WFK_donutHoleArea(mySlice,threshold,left)
% Given a two-dimensional slice of a volume,
% (essentially, a gray scale cross-section of a lead),
% threshold the image to a binary image, and then find a
% single, large interior hole; if there is one, then count and return
% the number of pixels in that interior hole.  Otherwise, return zero.
% 
% The argument "left" should be 1 if left hemisphere, 0 if right.  This
% is just used to manage where the images are displayed on the GUI.
%
colormap gray;
subplot(4,7, 7-left, 'align' ); axis off; cla;
subplot(4,7,14-left, 'align' ); axis off; cla;
subplot(4,7,21-left, 'align' ); axis off; cla;
subplot(4,7,28-left, 'align' ); axis off; cla;

subplot(4,7,7-left, 'align');
imagesc(mySlice');
axis on;
axis square;
xlabel('Original slice');

binaryImage = mySlice > threshold;

subplot(4,7,14-left, 'align');
imagesc(binaryImage');
axis on;
axis square;
xlabel('Thresholded image');

holeImage = WFK_findHoleIn(binaryImage);

subplot(4,7,21-left, 'align');
imagesc(holeImage');
axis on;
axis square;
xlabel('Detected ''hole'' ');
drawnow;

numPixels = sum(sum(holeImage));
end

