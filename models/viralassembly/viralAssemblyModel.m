function viralAssemblyModel ()
	
	%% Initial Conditions
	% We're setting everything to 0 except the first variable
	% The first variable is the copy number of gapped DNA in the nucleus
	% This simulates the initial infection 
	initial = zeros(19,1);
	initial(1) = 1;
	
	%% Run the simulation
	% Run for 100 time units (minutes?)
	Tend = 100;
	% I use tic and toc to time how long the simulation takes
	tic
	[t, out] = ode45(@mathva, [0,Tend], initial);
	toc
	
	%% Plot!
	% This plots concentration of virions over time
	figure(1);
	plot(t, out(:,19),'LineWidth',2);
	title('Concentration of Virions over Time')
	xlabel('Time')
	ylabel('Virions')
	
end

function dS = mathva(~,S)
	
	%% Provide useful names for things
	D_gap  = S(1);  % var(1)
	D_ccc  = S(2);  % var(2)
	R_19s  = S(3);  % var(3)
	R_35u  = S(4);  % var(4)
	R_35s1 = S(5);  % var(5)
	R_35s2 = S(6);  % var(6)
	R_35s3 = S(7);  % var(7)
	R_35s4 = S(8);  % var(8)
	P_1    = S(9);  % var(9)
	P_2    = S(10); % var(10)
	P_3    = S(11); % var(11)
	P_4    = S(12); % var(12)
	P_4s   = S(13); % var(13)
	P_5    = S(14); % var(14)
	P_6    = S(15); % var(15)
	E_6    = S(16); % var(16)
	E_2    = S(17); % var(17)
	V_i    = S(18); % var(18)
	V      = S(19); % var(19)
	
	%% Constants
	% ALL TIME (SHOULD BE) IN MINUTES
	
	out_inf   = 0;          % No outside infection (for now)
	k_v       = 0.01;       % Rate of virions reentering host nucleus
	alpha_c   = 0.1;        % Rate of repair of gapped DNA, value from Nakabayashi
	gamma_c   = 0;          % Degradation rate of CCC DNA, assumed to be 0
	alpha_19  = 0.05;       % Transcription rate of 19S, value from Nakabayashi
	gamma_19  = log(2)/600; % Degradation rate = ln(2)/(half-life)
	alpha_35  = 0.0653;     % Transcription rate of 35S, value from Martiene
	gamma_35u = log(2)/600; % Degradation rate = ln(2)/(half-life)
	
	k_s1 = 1;       % Rate of splicing
	k_s2 = 1;       % Rate of splicing
	k_s3 = 1;       % Rate of splicing
	k_s4 = 1;       % Rate of splicing
	
	gamma_35s1 = log(2)/600; % See note for gamma_19
	gamma_35s2 = log(2)/600; % See note for gamma_19
	gamma_35s3 = log(2)/600; % See note for gamma_19
	gamma_35s4 = log(2)/600; % See note for gamma_19
	
	beta_1u  = 0.1; % From Nakabayashi
	beta_2u  = 0.1; % From Nakabayashi
	beta_3u  = 0.1; % From Nakabayashi
	beta_3u1 = 0.1; % From Nakabayashi
	beta_3u2 = 0.1; % From Nakabayashi
	beta_3u3 = 0.1; % From Nakabayashi
	beta_3u4 = 0.1; % From Nakabayashi
	beta_4u  = 0.1; % From Nakabayashi
	beta_4u1 = 0.1; % From Nakabayashi
	beta_4u2 = 0.1; % From Nakabayashi
	beta_4u3 = 0.1; % From Nakabayashi
	beta_4u4 = 0.1; % From Nakabayashi
	beta_5u  = 0.1; % From Nakabayashi
	beta_5u1 = 0.1; % From Nakabayashi
	beta_5u2 = 0.1; % From Nakabayashi
	beta_5u3 = 0.1; % From Nakabayashi
	beta_5u4 = 0.1; % From Nakabayashi
	beta_6   = 0.1; % From Nakabayashi
	
	delta_1 = 0.0001;   % From Nakabayashi
	delta_2 = 0.0001;   % From Nakabayashi
	delta_3 = 0.0001;   % From Nakabayashi
	delta_4 = 0.0001;   % From Nakabayashi
	delta_5 = 0.0001;   % From Nakabayashi
	delta_6 = 0.0001;   % From Nakabayashi
	
	delta_v = 1;    % Rate of degradation of virions
	
	k_p   = 1;      % Packaging rate
	k_l   = 1;      % Rate of P2 leaving for elIB
	k_p5s = 1;      % Splicing of P4
	r_acc = 1;      % 
	k_vap = 1;      % Not used???
	k_anchor = 1;   % Rate of P3 binding to virions
	
	%% Equations
	
	% Gapped DNA in nucleus
	eq1 = out_inf + k_v*V - alpha_c*D_gap; %ok
	
	% Covalently closed circular DNA in nucleus
	eq2 = alpha_c*D_gap - gamma_c*D_ccc; %ok
	
	% 19S RNA
	eq3 = alpha_19*D_ccc - gamma_19*R_19s; %ok
	
	% Unspliced 35S RNA
	eq4 = alpha_35*D_ccc - (gamma_35u + k_s1 + k_s2 + k_s3 + k_s4 + k_p*P_4s*P_5)*R_35u; %ok
	
	% Spliced form 1 of 35S RNA
	eq5 = k_s1*R_35u - gamma_35s1*R_35s1; %ok
	
	% Spliced form 2 of 35S RNA
	eq6 = k_s2*R_35u - gamma_35s2*R_35s2; %ok
	
	% Spliced form 3 of 35S RNA
	eq7 = k_s3*R_35u - gamma_35s3*R_35s3; %ok
	
	% Spliced form 4 of 35S RNA
	eq8 = k_s4*R_35u - gamma_35s4*R_35s4; %ok
	
	% Protein 1
	eq9 = beta_1u*R_35u - delta_1*P_1; %ok-but missing binding to plasmodesmata
	
	% Protein 2
	eq10 = beta_2u*R_35u - delta_2*P_2 - k_l*P_2; %ok
	
	% Protein 3
	eq11 = beta_3u*R_35u + beta_3u1*R_35s1 + beta_3u2*R_35s2 + beta_3u3*R_35s3 + beta_3u4*R_35s4 - delta_3*P_3 - k_anchor*P_3*V_i; %ok-missing elIB
	
	% Protein 4
	eq12 = beta_4u*R_35u + beta_4u1*R_35s1 + beta_4u2*R_35s2 + beta_4u3*R_35s3 + beta_4u4*R_35s4 - delta_4*P_4 - k_p5s*P_4; %ok
	
	% Protein 4, subunits
	eq13 = k_p5s*P_4 - delta_4*P_4s - k_p*P_4s*P_5*R_35u; %ok
	
	% Protein 5
	eq14 = beta_5u*R_35u + beta_5u1*R_35s1 + beta_5u2*R_35s2 + beta_5u3*R_35s3 + beta_5u4*R_35s4 - delta_5*P_5 - k_p*P_4s*P_5*R_35u; %ok
	
	% Protein 6
	eq15 = beta_6*R_19s - delta_6*P_6; %ok-missing accumulation to edIBs
	
	% edIBs
	eq16 = r_acc * P_6; % not really used for anything
	
	% elIB
	eq17 = r_acc * P_2; % not really used for anything
	
	% Intermediate virions
	eq18 = k_p*P_4s*P_5*R_35u - k_anchor*P_3*V_i; %ok
	
	% Complete virions
	eq19 = k_anchor*P_3*V_i - k_v*V - delta_v*V; %ok
	
	% Altogether now!
	dS = [eq1 eq2 eq3 eq4 eq5 eq6 eq7 eq8 eq9 eq10 eq11 eq12 eq13 eq14 eq15 eq16 eq17 eq18 eq19]';    
	
end