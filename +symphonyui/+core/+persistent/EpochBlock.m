classdef EpochBlock < symphonyui.core.persistent.TimelineEntity
    
    properties (SetAccess = private)
        protocolId
        epochs
    end
    
    methods
        
        function obj = EpochBlock(cobj)
            obj@symphonyui.core.persistent.TimelineEntity(cobj);
        end
        
        function p = get.protocolId(obj)
            p = char(obj.cobj.ProtocolID);
        end
        
        function g = get.epochs(obj)
            c = obj.cellArrayFromEnumerable(obj.cobj.Epochs);
            g = cell(1, numel(c));
            for i = 1:numel(c)
                g{i} = symphonyui.core.persistent.Epoch(c{i});
            end
        end
        
    end
    
end

