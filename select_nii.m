function loadimage(source,callbackdata,image,path,image_var)

[image,path] = uigetfile('*.nii','/data/projects/CVR/metadata/sandbox');
image_var = load_nii([path '/' image]);

end