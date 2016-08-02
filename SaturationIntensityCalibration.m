folder='\\Elder-pc\j\Elder Backup Raw Images\2016\2016-08\2016-08-01\';
filelist={'08-01-2016_19_46_54_top';'08-01-2016_19_46_00_top';'08-01-2016_19_45_06_top';'08-01-2016_19_44_12_top';'08-01-2016_19_41_05_top';'08-01-2016_19_40_10_top';'08-01-2016_19_39_16_top';'08-01-2016_19_36_40_top';'08-01-2016_19_34_19_top';'08-01-2016_19_33_25_top';'08-01-2016_19_32_31_top';'08-01-2016_19_31_37_top';'08-01-2016_19_30_43_top';'08-01-2016_19_29_49_top';'08-01-2016_19_28_55_top';'08-01-2016_19_28_01_top'};
%list=2:2:54;
%filelist=filelist(list);
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
Nsat=85;
Num=[];
Numlist={};
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
Nsatlist=linspace(20,220,40);
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
    P=polyfit(woaMeanlist,Numlist,1);
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