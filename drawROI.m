function drawROI(source,callbackdata,slice,anat,dir_input,subj)

global ax_slider_value;

addpath('/data/wayne/matlab/NIFTI');
addpath('/data/wayne/matlab/general');

cd(dir_input);
display(dir_input);


fileID = fopen(strcat(dir_input,'/metadata/noprocessing.txt'),'r');
format = '%d';
A = fscanf(fileID,format);

if A == 1
    tag = 'processed_not';
else
    tag = 'processed';
end

fname = strcat('flirt/',subj.name,'_',subj.breathhold,'_',tag,'_to_anat.nii');
processed_to_anat = load_nii([dir_input '/' fname]);

h = imfreehand('Closed','True');

anat.slice_z = anat.slice_z + floor(ax_slider_value - anat.slice_z);
get_signal = (double(repmat(imresize(squeeze(processed_to_anat.img(:,:,anat.slice_z)),[anat.x anat.y]),[1 1 3]))-anat.sigmin) / anat.sigmax;
% get_signal = rot90(get_signal(anat.xrange,anat.yrange,:));
% get_signal = flip(get_signal,2);

figure,
imshow(get_signal);
%  Create a mask from freehand ROI 
binaryImage = h.createMask();
imshow(binaryImage);
% binaryImage = flip(binaryImage,2);
% binaryImage = rot90(binaryImage(anat.xrange,anat.yrange,:));
% binaryImage = rot90(binaryImage(anat.xrange,anat.yrange,:));
% binaryImage = rot90(binaryImage(anat.xrange,anat.yrange,:));
% imshow(binaryImage);
nii = make_nii(binaryImage);
save_mask = strcat('timeseries/mask.nii');
save_nii(nii,save_mask);

%  Display the free hand mask 
%         figure,
%         imshow(binaryImage);
% %  Calculate the area, in pixels, of the ROI 
% numberOfPixels = sum(binaryImage(:));
% %  Get coordinates of the boundary of the freehand drawing
% structBoundaries = bwboundaries(binaryImage);
% xy = structBoundaries{1};
% x = xy(:,2);
% y = xy(:,1);
%         hold on;
%         plot(x,y,'Linewidth',2);
%         drawnow;

burnedImage = get_signal(:,:,:);
burnedImage(binaryImage) = 0;
figure,
imshow(burnedImage);

blackMaskedImage = get_signal(:,:,:);
blackMaskedImage(~binaryImage) = 0;
figure,
imshow(blackMaskedImage);
% 
% mkdir(dir_input,'/timeseries');
% fileID = fopen('timeseries/mask.1D','w+'); % Open the text file in write mode to write the processed and stimulus values (initially both will be 1)
% format = '%d\n';
% fprintf(fileID,format,blackMaskedImage); % Write the filtering and stimulus values in the file (they will be used in process_fmri and analyze_fmri)
% fclose(fileID);
% 
% nii = make_nii(get_signal);
% save_mask = strcat('timeseries/get_signal.nii');
% save_nii(nii,save_mask);
%         thing = vol2vec(blackMaskedImage,0);
end