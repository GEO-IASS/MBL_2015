function ConvertCube(Date)


% Directory = 'Jun11';
% find images
imagedir = dir(Date); 

% for each image 

imagedir = imagedir(arrayfun(@(x)x.name(1),imagedir) ~='.'); %remove hidden files

for i = 1:length(imagedir); % find number of 3d files in directory
    fid = fopen(imagedir(i).name);  
    cuberead = fread(fid,[2048 2048],'uint16'); % read in files
    figure(i); 
    for j = 1:4
        for k = 1:4 
        ch = (cuberead(j:4:2048, k:4:2048)); % 512x512 grid of 4x4 squares containing pixels for each channel
        channel = sprintf('chan',j,'.tiff');
        imagesc(ch); % make image
        outname = sprintf('%s%s%s',imagedir(i).name,'.',channel); % this doesn't actually save?
        subplot(4,4,k+4*(j-1)); % plot all 16 channels in one figure
        end
    end  
end

end

