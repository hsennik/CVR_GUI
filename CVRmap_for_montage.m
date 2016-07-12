function CVRmap_for_montage(anat,funct,mp,sliceval,gen_file_location)
% Function to save axial slices for a montage 
% 
% INPUTS 
%     anat - 3D anatomical subject data 
%     funct - 4D functional subject data 
%     mp - GUI data
%     sliceval - slice position 
%     gen_file_location - directory where images for montage should we stored
% 
% *************** REVISION INFO ***************
% Original Creation Date - June 15, 2016
% Author - Hannah Sennik
%   REVISIONS 
%       A - 2016-07-11 - Moved the CVRmap generation to CVRmap.m to avoid
%                        duplication of code

dimension = 'axial'; % if montage button is pressed, want montage of axial CVR maps
montage = 1; % set montage variable to 1 to execute montage functionality in CVRmap.m
CVRmap(dimension,anat,funct,mp,sliceval,montage,gen_file_location); % call the CVRmap function

end


