function findRawDisks(void)
%
% function to find Raw HARP disks connected to PC via USB 
%
% calls dd.exe version 0.5 
%


global PARAMS C

    if exist('dd.exe') && ispc
        ddx = which('dd.exe');  % get path and filename
        [status, result] = system([ddx,' --list']);
       % disp(result)
        
        % disp_msg(result) % doesn't show newline feeds
        % because of the way disp_msg works on vector of chars
        % the following works
         C = textscan(result, '%s', 'delimiter', '\n');
        % disp(C{:})
        
        str0 = 'NT Block Device Objects';
        k0 = strmatch(str0,C{:});
        str1 = '\\?\Device\Harddisk';
        k1 = strmatch(str1,C{:});
        str2 = 'link to \\?';
        k2 = strmatch(str2,C{:});
        str3 = 'Fixed hard disk media. Block size = 512';
        k3 = strmatch(str3,C{:});
        str4 = 'size is';
        k4 = strmatch(str4,C{:});  
        
        if ~isempty(k3)
            for m = 1:length(k3)
                disp(char(C{1}(k3(m)-2)))
                disp(char(C{1}(k3(m)-1)))
                disp(char(C{1}(k3(m))))
                disp(char(C{1}(k3(m)+1)))
                disp(' ')
            end
            
        end
        
        
        
        
%         str0 = 'NT Block Device Objects';
%         k0 = strfind(result, str0 );
%         str1 = '\\?\Device\Harddisk';
%         k1 = strfind(result, str1);
%         str2 = 'link to \\?';
%         k2 = strfind(result, str2);
%         str3 = 'Fixed hard disk media. Block size = 512';
%         k3 = strfind(result, str3);
%         str4 = 'size is';
%         k4 = strfind(result, str4);        
        
        
    end