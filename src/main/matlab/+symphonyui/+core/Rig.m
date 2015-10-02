classdef Rig < handle
    
    properties
        sampleRate
    end
    
    properties (SetAccess = private)
        daqController
        devices
        isClosed
    end
    
    methods
        
        function obj = Rig(description)
            obj.sampleRate = description.sampleRate;
            obj.daqController = description.daqController;
            obj.devices = description.devices;
            obj.isClosed = false;
            
            for i = 1:numel(obj.devices)
                obj.devices{i}.cobj.Clock = obj.daqController.cobj.Clock;
            end
        end
        
        function delete(obj)
            obj.close();
        end
        
        function close(obj)
            if obj.isClosed
                return;
            end
            obj.daqController.close();
            for i = 1:numel(obj.devices)
                obj.devices{i}.close();
            end
            obj.isClosed = true;
        end
        
        function set.sampleRate(obj, r)
            if isnumeric(r)
                r = symphonyui.core.Measurement(r, 'Hz');
            end
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
        
        function d = getDevices(obj, expression)
            if nargin < 2
                expression = '.';
            end
            d = {};
            for i = 1:numel(obj.devices)
                if regexpi(obj.devices{i}.name, expression, 'once')
                    d{end + 1} = obj.devices{i}; %#ok<AGROW>
                end
            end
        end
        
        function n = getDeviceNames(obj, expression)
            n = cellfun(@(d)d.name, obj.getDevices(expression), 'UniformOutput', false);
        end
        
        function d = getOutputDevices(obj)
            d = {};
            for i = 1:numel(obj.devices)
                if ~isempty(obj.devices{i}.outputStreams)
                    d{end + 1} = obj.devices{i}; %#ok<AGROW>
                end
            end
        end
        
        function d = getInputDevices(obj)
            d = {};
            for i = 1:numel(obj.devices)
                if ~isempty(obj.devices{i}.inputStreams)
                    d{end + 1} = obj.devices{i}; %#ok<AGROW>
                end
            end
        end
        
    end
    
end

