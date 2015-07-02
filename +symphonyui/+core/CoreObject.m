classdef (Abstract) CoreObject < handle
    
    properties (SetAccess = private, Hidden)
        cobj
    end
    
    methods
        
        function tf = isequal(obj, other)
            tf = obj.cobj.Equals(other.cobj);
        end
        
    end
    
    methods (Access = protected)
        
        function obj = CoreObject(cobj)
            obj.cobj = cobj;
        end
        
        function c = cellArrayFromEnumerable(~, enum)
            c = {};
            e = enum.GetEnumerator();
            i = 1;
            while e.MoveNext()
                c{i} = convert(e.Current());
                i = i + 1;
            end
        end
        
        function m = mapFromKeyValueEnumerable(~, enum)
            m = containers.Map();
            e = enum.GetEnumerator();
            while e.MoveNext()
                kv = e.Current();
                m(char(kv.Key)) = convert(kv.Value);
            end
        end
        
        function t = datetimeFromDateTimeOffset(~, dto)
            t = datetime(dto.Year, dto.Month, dto.Day, dto.Hour, dto.Minute, dto.Second);
            t.TimeZone = char(dto.Offset.ToString());
        end
        
        function dto = dateTimeOffsetFromDatetime(~, t)
            if isempty(t.TimeZone)
                error('Datetime ''TimeZone'' must be set');
            end
            t.Format = 'ZZZZZ';
            offset = System.TimeSpan.Parse(char(t));
            dto = System.DateTimeOffset(t.Year, t.Month, t.Day, t.Hour, t.Minute, t.Second, offset);
        end
        
    end
    
end

function v = convert(dotNetValue)
    v = dotNetValue;
    if ~isa(v, 'System.Object')
        return;
    end
    
    clazz = strtok(class(dotNetValue), '[');
    switch clazz
        case 'System.Int16'
            v = int16(v);
        case 'System.UInt16'
            v = uint16(v);
        case 'System.Int32'
            v = int32(v);
        case 'System.UInt32'
            v = uint32(v);
        case 'System.Int64'
            v = int64(v);
        case 'System.UInt64'
            v = uint64(v);
        case 'System.Single'
            v = single(v);
        case 'System.Double'
            v = double(v);
        case 'System.Boolean'
            v = logical(v);
        case 'System.Byte'
            v = uint8(v);
        case {'System.Char', 'System.String'}
            v = char(v);
    end
end