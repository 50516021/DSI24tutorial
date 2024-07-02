function y = fadein(ms, x, fs)
%FADEIN   apply fade-in effect to input signal
%   fadein(ms, x, fs) adds fade-in effect to input signal x of
%   sampling frequency fs Hz, by applying Hanning window
%   (technically a hann window because both wings of the curve are
%   zero).
%
%   Input:
%      ms - length of fade-in in milliseconds
%       x - input signal
%      fs - samling frequency
%
%   Example: cabin announcement in an airplane
%      sound(fadein(50, fadeout(950, sinewave(440, 1000, fs), fs), fs), fs)

%   2004-11-11 by MARUI Atsushi
%   2005-04-04 now works with multichannel audio
%   2009-11-11 changed to cosine raise (instead of hann)

if length(x)~=size(x,1)
  x = x';
end

t = floor(ms/1000 * fs);

if false
  % hanning window
  w = hann(2 * t);
  w = w(1:t);
else
  % raised cosine
  tt = (1:t)/t;
  w = cos(tt*pi+pi) / 2 + 0.5;
end

y = x;
for i=1:t
  y(i,:) = y(i,:) * w(i);
end

