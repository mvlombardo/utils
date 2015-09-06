function d = cohens_d(x,y,DIM)
% 
% Function will compute cohen's d effect size.
%
% INPUT
%	x = matrix or vector
%	y = matrix or vector
%	DIM = specify the dimension which samples are along
%
% Example usage
%
% x = [1:100]'
% y = [101:200]'
% d = cohens_d(x, y, 1)
%
% written by mvlombardo - 30.08.2015
%

% n-1 for x and y
lx = size(x,DIM)-1;
ly = size(y,DIM)-1;

% mean difference (numerator)
md = abs(nanmean(x,DIM) - nanmean(y,DIM));

% pooled variance (denominator)
csd = (lx .* nanvar(x,0,DIM)) + (ly .* nanvar(y,0,DIM));
csd = sqrt(csd./(lx + ly));

% Cohen's d
d = md./csd;

end % function d = cohens_d(x,y,DIM)