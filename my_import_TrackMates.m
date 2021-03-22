function tracks = my_import_TrackMates(file)
    %% Load and Test compliance

    try
        doc = xmlread(file);
    catch %#ok<CTCH>
        error('Failed to read XML file %s.',file);
    end
    
    root = doc.getDocumentElement;
    
    if ~strcmp(root.getTagName, 'Tracks')
        error('MATLAB:importTrackMateTracks:BadXMLFile', ...
            'File does not seem to be a proper track file.')
    end
    %initialize
    poolobj = gcp('nocreate');
    delete(poolobj);
    p = parpool;
    %% Parse 
    
    nTracks = str2double( root.getAttribute('nTracks') );
    max_N = 1e3;
    tracks = NaN(max_N, 4,nTracks);
    trackNodes = root.getElementsByTagName('particle');
    
    parfor i = 1 : nTracks
       
        trackNode = trackNodes.item(i-1);
        nSpots = str2double( trackNode.getAttribute('nSpots') );
        A = NaN( nSpots, 4); % T, X, Y, Z
        
        detectionNodes = trackNode.getElementsByTagName('detection');
        cnt = 0;
        for j = 1 : nSpots
           
            try
            detectionNode = detectionNodes.item(j-1);
            t = str2double(detectionNode.getAttribute('t'));
            x = str2double(detectionNode.getAttribute('x'));
            y = str2double(detectionNode.getAttribute('y'));
            z = str2double(detectionNode.getAttribute('z'));
            A(j, :) = [ t x y z ];
            cnt = cnt + 1;
            catch
                %warning('there is something wrong with nSpots')
                A = A(1:200,:);
                break;
            end
        end
        
        tracks(:,:,i) = A;
        
    end
    delete(p)
end