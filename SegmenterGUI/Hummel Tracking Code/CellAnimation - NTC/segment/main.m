%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%connect to omero

%move into OmeroCode directory
oldDir = cd('C:/Users/sam/work/CellAnimation/OmeroCode');

%set up a connection to Omero
%return values are used to interface with the database
[client, session, gateway] = ConnectToOmero();

%move back into the segmentation directory
cd(oldDir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Use dataset name (date) and well name to index to correct well id
datasetname = input('Dataset Name: ', 's');
datasetid = -1;
service = session.getContainerService();
options = omero.sys.ParametersI;
projectlist = service.loadContainerHierarchy(omero.model.Project.class, [], options);
for(i=0:size(projectlist)-1)
    project = projectlist.get(i);
    datasetlist = project.linkedDatasetList;
    for(j=0:size(datasetlist)-1)
        if(strcmp(datasetlist.get(j).getName().getValue(),...
                 datasetname) == 1)
            dataset = datasetlist.get(j);
            datasetid = dataset.getId().getValue();
            break;
        end
    end
end

if(datasetid == -1)
    error('Invalid dataset name');
end

%imageList = dataset.linkedImageList  %datasets not linked to images?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load the first image (used to create training set)

%user input: the well we are interested in
wellid = input('Well id#: ');

%call function to save desired image (time 0) locally
SaveImageFromOmero(gateway, wellid, 0, '0.tif', 'tif');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Automatically segment the image, then manually correct errors

%Automatic first attempt at segmentation
img = imread('0.tif');
[s,l] = NaiveSegment(img);

%save the results locally; this is the beginning of the training set
save('properties.mat', 's', 'l');

%Review GUI used to correct segmentation errors
SegmentReview(1, '0.tif', 'properties.mat');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Allow the addition of other objects to the training set
timepoint = 1;
yesorno = 'y';
while(strcmp(yesorno, 'y'))
    yesorno = input('Would you like to add to the training set (y/n)?',...
                    's');
    if(strcmp(yesorno, 'y'))
        timepoint = timepoint + 1;
        imagefilename = [int2str(timepoint) '.tif'];
        SaveImageFromOmero(gateway, wellid, timepoint, ...
                           imagefilename, 'tif');
        SegmentReview(1, imagefilename);
    end
end
clear yesorno timepoint imagefilename
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%use the training set from above to create a classifier
load('properties.mat', 's');
oldDir = cd('../classify');
names = {'debris', 'nucleus', 'over', 'under', 'premitotic', ...
         'postmitotic'};%, 'apoptotic'};
classifier = struct();
for i=1:size(names, 2)

    classifier = setfield(classifier, names{1,i}, ...
                 CreateClassifier(names{1,i}, s, ...
                 'Area',            'Eccentricity',  'MajorAxisLength', ...
                 'MinorAxisLength', 'ConvexArea',    'FilledArea', ...
                 'EquivDiameter',   'Solidity',      'Perimeter'));
end
cd(oldDir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
