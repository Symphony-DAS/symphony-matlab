classdef Device < symphonyui.core.CoreObject
    
    properties (SetAccess = private)
        name
        manufacturer
        configuration
        inputStreams
        outputStreams
    end
    
    properties (Access = private)
        staticConfigurationDescriptors
    end        
    
    properties
        sampleRate
        background
    end
    
    methods
        
        function obj = Device(cobj)
            obj@symphonyui.core.CoreObject(cobj);
            obj.staticConfigurationDescriptors = symphonyui.core.PropertyDescriptor.empty(0, 1);
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
        
        function c = get.configuration(obj)
            function out = wrap(in)
                out = in;
                if ischar(in) && ~isempty(in) && in(1) == '{' && in(end) == '}'
                    out = symphonyui.core.util.str2cellstr(in);
                end
            end
            c = obj.mapFromKeyValueEnumerable(obj.cobj.Configuration, @wrap);
        end
        
        function addConfigurationSetting(obj, key, value)
            if isempty(key)
                error('Key cannot be empty');
            end
            if isempty(value) && ~ischar(value) && ~iscell(value)
                value = NET.createArray('System.Double', 0);
            elseif iscellstr(value)
                value = symphonyui.core.util.cellstr2str(value);
            end
            obj.tryCore(@()obj.cobj.Configuration.Item(key, value));
        end
        
        function tf = removeConfigurationSetting(obj, key)
            desc = obj.staticConfigurationDescriptors;
            if ~isempty(desc.findByName(key))
                error('Cannot remove a setting with a static descriptor');
            end
            tf = obj.tryCoreWithReturn(@()obj.cobj.Configuration.Remove(key));
        end
        
        function d = getConfigurationDescriptors(obj)
            desc = obj.staticConfigurationDescriptors;
            map = obj.configuration;
            keys = map.keys;
            d = symphonyui.core.PropertyDescriptor.empty(0, numel(keys));
            for i = 1:numel(keys)
                static = desc.findByName(keys{i});
                if isempty(static)
                    d(i) = symphonyui.core.PropertyDescriptor(keys{i}, map(keys{i}), ...
                        'isReadOnly', true);
                else
                    static.value = map(static.name);
                    d(i) = static;
                end
            end
        end
        
        function addStaticConfigurationDescriptor(obj, desc)
            obj.addConfigurationSetting(desc.name, desc.value);
            obj.staticConfigurationDescriptors(end + 1) = desc;
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

