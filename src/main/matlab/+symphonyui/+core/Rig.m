classdef Rig < handle
    % A Rig represents an electrophysiology setup. A Rig is constructed with a RigDescription that describes all of its
    % devices.
    %
    % Rig Methods:
    %   getDevice       - Gets the first device whose name matches the given regular expression
    %   getDevices      - Gets a cell array of devices whose names match the given regular expression
    %   getDeviceNames  - Gets all device names that match the given regular expression
    %
    %   getOutputDevices    - Gets all devices with at least one bound output stream
    %   getInputDevices     - Gets all devices with at least one bound input stream

    properties (SetObservable)
        sampleRate  % Common sample rate of DAQ and devices (Measurement)
    end

    properties (SetAccess = private)
        sampleRateType
        daqController
        devices
        isClosed
    end

    methods

        function obj = Rig(description)
            % Constructs a Rig with the given RigDescription

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
            % Gets the first device whose name matches the given regular expression

            for i = 1:numel(obj.devices)
                if regexpi(obj.devices{i}.name, expression, 'once')
                    d = obj.devices{i};
                    return;
                end
            end
            error(['A device named ''' expression ''' does not exist']);
        end

        function d = getDevices(obj, expression)
            % Gets a cell array of devices whose names match the given regular expression

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
            % Gets all device names that match the given regular expression

            if nargin < 2
                expression = '.';
            end
            n = cellfun(@(d)d.name, obj.getDevices(expression), 'UniformOutput', false);
        end

        function d = getOutputDevices(obj)
            % Gets all devices with at least one bound output stream

            d = {};
            for i = 1:numel(obj.devices)
                if ~isempty(obj.devices{i}.getOutputStreams())
                    d{end + 1} = obj.devices{i}; %#ok<AGROW>
                end
            end
        end

        function d = getInputDevices(obj)
            % Gets all devices with at least one bound input stream

            d = {};
            for i = 1:numel(obj.devices)
                if ~isempty(obj.devices{i}.getInputStreams())
                    d{end + 1} = obj.devices{i}; %#ok<AGROW>
                end
            end
        end

    end

end
