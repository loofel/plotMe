function varargout = parseArguments( allowed, arguments )
%PARSEarguments Summary of this function goes here
%   This function allows the use of arguments like matlab uses arguments.
%   allowed is a cell array containing allowed settings
%   arguments{1} is the cell struct of property sets
%       e.g.
%       {'fields',{'isHotWire';'isCandaq'},'values',{'hotWire';candaq'}...
%   varargout{1} contains the propertynames
%   varargout{2} contains the propertyvalues

amount = length(arguments);
if mod(amount,2) ~= 0
    varargout{1} = 'Nargin inbalance';
    varargout{2} = Inf;
    return;
else
    names = cell(amount/2,1);
    values = cell(amount/2,1);
    k = 1;
    for i = 1:2:amount
        names{k} = arguments{i};
        values{k} = arguments{i+1};
        k = k+1;
    end
    if ~isempty(allowed)
        for i = 1:amount/2
            name = names{i};
            found = 0;
            for j = 1:length(allowed)
                if strcmpi(name,allowed{j})
                    found = 1;
                    break;
                end
            end
            if found == 0
                varargout{1} = ['Unknown property: ', name];
                varargout{2} = inf;
                return;
            end
        end    
    end
    varargout{1} = names;
    varargout{2} = values;
end
end