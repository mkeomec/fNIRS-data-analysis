function [AUC,amplitude,cog,WP] = GetStatisticDeconv_20150120(d,timeinterval1,timeinterval2, baselinetime1,baselinetime2,SubID, WP, cog)
%Outputs amplitude and area under curve for defined data
%First amplitude/AUC is for oxygenated Hb data, second is for deoxygenated
%takes d as outdata from block avging code
%d(1,:) = labtimes, d(2,:) = Hbo2 data, d(3,:) = HbR data
%baselinetime is the time interval (in seconds) as a vector which we define a baseline
delimiter = '_';
%SubID = strtok(d,delimiter);

y = strfind(d,'no');
%cog = str2num(d(y+2));

z = strfind(d,'_');
%WP = str2num(d(z(1)+3:z(2)-1));

d = importdata(d);
d = d';
baselinetimeO2 = d(2,find(d(1,:)==baselinetime1(1)):find(d(1,:)==baselinetime1(2)));
baselineO2 = min(baselinetimeO2);

baselinetimeR = d(3,find(d(1,:)==baselinetime2(1)):find(d(1,:)==baselinetime2(2)));
baselineR = max(baselinetimeR);

%Calculate area under cureve for block-averaged data
MATO2 = d(2,find(d(1,:)==timeinterval1(1)):find(d(1,:)==timeinterval1(2)));
MATO2 = MATO2 - baselineO2;
MATR = d(3,find(d(1,:)==timeinterval2(1)):find(d(1,:)==timeinterval2(2)));
MATR = MATR - baselineR;

AUC = [trapz(MATO2)/25,trapz(MATR)/25];

%Calculate amplitude of block-averaged data
amplitudeO2 = max(MATO2);
amplitudeR = min(MATR);
amplitude = [amplitudeO2, amplitudeR];


FID = fopen(strcat('ResultsStatistics_Deconv',num2str(SubID),'NoISI','_01-2015.txt'),'a+');
fprintf(FID,'%d %d %d %d %d %d \r\n',[WP cog AUC amplitude]');
fclose(FID);


    
    



