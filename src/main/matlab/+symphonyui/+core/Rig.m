classdef Rig < handle
    
    properties (SetObservable)
        sampleRate
    end
    
    properties (SetAccess = private)
        sampleRateType
        daqController
        devices
        isClosed
    end
    
    methods
        
        function obj = Rig(description)
            obj.daqController = description.daqController;
            obj.devices = description.devices;
            obj.isClosed = false;
            
            for i = 1:numel(obj.devices)
                obj.devices{i}.cobj.Clock = obj.daqController.cobj.Clock;
            end
            
            obj.sampleRate = obj.daqController.sampleRate;
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
        
        function r = get.sampleRate(obj)
            r = obj.daqController.sampleRate;
            devs = obj.devices;
            for i = 1:numel(devs)
                if r ~= devs{i}.sampleRate
                    error('Non-homogenous sample rate');
                end
            end
        end
        
        function set.sampleRate(obj, r)
            if isnumeric(r) && ~isempty(r)
                r = symphonyui.core.Measurement(r, 'Hz');
            end
            obj.daqController.sampleRate = r; %#ok<MCSUP>
            devs = obj.devices; %#ok<MCSUP>
            for i = 1:numel(devs)
                devs{i}.sampleRate = r;
            end
        end
        
        function t = get.sampleRateType(obj)
            t = obj.daqController.sampleRateType;
        end
        
        function d = getDevice(obj, expression)
            for i = 1:numel(obj.devices)
                if regexpi(obj.devices{i}.name, expression, 'once')
                    d = obj.devices{i};
                    return;
                end
            end
            error(['A device named ''' expression ''' does not exist']);
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
            if nargin < 2
                expression = '.';
            end
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

