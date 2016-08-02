%%
filefolder='\\Elder-pc\j\Elder Backup Raw Images\2016\2016-08\2016-08-01\';
filelist={'08-01-2016_16_07_52_TopA';'08-01-2016_16_07_52_TopB';'08-01-2016_16_07_00_TopA';'08-01-2016_16_07_00_TopB';'08-01-2016_16_05_40_TopA';'08-01-2016_16_05_40_TopB';'08-01-2016_16_04_49_TopA';'08-01-2016_16_04_49_TopB';'08-01-2016_16_03_57_TopA';'08-01-2016_16_03_57_TopB';'08-01-2016_16_03_05_TopA';'08-01-2016_16_03_05_TopB';'08-01-2016_16_02_14_TopA';'08-01-2016_16_02_14_TopB';'08-01-2016_16_01_22_TopA';'08-01-2016_16_01_22_TopB';'08-01-2016_16_00_30_TopA';'08-01-2016_16_00_30_TopB';'08-01-2016_15_59_39_TopA';'08-01-2016_15_59_39_TopB';'08-01-2016_15_58_17_TopA';'08-01-2016_15_58_17_TopB';'08-01-2016_15_57_26_TopA';'08-01-2016_15_57_26_TopB';'08-01-2016_15_56_34_TopA';'08-01-2016_15_56_34_TopB'};
frequencylist=[145.650000000000;145.650000000000;141.150000000000;141.150000000000;144.650000000000;144.650000000000;142.150000000000;142.150000000000;142.650000000000;142.650000000000;147.150000000000;147.150000000000;146.650000000000;146.650000000000;146.150000000000;146.150000000000;141.650000000000;141.650000000000;144.150000000000;144.150000000000;145.150000000000;145.150000000000;143.150000000000;143.150000000000;143.650000000000;143.650000000000];
frequencylist=frequencylist(2:2:length(filelist));
fileAlist=filelist(1:2:length(filelist)-1);
fileBlist=filelist(2:2:length(filelist));
frequency0=146.15;
%%
ROI=[360,440,650,1050];
imgAlist={};
imgBlist={};

for i=1:length(fileAlist)
    imgA=fitsread([filefolder,fileAlist{i},'.fits']);
    imgA=imgA(ROI(2):ROI(4),ROI(1):ROI(3),:);
    imgAlist=[imgAlist;imgA];
    
    imgB=fitsread([filefolder,fileBlist{i},'.fits']);
    imgB=imgB(ROI(2):ROI(4),ROI(1):ROI(3),:);
    imgBlist=[imgBlist;imgB];
end

%%
Z=ROI(2):ROI(4);
Z=Z';
Zth1=500;Zth2=950;
NumA=[];
NumB=[];
Nsat=inf;
mask1=Z>Zth1;mask2=Z<Zth2;
mask=mask1&mask2;


for i=1:length(imgAlist)
    
    NmapA=AtomNumber(imgAlist{i},(0.7*10^-6)^2,0.215*10^-12/2, Nsat );
    NmapA=CleanImage(NmapA );
    nzA=sum(NmapA,2);
    nzA=TailTailor(nzA,Z,Zth1,Zth2);
    NumA=[NumA;sum(nzA(mask))];


    NmapB=AtomNumber(imgBlist{i},(0.7*10^-6)^2,0.215*10^-12/2, Nsat );
    NmapB=CleanImage(NmapB );
    nzB=sum(NmapB,2);
    nzB=TailTailor(nzB,Z,Zth1,Zth2);
    NumB=[NumB;sum(nzB(mask))];
    
    disp(i)
end
%%


%%
detuning=(frequencylist-frequency0)*2;
RelDiff=(NumA-NumB)./NumA*100;

scatter(detuning,RelDiff);
xlabel('detuning (MHz)'); ylabel('Relative difference in Atom number (%)');

