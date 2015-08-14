classdef Device < symphonyui.core.CoreObject
    
    properties (SetAccess = private)
        name
        manufacturer
    end
    
    properties
        sampleRate
        background
    end
    
    methods
        
        function obj = Device(cobj)
            obj@symphonyui.core.CoreObject(cobj);
        end
        
        function n = get.name(obj)
            n = char(obj.cobj.Name);
        end

        function m = get.manufacturer(obj)
            m = char(obj.cobj.Manufacturer);
        end
        
        function d = bindStream(obj, stream)
            obj.tryCore(@()obj.cobj.BindStream(stream.cobj));
            d = obj;
        end
        
        function r = get.sampleRate(obj)
            cir = obj.cobj.InputSampleRate;
            cor = obj.cobj.OutputSampleRate;
            if (cir ~= cor)
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
            obj.updateBackgroundOutputDataStream(); 
        end
        
        function b = get.background(obj)
            b = symphonyui.core.Measurement(obj.cobj.Background);
        end
        
        function set.background(obj, b)
            obj.cobj.Background = b.cobj;
            obj.updateBackgroundOutputDataStream();           
        end
        
        function applyBackground(obj)
            obj.tryCore(@()obj.cobj.ApplyBackground());
        end
        
    end
    
    methods (Access = private)
        
        function updateBackgroundOutputDataStream(obj)
            if isempty(obj.cobj.Controller)
                return;
            end
            bg = Symphony.Core.Background(obj.cobj.Background, obj.cobj.OutputSampleRate);
            stream = Symphony.Core.BackgroundOutputDataStream(bg);
            obj.cobj.Controller.BackgroundDataStreams.Item(obj.cobj, stream);
        end
        
    end
    
end

