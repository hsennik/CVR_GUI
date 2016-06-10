%function bselection(source,callbackdata,slice1,slice2,slice3)

function bselection(source,callbackdata,x,y,z,vox1,vox2,vox3,min,max,anat,range1,range2,range3,cereb)

%    display(['Previous: ' callbackdata.OldValue.String]);
%    display(['Current: ' callbackdata.NewValue.String]);
%    display('------------------');

global button_state;
global radio_selection;
global slider_value;

radio_selection = get(callbackdata.NewValue,'String');

switch (radio_selection)
   case 'Axial'
%        display (radio_selection);
%        display(slider_value);
%        z = z + floor(slider_value);
%        slice1 = (double(repmat(imresize(squeeze(anat.img(:,:,z)),[vox1 vox2]),[1 1 3]))- min) / max;
%        slice1 = rot90(slice1(range1,range2,:));
%        imshow(slice1);

        z = z + floor(slider_value);
        slice1 = (double(repmat(imresize(squeeze(anat.img(:,:,z)),[vox1 vox2]),[1 1 3]))- min) / max;
        mask1 = edge(imresize(double(squeeze(cereb.img(:,:,z))),[vox1 vox2],'nearest'),'Canny');
       
       if button_state == 1
            slice1(:,:,1) = slice1(:,:,1) + mask1;
            slice1(:,:,2) = slice1(:,:,2) - mask1;
            slice1(:,:,3) = slice1(:,:,3) - mask1;
            slice1 = rot90(slice1(range1,range2,:));
            imshow(slice1);
       else
            slice1 = rot90(slice1(range1,range2,:));
            imshow(slice1);
       end

   case 'Coronal'
%        display(radio_selection);
%        display(slider_value);
%        y = y + floor(slider_value);
%        slice2 = (double(repmat(imresize(squeeze(anat.img(:,y,:)),[vox1 vox3]),[1 1 3]))- min) / max;
%        slice2 = rot90(slice2(range1,range3,:));
%        imshow(slice2);

       y = y + floor(slider_value);
       slice2 = (double(repmat(imresize(squeeze(anat.img(:,y,:)),[vox1 vox3]),[1 1 3]))- min) / max;
       mask2 = edge(imresize(double(squeeze(cereb.img(:,y,:))),[vox1 vox3],'nearest'),'Canny');
       
       if button_state == 1
           slice2(:,:,1) = slice2(:,:,1) + mask2;
           slice2(:,:,2) = slice2(:,:,2) - mask2;
           slice2(:,:,3) = slice2(:,:,3) - mask2;
           slice2 = rot90(slice2(range1,range3,:));
           imshow(slice2);
       else
           slice2 = rot90(slice2(range1,range3,:));
           imshow(slice2);
       end

   case 'Saggital'
%        display(radio_selection);
%        display(slider_value);
%        x = x + floor(slider_value);
%        slice3 = (double(repmat(imresize(squeeze(anat.img(x,:,:)),[vox2 vox3]),[1 1 3]))- min) / max;
%        slice3 = rot90(slice3(range2,range3,:));
%        imshow(slice3);

       x = x + floor(slider_value);
       slice3 = (double(repmat(imresize(squeeze(anat.img(x,:,:)),[vox2 vox3]),[1 1 3]))- min) / max;
       mask3 = edge(imresize(double(squeeze(cereb.img(x,:,:))),[vox2 vox3],'nearest'),'Canny');
       
       if button_state ==1
           slice3(:,:,1) = slice3(:,:,1) + mask3;
           slice3(:,:,2) = slice3(:,:,2) - mask3;
           slice3(:,:,3) = slice3(:,:,3) - mask3;
           slice3 = rot90(slice3(range2,range3,:));
           imshow(slice3);
       else
           slice3 = rot90(slice3(range2,range3,:));
           imshow(slice3);
       end

end
end
