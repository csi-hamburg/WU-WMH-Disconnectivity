BASEDIR = fullfile(pwd(), '..', '..')

NeMo = read_surface_data(fullfile(BASEDIR, 'derivatives', 'NeMoMaps_surf_derivatives', 'NeMo_5mm_sqrt_fs5_lh+rh_on_lh_by_subj.mgh'));
NeMo_old = read_surface_data('NeMo_5mm_sqrt_adj_fs5_lh+rh_on_lh.mgh');
%NeMo_left = read_surface_data(fullfile(BASEDIR, 'derivatives', 'palm', 'NeMo_5mm_fs5_lh.mgh'));
%NeMo_right = read_surface_data(fullfile(BASEDIR, 'derivatives', 'palm', 'NeMo_5mm_fs5_rh.mgh'));


[surf_left, surf_right] = fetch_template_surface('fsaverage5');
surface = fetch_template_surface('fsaverage5', 'join', true);

obj = plot_hemispheres(...
   mean(NeMo{1})',  ...
   {surf_left}, ...
   'labeltext', {'NeMo'}...
   );


demographics = readtable(fullfile(BASEDIR, 'derivatives', 'GLM', 'X_full.csv'));
n = height(demographics);
demographics.Properties.VariableNames = {'ID', 'age', 'sex', 'NIHSS', 'ivt', 'mRS', 'WMHvol', 'WMHvol_lh', 'WMHvol_rh'};
X = demographics(kron(1:n, [1, 1]),1:7);
X.WMHvolhemi = kron(demographics.WMHvol_lh,[1;0]) + kron(demographics.WMHvol_rh,[0;1]);
X.logWMHvol = log10(X.WMHvol);
X.logWMHvolhemi = log10(X.WMHvolhemi);


hemis = {'lh','rh'};
X.hemi = hemis(kron(ones(n,1),[1;2]))';

%%
covs = X(:,{'logWMHvolhemi','age','sex'});
terms_covs = FixedEffect(covs.Variables, covs.Properties.VariableNames, false);

term_mRS = FixedEffect(X.mRS, 'mRS', false);
term_hemi = FixedEffect(X.hemi, 'hemi', false);
term_subject = MixedEffect(X.ID, [], 'add_intercept', false);

model = terms_covs + term_hemi + term_mRS + term_subject;
model_ix = model + term_hemi * term_mRS;

%model = terms_covs + term_mRS;

contrast = X.mRS;
contrast_ix = (X.mRS .* (X.hemi == "lh")) - (X.mRS .* (X.hemi == "rh"));
[mask_left, mask_right] = fetch_mask('fsaverage5', 'join', false);
 
slm = SLM( ...
    model_ix, ...
    -contrast_ix, ...
    'surf', surf_left, ...
    'correction', {'rft', 'fdr'}, ...
    'cluster_threshold', 0.01, ...
    'two_tailed', false,...
    'mask', []);
slm.fit(NeMo{1});




disp(slm.P.clus{1}(1:3,:))
disp(slm.P.peak{1}(1:3,:))
%%
%[skwn, krts] = slm.qc(NeMo{1}, 'v', 88);
% Change plot_slm to tutorial_plot_slm if not run in a live script.
[surf_left_inf, surf_right_inf] = fetch_template_surface('fsaverage5', 'layer','inflated');

obj = tutorial_plot_slm(slm, surf_left_inf, 'mask', mask_left, ...
    'plot_clus', true, 'plot_peak', true, 'plot_fdr', true, 'alpha', 0.5);

%%
[correlation, feature] = meta_analytic_decoder(slm.t, ...
    'template', 'fsaverage5');
disp(correlation(1:3));