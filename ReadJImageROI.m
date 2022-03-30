function [sROI, matROIs] = ReadJImageROI(cstrFilename, shape)

% ReadJImageROI - FUNCTION Read an ImageJ ROI into a matlab structure
%
% Usage: [sROI, matROIs] = ReadJImageROI(strFilename, shape)        
%

    
%     if(numel(cstrFilename)>1)
%         sROI = [];
%         matROIs = [];
%         fprintf(2,'\n--------WARNING!--------\nOnly 1 file may be passed in at a time!\nValid extensions are .roi, .zip, and .roj\nReturning empty.\n------------------------\n\n');
%         return;
%     end

    idx = strfind(cstrFilename,'.');
    if(isempty(idx))
        sROI = [];
        matROIs = [];
        fprintf(2,'\n--------WARNING!--------\nMissing file extension!\nValid extensions are .roi, .zip, and .roj\nReturning empty.\n------------------------\n\n');
        return;
    end
   
    ext = lower(cstrFilename((idx+1):end));
   
    switch ext
        case 'roi'
            [sROI, matROIs] = ReadImageJROI(cstrFilename, shape);
            return;
        case 'zip'
            [sROI, matROIs] = ReadImageJROI(cstrFilename, shape);
            return;           
        case 'roj'
            segments = importdata(cstrFilename);
        otherwise
            sROI = [];
            matROIs = [];
            fprintf(2,'\n--------WARNING!--------\nInvalid file extension!\nValid extensions are .roi, .zip, and .roj\nReturning empty.\n------------------------\n\n');
            return;
    end
   
    cvsROIs = cell(1,length(segments));
    for seg = 1:length(segments)
        this = segments(seg);
        cvsROIs{seg} = make_ROI(this.coordinates, this.name);        
    end         
   
    % - Return ROIs
    sROI = cvsROIs;   
    matROIs = zeros(shape(1),shape(2),numel(cvsROIs));
    for num_comp = 1:numel(cvsROIs)
       cmp = cvsROIs{num_comp};
       coords = cmp.mnCoordinates;   
       coords_sqr = sub2ind(shape,coords(:,1),coords(:,2));    
       mm = zeros(shape);
       mm(coords_sqr) = 1;
       mm = bwconvhull(mm);
       matROIs(:,:,num_comp) = mm;
    end       
end


% --- END of ReadJImageROI.m ---
