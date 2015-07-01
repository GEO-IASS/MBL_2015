function ConvertCube(Date)
% interprets binary .3d data files produced by HSI into 16 tiffs and graphs
% them in a 4x4 grid...theoretically

% need to be in the directory to execute the function
% ex: ConvertCube('Jun29')

imagedir = dir(['../', Date]); 

% for each image 

imagedir = imagedir(arrayfun(@(x)x.name(1),imagedir) ~='.'); %remove hidden files

for i = 1:length(imagedir); 
%     fid = fopen(imagedir(i).name);
    cuberead = fread(fopen(imagedir(i).name),[2048 2048],'uint16');
    FolderID = imagedir(i).name(1:end-3);
    mkdir(FolderID) % make directory to fill with tiffs
    figure(i); 
    for j = 1:4
        for k = 1:4 
        ch = (cuberead(j:4:2048, k:4:2048)); % 512x512 grid of 4x4 squares containing pixels for each channel
        channel = sprintf('%s%d%s','chan',k+4*(j-1),'.tif');
        imagesc(ch); % make image
        outname = sprintf('%s%s%s',imagedir(i).name,'.',channel); % this doesn't actually save?
        subplot(4,4,k+4*(j-1)); % plot all 16 channels in one figure
        % currently failing to plot the 16th tiff?
        imwrite(uint16(ch), [FolderID, '/', outname]) 
        end
    end  
end

end
