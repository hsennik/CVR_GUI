clear all;
close all;

addpath('/data/wayne/matlab/NIFTI');
%dir_input = '/data/projects/CVR/metadata/sandbox';

[FileName,PathName] = uigetfile('*.nii','/data/projects/CVR/metadata/sandbox/test_files');
%dname = uigetdir('/data');

% fname_anat = 'T1_nii.nii';
% fname_cereb = 'T1_cerebellar.nii';

%anatomical_view = load_nii([dir_input '/' fname_anat]);
anatomical_view = load_nii([PathName '/' FileName]); 
% Change to number of voxels?   
[voxx voxy voxz] = size(anatomical_view.img);
% Voxel size (kind of dimension)
%[sizex sizey sizez] = anatomical_view.h
[CerebFileName,CerebPathName] = uigetfile('*nii','/data/projects/CVR/metadata/sandbox/test_files');
cereb_overlay = load_nii([CerebPathName '/' CerebFileName]);
%cereb_overlay = load_nii([dir_input '/' fname_cereb]);

slice_x = 30; %30 
slice_y = 30; %75
slice_z = 30; %70

xrange = [16:190];
yrange = [30:190];
zrange = [30:190];

numx = length(xrange);
numy = length(yrange);
numz = length(zrange);

sigmin = 10; %10
sigmax = 500; %500

slice_ax = (double(repmat(imresize(squeeze(anatomical_view.img(:,:,slice_z)),[voxx voxy]), [1 1 3]))- sigmin) / sigmax ;
slice_cor = (double(repmat(imresize(squeeze(anatomical_view.img(:,slice_y,:)),[voxx voxz]), [1 1 3])) - sigmin) / sigmax;
slice_sag = (double(repmat(imresize(squeeze(anatomical_view.img(slice_x,:,:)),[voxy voxz]), [1 1 3])) - sigmin) / sigmax;

slice_ax = rot90(slice_ax(xrange,yrange,:));
slice_cor = rot90(slice_cor(xrange,zrange,:));
slice_sag = rot90(slice_sag(yrange,zrange,:));

global radio_selection;
radio_selection = 'Axial'; 

global slider_value;
slider_value = 0;

%  Create and then hide the UI as it is being constructed.
f = figure('Name', 'CVR Axial GUI',...
            'Visible','on',...
            'Position',[360,500,1200,750]);
   

bg = uibuttongroup('Title', 'Slice Dimension',...
                  'Visible','on',...
                  'Position',[0 0 .15 .4],...
                  'SelectionChangedFcn', {@bselection,slice_x,slice_y,slice_z,voxx,voxy,voxz,sigmin,sigmax,anatomical_view,xrange,yrange,zrange,cereb_overlay});
              
% Create three radio buttons in the button group.
r1 = uicontrol(bg,'Style',...
                  'radiobutton',...
                  'String','Axial',...
                  'Position',[10 200 100 30],...
                  'HandleVisibility','on');
             
r2 = uicontrol(bg,'Style','radiobutton',...
                  'String','Coronal',...
                  'Position',[10 125 100 30],...
                  'HandleVisibility','on');

r3 = uicontrol(bg,'Style','radiobutton',...
                  'String','Saggital',...
                  'Position',[10 50 100 30],...
                  'HandleVisibility','on');

%Slider object to control fourth dimension (time)
uicontrol('style', 'slider',...
            'Min',0,'Max',150,'Value',0,... %value property changes as we move the slider
            'units', 'normalized',...
            'position',[0.04 0.6 0.08 0.25],...
            'callback',{@sliderpos,slice_x,slice_y,slice_z,voxx,voxy,voxz,sigmin,sigmax,anatomical_view,xrange,yrange,zrange,cereb_overlay});
        
uicontrol('Style', 'text',....
            'units', 'normalized',...
            'position', [0.03 0.86 0.1 0.05],...
            'String', 'Slice Position');

%Dropdown menu to switch between mapping methods
htext  = uicontrol('Style','text','String','CVR Mapping Method',...
           'Position',[536,50,150,15]);
hpopup = uicontrol('Style','popupmenu',...
           'String',{'Posterior Fossa','Stimulate File','Resp. Data', 'Resp. Bellows', 'End Tidal CO2'},...
           'Position',[550,20,125,25],...
           'callback',{});
       
       
%Toggle button to overlay CVR map
tb = uicontrol('Style','togglebutton',...
                'Visible','on',...
                'String','Overlay pf mask',...
                'Value',0,'Position',[720,20,150,40],...
                'callback',{@overlay,slice_x,slice_y,slice_z,voxx,voxy,voxz,sigmin,sigmax,anatomical_view,xrange,yrange,zrange,cereb_overlay});
            
% %Push button to complete pre-processing of image
% tb = uicontrol('Style', 'pushbutton',...
%                 'String','Process Image',...
%                 'Position',[350,20,150,40]);

% axes('Position',[0,0.05,0.3,0.7])
imshow(slice_ax);
% axes('Position',[0.35,0.05,0.3,0.7])
% imshow(slice_cor);
% axes('Position',[0.7,0.05,0.3,0.7])
% imshow(slice_sag);



