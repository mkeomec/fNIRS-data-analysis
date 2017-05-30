
function [onsetvec] = make_onsetvec( onset_times, timebase )
% make_onsetvec creates a 0/1 vector, with 1s where there is a trial
% onset
% Inputs:
%       onset_times:       vector (ntrials x 1) of trial onset times
%       timebase:          vector (npts x 1) of timestamps
% output:
%       onsetvec:        vector (npts x 1) ... 0s, 1s where trial onset
%
% written by Gary Strangman
timebase;
size(timebase)
npts = length(timebase) % number of data points

onsetvec = zeros(npts,1);
for i = 1:length(onset_times)
    onset = find(timebase>=onset_times(i));
    if numel(onset) > 0;
        onsetvec(onset(1)) = 1;
        
    end
end;

