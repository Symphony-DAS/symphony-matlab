classdef Epoch < symphonyui.core.CoreObject
    % An Epoch represents a period of time in the experimental time line. It is a generalization of the common notion of
    % a "trial".
    %
    % Epoch Methods:
    %   addStimulus     - Adds a stimulus to present when this epoch is run
    %   removeStimulus  - Removes a stimulus for the specified device
    %   getStimulus     - Gets the stimulus for the specified device
    %   hasStimulus     - Indicates if this epoch has a stimulus for the specified device
    %
    %   addResponse     - Adds a response to be recorded when this epoch is run
    %   removeResponse  - Removes a response for the specified device
    %   getResponse     - Gets the response for the specified device
    %   hasResponse     - Indicates if this epoch has a response for the specified device
    %
    %   setBackground   - Sets a background value for a device while this epoch is run
    %   hasBackground   - Indicates if this epoch has a background for the specified device
    %
    %   addParameter    - Adds a key/value pair (parameter) to this epoch
    %   addKeyword      - Adds a keyword tage to this epoch

    properties
        parameters              % Parameters added to this epoch (containers.Map)
        keywords                % Keywords attached to this epoch
        shouldWaitForTrigger    % Indicates if this epoch should wait for an external trigger before running
        shouldBePersisted       % Indicates if this epoch should be persisted upon completion
    end

    properties (SetAccess = private)
        duration    % Duration of this epoch, defined by the duration of its longest stimulus or response (duration)
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
            % Adds a stimulus to present when this epoch is run

            obj.tryCore(@()obj.cobj.Stimuli.Add(device.cobj, stimulus.cobj));
        end

        function removeStimulus(obj, device)
            % Removes a stimulus for the specified device

            obj.tryCore(@()obj.cobj.Stimuli.Remove(device.cobj));
        end

        function s = getStimulus(obj, device)
            % Gets the stimulus for the specified device

            cstim = obj.tryCoreWithReturn(@()obj.cobj.Stimuli.Item(device.cobj));
            s = symphonyui.core.Stimulus(cstim);
        end

        function tf = hasStimulus(obj, device)
            % Indicates if this epoch has a stimulus for the specified device

            tf = obj.tryCoreWithReturn(@()obj.cobj.Stimuli.ContainsKey(device.cobj));
        end

        function addDirectCurrentStimulus(obj, device, measurement, duration, sampleRate)
            % A convenience method for adding a constant, zero-frequency, stimulus to this epoch. This method is mostly
            % useful for interval epochs where you just want to set the intervals duration by using a constant mean
            % stimulus.

            g = symphonyui.builtin.stimuli.DirectCurrentGenerator();
            g.offset = measurement.quantity;
            g.units = measurement.displayUnits;
            g.time = duration;
            g.sampleRate = sampleRate;
            obj.addStimulus(device, g.generate());
        end

        function addResponse(obj, device)
            % Adds a response to be recorded when this epoch is run

            obj.tryCore(@()obj.cobj.Responses.Add(device.cobj, Symphony.Core.Response()));
        end

        function removeResponse(obj, device)
            % Removes a response for the specified device

            obj.tryCore(@()obj.cobj.Responses.Remove(device.cobj));
        end

        function r = getResponse(obj, device)
            % Gets the response for the specified device

            cres = obj.tryCoreWithReturn(@()obj.cobj.Responses.Item(device.cobj));
            r = symphonyui.core.Response(cres);
        end

        function tf = hasResponse(obj, device)
            % Indicates if this epoch has a response for the specified device

            tf = obj.tryCoreWithReturn(@()obj.cobj.Responses.ContainsKey(device.cobj));
        end

        function m = get.parameters(obj)
            m = obj.mapFromKeyValueEnumerable(obj.cobj.ProtocolParameters, @obj.valueFromPropertyValue);
        end

        function addParameter(obj, name, value)
            % Adds a key/value pair (parameter) to this epoch

            obj.tryCore(@()obj.cobj.ProtocolParameters.Add(name, obj.propertyValueFromValue(value)));
        end

        function k = get.keywords(obj)
            k = obj.cellArrayFromEnumerable(obj.cobj.Keywords, @char);
        end

        function addKeyword(obj, keyword)
            % Adds a keyword tag to this epoch

            obj.tryCore(@()obj.cobj.Keywords.Add(keyword));
        end

        function setBackground(obj, device, background)
            % Sets a background value for a device while this epoch is run. A background is only used in the absence of
            % a stimulus.

            obj.tryCore(@()obj.cobj.SetBackground(device.cobj, background.cobj, device.cobj.OutputSampleRate));
        end

        function tf = hasBackground(obj, device)
            % Indicates if this epoch has a background for the specified device

            tf = obj.tryCoreWithReturn(@()obj.cobj.Backgrounds.ContainsKey(device.cobj));
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
