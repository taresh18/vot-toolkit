function [ranks, scores] = analyze_ranks(experiments, trackers, sequences, varargin)

usepractical = false;
labels = {};

for i = 1:2:length(varargin)
    switch lower(varargin{i})
        case 'labels'
            labels = varargin{i+1} ;             
        case 'usepractical'
            usepractical = varargin{i+1} ;  
        otherwise 
            error(['Unknown switch ', varargin{i},'!']) ;
    end
end 

aspect_count = length(sequences);

if ~isempty(labels)
    aspect_count = length(labels);
end;

ranks = nan(numel(experiments), aspect_count, numel(trackers), 2);
scores = nan(numel(experiments), aspect_count, numel(trackers), 2);

for e = 1:numel(experiments)

    experiment = experiments{e};

    print_text('Ranking analysis for experiment %s ...', experiment.name);

    print_indent(1);

	experiment_sequences = convert_sequences(sequences, experiment.converter);

    if isempty(labels)

        aspects = create_sequence_aspects(experiment, trackers, experiment_sequences);
        
    else
        
        aspects = create_label_aspects(experiment, trackers, experiment_sequences, labels);

    end;
    
    [accuracy, robustness, available] = trackers_ranking(experiment, trackers, experiment_sequences, aspects, 'usepractical', usepractical);

	accuracy.average_ranks = accuracy.average_ranks(:, available);
	accuracy.mu = accuracy.mu(:, available);
	accuracy.std = accuracy.std(:, available);

	robustness.average_ranks = robustness.average_ranks(:, available);
	robustness.mu = robustness.mu(:, available);
	robustness.std = robustness.std(:, available);
  
    print_indent(-1);
    
    ranks(e, :, available, 1) = accuracy.ranks;
    ranks(e, :, available, 2) = robustness.ranks;

    scores(e, :, available, 1) = accuracy.mu;
    scores(e, :, available, 2) = robustness.mu;
    
end;