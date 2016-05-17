folder='/Users/Zhenjie/Data/2016-05-16/';
filelist={'05-17-2016_00_00_52_top';'05-17-2016_00_00_00_top';'05-16-2016_23_59_08_top';'05-16-2016_23_58_15_top';'05-16-2016_23_55_06_top';'05-16-2016_23_54_13_top';'05-16-2016_23_53_21_top';'05-16-2016_23_52_28_top';'05-16-2016_23_51_36_top';'05-16-2016_23_50_44_top';'05-16-2016_23_49_51_top';'05-16-2016_23_48_59_top';'05-16-2016_23_48_07_top';'05-16-2016_23_47_14_top';'05-16-2016_23_46_22_top';'05-16-2016_23_45_29_top';'05-16-2016_23_44_37_top';'05-16-2016_23_43_45_top';'05-16-2016_23_40_38_top';'05-16-2016_23_39_21_top';'05-16-2016_23_38_29_top';'05-16-2016_23_37_04_top';'05-16-2016_23_36_12_top';'05-16-2016_23_35_19_top';'05-16-2016_23_34_27_top';'05-16-2016_23_33_35_top';'05-16-2016_23_32_43_top';'05-16-2016_23_31_50_top';'05-16-2016_23_30_41_top';'05-16-2016_23_29_49_top';'05-16-2016_23_28_56_top';'05-16-2016_23_28_04_top';'05-16-2016_23_27_11_top';'05-16-2016_23_25_54_top';'05-16-2016_23_25_01_top';'05-16-2016_23_22_32_top';'05-16-2016_23_21_31_top';'05-16-2016_23_20_38_top';'05-16-2016_23_19_30_top';'05-16-2016_23_18_38_top';'05-16-2016_23_17_45_top';'05-16-2016_23_16_28_top';'05-16-2016_23_15_16_top';'05-16-2016_23_14_10_top';'05-16-2016_23_13_17_top';'05-16-2016_23_12_25_top';'05-16-2016_23_11_32_top'};
ROI=[140,45,335,480];
%%
imglist={};
woaMean=[];

for i=1:length(filelist)
    img=fitsread([folder,filelist{i},'.fits']);
    img=img(ROI(2):ROI(4),ROI(1):ROI(3),:);
    imglist=[imglist;img];
    woa=img(:,:,2)-img(:,:,3);
    woaMean=[woaMean;mean(woa(:))];
end
%%
Z=ROI(2):ROI(4);
Z=Z';
Nsat=330;
Num=[];
for i=1:length(imglist)
    Nmap=AtomNumber(imglist{i},(1.4*10^-6)^2,0.215*10^-12/2, Nsat );
    Nmap=CleanImage(Nmap );
    nz=sum(Nmap,2);
    nz=TailTailor(nz,Z,100,400);
    Num=[Num;sum(nz)];
    %Num=[Num;sum(Nmap(:))];
end

scatter(woaMean,Num);
ylim([0,max(Num)])
%%
Nsatlist=linspace(80,600,25);
Stdlist=[];
for i=1:length(Nsatlist)
    tic
    Numlist=[];
    for j=1:length(imglist)
        Nmap=AtomNumber(imglist{j},(1.4*10^-6)^2,0.215*10^-12/2, Nsatlist(i) );
        Nmap=CleanImage(Nmap );
        nz=sum(Nmap,2);
        nz=TailTailor(nz,Z,100,400);
        Numlist=[Numlist;sum(nz)];
        
    end
    Stdlist=[Stdlist;std(Numlist)];
    toc
end  

scatter(Nsatlist,Stdlist);
