classdef EntityFactory < handle
    
    properties (Access = private)
        cache
    end
    
    methods
        
        function obj = EntityFactory()
            obj.cache = containers.Map();
        end            
        
        function e = create(obj, centity)
            uuid = char(centity.UUID.ToString());
            if obj.cache.isKey(uuid)
                e = obj.cache(uuid);
                return;
            end
            
            e = construct(centity, obj);
            obj.cache(uuid) = e;
        end
        
    end
    
end

function e = construct(centity, factory)
    if isa(centity, 'Symphony.Core.IPersistentDevice')
        e = symphonyui.core.persistent.Device(centity, factory);
    elseif isa(centity, 'Symphony.Core.IPersistentSource')
        e = symphonyui.core.persistent.Source(centity, factory);
    elseif isa(centity, 'Symphony.Core.IPersistentExperiment')
        e = symphonyui.core.persistent.Experiment(centity, factory);
    elseif isa(centity, 'Symphony.Core.IPersistentEpochGroup')
        e = symphonyui.core.persistent.EpochGroup(centity, factory);
    elseif isa(centity, 'Symphony.Core.IPersistentEpochBlock')
        e = symphonyui.core.persistent.EpochBlock(centity, factory);
    elseif isa(centity, 'Symphony.Core.IPersistentEpoch')
        e = symphonyui.core.persistent.Epoch(centity, factory);
    elseif isa(centity, 'Symphony.Core.IPersistentBackground')
        e = symphonyui.core.persistent.Background(centity, factory);
    elseif isa(centity, 'Symphony.Core.IPersistentResponse')
        e = symphonyui.core.persistent.Response(centity, factory);
    elseif isa(centity, 'Symphony.Core.IPersistentStimulus')
        e = symphonyui.core.persistent.Stimulus(centity, factory);
    elseif isa(centity, 'Symphony.Core.IPersistentResource')
        e = symphonyui.core.persistent.Resource(centity, factory);
    else
        error('Unknown core persistent class');
    end
end