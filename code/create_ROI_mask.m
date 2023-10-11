function [mask, f] = create_ROI_mask(vox_coords, vox_size, filename)
% Create a binary mask given voxel coordinates
% This function will take any mat file with ROI information (such as a VOI)
% and converts it into a binary nii file for easier parameter extraction
% and such... Settings are relevant to fmri97
% S.Srokova - Jan 2023

%% Info about masks - EXPERIMENT SPECIFIC, DEPENDS ON RESOLUTION!!

% The ordering here follows that of mars_utils e2xyz where each row of the
% 53 x 63 x 52 matrix corresponds to the same X coordinate, each column
% corresponds to the same Y coordinate, and each layer/slice is the same Z
% coordinate. 
% 3 mm data =  voxel 1,1,1 = 78,-112,-70 and voxel 53,63,52 = -78,74,83 in mni 
% 2 mm data  1,1,1 = 78,-112,-70 / 79,95,78 = -78,76,84

% NOTE: Some functions may output the left and right hemi flipped. Always
% check you are getting the hemisphere you expect.

if vox_size == 2
    dims = [79 95 78];      % 2 mm data
    %x_coords = repmat(78:-2:-78, 1, dims(2)*dims(3));
    x_coords = repmat(-78:2:78, 1, dims(2)*dims(3));
    y_coords = repmat(repelem(-112:2:76, 1, dims(1)), 1, dims(3));
    z_coords = repelem(-70:2:84, 1, dims(1)*dims(2));
    
    % Mask settings taken from fmri97.
    f = struct();
    f.fname = filename;
    f.dim = dims;
    f.dt = [2 0];
    f.pinfo = [1;0;352];
    f.mat = [-2 0 0 80; 0 2 0 -114; 0 0 2 -72; 0 0 0 1];
    f.n = [1 1];
    f.descrip = 'roi_mask';
    
    
elseif vox_size == 3
    dims = [53 63 52];     % 3 mm data
    %x_coords = repmat(78:-3:-78, 1, dims(2)*dims(3));
    x_coords = repmat(-78:3:78, 1, dims(2)*dims(3));
    y_coords = repmat(repelem(-112:3:74, 1, dims(1)), 1, dims(3));
    z_coords = repelem(-70:3:83, 1, dims(1)*dims(2));
    
    % Mask settings for 3 mm data may be done later...
else
    error('Voxel size either not inputted or not matching the predetermined settings');
end

% Prefill mask
temp = logical(ones(dims)); 
mask = logical(zeros(dims));

% Indices of all voxels in the FOV
[mask_coords(:,1), mask_coords(:,2), mask_coords(:,3)] = ind2sub(dims,find(temp));

% MNI coords of all voxels
xyz = [x_coords', y_coords', z_coords'];  

% Coordinates of the voxels in the ROI
if size(vox_coords, 1) ~= 3
    error('Make sure the voxels you input are entered as 3 by X double where X = number of voxels...');
end

% Find the position of the voxels 
temp = ismember(xyz, vox_coords', 'rows');

% Make a mask
mask = uint8(reshape(temp, dims)); 

% Save
spm_write_vol(f, uint8(mask));

end
