BASEDIR=fullfile(pwd(), '..', '..')
OUTDIR=fullfile(BASEDIR, 'derivatives', 'palm')

FS='/opt/freesurfer'
%FS='/usr/local/freesurfer/7.4.1/'


hemi = 'lh';
input = fullfile(BASEDIR, 'derivatives', 'NeMoMaps_surf', ['NeMo_5mm_' hemi '.mgh']);
y = fullfile(OUTDIR, ['NeMo_5mm_sqrt_adj_' hemi '.mgh']);
y5 = fullfile(OUTDIR, ['NeMo_5mm_sqrt_adj_fs5_' hemi '.mgh']);

surffile = fullfile(FS, 'subjects', 'fsaverage5', 'surf', [hemi '.white']);
areafile = fullfile(FS, 'subjects', 'fsaverage5', 'surf', [hemi '.white.avg.area.mgh']);

iters = 100;
itersstr = sprintf('%d',iters);

cft = 1.3;
pthresh = 10^-cft;
zthresh = fast_p2z(pthresh);
zthreshstr = sprintf('%f',zthresh);


a = MRIread(input);
a.vol = sqrt(a.vol);
MRIwrite(a, y)  

% resample to fsaverage5
system(['mri_surf2surf --srcsubject fsaverage --trgsubject fsaverage5 --hemi ' hemi, ' --sval ', y, ' --tval ', y5])


design_raw = fullfile(OUTDIR, 'X_raw.csv')
system(['cat ' fullfile(BASEDIR, 'derivatives', 'GLM', 'X_full.csv') ' | awk -F '' '' ''{print 1,$6}'' > ' design_raw])
contrast_raw = fullfile(OUTDIR, 'C_mRS_raw.csv')
dlmwrite(contrast_raw, [0 1], 'delimiter', ' ')


design_adj = fullfile(OUTDIR, 'X_adj.csv')
if strcmp(hemi, 'lh')
	hemistr = '$8'
elseif strcmp(hemi, 'rh')
	hemistr = '$9'
end



system(['cat ' fullfile(BASEDIR, 'derivatives', 'GLM', 'X_full.csv') ' | awk -F '' '' ''{print 1,$2, $3, $6, log(' hemistr ')}'' > ' design_adj])
contrast_adj = fullfile(OUTDIR, 'C_mRS_adj.csv')
dlmwrite(contrast_adj, [0 0 0 1 0], 'delimiter', ' ')


system(['Text2Vest ' design_raw ' ' strrep(design_raw, '.csv', '.mat')]) 
system(['Text2Vest ' contrast_raw ' ' strrep(contrast_raw, '.csv', '.con')]) 

system(['Text2Vest ' design_adj ' ' strrep(design_adj, '.csv', '.mat')])
system(['Text2Vest ' contrast_adj ' ' strrep(contrast_adj, '.csv', '.con')]) 

palm('-i', y5, '-d', strrep(design_raw, '.csv', '.mat'), '-d', strrep(design_adj, '.csv', '.mat'),...
       	'-t', strrep(contrast_raw, '.csv', '.con'), '-t', strrep(contrast_adj, '.csv', '.con'),...
       	'-logp', '-accel','tail', '-n', itersstr, '-T', '-C', zthreshstr, '-Cstat', 'mass', '-Cstat', 'extent',...
       	'-o', fullfile(OUTDIR, [hemi '_fsp']), '-s', surffile, areafile);


