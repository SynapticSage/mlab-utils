function T = structavg(S, dim, varargin)

T = nd.structfun(S, dim, 'fun', @nanmean, varargin{:});