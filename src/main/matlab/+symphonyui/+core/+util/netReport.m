function r = netReport(netException)
    if isa(netException, 'System.Exception')
        netException = NET.NetException('', '', netException);
    end
    x = netException.ExceptionObject;
    r = char(x.Message);
    while ~isempty(x.InnerException)
        x = x.InnerException;
        r = [r char(10) char(x.Message)]; %#ok<AGROW>
    end
end
