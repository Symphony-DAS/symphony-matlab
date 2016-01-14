classdef EpochBlock < symphonyui.core.persistent.TimelineEntity

    properties (SetAccess = private)
        protocolId
        protocolParameters
        epochs
        epochGroup
    end

    methods

        function obj = EpochBlock(cobj)
            obj@symphonyui.core.persistent.TimelineEntity(cobj);
        end

        function p = get.protocolId(obj)
            p = char(obj.cobj.ProtocolID);
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

        function e = get.epochs(obj)
            e = obj.cellArrayFromEnumerableOrderedBy(obj.cobj.Epochs, 'startTime', @symphonyui.core.persistent.Epoch);
        end

        function g = get.epochGroup(obj)
            g = symphonyui.core.persistent.EpochGroup(obj.cobj.EpochGroup);
        end

    end

end
