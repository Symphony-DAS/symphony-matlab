classdef EpochSet < symphonyui.app.EntitySet
    
    properties (SetAccess = private)
        stimulusMap
        responseMap
    end
    
    methods
        
        function obj = EpochSet(epochs)
            obj@symphonyui.app.EntitySet(epochs);
        end
        
        function m = get.stimulusMap(obj)
            m = containers.Map();
            for i = 1:numel(obj.entities)
                epoch = obj.entities{i};
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
            for i = 1:numel(obj.entities)
                epoch = obj.entities{i};
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

