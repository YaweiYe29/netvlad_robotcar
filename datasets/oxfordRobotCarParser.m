classdef oxfordRobotCarParser<handle
    
    properties
        imageFns;
        imageTimeStamp;
        posDisThr;
        seqIdx;
        seqTimeStamp;
        utm;
        nonTrivPosDistThr;
    end
    
    methods
        function obj= oxfordRobotCarParser(seqTimeStamp, posDisThr, ...
                nonTrivPosDistThr)
            
            obj.posDisThr= posDisThr;
            obj.nonTrivPosDistThr= nonTrivPosDistThr;
            
            paths= localPaths();
            datasetRoot= paths.dsetRootRobotCar;
            
            datasetPathList = cell(size(seqTimeStamp));
            for i = 1:length(seqTimeStamp)
                datasetPathList{i} = {[datasetRoot seqTimeStamp{i} ...
                    '/stereo/centre/undistort_images_crop/']};
            end
            
            imageFnsAllSeq = [];
            seqIdx = [];
            for j = 1:length(datasetPathList)
                imageSingleSeq = dir(char(fullfile(datasetPathList{j},'*.jpg')));
                
                imageFoldersSingleSeq = char(imageSingleSeq.folder);
                imageNamesSingleSeq = char(imageSingleSeq.name);
                imageFnsSingleSeq = cellstr(strcat(string(...
                    imageFoldersSingleSeq(:,44:end)), ...
                    '/', string(imageNamesSingleSeq)));
                imageFnsAllSeq = [imageFnsAllSeq; imageFnsSingleSeq];
                
                seqIdx = [seqIdx; j*ones(length(imageFnsSingleSeq), 1)];
            end
            obj.imageFns = imageFnsAllSeq;
            obj.imageTimeStamp = cellfun(@(x) str2double(x(end-23:end-8)), imageFnsAllSeq);
            obj.seqIdx = seqIdx;
            obj.seqTimeStamp = seqTimeStamp;
            obj.loadUTMPosition();
            obj.removeImagesWithBadGPS();
        end
        
        function loadUTMPosition(obj)
            % Estimate image positions by applyiimageTimeStampng linear interpolation on GPS
            % measurements based on image timestamps
            paths = localPaths;
            imageGPSPositions = [];
            gpsDataRoot = paths.gpsDataRootRobotCar;
            
            parfor i = 1:length(obj.seqTimeStamp)
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
        
        function removeImagesWithBadGPS(obj)
            validGPSMeasurements = ~isnan(obj.utm(:,1));
            
            obj.imageFns = obj.imageFns(validGPSMeasurements);
            obj.imageTimeStamp = obj.imageTimeStamp(validGPSMeasurements);
            obj.seqIdx = obj.seqIdx(validGPSMeasurements);
            obj.utm = obj.utm(validGPSMeasurements, :);
        end
    end
end

