classdef EpochSet < symphonyui.core.persistent.collections.TimelineEntitySet
    
    properties (SetAccess = private)
        protocolParameters
        stimulusMap
        responseMap
    end
    
    methods
        
        function obj = EpochSet(epochs)
            obj@symphonyui.core.persistent.collections.TimelineEntitySet(epochs);
        end
        
        function p = get.protocolParameters(obj)
            maps = cell(1, numel(obj.objects));
            for i = 1:numel(obj.objects)
                maps{i} = obj.objects{i}.protocolParameters;
            end
            p = obj.intersectMaps(maps);
        end
        
        function m = get.stimulusMap(obj)
            m = containers.Map();
            for i = 1:numel(obj.objects)
                epoch = obj.objects{i};
                stimuli = epoch.stimuli;
                for k = 1:numel(stimuli)
                    device = stimuli{k}.device.name;
                    if ~m.isKey(device)
                        m(device) = [];
                    end
                    
                    m(device) = [m(device) stimuli(k)];
                end
            end
        end
        
        function m = get.responseMap(obj)
            m = containers.Map();
            for i = 1:numel(obj.objects)
                epoch = obj.objects{i};
                responses = epoch.responses;
                for k = 1:numel(responses)
                    device = responses{k}.device.name;
                    if ~m.isKey(device)
                        m(device) = [];
                    end
                    
                    m(device) = [m(device) responses(k)];
                end
            end
        end
        
    end
    
end

