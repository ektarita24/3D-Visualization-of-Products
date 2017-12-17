clc;
close all;
clear all;
warning off;
%Select Query Image Path And Name
[query_fname, query_fpathname] = uigetfile('*.jpg; *.png; *.bmp', 'Select front view query image');

if (query_fname ~= 0)
    query_fullpath = strcat(query_fpathname, query_fname);%concates the fullpath with filename
    frontview=query_fullpath;
    figure,imshow(frontview);
    [pathstr, fname, ext] = fileparts(query_fullpath); % fiparts returns char type
    videoName=fname;
    if ( strcmp(lower(ext), '.jpg') == 1 || strcmp(lower(ext), '.png') == 1 ...
            || strcmp(lower(ext), '.bmp') == 1 )%lower(ext) convertsthe extension to lower case
        
        [X,map] = imread( fullfile( pathstr, strcat(fname, ext) ) );% Get File Name 
        %X=imresize(X,[500 500]);
        F=depthEstimation(X);
        fname=strcat(fname,'FrontView.jpg');
        imwrite(F,fname);
       
    else
        errordlg('You have not selected the correct file type');
    end
else
    return;
end

[query_bname, query_bpathname] = uigetfile('*.jpg; *.png; *.bmp', 'Select back view query image');

if (query_bname ~= 0)
    query_fullpath = strcat(query_bpathname, query_bname);%concates the fullpath with filename
    [pathstr, bname, ext] = fileparts(query_fullpath); % fiparts returns char type
    if ( strcmp(lower(ext), '.jpg') == 1 || strcmp(lower(ext), '.png') == 1 ...
            || strcmp(lower(ext), '.bmp') == 1 )%lower(ext) convertsthe extension to lower case
        
        [X,map] = imread( fullfile( pathstr, strcat(bname, ext) ) );% Get File Name 
        %X=imresize(X,[500 500]);
        B=depthEstimation(X);
        bname=strcat(bname,'BackView.jpg');
        imwrite(B,bname);
        %clears all memory allocated for above variable.
    else
        errordlg('You have not selected the correct file type');
    end
else
    return;
end


[query_sname, query_spathname] = uigetfile('*.jpg; *.png; *.bmp', 'Select side view query image');

if (query_sname ~= 0)
    query_fullpath = strcat(query_spathname, query_sname);%concates the fullpath with filename
    sideview=query_fullpath;
    [pathstr, sname, ext] = fileparts(query_fullpath); % fiparts returns char type
    if ( strcmp(lower(ext), '.jpg') == 1 || strcmp(lower(ext), '.png') == 1 ...
            || strcmp(lower(ext), '.bmp') == 1 )%lower(ext) convertsthe extension to lower case
        
        [X,map] = imread( fullfile( pathstr, strcat(sname, ext) ) );% Get File Name 
        %X=imresize(X,[500 500]);
        S=depthEstimation(X);
        sname=strcat(sname,'SideView.jpg');
        imwrite(S,sname);
    else
        errordlg('You have not selected the correct file type');
    end
else
    return;
end

c=combineImages(frontview,sideview);
[X,map]=imread(c);
C=combinedDepthEstimation(X);

images=cell(16,1);
images{1}=imread(fname);
images{2}=imread(sname);
images{3}=imread(bname);
images{4}=imread(fname);
images{5}=imread(sname);
images{6}=imread(bname);
images{7}=imread(fname);
images{8}=imread(sname);
images{9}=imread(bname);
images{10}=imread(fname);
images{11}=imread(sname);
images{12}=imread(bname);
images{13}=imread(fname);
images{14}=imread(sname);
images{15}=imread(bname);
images{16}=imread(fname);

s=size(images{1});
row=s(1);
col=s(2);
images{1}=imresize(images{1},[row col]);
images{2}=imresize(images{2},[row col]);
images{3}=imresize(images{3},[row col]);
images{4}=imresize(images{4},[row col]);
images{5}=imresize(images{5},[row col]);
images{6}=imresize(images{6},[row col]);
images{7}=imresize(images{7},[row col]);
images{8}=imresize(images{8},[row col]);
images{9}=imresize(images{9},[row col]);
images{10}=imresize(images{10},[row col]);
images{11}=imresize(images{11},[row col]);
images{12}=imresize(images{12},[row col]);
images{13}=imresize(images{13},[row col]);
images{14}=imresize(images{14},[row col]);
images{15}=imresize(images{15},[row col]);
images{16}=imresize(images{16},[row col]);

videoName=strcat(videoName,'Video.avi');
writerObj=VideoWriter(videoName);
writerObj.FrameRate=1;
secsPerImage=[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
open(writerObj);
for u=1:length(images)
    frame=im2frame(images{u});
    for v=1:secsPerImage(u)
        writeVideo(writerObj,frame);
    end
end
close(writerObj);
implay(videoName);