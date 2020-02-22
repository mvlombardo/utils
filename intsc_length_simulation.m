function res = intsc_length_simulation(inv_freq_pow, short_length, medium_length, long_length)
%   Compute intrinsic neural timescale on simulated colored noise at
%   different lengths of the time series. Allows us to see how a sample 
%   time series of a certain length get close to the actual value when 
%   computed on the full time series.
%
%   INPUT
%   
%   inv_freq_pow = number indicating inverse frequency power (1 for
%   pink noise, 2 for brown noise, 0 for white noise
%   short_length = length of short length sample time series (e.g., 300)
%   medium_length = length for medium length sample time series (e.g., 600)
%   long_length = length for long length sample time series (e.g., 20000)
% 
%   Example usage:
%
%   inv_freq_pow = 1.2; 
%   short_length = 300; 
%   medium_length = 600; 
%   long_length = 20000; 
%   res = intsc_length_simulation(inv_freq_pow, short_length, medium_length, long_length);
%

%% some initial things to set
% set seed for reproducibility
rng(3);

% length of the time series data to sample from
total_length = 500000;

%% simulate time series
% noise_ts = dsp.ColoredNoise('Color',noise_color, ...
%     'SamplesPerFrame',total_length,'NumChannels',1);
noise_ts = dsp.ColoredNoise(inv_freq_pow, ...
    'SamplesPerFrame',total_length, ...
    'NumChannels',1);

data2use = noise_ts();

%% compute actual intsc on the full time series
tr = 1.302;
[real_intsc] = intsc(data2use, tr);


%% now compute intsc on sample time series of shorter length than original
% number of times to sample time series of certain length
n_samples = 1000;

for i = 1:n_samples
    
    % long length time series
    len2use = long_length;
    
    a = randperm(length(data2use)-len2use+10);
    start_idx = a(1);
    idx2use = start_idx:1:((start_idx+1)+len2use);
    long_length_res(i,1) =  intsc(data2use(idx2use), tr);
    
    % medium length time series
    len2use = medium_length;
    
    a = randperm(length(data2use)-len2use+10);
    start_idx = a(1);
    idx2use = start_idx:1:((start_idx+1)+len2use);
    medium_length_res(i,1) =  intsc(data2use(idx2use), tr);

    % short length time series
    len2use = short_length;
    
    a = randperm(length(data2use)-len2use+10);
    start_idx = a(1);
    idx2use = start_idx:1:((start_idx+1)+len2use);
    short_length_res(i,1) =  intsc(data2use(idx2use), tr);
end % for i

res = [short_length_res, medium_length_res, long_length_res];

%% make a plot
figure; set(gcf,'color','white');
plot(res);
grid on; 
% plot real intcs value as black horizontal line
hold on; plot(xlim, [real_intsc,real_intsc],'k');
% add x and y-axis labels
ylabel('Intrinsic Neural Timescale'); xlabel('Sample Time Series');
% add a legend
legend(sprintf('Short %d samples',short_length), ...
    sprintf('Medium %d samples',medium_length), ...
    sprintf('Long %d samples',long_length));

end % function intsc_length_simulation



%% Watanabe's intsc function
function varargout = intsc(Series , TimeResolution)
	
%% Input
%
% Series: signal time series
% TimeResolution: time resolution of the time series (sec). 
%
%% Output
%
% STS: signal timescale. 
% ACF: autocorrelation function
% Lags: Vector of lags corresponding to ACF (0,1,2,...,nLags).
% bounds:  Two element vector indicating the approximate upper and lower
%     confidence bounds assuming that Series is an MA(M) process. Note that
%     Bounds is approximate for lags > M only.
%
%% Reference:
%   Box, G.E.P., Jenkins, G.M., Reinsel, G.C., "Time Series Analysis:
%     Forecasting and Control", 3rd edition, Prentice Hall, 1994.


%% Optional values

nLags = 20;
Q = 0;
nSTDs = 2;

% nLags: the number of the lags of the autocorrelation function to compute.
% Q: the number of lags beyond which the theoretical autocorrelation function is deemed to have died out.
% nSTDs: the number of standard deviations of the sample autocorrelation function estimation error.


[rows , columns]  =  size(Series);

if (rows ~= 1) & (columns ~= 1)
   error('GARCH:autocorr:NonVectorInput' , ' Input ''Series'' must be a vector.');
end

rowSeries   =  size(Series,1) == 1;

Series      =  Series(:);       % Ensure a column vector
n           =  length(Series);  % Sample size.
defaultLags =  20;              % BJR recommend about 20 lags for ACFs.

%
% Ensure the number of lags, nLags, is a positive
% integer scalar and set default if necessary.
%

if (nargin >= 2) & ~isempty(nLags)
  if prod(size(nLags)) > 1
     error('GARCH:autocorr:NonScalarLags' , ' Number of lags ''nLags'' must be a scalar.');
  end
  if (round(nLags) ~= nLags) | (nLags <= 0)
     error('GARCH:autocorr:NonPositiveInteger' , ' Number of lags ''nLags'' must be a positive integer.');
  end
  if nLags > (n - 1)
     error('GARCH:autocorr:LagsTooLarge' , ' Number of lags ''nLags'' must not exceed ''Series'' length - 1.');
  end
else
  nLags  =  min(defaultLags , n - 1);
end

%
% Ensure the hypothesized number of lags, Q, is a non-negative integer
% scalar, and set default if necessary.
%
if (nargin >= 3) & ~isempty(Q)
  if prod(size(Q)) > 1
     error('GARCH:autocorr:NonScalarQ' , ' Number of lags ''Q'' must be a scalar.');
  end
  if (round(Q) ~= Q) | (Q < 0)
     error('GARCH:autocorr:NegativeInteger' , ' Number of lags ''Q'' must be a non-negative integer.');
  end
  if Q >= nLags
     error('GARCH:autocorr:QTooLarge' , ' ''Q'' must be less than ''nLags''.');
  end
else
  Q  =  0;     % Default is 0 (Gaussian white noise hypothisis).
end

%
% Ensure the number of standard deviations, nSTDs, is a positive
% scalar and set default if necessary.
%

if (nargin >= 4) & ~isempty(nSTDs)
  if prod(size(nSTDs)) > 1
     error('GARCH:autocorr:NonScalarSTDs' , ' Number of standard deviations ''nSTDs'' must be a scalar.');
  end
  if nSTDs < 0
     error('GARCH:autocorr:NegativeSTDs' , ' Number of standard deviations ''nSTDs'' must be non-negative.');
  end
else
  nSTDs =  2;     % Default is 2 standard errors (95% condfidence interval).
end

%
% Convolution, polynomial multiplication, and FIR digital filtering are
% all the same operation. The FILTER command could be used to compute
% the ACF (by computing the correlation by convolving the de-meaned
% Series with a flipped version of itself), but FFT-based computation
% is significantly faster for large data sets.
%
% The ACF computation is based on Box, Jenkins, Reinsel, pages 30-34, 188.
%

nFFT =  2^(nextpow2(length(Series)) + 1);
F    =  fft(Series-mean(Series) , nFFT);
F    =  F .* conj(F);
ACF  =  ifft(F);
ACF  =  ACF(1:(nLags + 1));         % Retain non-negative lags.
ACF  =  ACF ./ ACF(1);     % Normalize.
ACF  =  real(ACF);

%
% Compute approximate confidence bounds using the Box-Jenkins-Reinsel
% approach, equations 2.1.13 and 6.2.2, on pages 33 and 188, respectively.
%

sigmaQ  =  sqrt((1 + 2*(ACF(2:Q+1)'*ACF(2:Q+1)))/n);
bounds  =  sigmaQ * [nSTDs ; -nSTDs];
Lags    =  [0:nLags]';

if nargout == 0                     % Make plot if requested.

%
%  Plot the sample ACF.
%
  lineHandles  =  stem(Lags , ACF , 'filled' , 'r-o');
  set   (lineHandles(1) , 'MarkerSize' , 4)
  grid  ('on')
  xlabel('Lag')
  ylabel('Sample Autocorrelation')
  title ('Sample Autocorrelation Function (ACF)')
  hold  ('on')
%
%  Plot the confidence bounds under the hypothesis that the underlying
%  Series is really an MA(Q) process. Bartlett's approximation gives
%  an indication of whether the ACF is effectively zero beyond lag Q.
%  For this reason, the confidence bounds (horizontal lines) appear
%  over the ACF ONLY for lags GREATER than Q (i.e., Q+1, Q+2, ... nLags).
%  In other words, the confidence bounds enclose ONLY those lags for
%  which the null hypothesis is assumed to hold.
%

  plot([Q+0.5 Q+0.5 ; nLags nLags] , [bounds([1 1]) bounds([2 2])] , '-b');

  plot([0 nLags] , [0 0] , '-k');
  hold('off')
  a  =  axis;
  axis([a(1:3) 1]);

else

%
%  Re-format outputs for compatibility with the SERIES input. When SERIES is
%  input as a row vector, then pass the outputs as a row vectors; when SERIES
%  is a column vector, then pass the outputs as a column vectors.
%
  if rowSeries
     ACF     =  ACF.';
     Lags    =  Lags.';
     bounds  =  bounds.';
  end

  % Sum of the positive ACF values

  PositiveACF = 0;
  j = 2;
  while ACF(j) > 0 && j <= nLags
      PositiveACF = PositiveACF + ACF(j);
      j = j + 1;
  end

  STS = PositiveACF * TimeResolution;

  varargout  =  {STS, ACF , Lags , bounds};

end


end % function intsc_watanabe