close all;
clear all;
rng(1943);

N = 500;
[mut,X] = genData(N);

% Plot
plotF(mut);
plotF(X(randsample(1:500,64),:));

% Initialise
D = size(X,2);
K = 15;

sigma_A = 0.35;
sigma_n = 0.1;
alpha = 1;

nu = rand(N,K);
nu = nu./repmat(sum(nu,2),1,K);
Phi = 0.1 * ones(D,D,K);
phi = rand(K,D);
tau = rand(K,2);

for I = 1:200
    % Update nu
    for k = 1:K
        nu(:,k) = 1./(1+exp(-(psi(tau(k,1))-psi(tau(k,2))- 0.5/sigma_n^2*(trace(Phi(:,:,k))+phi(k,:)*phi(k,:)')+1/sigma_n^2*phi(k,:)*(X-nu*phi+nu(:,k)*phi(k,:))')));
    end
    % update Phi, phi
    for k = 1:K
        Phi(:,:,k) = (1/sigma_A^2 + 1/sigma_n^2 * sum(nu(:,k)))^-1 * eye(D);
        phi(k,:) = 1/sigma_n^2 * nu(:,k)'*(X-nu*phi+nu(:,k)*phi(k,:)) * Phi(1,1,k);
    end
    % update tau
    nu_sum = sum(nu)';
    tau(:,1) = alpha/K + nu_sum;
    tau(:,2) = N + 1 - nu_sum;
end

plotF(phi)