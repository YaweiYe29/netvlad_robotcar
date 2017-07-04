classdef dbOxfordRobotCar < dbBase
    
    methods
        function db= dbOxfordRobotCar(whichSet)
            % fullSize is: true or false
            % whichSet is one of: train, val, test
            
            assert( ismember(whichSet, {'train', 'val', 'test'}) );
            
            db.name= sprintf('robotcar_%s', whichSet);
            
            paths= localPaths();
            dbRoot= paths.dsetRootPitts;
            db.dbPath= [dbRoot, 'images/'];
            db.qPath= [dbRoot, 'queries/'];
            
            db.dbLoad();
        end
    end
end

