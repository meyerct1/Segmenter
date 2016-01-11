function [D,H,CO] = ImSementer()
%Import the images in the folder selected
% asks user to locate the image directory where the images
% are being stored and begins segmentation
%  Create and then hide the UI as it is being constructed.
%Christian Meyer 06/22/15


%Declare structure for passing handles in GUI
H = struct();
%Declare a structure for passing data in GUI
%Set default values here
D = struct('imDir','TestImages',...
            'BT','0.5',...
            'THR','50',...
            'NT','10',...
            'FH','true',...
            'CIDRE', 0,...
            'fileExt','.tiff');

        
%Load in the functions in the funDir directory
addpath('Functions')



  %Set up the gui
        H.segFig = figure('Name','Segmenter Quality', 'numbertitle', 'off','position',[100 100 1000 1000]);
        
        H.imDir   =   uicontrol('style','pushbutton','string','imDir',...
                'units','normalized','position',[.01,.17,.2,.1]);
            
        H.CIDRE   =   uicontrol('style','pushbutton','string','Build CIDRE MODEL',...
                    'units','normalized','position',[.01,.17,.2,.1]);

        H.ldCIDRE = uicontrol('style','pushbutton','string','Load CIDRE MODEL',...
            'units','normalized','position',[.01,.17,.2,.1]);
        
        uicontrol('Style','text',...
                'String','Image Number',...
                'Units','normalized',...
                'Position',[.01,.9,.19,.1],'horizontalalignment','left');
            
            
        H.imNum     =  uicontrol('Style','edit',...
                        'string','1',...
                        'Units','normalized',...
                        'Position',[.01,.65,.2,.1]);    
                    
        H.fileExt     =  uicontrol('Style','edit',...
                        'string',D.fileExt,...
                        'Units','normalized',...
                        'Position',[.01,.65,.2,.1]);  
                    
        uicontrol('Style','text',...
                'String',{'Background Threshold [0,1]'},...
                'Units','normalized',...
                'Position',[.01,.9,.19,.1],'horizontalalignment','left');

            
        uicontrol('Style','text',...
                'String',{'TopHatRadius pixels'},...
                'Units','normalized',...
                'Position',[.01,.7,.19,.1],'horizontalalignment','left');
            
        uicontrol('Style','text',...
                'String',{'NoiseThreshold [0,1]'},...
                'Units','normalized',...
                'Position',[.01,.5,.19,.1],'horizontalalignment','left');
            
        uicontrol('Style','text',...
                'String',{'FillHoles'},...
                'Units','normalized',...
                'Position',[.01,.33,.19,.1],'horizontalalignment','left');

                    
        H.BTval     =   uicontrol('Style','edit',...
                        'Units','normalized','string',num2str(D.BT),...
                        'Position',[.01,.85,.15,.1]);
                    
        H.THRval     =  uicontrol('Style','edit',...
                        'string',num2str(D.THR),...
                        'Units','normalized',...
                        'Position',[.01,.65,.2,.1]);
                    
        H.NTval     =   uicontrol('Style','edit',...
                        'string',num2str(D.NT),...
                        'Units','normalized',...
                        'Position',[.01,.45,.2,.1]);
                    
        H.FHval     =   uicontrol('Style','listbox',...
                        'string',{'true','false'},...
                        'Units','normalized',...
                        'Position',[.01,.28,.2,.1]);
                    

        
        %Where the original image will be displayed
        H.testOrg = subplot(2,2,2)
        set(gca,'visible','on')
        set(H.testOrg,'units','normalized')
        set(H.testOrg,'position',[.2,.52,.8,.45])
        title('Original')

        %Where the segmented image will be displayed
        H.testFin = subplot(2,2,4)
        set(gca,'visible','on')
        set(H.testFin,'units','normalized')
        set(H.testFin,'position',[.2,0,.8,.48])
        title('Binary')
                    
        %all buttons call the testsegmenter
        set(H.imDir,'call',@filFinder2)
        set([H.BTval, H.FHval, H.NTval, H.THRval],'call',{@testSeg})
        set(H.CIDRE,'call',@crCIDRE)
        set(H.ldCIDRE,'call',@loadCIDRE)
        
        %%Load a cidre model
        function [] = loadCIDRE(varargin)
            [filename, pathname] = uigetfile();
            temp = load([pathname filename]);
            CIDREmodel = temp.CIDREmodel;
        end

    
        %%Create a CIDRE model
        function [] = crCIDRE(varargin)
            D.imDir = get(H.imDir,'string');
            D.fileExt = get(H.fileExt,'string');
            CIDREmodel = cidre([D.imDir filesep '*' D.fileExt])
            save('CIDREmodel.mat','CIDREmodel')
            D.CIDRE = 1;
        end
    
        %Function to get the image directory name
        function [] = filFinder2(varargin)
                str = uigetdir();
                set(H.imDir,'string',str)
        end
    
        %Function for opening up a gui to allow testing of the current
        %segmentation on the first image in the first well
        function[] = testSeg(varargin)
            D.BT = str2double(get(H.BTval,'string'));
            D.THR = str2double(get(H.THRval,'string'));
            D.NT = str2double(get(H.NTval,'string'));
            str = get(H.FHval,'string');
            D.FH = str(get(H.FHval,'value'));
            set(H.txt1,'string',num2str(get(H.BTval,'val')))

            %Copied code from LocalNaiveSegment.m
            directory		= D.imDir;
            wellName		= D.wellName{1};
            imageNameBase 	= D.imageNameBase;
            fileExt			= D.fileExt;
            digitsForEnum	= D.digitsForEnum;
            startIndex		= D.startIndex;
            endIndex		= D.endIndex;
            framestep		= D.framestep;
            outdir			= D.outdir;
            imNum = D.startIndex;  %Just pick the first image of the first well
            imNumStr = sprintf('%%0%dd', digitsForEnum);
            imNumStr = sprintf(imNumStr, imNum * framestep);

            %Load Image name the objSet well name and image name
            %LoadImage function is in the functions folder
            [im, objSet.wellName, objSet.imageName] = ...
                LoadImage([	directory filesep ...
                            wellName filesep ...
                            imageNameBase imNumStr fileExt]);
            
            %Correct with CIDRE model   if available        
            if D.CIDRE == 1
                temp = load([D.outdir filesep D.ExpName '_CIDRE_Model' filesep  D.ExpName '_cidreModel.mat']);
                CIDREmodel = temp.CIDREmodel;
                im = (double(im)-CIDREmodel.z)./(CIDREmodel.v);
                %Reconvert the image to uint16 if corrected.
                im = uint16(im);
            end

            
            subplot(H.testOrg)
            
            imshow(im, [])
            truesize()
            title('Original')


            % Subtract background, in pixel radius (default 50) tophat filter
            %Use only if CIDRE hasn't been run on the image
            if D.CIDRE~=1 
                im	= imtophat(im2double(im), strel('disk', num2double(D.FH)));
            end

            % maps the intensity values such that 1% of data is saturated 
            % at low and high intensities 
            im	= imadjust(im);

            % To Binary Image 
            im	= im2bw(im, D.BT);

            % Remove Noise
            if str2double(D.NT) > 0.0
                noise = imtophat(im, strel('disk', str2double(D.NT)));
                im = im - noise;
            end

            % Fill Holes
            if D.FH{1}
                im = imfill(im, 'holes');
            end
            l	= bwlabel(im);

            % Compute intensities from background adjusted image
            [bounds,L,N] = bwboundaries(im);
            
            subplot(H.testFin)
            size(bounds)
            imshow(im,[])
            truesize()
            hold on
             for k = 1:size(bounds,1)
                 boundary = bounds{k};
                  if(k > N)
                    plot(boundary(:,2), boundary(:,1), 'g','LineWidth',2)
                  else
                    plot(boundary(:,2), boundary(:,1), 'r','LineWidth',2)
                  end
             end
             
            str = sprintf('Naive Segmentation');
            title(str)
            hold off
    
    
%             %Send to a test naive segmentation
%             [objSet.props, objSet.labels] = ...
%                 TestNaiveSegment(H, D, im, 'BackgroundThreshold', D.BT, 'TopHatRadius', D.THR, 'NoiseThreshold', D.NT, 'FillHoles', D.FH);
%             

            return
        end


        function [] = SegIm(varargin)
            D.imDir = get(H.imDir,'string');
            D.imageNameBase = get(H.imageNameBase,'string');
            D.startIndex = get(H.startIndex,'string');
            D.endIndex = get(H.endIndex,'string');
            D.BT = str2double(get(H.BTval,'string'));
            D.THR = str2double(get(H.THRval,'string'));
            D.NT = str2double(get(H.NTval,'string'));
            D.FH = get(H.NTval,'string');

            for i = 1:size(D.wellName,1)
                %Run the naive segmentation for each well out of the
                %localNaiveSegment function
                LocalNaiveSegment(D,i)
            end
            
            close(H.segFig)
        end
    end