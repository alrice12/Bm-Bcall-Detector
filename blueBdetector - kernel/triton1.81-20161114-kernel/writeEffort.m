function writeEffort(rootNode, spreadsheet)
% writeEffort(rootNode, spreadsheet)
% Based on the current effort tree rooted at rootNode,
% write the Effort to a spreadhseet.  Spreadsheet may be
% either a string indicating a filename to be used or 
% a handle to an active X (OLE) spreadsheet.

global TREE
currNode = rootNode.getFirstChild();
tLength = rootNode.getDepth();
if nargout > rootNode.getDepth()
    tLength = nargout-1;
end
struct = cell(1,tLength);
list = cell(0,tLength);
flag1 = 0;
level = currNode.getLevel();
first = true;
params = cell(0,6);
while ~isempty(currNode) || level > 1
    
    previous = currNode;
    level = currNode.getLevel();
    gpValue = currNode.getValue();
    %disp(char(gpValue(2)));
    selected = strcmp(gpValue(1), 'selected');
    if selected
        level = currNode.getLevel();
        % We need to store two values for the second level of the tree
        % Common name and abbreviation
        offset = level >= 2;
        if level == 2
            values{level} = char(currNode.getName());
        end
        values{currNode.getLevel()+offset} = char(gpValue(2));
        traverseChildren = currNode.getAllowsChildren();
        
        if traverseChildren
            % Traverse children
            currNode = currNode.getFirstChild();
        else
            % At a leaf node.  values{1:level} contain the tree info
            list(end+1,1:level+offset) = values(1:level+offset);
            if first
                values{1} = '';  % effort template does not repeat group
            end
            params(end+1, :) = TREE.frequency(str2num(gpValue(3)),:);
        end
    else
        traverseChildren = false;
    end
    
    %disp([num2str(isempty(currNode.getNextSibling())), ' ', num2str(~isempty(currNode.getParent()))]);
    if ~ traverseChildren
        % Don't go further down the chain
        % We are either at a leaf or we are not interested in this chain
        
        if ~isempty(currNode.getNextSibling())
            % process siblings of the current node
            currNode = currNode.getNextSibling();
        elseif ~isempty(currNode.getParent().getNextSibling())
            % no more siblings, process parent's siblings
            currNode = currNode.getParent().getNextSibling();
        elseif level ~= 1
            % process grandparent's sibling
            % Todo:  Make the whole process more general, perhaps
            %        use a stack and push/pop
            level = currNode.getParent().getParent().getLevel();
            currNode = currNode.getParent().getParent().getNextSibling();
        end
    end
    
    if previous == currNode
        break
    end
end

list = [list, params];


if ischar(spreadsheet)
    % filename, try to open it
    try
        Excel = actxserver('Excel.Application');
    catch err
        errordlg('Unable to access spreadsheet interface')
        return
    end
    %Excel.Visible = 1;  % for debugging

    try
        Workbook = Excel.workbooks.Open(spreadsheet);  % Open workbook
    catch err
        errordlg(sprintf('Unable to open spreadsheet %s', spreadsheet));
        return
    end
else
    Workbook = spreadsheet;  % Already open, copy handle
end

try
    EffortSheet = Workbook.Sheets.Item('Effort'); % Access the Effort sheet
catch
    errordlg('Master template missing Effort sheet');
end

% Clear out the current effort
RowsN = EffortSheet.UsedRange.Rows.Count;
Range = EffortSheet.Range(sprintf('2:%d', RowsN));
Range.Clear();  

% Add selected effort
[rows, cols] = size(list);
lastcell = sprintf('%s%d', excelColumn(cols-1), 1+rows);
Range = EffortSheet.Range(sprintf('A2:%s', lastcell));
set(Range, 'Value', list);

if ischar(spreadsheet)
    % save and close, user wanted file operation
    Workbook.Save();  % Save changes
    Workbook.Close(false);  % Close program
    Excel.Quit;  % Exit server
end


