function name = packageName(path)
    if isempty(path)
        name = [];
        return;
    end
    name = regexp(path, '\+(\w)+', 'tokens');
    name = strcat([name{:}], [repmat({'.'},1,numel(name)-1) {''}]);
    name = [name{:}];
end

