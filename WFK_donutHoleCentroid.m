function [aveRow,aveCol] = WFK_donutHoleCentroid(mySlice,threshold)
% Given a two-dimensional slice of a volume,
% (essentially, a gray scale cross-section of a lead),
% threshold the image to a binary image, and then find a
% single, large interior hole; if there is one, then find the centroid
% of the interior hole.
colormap gray;
% subplot(4,5, 5); axis off; cla;
% subplot(4,5,10); axis off; cla;
% subplot(4,5,15); axis off; cla;
% subplot(4,5,20); axis off; cla;
% 
% subplot(4,5,5);
% imagesc(mySlice);
% axis on;
% axis square;
% xlabel('Original slice');

binaryImage = mySlice > threshold;
% 
% subplot(4,5,10);
% imagesc(binaryImage);
% axis on;
% axis square;
% xlabel('Thresholded image');

holeImage = WFK_findHoleIn(binaryImage);
% 
% subplot(4,5,15);
% imagesc(holeImage);
% axis on;
% axis square;
% xlabel('Detected hole');

[holeYindices, holeXindices] = find(holeImage);
aveRow = mean(holeYindices);
aveCol = mean(holeXindices);

end

