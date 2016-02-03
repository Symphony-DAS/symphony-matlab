classdef Device < symphonyui.core.CoreObject

    properties (SetAccess = private)
        name
        manufacturer
        inputStreams
        outputStreams
    end

    properties (Access = private)
        configurationSettingDescriptors
    end

    properties
        sampleRate
        background
    end

    methods

        function obj = Device(cobj)
            obj@symphonyui.core.CoreObject(cobj);
            obj.configurationSettingDescriptors = symphonyui.core.PropertyDescriptor.empty(0, 1);
        end

        function delete(obj)
            obj.close();
        end

        function close(obj) %#ok<MANU>
            % For subclasses.
        end

        function n = get.name(obj)
            n = char(obj.cobj.Name);
        end

        function m = get.manufacturer(obj)
            m = char(obj.cobj.Manufacturer);
        end

        function addConfigurationSetting(obj, name, value, varargin)
            descriptors = obj.getConfigurationSettingDescriptors();
            if ~isempty(descriptors.findByName(name))
                error([name ' already exists']);
            end
            descriptors(end + 1) = symphonyui.core.PropertyDescriptor(name, value, varargin{:});
            obj.tryCore(@()obj.cobj.Configuration.Add(name, obj.propertyValueFromValue(value)));
            obj.configurationSettingDescriptors = descriptors;
        end

        function setConfigurationSetting(obj, name, value)
            descriptors = obj.getConfigurationSettingDescriptors();
            d = descriptors.findByName(name);
            if isempty(d)
                error([name ' does not exist']);
            end
            d.value = value;
            obj.tryCore(@()obj.cobj.Configuration.Item(name, obj.propertyValueFromValue(value)));
            obj.configurationSettingDescriptors = descriptors;
        end

        function tf = removeConfigurationSetting(obj, name)
            descriptors = obj.getConfigurationSettingDescriptors();
            index = arrayfun(@(d)strcmp(d.name, name), descriptors);
            descriptors(index) = [];
            tf = obj.tryCoreWithReturn(@()obj.cobj.Configuration.Remove(name));
            obj.configurationSettingDescriptors = descriptors;
        end

        function d = getConfigurationSettingDescriptors(obj)
            d = obj.configurationSettingDescriptors;
        end
        
        function addResource(obj, name, variable)
            bytes = getByteStreamFromArray(variable);
            obj.tryCoreWithReturn(@()obj.cobj.AddResource('com.mathworks.data', name, bytes));
        end
        
        function v = getResource(obj, name)
            cres = obj.tryCoreWithReturn(@()obj.cobj.GetResource(name));
            v = getArrayFromByteStream(uint8(cres.Data));
        end
        
        function n = getResourceNames(obj)
            n = obj.cellArrayFromEnumerable(obj.cobj.GetResourceNames(), @char);
        end

        function d = bindStream(obj, stream, name)
            if nargin < 3
                obj.tryCore(@()obj.cobj.BindStream(stream.cobj));
            else
                obj.tryCore(@()obj.cobj.BindStream(name, stream.cobj));
            end
            d = obj;
        end

        function s = get.inputStreams(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.InputStreams, @symphonyui.core.DaqStream);
        end

        function s = get.outputStreams(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.OutputStreams, @symphonyui.core.DaqStream);
        end

        function r = get.sampleRate(obj)
            cir = obj.cobj.InputSampleRate;
            cor = obj.cobj.OutputSampleRate;
            if (~cir.Equals(cor))
                error('Mismatched input and output sample rate');
            end
            if isempty(cir)
                r = [];
            else
                r = symphonyui.core.Measurement(cir);
            end
        end

        function set.sampleRate(obj, r)
            obj.cobj.InputSampleRate = r.cobj;
            obj.cobj.OutputSampleRate = r.cobj;
        end

        function b = get.background(obj)
            cbg = obj.tryCoreWithReturn(@()obj.cobj.Background);
            b = symphonyui.core.Measurement(cbg);
        end

        function set.background(obj, b)
            obj.cobj.Background = b.cobj;
        end

        function applyBackground(obj)
            obj.tryCore(@()obj.cobj.ApplyBackground());
        end

    end

end
