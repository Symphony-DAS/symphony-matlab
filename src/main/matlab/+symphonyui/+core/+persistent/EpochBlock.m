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
        
        function e = get.epochs(obj)
            c = obj.cellArrayFromEnumerable(obj.cobj.Epochs, @symphonyui.core.persistent.Epoch);
        end
        
    end
    
end

