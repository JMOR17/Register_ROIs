function [FinalImage, medTime] = j_load_downsample_TiffStack_3(FileTif, n, factor, verbose)

    if(nargin<4)
        verbose = true;
    end

    if(nargin<3)
        factor = 1;
    end

    InfoImage=imfinfo(FileTif);
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    if(isinf(n) || n>length(InfoImage))
        NumberImages=length(InfoImage);
    else
        NumberImages = n;
    end
    newNumberImages = floor(NumberImages/factor);
    
    FinalImage = zeros(nImage,mImage,newNumberImages,'single');
    blockImage = zeros(nImage,mImage,factor,'single');
    TifLink = Tiff(FileTif, 'r');
    block = 1;
    medTime = 0;
    for i=1:NumberImages
        subIndex = mod(i-1,factor)+1;
        if(i==1)
            TifLink.setDirectory(i);
        else
            TifLink.nextDirectory;
        end
        blockImage(:,:,subIndex) = TifLink.read();
        if(subIndex==factor)
            tic;
            FinalImage(:,:,block) = median(blockImage,3);
            medTime = medTime+toc;
%             blockImage = zeros(nImage,mImage,factor,'single');
            if(verbose)
                fprintf('\n%d of %d',block, newNumberImages);
            end
            block = block+1;            
        end
    end    
    TifLink.close();
    fprintf('\n');
end