folder='J:\Elder Backup Raw Images\2016\2016-07\2016-07-26\';
filelist={'07-26-2016_21_21_20_TopA';'07-26-2016_21_21_20_TopB';'07-26-2016_21_20_28_TopA';'07-26-2016_21_20_28_TopB';'07-26-2016_21_19_36_TopA';'07-26-2016_21_19_36_TopB';'07-26-2016_21_18_44_TopA';'07-26-2016_21_18_44_TopB';'07-26-2016_21_17_52_TopA';'07-26-2016_21_17_52_TopB';'07-26-2016_21_16_59_TopA';'07-26-2016_21_16_59_TopB';'07-26-2016_21_16_07_TopA';'07-26-2016_21_16_07_TopB';'07-26-2016_21_15_15_TopA';'07-26-2016_21_15_15_TopB';'07-26-2016_21_12_45_TopA';'07-26-2016_21_12_45_TopB';'07-26-2016_21_11_53_TopA';'07-26-2016_21_11_53_TopB';'07-26-2016_21_11_01_TopA';'07-26-2016_21_11_01_TopB';'07-26-2016_21_10_09_TopA';'07-26-2016_21_10_09_TopB';'07-26-2016_21_09_16_TopA';'07-26-2016_21_09_16_TopB';'07-26-2016_21_08_24_TopA';'07-26-2016_21_08_24_TopB';'07-26-2016_21_07_32_TopA';'07-26-2016_21_07_32_TopB';'07-26-2016_21_06_40_TopA';'07-26-2016_21_06_40_TopB';'07-26-2016_21_04_55_TopA';'07-26-2016_21_04_55_TopB';'07-26-2016_21_04_03_TopA';'07-26-2016_21_04_03_TopB';'07-26-2016_21_01_08_TopA';'07-26-2016_21_01_08_TopB';'07-26-2016_21_00_16_TopA';'07-26-2016_21_00_16_TopB';'07-26-2016_20_59_24_TopA';'07-26-2016_20_59_24_TopB';'07-26-2016_20_58_32_TopA';'07-26-2016_20_58_32_TopB';'07-26-2016_20_57_40_TopA';'07-26-2016_20_57_40_TopB';'07-26-2016_20_56_48_TopA';'07-26-2016_20_56_48_TopB';'07-26-2016_20_55_03_TopA';'07-26-2016_20_55_03_TopB';'07-26-2016_20_54_11_TopA';'07-26-2016_20_54_11_TopB';'07-26-2016_20_53_19_TopA';'07-26-2016_20_53_19_TopB'};
list=2:2:54;
filelist=filelist(list);
warning('off','all')
%%
ROI=[360,440,650,1050];
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
WOAThreshold1=000;
WOAThreshold2=inf;
mask1=woaMean<WOAThreshold1;
mask2=woaMean>WOAThreshold2;
mask=mask1 | mask2;
imglist(mask)=[];
woaMean(mask)=[];

Z=ROI(2):ROI(4);
Z=Z';
Nsat=200;
Num=[];
Numlist={i};
for i=1:length(imglist)
    woa=img(:,:,2)-img(:,:,3);
    Nmap=AtomNumber(imglist{i},(1.4*10^-6)^2,0.215*10^-12/2, Nsat );
    Nmap=CleanImage(Nmap );
    nz=sum(Nmap,2);
    nz=TailTailor(nz,Z,500,950);
    Num=[Num;sum(nz)];
    Numlist=[Numlist;nz];
    %Num=[Num;sum(Nmap(:))];
end

scatter(woaMean,Num);
ylim([0,max(Num)])
%%
Nsatlist=linspace(70,450,60);
Stdlist=[];
klist=[];
for i=1:length(Nsatlist)
    tic
    Numlist=[];
    woaMeanlist=[];
    for j=1:length(imglist)
        imgtemp=imglist{j};
        Nmap=AtomNumber(imglist{j},(1.4*10^-6)^2,0.215*10^-12/2, Nsatlist(i) );
        Nmap=CleanImage(Nmap);
        woa=sum(sum(imgtemp(:,:,2)-imgtemp(:,:,3)));
        nz=sum(Nmap,2);
        nz=TailTailor(nz,Z,500,950);
        woaMeanlist=[woaMeanlist;woa];
        Numlist=[Numlist;sum(nz)];
        
    end
    P=polyfit(woaMeanlist,Numlist,2);
    klist=[klist;P(1)];
    Stdlist=[Stdlist;std(Numlist)];
    toc
end  
%%
scatter(Nsatlist,Stdlist);
xlabel('Nsat');ylabel('Variance of total atom number');

%%
scatter(Nsatlist,klist);
xlabel('Nsat');ylabel('Variance of total atom number');

%%
plot(Z,Numlist{1}/max(Numlist{1}),Z,Numlist{3}/max(Numlist{3}),Z,Numlist{5}/max(Numlist{5}),Z,Numlist{7}/max(Numlist{7}),Z,Numlist{9}/max(Numlist{9}))
ylabel('n_{1d} (a.u.)');xlabel('z (pixel)');