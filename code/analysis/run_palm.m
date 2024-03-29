BASEDIR=fullfile(pwd(), '..', '..')
OUTDIR=fullfile(BASEDIR, 'derivatives', 'palm')
FS='/opt/freesurfer'

hemi = 'lh';
input = fullfile(BASEDIR, 'derivatives', 'NeMoMaps_surf', ['NeMo_5mm_' hemi '.mgh']);
input5 = fullfile(OUTDIR, ['NeMo_5mm_fs5_' hemi '.mgh']);
y = fullfile(OUTDIR, ['NeMo_5mm_log_adj_' hemi '.mgh']);
y5 = fullfile(OUTDIR, ['NeMo_5mm_log_adj_fs5_' hemi '.mgh']);
evperdat = fullfile(OUTDIR, ['NeMo_5mm_log_pvr_' hemi '.mgh']);
evperdat5 = fullfile(OUTDIR, ['NeMo_5mm_log_pvr_fs5_' hemi '.mgh']);
surffile = fullfile(FS, 'subjects', 'fsaverage5', 'surf', [hemi '.white']);
areafile = fullfile(FS, 'subjects', 'fsaverage5', 'surf', [hemi '.white.avg.area.mgh']);

iters = 1000;
itersstr = sprintf('%d',iters);

cft = 1.3;
pthresh = 10^-cft;
zthresh = fast_p2z(pthresh);
zthreshstr = sprintf('%f',zthresh);


a=MRIread(input);
a.vol=sqrt(a.vol);
b=a;
a.vol(isinf(a.vol))=-10;
b.vol(~isinf(b.vol))=0;
b.vol(isinf(b.vol))=1;  
MRIwrite(a, y)  
MRIwrite(b, evperdat)  

% resample to fsaverage5
system(['mri_surf2surf --srcsubject fsaverage --trgsubject fsaverage5 --hemi ' hemi, ' --sval ', input, ' --tval ', input5])
system(['mri_surf2surf --srcsubject fsaverage --trgsubject fsaverage5 --hemi ' hemi, ' --sval ', y, ' --tval ', y5])
system(['mri_surf2surf --srcsubject fsaverage --trgsubject fsaverage5 --hemi ' hemi, ' --sval ', evperdat, ' --tval ', evperdat5])

design=fullfile(BASEDIR, 'derivatives', 'GLM', 'lh', 'mRS', 'X.csv')
contrast=fullfile(BASEDIR, 'derivatives', 'GLM', 'lh', 'mRS','mRS_pos.mat')

system(['Text2Vest ' design ' design.mat']) 
system(['Text2Vest ' contrast ' design.con']) 

palm('-i', y5, '-d', fullfile(OUTDIR, 'design.mat'),'-t', fullfile(OUTDIR, 'design.con'), '-logp',...
     '-accel','tail', '-n', itersstr, '-T', '-C', zthreshstr, '-Cstat', 'mass', '-o',[hemi '_fsp'],'-s',surffile, areafile);

%disp(['palm -i ', y5, ' -d ', fullfile(OUTDIR, 'design.mat'),' -t ', fullfile(OUTDIR, 'design.con'), ' -logp', ' -evperdat ', [evperdat5 ' 5'],...
%     ' -accel ','tail', ' -n ', itersstr, ' -rmethod ','Manly',' -o ','fsp',' -s ',surffile, ' ', areafile]);
%return;
