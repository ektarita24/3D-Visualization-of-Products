function B=combinedDepthEstimation(X)
xz=X;
xZ=double(xz);% Convert to double precision
figure,imshow(X); %Displays the selected original image 
sX=size(X);%Get The Size, returns a 1-by-N vector of dimension lengths
disp(sX);

% color based segmentation
if size(X,3)==3 %TEST FOR RGB IMAGE
    X=rgb2gray(X);%Convert RGB image or colormap to grayscale
end

row = sX(1);
col = sX(2);
disp(row);
disp(col);

% Qualitative Depth map construction. and line detection
nbcol =255; % specifies the range for display. Default value is 16.
cod_X = wcodemat(X,nbcol);%Extended pseudocolor matrix scaling. rescales an input matrix to a specified range for display.gives an improved view of image
% Perform one step decomposition of X using db1.
% db1 if a wavelet family. Daubechies-->db  

% Refer - http://in.mathworks.com/help/wavelet/ref/dwt2.html
% Refer - http://eeweb.poly.edu/iselesni/WaveletSoftware/standard2D.html
[ca1,chd1,cvd1,cdd1] = dwt2(X,'db1');%Single-level discrete 2-D wavelet transform. 
% The dwt2 command performs a single-level two-dimensional wavelet decomposition with respect to
% either a particular wavelet i.e. db1 or particular wavelet decomposition filters (Lo_D and Hi_D)
% Lo_D is the decomposition low-pass filter.
% Hi_D is the decomposition high-pass filter.
% image coding
cod_ca1 = wcodemat(ca1,nbcol);
cod_chd1 = wcodemat(chd1,nbcol);
cod_cvd1 = wcodemat(cvd1,nbcol);
cod_cdd1 = wcodemat(cdd1,nbcol);

dec2d = [...
cod_ca1, cod_chd1;...
cod_cvd1, cod_cdd1 ...
];

% disp(dec2d); displays the matrix
% geometric depth map construction i.e. obtaining horizontal and vertical
% view of the image
[ca2,chd2,cvd2,cdd2] = dwt2(ca1,'db1');
a0 = idwt2(ca1,chd1,cvd1,cdd1,'db1',sX); % Single-level inverse discrete 2-D wavelet transform
% used to reconstruct the image using db1 wavelet. 
[c,s] = wavedec2(X,2,'db1'); % It is multilevel decomposition. returns the wavelet decomposition of the matrix X at level 2,

% Depth calculation based on linear perspective information
ca2new = (ca2/max(max(ca2)))*255; % max(A) returns the largest elements along different dimensions of an array.
chd2new = chd2+128;
cvd2new = cvd2+128;
cdd2new = cdd2+128;
subchip = [...
ca2new,chd2new;...
cvd2new,cdd2new ...
];
cod_chd1new = cod_chd1+255;
cod_cvd1new = cod_cvd1+255;
cod_cdd1new = cod_cdd1+255;

% Extract the coefficients
ca2 = appcoef2(c,s,'db1',2);%Extract 2-D approximation coefficients at level 2
% computes the approximation coefficients at level N using the wavelet decomposition structure [C,S]

% extracts from the wavelet decomposition structure [C,S] the horizontal, vertical, or diagonal 
% detail coefficients for O = 'h'(or 'v' or 'd', respectively), at level N, 
% where N must be an integer such that 1 ? N ? size(S,1)-2. 
chd2 = detcoef2('h',c,s,2);
cvd2 = detcoef2('v',c,s,2);
cdd2 = detcoef2('d',c,s,2);
ca1 = appcoef2(c,s,'db1',1);
chd1 = detcoef2('h',c,s,1);
cvd1 = detcoef2('v',c,s,1);
cdd1 = detcoef2('d',c,s,1);

%Reconstruct the coefficients
% wrcoef2 reconstructs the coefficients of an image. 
% X = wrcoef2('type',C,S,'wname',N) computes the matrix of reconstructed coefficients of level N, 
% based on the wavelet decomposition structure [C,S]
a2 = wrcoef2('a',c,s,'db1',2);%Reconstruct single branch from 2-D wavelet coefficients
hd2 = wrcoef2('h',c,s,'db1',2);
vd2 = wrcoef2('v',c,s,'db1',2);
dd2 = wrcoef2('d',c,s,'db1',2);

[c,s]=upwlev2(c,s,'db1');%Single-level reconstruction of 2-D wavelet decomposition
sc=size(c);
siz = s(size(s,1),:);
ca1 = appcoef2(c,s,'db1',1);
a1 = upcoef2('a',ca1,'db1',1,siz); %  computes the 1-step reconstructed coefficients of matrix ca1 and takes the central part of size siz.
clear ca1
chd1 = detcoef2('h',c,s,1);
hd1 = upcoef2('h',chd1,'db1',1,siz);
clear chd1
cvd1 = detcoef2('v',c,s,1);
vd1 = upcoef2('v',cvd1,'db1',1,siz);
clear cvd1
cdd1 = detcoef2('d',c,s,1);
dd1 = upcoef2('d',cdd1,'db1',1,siz);
clear cdd1
a0 = waverec2(c,s,'db1'); % wavelet reconstruction
figure,imshow(a0/max(max(a0)))

figure,imshow(hd1)
imwrite(hd1,'horizontal.jpg')
figure,imshow(vd1)
imwrite(vd1,'vertical.jpg')
figure,imshow(dd1)
imwrite(dd1,'diagonal.jpg')

bgImg = imread('horizontal.jpg');%Background Image
fgImg = imread('vertical.jpg');%Foreground Image
diaImg= imread('diagonal.jpg');
B=imsharpen(xz);

%Size Validation
bg_size = size(bgImg);
fg_size = size(fgImg);
dia_size = size(diaImg);
sizeErr = isequal(bg_size, fg_size, dia_size);% returns 1 if all are equal else returns 0
if(sizeErr == 0)
    disp('Error: Images to be fused should be of same dimensions');
    return;
end
%Fuse Images
fusedImg1 = wfusimg(fgImg, diaImg,'db2',1,'max','min');
fusedImg2 = wfusimg(fusedImg1, bgImg,'db2',1,'max','min');
FI=double(fusedImg2);
figure,
imshow(fusedImg2);
hold on % Retain current graph when adding new graphs
HK=imshow(B);
hold off