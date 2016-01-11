%Parameters for SF Segmentation
%%BT = Background threshold percent above norm considered significant
%%NT = Noise Threshold (Size of disk that is rolled over binary image
%%FH is the logical to fill holes
SF.P = struct( 'BT',0.1,...
            'NT',10,...
              'FH','true',...
              'THR',50);

%Parameters for Nuclei Segmentation
NUC.P = struct( 'BT',0.2,...
              'NT',3,...
              'FH','true',...
              'THR',50);


imNum = 36;
%Show SF image 
figure(10)
subplot(1,2,1)
[SFim, objSet.wellName, objSet.imageName] = ...
    LoadImage([SF.dir SF.filnms(imNum).name]);
imshow(SFim,[])
title('SmartFlare')

subplot(1,2,2)
[NUCim, objSet.wellName, objSet.imageName] = ...
    LoadImage([NUC.dir NUC.filnms(imNum).name]);
imshow(NUCim,[])
NUCim = uint16(NUCim);
title('H2B RFP')

figure(11)
subplot(2,2,1)
[SFim, objSet.wellName, objSet.imageName] = ...
    LoadImage([SF.dir SF.filnms(imNum).name]);
%Correct with CIDRE model
SFim = (double(SFim)-CIDREmodelSF.z)./(CIDREmodelSF.v);
%Reconvert the image to uint16 if corrected.
SFim = uint16(SFim);
% maps the intensity values such that 1% of data is saturated 
% at low and high intensities 
SFim	= imadjust(SFim);
% To Binary Image 
SFim	= im2bw(SFim, SF.P.BT);
noise = imtophat(SFim, strel('disk', (SF.P.NT)));
SFim = SFim - noise;
SFim = imfill(SFim, 'holes');
imshow(SFim,[])
title('CIDRE corrected SF')


subplot(2,2,2)
[SFim, objSet.wellName, objSet.imageName] = ...
    LoadImage([SF.dir SF.filnms(imNum).name]);
%Correct with THR
SFim = imtophat(im2double(SFim), strel('disk', SF.P.THR));
% maps the intensity values such that 1% of data is saturated 
% at low and high intensities 
SFim	= imadjust(SFim);
% To Binary Image 
SFim	= im2bw(SFim, SF.P.BT);
noise = imtophat(SFim, strel('disk', (SF.P.NT)));
SFim = SFim - noise;
SFim = imfill(SFim, 'holes');
imshow(SFim,[])
title('Top Hat corrected SF')

%Image processing on CIDRE
subplot(2,2,3)
[NUCim, objSet.wellName, objSet.imageName] = ...
    LoadImage([NUC.dir NUC.filnms(imNum).name]);
%Correct with CIDRE model
NUCim = (double(NUCim)-CIDREmodelNUC.z)./(CIDREmodelNUC.v);
%Reconvert the image to uint16 if corrected.
NUCim = uint16(NUCim);
% maps the intensity values such that 1% of data is saturated 
% at low and high intensities 
NUCim	= imadjust(NUCim);
% To Binary Image 
NUCim	= im2bw(NUCim, NUC.P.BT);
noise = imtophat(NUCim, strel('disk', (NUC.P.NT)));
NUCim = NUCim - noise;
NUCim = imfill(NUCim, 'holes');
imshow(NUCim,[])
title('CIDRE corrected NUC')


subplot(2,2,4)
[NUCim, objSet.wellName, objSet.imageName] = ...
    LoadImage([NUC.dir NUC.filnms(imNum).name]);
%Correct with THR
NUCim = imtophat(im2double(NUCim), strel('disk', NUC.P.THR));
% maps the intensity values such that 1% of data is saturated 
% at low and high intensities 
NUCim	= imadjust(NUCim);
% To Binary Image 
NUCim	= im2bw(NUCim, NUC.P.BT);
noise = imtophat(NUCim, strel('disk', (NUC.P.NT)));
NUCim = NUCim - noise;
NUCim = imfill(NUCim, 'holes');
imshow(NUCim,[])
title('Top Hat corrected NUC')

