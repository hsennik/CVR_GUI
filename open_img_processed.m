clear all;
close all;

addpath('/data/wayne/matlab/NIFTI');
dir_input = '/data/hannahsennik/CVR/data/recon/ChanR16';
cereb_input = '/data/hannahsennik/FSL_registration/sandbox/Output';

fname_anat = 'ChanR16_anat_brain.nii';
fname_cereb = 'cereb_Chan_stand2target.nii';

anatomical_view = load_nii([dir_input '/' fname_anat]);
[dimx dimy dimz] = size(anatomical_view.img);
cereb_overlay = load_nii([cereb_input '/' fname_cereb]);

slice_x = 30; %30 
slice_y = 75; %75
slice_z = 40; %70

xrange = [10:250];
yrange = [10:250];
zrange = [10:160];

numx = length(xrange);
numy = length(yrange);
numz = length(zrange);

sigmin = 10; %10
sigmax = 500; %500

slice_ax = (double (repmat(anatomical_view.img(:,:,slice_z),[1 1 3]) )- sigmin)/sigmax ;
%slice_ax = (double(repmat(imresize(squeeze(anatomical_view.img(:,:,slice_z)),[dimx dimy]), [1 1 3]))- sigmin) / sigmax ;
% slice_cor = (double(repmat(imresize(squeeze(anatomical_view.img(:,slice_y,:)),[dimx dimz]), [1 1 3])) - sigmin) / sigmax;
% slice_sag = (double(repmat(imresize(squeeze(anatomical_view.img(slice_x,:,:)),[dimy dimz]), [1 1 3])) - sigmin) / sigmax;

%slice_ax = rot90(slice_ax(xrange,yrange,:));
% slice_cor = rot90(slice_cor(xrange,zrange,:));
% slice_sag = rot90(slice_sag(yrange,zrange,:));

imshow(slice_ax);
% imshow(slice_cor);
% imshow(slice_sag);

mask_ax = edge(double(cereb_overlay.img(:,:,slice_z)),'Canny');

slice_ax(:,:,1) = slice_ax(:,:,1) + mask_ax;
slice_ax(:,:,2) = slice_ax(:,:,2) - mask_ax;
slice_ax(:,:,3) = slice_ax(:,:,3) - mask_ax;

cerebellum = double(cereb_overlay.img(:,:,slice_z));
cerebellum = rot90(cerebellum(xrange,yrange,:));

slice_ax = rot90(slice_ax(xrange,yrange,:));

figure,  
imshow(slice_ax); 

