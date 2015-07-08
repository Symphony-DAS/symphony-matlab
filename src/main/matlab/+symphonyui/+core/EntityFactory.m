classdef EntityFactory < handle
    
    properties (Access = private)
        cache
    end
    
    methods
        
        function obj = EntityFactory()
            obj.cache = containers.Map();
        end
        
        function c = fromCoreEntityEnumerable(obj, enum)
            c = {};
            enum = Symphony.Core.EnumerableExtensions.Wrap(enum);
            e = enum.GetEnumerator();
            i = 1;
            while e.MoveNext()
                c{i} = obj.fromCoreEntity(e.Current);
                i = i + 1;
            end
        end
        
        function e = fromCoreEntity(obj, coreEntity)
            id = char(coreEntity.UUID.ToString());
            if obj.cache.isKey(id)
                e = obj.cache(id);
            else
                e = obj.wrap(coreEntity);
                obj.cache(id) = e;
            end
        end
        
    end
    
    methods (Access = private)
        
        function e = wrap(obj, coreEntity)
            import symphonyui.core.persistent.*;
            
            if isa(coreEntity, 'Symphony.Core.IPersistentDevice')
                e = Device(coreEntity, obj);
            elseif isa(coreEntity, 'Symphony.Core.IPersistentSource')
                e = Source(coreEntity, obj);
            elseif isa(coreEntity, 'Symphony.Core.IPersistentExperiment')
                e = Experiment(coreEntity, obj);
            elseif isa(coreEntity, 'Symphony.Core.IPersistentEpochGroup')
                e = EpochGroup(coreEntity, obj);
            elseif isa(coreEntity, 'Symphony.Core.IPersistentEpochBlock')
                e = EpochBlock(coreEntity, obj);
            elseif isa(coreEntity, 'Symphony.Core.IPersistentEpoch')
                e = Epoch(coreEntity, obj);
            elseif isa(coreEntity, 'Symphony.Core.IPersistentBackground')
                e = Background(coreEntity, obj);
            elseif isa(coreEntity, 'Symphony.Core.IPersistentResponse')
                e = Response(coreEntity, obj);
            elseif isa(coreEntity, 'Symphony.Core.IPersistentStimulus')
                e = Stimulus(coreEntity, obj);
            else
                error(['Unknown core entity type: ' class(coreEntity)]);
            end
        end
        
    end
    
end
