addpath('/data/wayne/matlab/NIFTI');
addpath('/data/wayne/matlab/general');

dir_input = '/data/projects/CVR/GUI_subjects/ChanR16';
cd(dir_input);
display(dir_input);

slice_z = 12;

fileID = fopen(strcat(dir_input,'/metadata/noprocessing.txt'),'r');
format = '%d';
A = fscanf(fileID,format);

if A == 1
    tag = 'processed_not';
else
    tag = 'processed';
end

fname = strcat('data/',tag,'/CVR_',subj.date,'/final/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'.nii');
processed = load_nii([dir_input '/' fname]);

[processed.x,processed.y,processed.z] = size(processed.img);

processed_data = (double(imresize(squeeze(processed.img(:,:,slice_z)),[processed.x processed.y]))-10) / 500;

figure,
imshow(processed_data);

nii = make_nii(processed_data);
processed_slice = strcat('timeseries/processed_data.nii');
save_nii(nii,processed_slice);

h = imfreehand('Closed','True');

binaryImage = h.createMask();
binaryImage = double(binaryImage);

blackMaskedImage = processed_data(:,:,:);
blackMaskedImage(~binaryImage) = 0;
figure,
imshow(blackMaskedImage);

nii = make_nii(binaryImage,4);
save_mask = strcat('timeseries/maskedfunctional.nii');
save_nii(nii,save_mask);

timeseries = strcat(dir_input,'/timeseries/work.1D');
newplot = load(timeseries);
figure('Name','Timeseries'),
plot(newplot); 