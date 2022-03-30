clear;

%Motion corrected tiff stacks must all have the same name, defined in line
%10 of register_rois2.m
baseFolder = '';        % Folder with your reference motion corrected tiff stack and RoiSet.zip

otherFolders = {'';     % Folders to register the ROIs to. Each needs to contain a motion corrected tiff stack
                '';
                '';
                ''
                };
            
register_rois2(baseFolder,otherFolders);