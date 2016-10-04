function [ peaks ] = WFK_findPeaks( area )
%
% Given a linear vector of areas of holes in slices,
% return a list of the indices of the local maxima (peaks) in the vector.
%
maxArea = max(max(area));
quarterMax = 0.25 * maxArea;
firstDeriv = area(2:end) - area(1:end-1);
focalArea = area(2:end-1);
focalFirstDeriv = firstDeriv(1:end-1);
nextFirstDeriv = firstDeriv(2:end);
posToNegCrossings = (focalFirstDeriv >= 0) & (nextFirstDeriv < 0) ...
                    & (focalArea > quarterMax);
peaks = find(posToNegCrossings);
peaks = peaks + 1;
% 
% subplot(4,5,5);  axis off; cla;
% subplot(4,5,10); axis off; cla;
% subplot(4,5,15); axis off; cla;
% subplot(4,5,20); axis off; cla;
% 
% subplot(4,5,5);
% axis on;
% plot(area);
% xlabel('area');
% 
% subplot(4,5,10);
% axis on;
% d = double(posToNegCrossings) * 200.0;
% plot(area);
% hold on;
% plot(d,'r');
% xlabel('Identified peaks in hole area');
% 
% pause on;
% pause (2.0);

end

