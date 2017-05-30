function downsample(filename)
[a,~] = strtok(filename,'.')

data=importdata(filename);
size(data)
data=data(1:10:end,:);
size(data)

fopen(strcat(a,'samp25.txt'),'w');
 formatspec='%s\n';
 dlmwrite(strcat(a,'samp25.txt'),data,'delimiter',' ','precision',16);