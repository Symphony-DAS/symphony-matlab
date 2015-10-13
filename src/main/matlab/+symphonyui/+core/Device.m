classdef Device < symphonyui.core.CoreObject
    
    properties (SetAccess = private)
        name
        manufacturer
        configuration
        inputStreams
        outputStreams
    end
    
    properties
        sampleRate
        background
    end
    
    methods
        
        function obj = Device(cobj)
            obj@symphonyui.core.CoreObject(cobj);
        end
        
        function delete(obj)
            obj.close();
        end
        
        function close(obj)
            
        end
        
        function n = get.name(obj)
            n = char(obj.cobj.Name);
        end

        function m = get.manufacturer(obj)
            m = char(obj.cobj.Manufacturer);
        end
        
        function c = get.configuration(obj)
            c = obj.mapFromKeyValueEnumerable(obj.cobj.Configuration);
        end
        
        function addConfigurationParameter(obj, name, value)
            obj.tryCore(@()obj.cobj.Configuration.Add(name, value));
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

