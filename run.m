clc; 
clear all;
close all;

% Set folder paths
inputFolder = "C:\Users\shaun\Downloads\RLE\RLE\evaluation\low"; % Input images
outputFolder = "C:\Users\shaun\Downloads\RLE\RLE\evaluation\low_LIME"; % Output images

% Create output folder if it doesn't exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Get all image files in input folder
imgFiles = dir(fullfile(inputFolder, '*.*')); % Read all files
imgFiles = imgFiles(~[imgFiles.isdir]); % Remove directories

% LIME Parameters
para.lambda = 0.15;  % Trade-off coefficient
para.sigma = 2;      % Sigma for Strategy III
para.gamma = 0.7;    % Gamma correction
para.solver = 1;     % 1: Sped-up Solver, 2: Exact Solver
para.strategy = 3;   % Strategy selection

post = true; % Apply post-processing (denoising)?

% Loop through images
for k = 1:length(imgFiles)
    % Read image
    filename = fullfile(inputFolder, imgFiles(k).name);
    L = imresize(im2double(imread(filename)), 1);

    % Apply LIME enhancement
    tic;
    [I, T_ini, T_ref] = LIME(L, para);
    toc;

    % Post-processing with BM3D denoising
    if post
        YUV = rgb2ycbcr(I);
        Y = YUV(:,:,1);
        
        sigma_BM3D = 10;
        [~, Y_d] = BM3D(Y, Y, sigma_BM3D, 'lc', 0);

        I_d = ycbcr2rgb(cat(3, Y_d, YUV(:,:,2:3)));
        I_f = (I) .* repmat(T_ref, [1,1,3]) + I_d .* repmat(1 - T_ref, [1,1,3]);
    end

    % Convert to uint8 and save image
    J = im2uint8(I);
    outputFile = fullfile(outputFolder, imgFiles(k).name);
    imwrite(J, outputFile);

    % Display progress
    disp(['Processed and saved: ', imgFiles(k).name, ' (', num2str(k), '/', num2str(length(imgFiles)), ')']);
end

disp('✅ Image processing completed!');
