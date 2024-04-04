BASEDIR = fullfile(pwd(), '..', '..')

NeMo = read_surface_data(fullfile(BASEDIR, 'derivatives', 'palm', 'xhemi', 'NeMo_5mm_sqrt_adj_fs5_lh+rh_on_lh.mgh'));

[surf_left, surf_right] = fetch_template_surface('fsaverage5');
surface = fetch_template_surface('fsaverage5', 'join', true);

% obj = plot_hemispheres(...
%    mean(NeMo{1})',  ...
%    {surf_left}, ...
%    'labeltext', {'NeMo'}...
%    );


demographics = readtable(fullfile(BASEDIR, 'derivatives', 'GLM', 'XX.csv'));
n = height(demographics);
demographics.Properties.VariableNames = {'ID', 'age', 'sex', 'NIHSS', 'ivt', 'mRS', 'WMHvol'};
X = demographics(kron(1:n, [1, 1]),:);
X.logWMHvol = log10(X.WMHvol);

hemis = {'lh','rh'};
X.hemi = hemis(kron(ones(n,1),[1;2]))';

covs = X(:,{'logWMHvol','age','sex'});
terms_covs = FixedEffect(covs.Variables, covs.Properties.VariableNames, true);

term_mRS = FixedEffect(X.mRS, 'mRS');
term_hemi = FixedEffect(X.hemi, 'hemi');
term_subject = MixedEffect(X.ID);

model = terms_covs + term_hemi + term_hemi * term_mRS  + term_subject;

contrast = X.mRS;
contrast_ix = (X.mRS .* (X.hemi == "lh")) - ...
                   (X.mRS .* (X.hemi == "rh"));
[mask_left, ~] = fetch_mask('fsaverage5', 'join', false);
 
slm = SLM( ...
    model, ...
    contrast_ix, ...
    'surf', surf_left, ...
    'correction', {'rft', 'fdr'}, ...
    'cluster_threshold', 0.01, ...
    'two_tailed', false, ...    
    'mask', mask_left);
slm.fit(NeMo{1});

disp(slm.P.clus{1}(1:5,:))

