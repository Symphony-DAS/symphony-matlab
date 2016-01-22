classdef Epoch < symphonyui.core.CoreObject

    properties
        parameters
        keywords
        shouldWaitForTrigger
        shouldBePersisted
    end

    properties (SetAccess = private)
        duration
    end

    methods

        function obj = Epoch(identifier)
            if isa(identifier, 'Symphony.Core.Epoch')
                cobj = identifier;
            else
                cobj = Symphony.Core.Epoch(identifier);
            end

            obj@symphonyui.core.CoreObject(cobj);
        end

        function addStimulus(obj, device, stimulus)
            obj.tryCore(@()obj.cobj.Stimuli.Add(device.cobj, stimulus.cobj));
        end

        function addDirectCurrentStimulus(obj, device, measurement, duration, sampleRate)
            g = symphonyui.builtin.stimuli.DirectCurrentGenerator();
            g.offset = measurement.quantity;
            g.units = measurement.displayUnits;
            g.time = duration;
            g.sampleRate = sampleRate;
            obj.addStimulus(device, g.generate());
        end

        function addResponse(obj, device)
            obj.tryCore(@()obj.cobj.Responses.Add(device.cobj, Symphony.Core.Response()));
        end

        function r = getResponse(obj, device)
            cres = obj.tryCoreWithReturn(@()obj.cobj.Responses.Item(device.cobj));
            r = symphonyui.core.Response(cres);
        end

        function tf = hasResponse(obj, device)
            tf = obj.tryCoreWithReturn(@()obj.cobj.Responses.ContainsKey(device.cobj));
        end

        function m = get.parameters(obj)
            function out = wrap(in)
                out = in;
                if ischar(in) && ~isempty(in) && in(1) == '{' && in(end) == '}'
                    out = symphonyui.core.util.str2cellstr(in);
                end
            end
            m = obj.mapFromKeyValueEnumerable(obj.cobj.ProtocolParameters, @wrap);
        end

        function addParameter(obj, name, value)
            if iscellstr(value)
                value = symphonyui.core.util.cellstr2str(value);
            end
            obj.tryCore(@()obj.cobj.ProtocolParameters.Add(name, value));
        end

        function k = get.keywords(obj)
            k = obj.cellArrayFromEnumerable(obj.cobj.Keywords, @char);
        end

        function addKeyword(obj, keyword)
            obj.tryCore(@()obj.cobj.Keywords.Add(keyword));
        end

        function setBackground(obj, device, background)
            obj.tryCore(@()obj.cobj.SetBackground(device.cobj, background.cobj, device.cobj.OutputSampleRate));
        end

        function tf = get.shouldWaitForTrigger(obj)
            tf = obj.cobj.ShouldWaitForTrigger;
        end

        function set.shouldWaitForTrigger(obj, tf)
            obj.cobj.ShouldWaitForTrigger = tf;
        end

        function tf = get.shouldBePersisted(obj)
            tf = obj.cobj.ShouldBePersisted;
        end

        function set.shouldBePersisted(obj, tf)
            obj.cobj.ShouldBePersisted = tf;
        end

        function d = get.duration(obj)
            cdur = obj.cobj.Duration;
            if cdur.IsNone()
                d = seconds(inf);
            else
                d = obj.durationFromTimeSpan(cdur.Item2);
            end
        end

    end

end
