function [spectrum,k,time] = PowerSpec(u,v,w,L,dim)
	tic;
	NFFT = 2.^nextpow2(size(u)); % next power of 2 fitting the length of u
	%u_fft=fftn(u,NFFT);
	%v_fft=fftn(v,NFFT);
	%w_fft=fftn(w,NFFT);
	% NFFT=33;
	uu_fft=fftn(u);
	vv_fft=fftn(v);
	ww_fft=fftn(w);

	% Calculate the numberof unique points
	%NumUniquePts = ceil((NFFT(1)+1)/2);

	% FFT is symmetric, throw away second half 
	%u_fft = u_fft(1:NumUniquePts,1:NumUniquePts,1:NumUniquePts);
	%v_fft = v_fft(1:NumUniquePts,1:NumUniquePts,1:NumUniquePts);
	%w_fft = w_fft(1:NumUniquePts,1:NumUniquePts,1:NumUniquePts);

	%mu = abs(u_fft)/length(u)^3;
	%mv = abs(v_fft)/length(v)^3;
	%mw = abs(w_fft)/length(w)^3;
	muu = abs(uu_fft)/length(u)^3;
	mvv = abs(vv_fft)/length(v)^3;
	mww = abs(ww_fft)/length(w)^3;

	% Take the square of the magnitude of fft of x. 
	%mu = mu.^2;
	%mv = mv.^2;
	%mw = mw.^2;
	muu = muu.^2;
	mvv = mvv.^2;
	mww = mww.^2;

	% Since we dropped half the FFT, we multiply mx by 2 to keep the same energy.
	% The Nyquist component, if it exists, is unique and should not be multiplied by 2.

	%if rem(NFFT, 2) % odd nfft excludes Nyquist point
		%mu(2:end,2:end,2:end) = mu(2:end,2:end,2:end)*2;
		%mv(2:end,2:end,2:end) = mv(2:end,2:end,2:end)*2;
		%mw(2:end,2:end,2:end) = mw(2:end,2:end,2:end)*2;
	%else
		%mu(2:end -1,2:end -1,2:end -1) = mu(2:end -1,2:end -1,2:end -1)*2;
		%mv(2:end -1,2:end -1,2:end -1) = mv(2:end -1,2:end -1,2:end -1)*2;
		%mw(2:end -1,2:end -1,2:end -1) = mw(2:end -1,2:end -1,2:end -1)*2;
	%end
	% Compute the radius vector along which the energies are sumed
	%mx=NumUniquePts;
	%my=NumUniquePts;
	%mz=NumUniquePts;

% % % % % 	for i=1:dim-1
% % % % % 		xx(i) = i-(dim+1)/2;
% % % % % 		yy(i) = i-(dim+1)/2;
% % % % % 		zz(i) = i-(dim+1)/2;
% % % % %     end
    % equivalent see above
	rx=[0:1:dim-1] - (dim-1)/2;
    ry=[0:1:dim-1] - (dim-1)/2;
    rz=[0:1:dim-1] - (dim-1)/2;
    
    
	test_x=circshift(rx',[(dim+1)/2 1]);
	test_y=circshift(ry',[(dim+1)/2 1]);
	test_z=circshift(rz',[(dim+1)/2 1]);
	
	[X,Y,Z]= meshgrid(test_x,test_y,test_z);
	r=(sqrt(X.^2+Y.^2+Z.^2));

% % % 	rx=[0:17 -15:-1]*2*pi/L;
% % % 	ry=[0:17 -15:-1]*2*pi/L;
% % % 	rz=[0:17 -15:-1]*2*pi/L;
% % % 
% % % 	[X,Y,Z]= meshgrid(rx,ry,rz);
% % % 	r=(sqrt(X.^2+Y.^2+Z.^2));
% % % 
% % %     test_spec=zeros(29,1);
% % %     for i=1:(dim+1)/2
% % %         for j=1:(dim+1)/2
% % %             for k=1:(dim+1)/2
% % %                 pos=1+round(r(i,j,k)/(2*pi/L)+0.5);
% % % 				if (r(i,j,k)>((dim-1)*pi/L/1E6) && r(i,j,k)<(dim-1)*pi/L)
% % %                     test_spec(pos)=test_spec(pos)+muu(i,j,k)+mvv(i,j,k)+mww(i,j,k);
% % %                 end
% % %             end
% % %         end
% % %     end
% % %  
% % %     test_spec=0.5*test_spec;
    dx=2*pi/L;
    k=[1:(dim-1)/2].*dx;
	for N=2:(dim-1)/2-1
% 		Radius1=sqrt(3)*(N-1); %lower radius bound
% 		Radius2=sqrt(3)*N; %upper radiusbound
%         Radius1= k(N);
%         Radius2= k(N+1);
% 		picker = ((Radius1 <= r(:,:,:)*dx) & (r(:,:,:)*dx) < Radius2);
        picker = (r(:,:,:)*dx <= (k(N+1) + k(N))/2) & ...
                 (r(:,:,:)*dx > (k(N) + k(N-1))/2);
		spectrum(N) = sum(muu(picker))+sum(mvv(picker))+sum(mww(picker));
%         picker = (r(:,:,:)*dx > (k(N+1)-k(N))/2 + k(N));
%         spectrum(N+1) = sum(muu(picker))+sum(mvv(picker))+sum(mww(picker));
    end
    % special handling for first and last energy value necessary
    picker = (r(:,:,:)*dx <= (k(2) + k(1))/2);
    spectrum(1) = sum(muu(picker))+sum(mvv(picker))+sum(mww(picker));
    picker = (r(:,:,:)*dx > (k((dim-1)/2) + k((dim-1)/2-1))/2);
    spectrum(16) = sum(muu(picker))+sum(mvv(picker))+sum(mww(picker));
	spectrum=0.5*spectrum./(2*pi/L);%(2*pi)^3;%

% 	dx=2*pi/L;
	%dy=pi/L;
	%dz=pi/L;
	%for I=1:mx
		%X0(I)=(I-1)*dx; 
	%end
%
	%for J=1:my
		%Y0(J)=(J-1)*dy;                                  
	%end
%
	%for K=1:mz
		%Z0(K)=(K-1)*dz;                                  
	%end
%
	%for I=1:mx
		%for J=1:my
			%for K=1:mz
				%R(I,J,K)=sqrt(X0(I)*X0(I)+Y0(J)*Y0(J)+Z0(K)*Z0(K));
			%end
		%end
	%end

	%% P=mod(nx,2);
	%% if (P < 1)
	%%     Nmax=mx-0.5;
	%% else
% 	Nmax=(dim+1)/2;
	%% end
	%spectrum=zeros(Nmax,1);
	%for N=1:Nmax
		%Radius1=sqrt(3)*(N-1)*dx; %lower radius bound
		%Radius2=sqrt(3)*N*dx; %upper radius bound
		%% bild picker index for selecting values lying on the shell
		%picker = (Radius1 <= R(:,:,:)) & (R(:,:,:) < Radius2);
		%% build summation over shell components
		%T_EVP1=sum(mu(picker))+sum(mv(picker))+sum(mw(picker));
		%% put them at position N in the spectrum
		%spectrum(N)=T_EVP1.*0.5.*6;               
	%end
% 	k=[1:Nmax].*dx;
	%spectrum = 1./(2*pi)^3.*spectrum;
	time=toc;
end
