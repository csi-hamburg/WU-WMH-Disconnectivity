DESIGN = [pwd filesep 'DESIGN.txt']
IMGDIR = [pwd filesep '../../derivatives/WMH_MNI_cropped']

cd('/home/eckhard/Downloads/CLSM_2.55.11.03.20')

clsm(DESIGN, IMGDIR, './out', 'vars', {'mRS'}, 'nperms', 1000, 'permvars', [1 0], 'highscoresarebad', true, 'fwhm', 3, 'multi', true, 'doica', true, 'newcolor', true)
