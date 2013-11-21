function plotF(A)

    [N,D] = size(A);
    Ns = sqrt(N);
    R = ceil(Ns);
    D = sqrt(D);
    figure;
    colormap gray;
    k=0;
    for i=1:R
      for j=1:R;
        k=k+1;
        if k > N
            return;
        end
        subplot(R,R,k);
        imagesc(reshape(A(k,:),D,D),[0 2]);
        axis off;
        axis equal;
      end;
    end;

end

