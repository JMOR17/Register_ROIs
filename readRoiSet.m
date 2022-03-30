function [ROI, names] = readRoiSet(filename, height, width)

    [sROI, ROI] = ReadImageJROI_C(filename, [height, width]);

    ROI = zeros(size(ROI));
    [aa,bb] = meshgrid(1:height,1:width);
    for i_roi = 1:size(ROI,3)
        temp = inpolygon(bb(:),aa(:),sROI{i_roi}.mnCoordinates(:,1),sROI{i_roi}.mnCoordinates(:,2));
        ROI(:,:,i_roi) = reshape(temp,[width height])';
    end
    names = cellfun(@(x) x.strName, sROI(:), 'UniformOutput', false);
       
end