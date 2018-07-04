function SwitchSPMfdr(SWITCHTYPE)
%   SWITCHTYPE = string denoting either 'voxelFDR' or 'topoFDR'
%


global defaults; spm_get_defaults; 

if strcmp(SWITCHTYPE,'voxelFDR')
    defaults.stats.topoFDR = 0;
elseif strcmp(SWITCHTYPE,'topoFDR')
    defaults.stats.topoFDR = 1;
end % if
