function y = WFK_ea_nanmean(varargin)
if nargin==2
    x=varargin{1};
    dim=varargin{2};
elseif nargin==1
    x=varargin{1};
    dim=1;
end

N = sum(~isnan(x), dim);
% y = nansum(x, dim) ./ N;  
y = ea_nansum(x, dim) ./ N;  % WFK August 1, 2016