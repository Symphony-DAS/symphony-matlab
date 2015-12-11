function r = netReport(netException)
    if isa(netException, 'System.Exception')
        netException = NET.NetException('', '', netException);
    end
    x = netException.ExceptionObject;
    while ~isempty(x.InnerException)
        x = x.InnerException;
    end
    r = char(x.Message);
end
