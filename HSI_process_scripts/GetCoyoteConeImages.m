function GetCoyoteConeImages(Directory, Rad4Umat)
load Coyote2Cones.dat % 2x16 (S, L) -- 431, 555 nm

% LightFilename = ['../../SpecData/',DateLight,'/LightField',num2str(LightNum)];
% load(LightFilename);
load([Directory, '/', Rad4Umat]);
RefObjectImg = BandImg;

WaveNumber = {'360nm', '380nm', '405nm', '420nm', '436nm', '460nm', '480nm', '500nm', '520nm', '540nm', '560nm', '580nm', '600nm', '620nm', '640nm', '660nm'};

% plot 16 channels individually
figure
for i = 1:16
    TempImg = RefObjectImg(:,:,i);
    inx1 = find(TempImg > 1); % find reflectance larger than one
    TempImg(inx1) = 1;% make reflectance larger than one equal 1 
    TempImg(isnan(TempImg)) = 0; % set NaNs equal to 0 (because of noise)
    RefObjectImg(:,:,i) = TempImg; % reflectance range 0-1
    subaxis(4,4,i, 'Spacing', 0.03), imshow(RefObjectImg(:,:,i)); title(WaveNumber(i));
end

ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 1,'\bf Reflectance images of 16 bands','HorizontalAlignment','center','VerticalAlignment', 'top');

% get color information for buzzard cones
for i = 1:16
    Simg(:,:,i) = RefObjectImg(:,:,i)*Coyote2Cones(1,i);
    Limg(:,:,i) = RefObjectImg(:,:,i)*Coyote2Cones(2,i);
end

% summation across all wavelengths
Scone = sum(Simg,3);
Lcone = sum(Limg,3);

for i = 1:16
    Background(i) = mean2(RefObjectImg(:,:,i)); % average all reflectance spectra across the entire image
end

WhiteSurface = ones(1,16); % white surface for normalization purpose
BlackSurface = 0.01*ones(1,16); % black surface for normalization purpose

for i = 1:16
    S_bk(i) = Background(i)*Coyote2Cones(1,i);
    L_bk(i) = Background(i)*Coyote2Cones(2,i);
    S_White(i) = WhiteSurface(i)*Coyote2Cones(1,i);
    L_White(i) = WhiteSurface(i)*Coyote2Cones(2,i);
    S_Black(i) = BlackSurface(i)*Coyote2Cones(1,i);
    L_Black(i) = BlackSurface(i)*Coyote2Cones(2,i);
end

% make the quantal catch 0 equal the black surface quantal catch (to avoid log problem)
inxS = find(Scone == 0);
Scone(inxS) = sum(S_Black);
inxL = find(Lcone == 0);
Lcone(inxL) = sum(L_Black);

% adapted to background and log-transformed (Ln)
SconeAdp = log(Scone/sum(S_bk)); 
LconeAdp = log(Lcone/sum(L_bk)); 

% normalized to a range from 0 to 1 (for display purpose), using black and white surfaces
SconeAdpNorm = (SconeAdp - log(sum(S_Black)/sum(S_bk)))/(log(sum(S_White)/sum(S_bk)) - log(sum(S_Black)/sum(S_bk)));
LconeAdpNorm = (LconeAdp - log(sum(L_Black)/sum(L_bk)))/(log(sum(L_White)/sum(L_bk)) - log(sum(L_Black)/sum(L_bk)));

figure
imshow(LconeAdpNorm); title('L cone');

% Edge detection (Laplacian of Gaussian (Stevens and Cuthill, PRSB 2006)
for i = 1:11
    img(:,:,i) = edge_Otsu(LconeAdpNorm, 'log', [], (i/2)); % adaptive thresholding (Otsu, 1979)
end
for i = 1:10
    imgp(:,:,i) = img(:,:,i) & img(:,:,(i+1));
end

Lcone_img = double(imgp(:,:,1)+imgp(:,:,2)+imgp(:,:,3)+imgp(:,:,4)+imgp(:,:,5)+imgp(:,:,6)+imgp(:,:,7)+imgp(:,:,8)+imgp(:,:,9)+imgp(:,:,10))./10;

figure
imshow(Lcone_img); title('Edge detection using Laplacian of Gaussian model');

% 542 nm = M and S (G/B) channels
LSimg(:,:,1) = LconeAdpNorm; LSimg(:,:,2) = LconeAdpNorm; LSimg(:,:,3) = SconeAdpNorm;

figure
subaxis(1,2,1, 'Spacing', 0.03), imshow(SconeAdpNorm); title('S cone');
subaxis(1,2,2, 'Spacing', 0.03), imshow(LconeAdpNorm); title('L cone');

figure
imshow(LSimg); title('LMS');

ConeNorm = (SconeAdpNorm+LconeAdpNorm)/2;

IsoSconeAdpNorm = SconeAdpNorm - ConeNorm;
IsoLconeAdpNorm = LconeAdpNorm - ConeNorm;

IsoLSimg(:,:,1) = (IsoLconeAdpNorm+3/4)/(6/4); IsoLSimg(:,:,2) = (IsoLconeAdpNorm+3/4)/(6/4); IsoLSimg(:,:,3) = (IsoSconeAdpNorm+3/4)/(6/4);

figure
imshow(IsoLSimg); title('Iso-LS');

% Edge detection (Laplacian of Gaussian (Stevens and Cuthill, PRSB 2006)

for i = 1:11 % adaptive thresholding (Otsu, 1979)
    imgS(:,:,i) = edge_Otsu(IsoSconeAdpNorm, 'log', [], (i/2));
    imgL(:,:,i) = edge_Otsu(IsoLconeAdpNorm, 'log', [], (i/2));
end
for i = 1:10
    imgpS(:,:,i) = imgS(:,:,i) & imgS(:,:,(i+1));
    imgpL(:,:,i) = imgL(:,:,i) & imgL(:,:,(i+1));
end

IsoSconeEdge_img = double(imgpS(:,:,1)+imgpS(:,:,2)+imgpS(:,:,3)+imgpS(:,:,4)+imgpS(:,:,5)+imgpS(:,:,6)+imgpS(:,:,7)+imgpS(:,:,8)+imgpS(:,:,9)+imgpS(:,:,10))./10;
IsoLconeEdge_img = double(imgpL(:,:,1)+imgpL(:,:,2)+imgpL(:,:,3)+imgpL(:,:,4)+imgpL(:,:,5)+imgpL(:,:,6)+imgpL(:,:,7)+imgpL(:,:,8)+imgpL(:,:,9)+imgpL(:,:,10))./10;

figure
subaxis(1,2,1, 'Spacing', 0.03), imshow(IsoSconeEdge_img); title('Iso S-cone'); 
subaxis(1,2,2, 'Spacing', 0.03), imshow(IsoLconeEdge_img); title('Iso L-cone');

% FlounDir = sprintf('%s%s', Directory, '/');
% 
% TiffWrite(FlounDir, DirImg, 'Coyote_DCimg', LconeAdpNorm, 'bw');
% TiffWrite(FlounDir, DirImg, 'Coyote_LoG', Lcone_img, 'bw');
% TiffWrite(FlounDir, DirImg, 'Coyote_LS', LSimg, 'rgb');
% TiffWrite(FlounDir, DirImg, 'Coyote_IsoLS', IsoLSimg, 'rgb');
% TiffWrite(FlounDir, DirImg, 'Coyote_IsoSconeLoG', IsoSconeEdge_img, 'bw');
% TiffWrite(FlounDir, DirImg, 'Coyote_IsoLconeLoG', IsoLconeEdge_img, 'bw');
end