function [x,yAll,MSE,traceP,z] = OptimizeEnVar(n,T,var_y,skip,Gap,NeAll,ClocRadAll,inflAll,Save,EXIT)

dt = 0.01;
t = 0:dt:T;
Steps = length(t);
%% ------------------------------------------

%% Model parameters
%% ------------------------------------------
F = 8;
%% ------------------------------------------

%% Observations
%% ------------------------------------------
H = getH(skip,n);
R = var_y*eye(size(H,1));
%% ------------------------------------------

%% Load Spin up data
%% ------------------------------------------
load(strcat('EnKFRunVary',num2str(var_y),'n',num2str(n),'Gap',num2str(Gap),'.mat'))
%% ------------------------------------------


%% Generate data
%% ------------------------------------------
yAll = model(xo,dt,Steps,F);
[z,~] = getObs(H,R,t,yAll,Gap,Steps);
%% ------------------------------------------

muo = mean(X,2);

%% EnVar 
%% ------------------------------------------
for zz=1:length(NeAll)
    Ne = NeAll(zz);
    Xo = X(:,1:Ne);
    for pp = 1:length(ClocRadAll)
        Cloc = getCov(n,ClocRadAll(pp));
        Lb = sqrtm(Cloc.*cov(X'));
        for tt = 1:length(inflAll)
            infl = inflAll(tt); 
            fprintf('EnVar, loc. Rad = %g, infl = %g, Ne = %g\n',ClocRadAll(pp),infl,Ne)
            [x,traceP,~]=myEnVar(infl,Cloc,Ne,Xo,muo,Lb,z,R,H,F,Gap,Steps,dt);
            MSE = sqrt(mean( (x(:,Gap+1:Gap:end)-yAll(:,Gap+1:Gap:end)).^2 ));
            traceP = sqrt(traceP/n);
            if Save == 1
                Filename = strcat('EnVar_Gap_',num2str(Gap),'_Ne_',num2str(Ne), ...
                    '_vary_',num2str(var_y),'_locRad_',num2str(ClocRadAll(pp)),'infl',num2str(inflAll(tt)),'_skip_',num2str(skip),'.mat');
                save(Filename,'MSE','traceP')
            end
        end
    end
end

if EXIT ==1
    exit;
end

