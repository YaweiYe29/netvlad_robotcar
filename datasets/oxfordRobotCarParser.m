classdef oxfordRobotCarParser<handle
    
    properties
        imageFns;
        imageTimeStamp;
        posDisThr;
        seqIdx;
        seqTimeStamp;
        utm;
        nonTrivPosDistThr;
        whichSet;
    end
    
    methods
        function obj= oxfordRobotCarParser(whichSet, seqTimeStamp, posDisThr, ...
                nonTrivPosDistThr)
            % whichSet is one of: train, val, test
            assert( ismember(whichSet, {'train', 'val', 'test'}) );
            obj.whichSet= whichSet;
            
            obj.posDisThr= posDisThr;
            obj.nonTrivPosDistThr= nonTrivPosDistThr;
            
            paths= localPaths();
            datasetRoot= paths.dsetRootRobotCar;

            datasetPathList = cell(11, 1);
            for i = 1:length(seqTimeStamp)
                datasetPathList{i} = {[datasetRoot seqTimeStamp{i} ...
                    '/stereo/centre/undistort_images_crop/']};
            end
            
            imageFnsAllSeq = [];
            seqIdx = [];
            for j = 1:length(datasetPathList)
                imageSingleSeq = dir(char(fullfile(datasetPathList{j},'*.jpg')));
                imageFnsSingleSeq = {imageSingleSeq.name}';
                imageFnsAllSeq = [imageFnsAllSeq; imageFnsSingleSeq];
                seqIdx = [seqIdx; j*ones(length(imageFnsSingleSeq), 1)];
            end
            
            obj.imageFns = imageFnsAllSeq;
            obj.imageTimeStamp = cellfun(@(x) str2double(x(1:16)), imageFnsAllSeq);
            obj.seqIdx = seqIdx;
            obj.seqTimeStamp = seqTimeStamp;
            obj.loadUTMPosition();
        end
        
        function loadUTMPosition(obj)
            % Estimate image positions by applyiimageTimeStampng linear interpolation on GPS
            % measurements based on image timestamps
            paths = localPaths;
            imageGPSPositions = [];
            gpsDataRoot = paths.gpsDataRootRobotCar;
            
            for i = 1:length(obj.seqTimeStamp)
                % Load GPS+INS measurements.
                ins_file = [gpsDataRoot obj.seqTimeStamp{i} '/gps/ins.csv'];
                
                imageTimeSingleSeq = obj.imageTimeStamp(obj.seqIdx == i);
                imageGPSPositionsSingleSeq = ...
                    getUTMPosition(ins_file, imageTimeSingleSeq);
                imageGPSPositions  = ...
                    [imageGPSPositions; imageGPSPositionsSingleSeq];
            end
            % Store keyframe position estimate from GPS+INS measurements
            obj.utm = imageGPSPositions;
        end
    end
end

