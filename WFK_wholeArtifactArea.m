function [ numPixels, centroidX, centroidY ] = WFK_wholeArtifactArea(mySlice,threshold,left)
% Given a two-dimensional slice of a volume,
% (essentially, a gray scale cross-section of a lead),
% threshold the image to a binary image, and then count and return
% the number of pixels in that binary image.  Otherwise, return zero.
subplot(4,7, 7-left, 'align' ); axis off; cla;
subplot(4,7,14-left, 'align' ); axis off; cla;
subplot(4,7,21-left, 'align' ); axis off; cla;
subplot(4,7,28-left, 'align' ); axis off; cla;
subplot(4,7, 7-left, 'align;');
colormap gray;
imagesc(mySlice);
axis on;
axis square;
xlabel('Original slice');
binaryImage = mySlice > threshold;
subplot(4,7,14-left, 'align');
imagesc(binaryImage);
axis on;
axis square;
xlabel('Seeking lead tip');
drawnow;
[Yindices, Xindices] = find(binaryImage);
numPixels = sum(sum(binaryImage));
centroidY = mean(Yindices);
centroidX = mean(Xindices);
end

