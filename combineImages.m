function X=combineImages(front,side)

i1=imread(front);
i2=imread(side);
Views=cell(2,1);
Views{1}=i1;
Views{2}=i2;

[x,y,z]=size(Views{1});
Views{2}=imresize(Views{2},[x y]);
% Read the first image from the image set.

I=Views{1};
% Initialize features for I(1)
grayImage = rgb2gray(I);
points = detectSURFFeatures(grayImage);
disp(points);
[features, points] = extractFeatures(grayImage, points);

% Initialize all the transforms to the identity matrix. Note that the
% projective transform is used here because the building images are fairly
% close to the camera. Had the scene been captured from a further distance,
% an affine transform would suffice.
tforms(2) = projective2d(eye(3));

% Iterate over remaining image pairs
for n = 2:length(Views)

    % Store points and features for I(n-1).
    pointsPrevious = points;
    featuresPrevious = features;

    % Read I(n).
    %I = read(buildingScene, n);
    I=Views{n};
    % Detect and extract SURF features for I(n).
    grayImage = rgb2gray(I);
    points = detectSURFFeatures(grayImage);
    disp(points);
    [features, points] = extractFeatures(grayImage, points);

    % Find correspondences between I(n) and I(n-1).
    indexPairs = matchFeatures(features, featuresPrevious);

    matchedPoints = points(indexPairs(:,1), :);
    disp(matchedPoints);
    matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);

    % Estimate the transformation between I(n) and I(n-1).
    tforms(n) = estimateGeometricTransform(matchedPoints, matchedPointsPrev,...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);

    % Compute T(1) * ... * T(n-1) * T(n)
    tforms(n).T = tforms(n-1).T * tforms(n).T;
end
[pathstr, fname, ext] = fileparts(front);
X=strcat(fname,'1.jpg');

imageSize = size(I);  % all the images are the same size

% Compute the output limits  for each transform
for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
end

imageSize = size(I);  % all the images are the same size

avgXLim = mean(xlim, 2);

[~, idx] = sort(avgXLim);

centerIdx = floor((numel(tforms)+1)/2);

centerImageIdx = idx(centerIdx);

Tinv = invert(tforms(centerImageIdx));

for i = 1:numel(tforms)
    tforms(i).T = Tinv.T * tforms(i).T;
end

for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
end

% Find the minimum and maximum output limits
xMin = min([1; xlim(:)]);
xMax = max([imageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([imageSize(1); ylim(:)]);

% Width and height of combine.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" combine.
combine = zeros([height width 3], 'like', I);

blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

% Create a 2-D spatial reference object defining the size of the combine.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
combineView = imref2d([height width], xLimits, yLimits);

% Create the combine.
for i = 1:2

    I = Views{i};

    % Transform I into the combine.
    warpedImage = imwarp(I, tforms(i), 'OutputView', combineView);

    % Overlay the warpedImage onto the combine.
    combine = step(blender, combine, warpedImage, warpedImage(:,:,1));
end
Y=strcat(fname,'11.jpg');
imwrite(combine,Y);
if(exist(X))
    display('Y');
else
    display('N');
    X=Y;
end

