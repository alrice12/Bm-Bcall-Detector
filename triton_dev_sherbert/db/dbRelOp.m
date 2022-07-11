function ComparisonStr = dbRelOp(Element, XPathFmt, Comparison, varargin)
% comparison = dbRelOp(Parameter, XPathFmt, RelOp, OptionalArgs)
% Helper function for translating comparisons into XQuery
% fragments.  Not intended to be called directly by the user.
%
% Compares XML element with the value in Comparison
% Comparison is equality if Comparison is a string or scalar value
% If Comparison is a cell array, the first element must be the comparison
% operator:  '=', '<', '<=', '>', '>=', '!='
%
% XPathFmt is an sprintf format string that allows the eleement to 
% be placed within an XQuery path.  
%
% Example:  Select $detection/Parameter/MinHz > 5000
% dbRelOp('MinHz', '$detection/Parameter/%s', {'>', 5000})
%
% Optional arguments:
%   'Type', string - Special handling for types:
%       'xs:dateTime' - Treat as a datetime.  Numeric values are assumed
%           to be Matlab serial dates.  Text strings are assumed to be
%           ISO8601 and are wrapped with an xs:dateTime constructor

type = '';
vidx = 1;

while vidx < length(varargin)
    switch varargin{vidx}
        case 'Type'
            type = varargin{vidx+1}; vidx = vidx + 2;
            switch type
                case {'xs:dateTime'}
                otherwise
                    error('Unknown Type argument');
            end
        otherwise
            error('Unknown optional argument')
    end
end

% Qualify the element using the format string
% e.g. '$i/%s' -->  $i/@someattribute
lhs = sprintf(XPathFmt, Element);

if iscell(Comparison)
    if length(Comparison) ~= 2
        error('Comparison cell arrays must be of length 2');
    end
    op = Comparison{1};
    value = Comparison{2};
else
    op = '=';  % default equality
    value = Comparison;
end
    
if isscalar(value)%false if string
    switch type
        case 'xs:dateTime'
            value = dbSerialDateToISO8601(value);
            value = sprintf('xs:dateTime("%s")',value);
        otherwise
    end
else
	value = sprintf('"%s"', value);  % add quotes for string
end

if isnumeric(value)
    ComparisonStr = sprintf('number(%s) %s %f', lhs, op, value);
else
    ComparisonStr = sprintf('%s %s %s', lhs, op, value);
end

