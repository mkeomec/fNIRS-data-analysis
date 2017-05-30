function DoItAllRedo_Deconv_20150123(SubID,WPlist)
for i = 1:length(WPlist)
    for j = 1:7
        k = strcat('DeconvData_',num2str(SubID),'GX_WP',num2str(WPlist(i)),'_cogno',num2str(j),'_samp25_01-2015.txt');
        if exist(k,'file')
    GetStatisticDeconv_20150120(k,[2 6],[2 6],[0 3],[0 3],SubID,WPlist(i),j);
        end
    end
end
