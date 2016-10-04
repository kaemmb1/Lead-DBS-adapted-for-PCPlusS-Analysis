function y = nansum(varargin)
if nargin==2
    x=varargin{1};
    dim=varargin{2};
elseif nargin==1
    x=varargin{1};
    dim=1;
end

y = sum( ((~isnan(x)) .* x), dim);

% y = nansum(x, dim) ./ N;

