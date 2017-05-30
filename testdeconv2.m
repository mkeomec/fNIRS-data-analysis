function [timevec, rhrf, rhrfStd] = testdeconv2(dataFilename,optical,PVTtrigger,cogno)

d = importdata(optical);
t = importdata(PVTtrigger);
t = t(:,1);

t(find(t==0)) = [];
t(:,1) = t(:,1) - d(1,2);

d(:,2) = d(:,2) - d(1,2);

OpticalData = zeros(length(d),3);
OpticalData(:,1) = d(:,2);
OpticalData(:,2) = d(:,3);
OpticalData(:,3) = d(:,4);

ov = make_onsetvec(t(:,1),OpticalData(:,1));

settings.preRFseconds = 5;   % pre-stimulus-onset time (second)
settings.sucRFseconds = 15;  % suc-stimulus-onset time (second)
settings.sampRate = 25;
settings.meansubtract = 1;   % mean-subtract each column of data
settings.sfProc = 0;    % 0: processing relatively short timeseries and speed is relativey fast
                        % 1: processing relatively long timeseries and speed is relatively slow    
settings.invMode = 'MP'; % 'MP' or "SVD"
settings.threshold = 1E-8; % threshold for "SVD"
settings.showUpdate = 0; % 1: show update in command window; 0: doesn't show update

colors = ['x','r','b','k'];
figure()
hold on

% axis([-5,15, -.15,.2])
[timevec,rhrf,rhrfStd] = ninDeconv_GS(OpticalData(:,2:3),ov,settings); % deconv using all events
errorbar(timevec,rhrf(:,1),rhrfStd(:,1)/1E6,'r');
errorbar(timevec,rhrf(:,2),rhrfStd(:,2)/1E6,'b');

strcat(dataFilename,'_cogno',num2str(cogno))
saveas(h,strcat(dataFilename,'_cogno',num2str(cogno)),'jpeg')


% errorbar(timevec,rhrf(:,3),rhrfStd(:,3),'k')

%settings.meansubtract = 0;
%[timevec,rhrf,rhrfStd] = ninDeconv_GS(d(:,4),ov,settings); % deconv using all events
%errorbar(timevec,rhrf/20,rhrfStd/20,'y')
