classdef DaqController < symphonyui.core.CoreObject
    
    properties
        sampleRate
    end
    
    properties (SetAccess = protected)
        sampleRateType
    end
    
    properties (SetAccess = private)
        streams
        processInterval
    end

    methods

        function obj = DaqController(cobj)
            obj@symphonyui.core.CoreObject(cobj);
        end
        
        function delete(obj)
            obj.close();
        end
        
        function close(obj) %#ok<MANU>
            % For subclasses.
        end
        
        function s = getStream(obj, name)
            cstr = obj.tryCoreWithReturn(@()obj.cobj.GetStream(name));
            if isempty(cstr)
                error(['A stream named ''' name ''' does not exist']);
            end
            s = symphonyui.core.DaqStream(cstr);
        end
        
        function s = get.streams(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.Streams, @symphonyui.core.DaqStream);
        end
        
        function setStreamsBackground(obj)
            obj.tryCore(@()obj.cobj.SetStreamsBackground());
        end
        
        function m = get.sampleRate(obj)
            cm = obj.cobj.SampleRate;
            if isempty(cm)
                m = [];
            else
                m = symphonyui.core.Measurement(cm);
            end
        end
        
        function set.sampleRate(obj, measurement)
            obj.setSampleRate(measurement);
        end
        
        function i = get.processInterval(obj)
            i = obj.durationFromTimeSpan(obj.cobj.ProcessInterval);
        end

    end
    
    methods (Access = protected)
        
        function setSampleRate(obj, measurement)
            if isempty(measurement)
                cm = [];
            else
                cm = measurement.cobj;
            end
            obj.cobj.SampleRate = cm;
        end
        
    end

end
