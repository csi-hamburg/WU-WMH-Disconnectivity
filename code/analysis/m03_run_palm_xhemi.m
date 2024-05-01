BASEDIR=fullfile(pwd(), '..', '..')
OUTDIR=fullfile(BASEDIR, 'derivatives', 'palm', 'xhemi')
FS='/opt/freesurfer'
%FS='/usr/local/freesurfer/7.4.1/'

y5 = fullfile(BASEDIR, 'derivatives', 'NeMoMaps_surf_derivatives', ['NeMo_5mm_sqrt_fs5_lh+rh_on_lh_by_subj.mgh']);
surffile = fullfile(FS, 'subjects', 'fsaverage5', 'surf', 'lh.white');
areafile = fullfile(FS, 'subjects', 'fsaverage5', 'surf', 'lh.white.avg.area.mgh');

iters = 100;
itersstr = sprintf('%d',iters);

cft = 1.3;
pthresh = 10^-cft;
zthresh = fast_p2z(pthresh);
zthreshstr = sprintf('%f',zthresh);



design_raw = fullfile(OUTDIR, 'X_raw.csv')
system(['cat ' fullfile(BASEDIR, 'derivatives', 'GLM', 'X_full.csv') ' | awk -F '' '' ''{print 1,$6}'' > ' design_raw])
contrast_raw = fullfile(OUTDIR, 'C_raw.csv')

X = dlmread(design_raw);
n = size(X,1);
XX = [kron(X,[1;1]), kron(ones(n,1), [0;1]), kron(ones(n,1), [0;1]).*kron(X(:,2),[1;1])];
C1 = [0 1 0 0];
C2 = [0 0 1 0];
C3 = [0 0 0 1];
eb = [-ones(2*n,1), 2*ones(2*n,1), kron((1:n)',[1;1]), kron(ones(n,1),[1;2])];

dlmwrite(fullfile(OUTDIR, 'X_xhemi_raw.csv'), XX, 'delimiter', ' ');
dlmwrite(fullfile(OUTDIR, 'C_xhemi_raw.csv'), [C1; C2; C3], 'delimiter', ' ');
dlmwrite(fullfile(OUTDIR, 'eb_xhemi.csv'), eb, 'delimiter', ' ');



design_adj = fullfile(OUTDIR, 'X_adj.csv')
system(['cat ' fullfile(BASEDIR, 'derivatives', 'GLM', 'X_full.csv') ' | awk -F '' '' ''{print 1, $2, $3, $6, log($8), log($9)}'' > ' design_adj])
% intercept, age, sex, mRS, WMH_lh, WMH_rh
contrast_raw = fullfile(OUTDIR, 'C_adj.csv')

X = dlmread(design_adj);
XX = [kron(X(:, 1:4),[1;1]), kron(ones(n,1), [0;1]), kron(ones(n,1), [0;1]).*kron(X(:,4),[1;1]), kron(X(:,5),[1;0]) + kron(X(:,6),[0;1])];
% intercept, age, sex, mRS, hemi, mRSxhemi, WMH

C1 = [0 0 0 1 0 0 0];
C2 = [0 0 0 0 1 0 0];
C3 = [0 0 0 0 0 1 0];

dlmwrite(fullfile(OUTDIR, 'X_xhemi_adj.csv'), XX, 'delimiter', ' ');
dlmwrite(fullfile(OUTDIR, 'C_xhemi_adj.csv'), [C1; C2; C3], 'delimiter', ' ');

system(['Text2Vest ' fullfile(OUTDIR, 'X_xhemi_adj.csv') ' ' fullfile(OUTDIR, 'design_xhemi_adj.mat')]) 
system(['Text2Vest ' fullfile(OUTDIR, 'C_xhemi_adj.csv') ' ' fullfile(OUTDIR, 'design_xhemi_adj.con')]) 



palm('-i', y5, '-d', fullfile(OUTDIR, 'design_xhemi_raw.mat'), '-d', fullfile(OUTDIR, 'design_xhemi_adj.mat'),...
       '-t', fullfile(OUTDIR, 'design_xhemi_raw.con'), '-t', fullfile(OUTDIR, 'design_xhemi_adj.con'),...
       	'-logp','-eb', fullfile(OUTDIR, 'eb_xhemi.csv'), '-accel','tail', '-n', itersstr, '-T', '-C', zthreshstr, '-Cstat', 'mass', '-Cstat', 'extent', '-o', fullfile(OUTDIR, 'xhemi_fsp'), '-s', surffile, areafile);


