classdef DaqController < symphonyui.core.CoreObject
    % A DaqController manages an A/D device such as an ITC-18.
    %
    % DaqController Methods:
    %   getStreams          - Gets all streams available in this controller
    %   getStream           - Gets a single stream belonging to this controller by name
    %   getInputStreams     - Gets all input streams available in this controller
    %   getOutputStreams    - Gets all output streams available in this controller
    
    properties
        sampleRate  % Sample rate of this controller
    end
    
    properties (SetAccess = protected)
        sampleRateType  % Property type of the sampleRate property
    end
    
    properties (SetAccess = private)
        streams             % Streams available in this controller
        processInterval     % Interval this controller attempts to maintain for process iterations
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
            % Gets a single stream belonging to this controller by name
            
            cstr = obj.tryCoreWithReturn(@()obj.cobj.GetStream(name));
            if isempty(cstr)
                error(['A stream named ''' name ''' does not exist']);
            end
            s = symphonyui.core.DaqStream(cstr);
        end
        
        function s = get.streams(obj)
            warning('The streams property is deprecated. Use getStreams().');
            s = obj.getStreams();
        end
        
        function s = getStreams(obj)
            % Gets all streams available in this controller
            s = obj.cellArrayFromEnumerable(obj.cobj.Streams, @symphonyui.core.DaqStream);
        end
        
        function s = getInputStreams(obj)
            % Gets all input streams available in this controller
            s = obj.cellArrayFromEnumerable(obj.cobj.InputStreams, @symphonyui.core.DaqStream);
        end
        
        function s = getOutputStreams(obj)
            % Gets all output streams available in this controller
            s = obj.cellArrayFromEnumerable(obj.cobj.OutputStreams, @symphonyui.core.DaqStream);
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
