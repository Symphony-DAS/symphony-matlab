function s = trueStruct(varargin)
    args = cell(1, numel(varargin) * 2);
    for i = 1:numel(varargin)
        k = i * 2 - 1;
        args{k} = varargin{i};
        args{k + 1} = true;
    end
    s = struct(args{:});
end

