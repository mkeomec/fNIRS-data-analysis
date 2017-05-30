function BatchDeconv_20150121(SubID,WPlist)
%Note: We changed the input for trigger to do deconvolution with and
%without ISI6

for i = 1:length(WPlist)
    for j = 1:7 %Assume there are 7 cogs
        optical = strcat(num2str(SubID),'_WP',num2str(WPlist(i)),'_cogno',num2str(j),'AdapData');
        if exist(strcat(optical,'.txt'),'file')
             %downsample(strcat(optical,'.txt')); %Removed when we alreadyhave samp25
            trigger = strcat('PVTtrial',num2str(SubID),'_WP',num2str(WPlist(i)),'_cog',num2str(j));
            optical_down = strcat(optical,'samp25.txt');
            testdeconv2015_01_21(optical_down,trigger,j,WPlist(i))
        end
    end
end
