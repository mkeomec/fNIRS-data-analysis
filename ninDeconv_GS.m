function [timevec, hrf, hrfStd] = ninDeconv( data, paradigm, settings )
% ninDeconv calculates haemodynamic response functions for multi-channel data 
% and multiple different paradigms
% Inputs:
%       data:       matrix (npts x nchns)
%       paradigm:   matrix (npts x ncdns)
%       settings:   structure (optional, two modes "MP" and "SVD")
% output:   
%       hrf:        matrix (nhrf x nchns x ncdns)
%       hrfStd:     matrix (nhrf x nchns x ncdns)
% 
% modified based on Gary Strangman's code
% written by Yi Yang, contact: zjuyangyi@gmail.com

if nargin < 3
    settings.preRFseconds = 5;   % pre-stimulus-onset time (second)
    settings.sucRFseconds = 10;  % suc-stimulus-onset time (second) 
    settings.sampRate = 25;      % sampling frequency
    settings.meansubract = 1;    % 1=subtract mean of each column to start
    settings.invMode = 'MP';     % "MP" (Moore-Penrose) or "SVD"
    settings.threshold = 1E-6;   % threshold for "SVD"
    settings.sfProc = 0;
    settings.showUpdate = 1;     % 1: show update; 0: doesn't show update   
end

% data = sparse(data);
% paradigm = sparse(paradigm);

if size(data,1) ~= size(paradigm,1)
    error('the lengths of data and paradigm are not equal, please check them');
end

nchns = size(data,2); % number of channels
ncdns = size(paradigm,2); % number of conditions

preRFtimepoints = floor( settings.preRFseconds * settings.sampRate );
sucRFtimepoints = floor( settings.sucRFseconds * settings.sampRate );
nhrf = preRFtimepoints + sucRFtimepoints + 1; % number of hrf points

% allocate memory for hrf
hrf = zeros(nhrf,nchns,ncdns);
hrfStd = zeros(nhrf,nchns,ncdns);

% subtract mean of each column if required
%if settings.meansubtract
    data = data - ones(size(data,1),1)*mean(data,1);
%end;

% computation is time-consuming, showing update indicates the code is
% running
%if settings.showUpdate
    h = waitbar(0,'please wait ...');
    for ii = 1:nchns
        for jj = 1:ncdns
            [hrf(:,ii,jj), hrfStd(:,ii,jj)] = ninDeconvSS( data(:,ii), paradigm(:,jj), settings);
            waitbar(((ii-1)*ncdns+jj)/(nchns*ncdns),h,...
                sprintf('%d/%d processed, please wait ... ',((ii-1)*ncdns+jj),nchns*ncdns));
        end
    end
    close(h);
%else
    for ii = 1:nchns
        for jj = 1:ncdns
            [hrf(:,ii,jj), hrfStd(:,ii,jj)] = ninDeconvSS( data(:,ii), paradigm(:,jj), settings);
        end
    end
%end    

hrf = squeeze(hrf);
hrfStd = squeeze(hrfStd);
timevec = [0:length(hrf)-1]/settings.sampRate-settings.preRFseconds;

end


%% subRoutine: ninDeconvSS

function [hrf, hrfStd] = ninDeconvSS( data, paradigm, settings )
% ninDeconvSS calculates haemodynamic response function for single
% channel data under single paradigm condition
% Inputs:
%       data:       vector (npts x 1)
%       paradigm:   vector (npts x 1)
%       settings:   structure 
% output:   
%       hrf:        vector (nhrf x 1)
%       hrfStd:     vector (nhrf x 1)
% 
% modified based on Gary Strangman's code
% written by Yi Yang, contact: zjuyangyi@gmail.com

npts = length(data); % number of data points
preRFtimepoints = floor( settings.preRFseconds * settings.sampRate );
sucRFtimepoints = floor( settings.sucRFseconds * settings.sampRate );
nhrf = preRFtimepoints + sucRFtimepoints + 1; % number of hrf points

m = data(sucRFtimepoints:npts-preRFtimepoints-1); % (ndeconv+nhrf-1:-1:nhrf);
clear data;

ndeconv = npts - nhrf + 1; % number of data points used for deconvolution
if ndeconv < nhrf
    error 'The length of data used for deconvolution is shorter than that of hrf';
end

switch settings.sfProc % slow or fast processing
    % 0: processing relatively short timeseries and speed is relativey fast
    case 0 
        % S = sparse(ndeconv,nhrf);
        S = zeros(ndeconv,nhrf);
%         for ii = 1:ndeconv
%             S(ii,:) = flipud(paradigm(ii:ii+nhrf-1));
%         end
        for ii = 1:nhrf
            S(:,ii) = paradigm(nhrf+1-ii:nhrf+ndeconv-ii);
        end
        clear paradigm;
        % S = sparse(S);
        StS = S' * S;
        % StS = full(StS);
        tmp = S' * m;
%         clear m;
    % 1: processing relatively long timeseries and speed is relatively slow    
    case 1
        StS = zeros(nhrf,nhrf);
        tmp = zeros(nhrf,1);
        for ii = 1:nhrf
            a = (paradigm(nhrf-ii+1:npts-ii+1))';
            for jj = 1:nhrf
                b = paradigm(nhrf-jj+1:npts-jj+1);
                StS(ii,jj) = a * b;
            end
            tmp(ii) = a * m;
        end
%         clear paradigm m;
end
        
switch settings.invMode
    
    case {'MP','mp','mP','Mp','Moore-Penrose'}
%         invStS = qrinv(StS);
        invStS = pinv(StS);
        
    case {'SVD','svd','Svd'}
        [U, SD, V]= svd(StS);
        sd = diag(SD);
        nSD = sum(sd > settings.threshold);
        invStS = ( U(:,1:nSD) * diag(1./sd(1:nSD)) * V(:,1:nSD)' )';
        
    otherwise
        error 'please input inversion mode as "MP" or "SVD"';
        
end

clear StS;
hrf = invStS * tmp;

if exist('S','var')
    mhat = S*hrf;
else
    mhat = zeros(size(m));
    for ii = 1:ndeconv
        subS = flipud(paradigm(ii:ii+nhrf-1));
        mhat(ii) = subS' * hrf;
    end
end

r = m - mhat;
mse = (r'*r) / (ndeconv-nhrf);
    
hrfStd = sqrt(diag(invStS)*mse);

end
