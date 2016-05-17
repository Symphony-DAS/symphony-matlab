classdef Stimulus < symphonyui.core.CoreObject
    % A Stimulus represents a single stimulus (i.e. the output of a single device) during an epoch.
    %
    % Stimulus Methods:
    %   getData     - Gets a vector of the data of this stimulus
    
    properties (SetAccess = private)
        stimulusId  % Identifier of this stimulus
        sampleRate  % Sample rate of this stimulus (Measurement)
        parameters  % Parameters used to generate this stimulus (container.Map)
        duration    % Duration of this stimulus (duration)
        units       % Units of this stimulus
    end
    
    methods
        
        function obj = Stimulus(cobj)
            obj@symphonyui.core.CoreObject(cobj);
        end
        
        function i = get.stimulusId(obj)
            i = char(obj.cobj.StimulusID);
        end
        
        function m = get.sampleRate(obj)
            cm = obj.cobj.SampleRate;
            if isempty(cm)
                m = [];
            else
                m = symphonyui.core.Measurement(cm);
            end
        end
        
        function p = get.parameters(obj)
            p = obj.mapFromKeyValueEnumerable(obj.cobj.Parameters);
        end
        
        function d = get.duration(obj)
            cdur = obj.cobj.Duration;
            if cdur.IsNone()
                d = seconds(inf);
            else
                d = obj.durationFromTimeSpan(cdur.Item2);
            end
        end
        
        function u = get.units(obj)
            u = char(obj.cobj.Units);
        end
        
        function [q, u] = getData(obj, duration)
            % Gets a vector of the data of this stimulus. Stimuli with infinite duration must specify the duration of
            % the vector to get.
            
            if nargin < 2
                duration = obj.duration;
            end
            if isempty(duration)
                error('Cannot get data for indefinite stimulus');
            end
            
            span = obj.timeSpanFromDuration(duration);
            enum = obj.tryCoreWithReturn(@()obj.cobj.DataBlocks(span));
            cblk = obj.firstFromEnumerable(enum);
            d = cblk.Data;
            q = double(Symphony.Core.Measurement.ToQuantityArray(d));
            u = char(Symphony.Core.Measurement.HomogenousDisplayUnits(d));
        end
        
    end
    
end

