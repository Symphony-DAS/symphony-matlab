function url = pathToUrl(path)
    if path(1) == filesep
        path(1) = [];
    end
    url = strrep(['file:/' path '/'],'\','/');
end

