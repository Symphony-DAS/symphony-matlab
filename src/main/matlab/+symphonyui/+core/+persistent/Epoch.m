classdef Epoch < symphonyui.core.persistent.TimelineEntity

    properties (SetAccess = private)
        protocolParameters
        responses
        stimuli
        backgrounds
        epochBlock
    end

    methods

        function obj = Epoch(cobj)
            obj@symphonyui.core.persistent.TimelineEntity(cobj);
        end

        function p = get.protocolParameters(obj)
            function out = wrap(in)
                out = in;
                if ischar(in) && ~isempty(in) && in(1) == '{' && in(end) == '}'
                    out = symphonyui.core.util.str2cell(in);
                end
            end
            p = obj.mapFromKeyValueEnumerable(obj.cobj.ProtocolParameters, @wrap);
        end

        function r = get.responses(obj)
            r = obj.cellArrayFromEnumerable(obj.cobj.Responses, @symphonyui.core.persistent.Response);
        end

        function s = get.stimuli(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.Stimuli, @symphonyui.core.persistent.Stimulus);
        end

        function b = get.backgrounds(obj)
            b = obj.cellArrayFromEnumerable(obj.cobj.Backgrounds, @symphonyui.core.persistent.Background);
        end

        function b = get.epochBlock(obj)
            b = symphonyui.core.persistent.EpochBlock(obj.cobj.EpochBlock);
        end

    end

end
