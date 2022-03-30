function [] = register_rois2(sourceFolder, otherFolders, clipAmount)

    if(nargin<3)
        clipAmount = 0;
    end
    
    HEIGHT = 512;
    WIDTH = 512;

    files = fullfile([sourceFolder; otherFolders(:)],'MC_Video_TSub_nonrigid.tif');    
    
    
    N_files = length(files);
    templates = NaN(HEIGHT,WIDTH,length(files));

    for i_file = 1:length(files)
        V = j_load_downsample_TiffStack_3(files{i_file},Inf,1, false);        
        templates(:,:,i_file) = max(V,[],3);
        templates(1:clipAmount,:,i_file) = 0;
        templates(:,1:clipAmount,i_file) = 0;
        templates((end-clipAmount+1):end,:,i_file) = 0;
        templates(:,(end-clipAmount+1),i_file) = 0;
        clear V;
    end
    
    sourceFolder2 = strrep(sourceFolder,'MotionCorrected','Analysis');
    otherFolders2 = strrep(otherFolders,'MotionCorrected','Analysis');
    [ROI,names] = readRoiSet(fullfile(sourceFolder2,'RoiSet.zip'),HEIGHT,WIDTH);
    
    FOV = [HEIGHT WIDTH];
    %%
    % %% RIGID
%     options = NoRMCorreSetParms('d1',FOV(1),'d2',FOV(2),'bin_width',200,'max_shift',30,'us_fac',50, 'init_batch', 200, 'iter', 10);
%     [shifted_rigid2,shifts_rigid2,template_rigid2] = normcorre_batch(templates,options);
    
    %%
    XY_shift = NaN(length(files),2);
    for i_file = 2:size(templates,3)
        temp = xcorr2(templates(:,:,1),templates(:,:,i_file));
        [a,b] = find(temp==max(temp(:)));
        XY_shift(i_file,:) = [a-HEIGHT b-WIDTH];
    end
    templates2 = templates;
    for i_file = 2:size(templates,3)
        templates2(:,:,i_file) = circshift(templates(:,:,i_file),XY_shift(i_file,:));
    end
    %% NON-RIGID
    options = NoRMCorreSetParms('d1',FOV(1),'d2',FOV(2),'grid_size',[32,32],'mot_uf',4,'bin_width',200,'max_shift',30,'max_dev',3,'us_fac',50,'init_batch',200,'shifts_method','cubic','iter',5);
    [shifted_nonrigid2,shifts_nonrigid2,template_nonrigid2] = normcorre_batch(templates2,options);

    %%
    inverse_shifts_nonrigid2 = shifts_nonrigid2;
    for i = 1:length(inverse_shifts_nonrigid2)
        inverse_shifts_nonrigid2(i).shifts = -inverse_shifts_nonrigid2(i).shifts;
        inverse_shifts_nonrigid2(i).shifts_up = -inverse_shifts_nonrigid2(i).shifts_up;
        inverse_shifts_nonrigid2(i).diff = -inverse_shifts_nonrigid2(i).diff;    
    end

   
    %%
    % Register ROIs to common template
    ROI2 = ROI;
    warning off;
    for i_roi = 1:size(ROI2,3)
        i_roi
        A = apply_shifts(ROI(:,:,i_roi),shifts_nonrigid2(1),options);
        ROI2(:,:,i_roi) = A;    
    end

    %%
    for i_session = 2:N_files
        for i_roi = 1:size(ROI,3)
            % Register to common template, then register to individual session
            A = apply_shifts(ROI2(:,:,i_roi),inverse_shifts_nonrigid2(i_session),options);
            [a,b] = find(A>0.5);
            a = a-XY_shift(i_session,1);
            b = b-XY_shift(i_session,2);
%             A = circshift(A,-XY_shift(i_session,:));
    %         A = imwarp(ROI(:,:,i_roi),tforms{1,i_session},'OutputView',imref2d([512 512]));            
%             a(a<1) = 1;
%             a(a>HEIGHT) = HEIGHT;
%             b(b<1) = 1;
%             b(b>WIDTH) = WIDTH;
            c = boundary(a,b,0.75);
    %         ROI(:,:,i_roi) = A>0.5;

            writeImageJROI_3([a(c) b(c)]+1, 3, 1, names{i_roi}, fullfile(otherFolders2{i_session-1},'\'));
        end
        zip(fullfile(otherFolders2{i_session-1},'RoiSet'),'*.roi',fullfile(otherFolders2{i_session-1}));
        home = pwd;
        cd(fullfile(otherFolders2{i_session-1}));
        delete *.roi;
        cd(home);
    %     rmdir(outputFolders{i_file}, 's');
    end

end