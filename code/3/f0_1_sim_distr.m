function f0_1_sim_distr(test_number, dgp_type, n, beta1_in, beta2_in, pi_in, hypothesis_type, M, seed_type, seed_input_if_seed_type_1)
% function f0_1_sim_distr(dgp_type, n, k_delta, k_beta2, beta1, beta2, hypothesis_type, M, seed_type, seed_input_if_seed_type_1)
    % Calculates the distribution and critical values for the robust tests
    %
    tic;
    if nargin < 1
        clear; clc;
        M = 2000;            %number of Simulations
        dgp_type = 2;
        n = 200;
        seed_type = 1;
        k_beta2 = 1; % 20;
        k_delta = 1;
        
        beta1_in = 1 .* ones(k_delta, 1); 
        beta2_in = 0 .* ones(k_beta2, 1); 
        pi_in = ones(k_delta+k_beta2, 1);
        hypothesis_type = 1;
        test_number = 1;
    else
        k_delta = length(beta1_in);
        k_beta2 = length(beta2_in);
    end
    

    if seed_type == 0  % all at once, random
        seed_input = 'shuffle';
        rng('shuffle');
        temp = rng;
        sim_number = temp.Seed;
        clear temp;
    elseif seed_type == 1  % all at once, reproducible
        seed_input0 = 1;
        if nargin == 10
            seed_input0 = seed_input_if_seed_type_1;
        end
        seed_input0 = seed_input0 - 1;
        sim_number = seed_input0;
    elseif seed_type == 2  % longleaf array, reproducible
        seed_input0 = str2num(getenv('SLURM_ARRAY_TASK_ID'));
        seed_input0 = seed_input0 - 1;
        sim_number = seed_input0;
    end
    
    % beta1_vec = unique([0 1/sqrt(n) 5/sqrt(n) 10/sqrt(n) 1])
    % beta2_vec = unique([0 1/sqrt(n) 5/sqrt(n) 10/sqrt(n) 1])
    
    warning('off','all');
    
    k_beta2_n = k_beta2;

    
%     j = 1;
%     if (seed_type == 1 || seed_type == 2)
%         seed_input = seed_input0 * 10^ceil(log(J)/log(10)) + j;
%     end
%     seed_input = j;
    seed_input = seed_input0 + 1;
%     data = class_tests_1(dgp_type, hypothesis_type, n, seed_input, k_beta2, k_delta, beta_in, k_beta2_n);
    data = class_tests_1(test_number, dgp_type, hypothesis_type, n, seed_input, beta1_in, beta2_in, pi_in, k_beta2_n);

    data = data.fcn_estimation_initial();
    data = data.fcn_tests_initial();
    
    seed = seed_input0 + 1000001;
    data = data.fcn_cluster_sim_distr(M, seed);
    data = data.fcn_bs2(M, seed);
    data = data.fcn_linearized_bs(M, seed);
    data = data.clean_up();
   
    
    %%
    output_main_dir = sprintf('./data/%d/dist/n%d', test_number, n);

    outputdir = sprintf('%s/output_%d_dgp%d_hyp%d_n%d_kd%d_kl%d_b1%d_b2%d', output_main_dir, test_number, dgp_type, hypothesis_type, n, k_delta, k_beta2, floor(beta1_in(1)*1000), floor(beta2_in(1)*1000));
    if exist(outputdir,'dir') == 0
        mkdir(outputdir);
    end
    outputname=sprintf('%s/dist_%d_dgp%d_hyp%d_b1%d_b2%d_n%d_kln%d_J%d_%d.mat', outputdir, test_number, dgp_type, hypothesis_type, floor(beta1_in(1)*1000), floor(beta2_in(1)*1000), n, k_beta2_n, M, sim_number);

    count = 0;
    while exist(outputname,'file') == 2
        fprintf('Error: Name Taken; Iterating Name Forward \n')
        count = count + 1;
        outputname=sprintf('%s/dist_%d_dgp%d_hyp%d_b1%d_b2%d_n%d_kln%d_J%d_%d_%d.mat', outputdir, test_number, dgp_type, hypothesis_type, floor(beta1_in(1)*1000), floor(beta2_in(1)*1000), n, k_beta2_n, M, sim_number, count);
    end
    fprintf('%s \n', outputname);
    time = toc / 60;
    
    save(outputname, 'data', 'time');

%     clear data;
    
end