%%
filefolder='\\Elder-pc\j\Elder Backup Raw Images\2016\2016-08\2016-08-01\';
filelist={'08-01-2016_19_02_39_top';'08-01-2016_19_01_45_top';'08-01-2016_19_00_51_top';'08-01-2016_18_59_57_top';'08-01-2016_18_57_16_top'};
ImageTime=[10;8;6;4;2];
%%
ROI=[360,440,650,1050];
imglist={};

for i=1:length(filelist)
    img=fitsread([filefolder,filelist{i},'.fits']);
    img=img(ROI(2):ROI(4),ROI(1):ROI(3),:);
    imglist=[imglist;img];

end

%%
Z=ROI(2):ROI(4);
Z=Z';
Zth1=500;Zth2=950;
Num=[];
NumB=[];
Nsat=inf;
mask1=Z>Zth1;mask2=Z<Zth2;
mask=mask1&mask2;


for i=1:length(imglist)
    
    Nmap=AtomNumber(imglist{i},(0.7*10^-6)^2,0.215*10^-12/2, Nsat );
    Nmap=CleanImage(Nmap );
    nz=sum(Nmap,2);
    nz=TailTailor(nz,Z,Zth1,Zth2);
    Num=[Num;sum(nz(mask))];  
    disp(i)
end
%%
scatter(ImageTime,Num)

