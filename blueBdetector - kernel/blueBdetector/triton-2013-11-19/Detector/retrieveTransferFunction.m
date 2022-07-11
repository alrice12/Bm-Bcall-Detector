function [xfr_f, id] = retrieveTransferFunction(DataFile, bin_kHz)
% function [xfr_f, id] = retrieveTransferFunction(DataFile, bin_kHz)
%
%	Retrieve the appropriate transfer function for the site and deployment
%	the file was recorded at. Assumes proper file naming
%
%	Input:
%		DataFile - File name
%			{project name}{deployment ID}{site}_YYmmDD_HHMMSS.x.wav
%		bin_kHz  - frequencies we are concerned with
%
%	Output:
%		xfr_f - PreAmp / Transfer function
%		id    - Name/Id of PreAmp, for reference

	xfr_f=[];

    [pathdir, fileName, ext] = fileparts(DataFile);
	undscr = strfind(fileName, '_');
	fileInfo = fileName(1:undscr(1)-1);
	id = 'Not Found';
	
	% Parse through the file name to get the project, deployment and site
	% information
    m = regexp(fileName, ...
        '(?<project>[A-Z]+[^0-9])(?<deployment>[0-9]+)(?<site>[^_]*)?_.*', ...
        'names');
    pjct = m.project;
    dpID = m.deployment;
    ste = m.site;
	
    % Fix known problems with encodings of project names in files
    switch pjct
        case 'SCAL'
            pjct = 'SOCAL';
        case 'PALMRA'
            pjct = 'PAL';
            ste = 'WT';  % Site not encoded properly
    end
	
	if strcmp(ste, 'SN') == 1
		ste = 'N';
	end
	
	% Get deployment from beluga.ucsd.edu
	q = dbInit();
	dply = dbDeploymentInfo(q, 'Project', pjct, 'Site', ste, 'DeploymentID', dpID);
	if isempty(dply)
		return;
	end
	id = num2str(dply.Sensors.Audio.PreampID);
	
	% Remove the "H" in front
	% !! TEMPORARY !! Remove this when the database is fixed.
	
	if id(1) == 'H'
		id = id(2:end);
	end
	
	% !! TEMPORARY !!
    previous_id = id;
    switch id
        case '306'
            id = '309';  % No tf available, use something close
        case '*'
            id = '320';  % Unknown
    end
    if ~strcmp(id, previous_id)
        fprintf('Project %s Site %s Deployment %s - Override TF %s --> %s\n', ...
            pjct, ste, dpID, previous_id, id);
    end
	
	transf = dbGetTransferFn(q, id);
	if isempty(transf)
		return;
	end
	
	bin_Hz = bin_kHz * 1000;
	xfr_f = interp1(transf(:,1), transf(:,2), bin_Hz, 'linear', 'extrap');
	
% 	figure; semilogx(tf(:,1),tf(:,2)); xlabel('Hz'); ylabel('dB');
end