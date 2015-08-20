classdef Rig < handle
    
    properties
        sampleRate
    end
    
    properties (SetAccess = private)
        daqController
        devices
    end
    
    methods
        
        function obj = Rig(description)
            obj.daqController = description.daqController;
            obj.devices = description.devices;
            obj.sampleRate = description.sampleRate;
        end
        
        function initialize(obj)
            obj.daqController.initialize();
        end
        
        function close(obj)
            obj.daqController.close();
        end
        
        function set.sampleRate(obj, r)
            daq = obj.daqController; %#ok<MCSUP>
            if isprop(daq, 'sampleRate')
                daq.sampleRate = r;
            end
            devs = obj.devices; %#ok<MCSUP>
            for i = 1:numel(devs)
                devs{i}.sampleRate = r;
            end
            obj.sampleRate = r;
        end
        
        function d = getDevice(obj, name)
            for i = 1:numel(obj.devices)
                if strcmp(obj.devices{i}.name, name)
                    d = obj.devices{i};
                    return;
                end
            end
            error(['A device named ''' name ''' does not exist']);
        end
        
    end
    
end

