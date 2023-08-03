%% Hazırlayanlar
% MAHMUT GÖRÜR
% RAMAZAN BERKAN TÜT
clc ;
%% Ses Kaydetme 
Fs=16000;
nbits=8;
recDuration = 1;
disp("Konuşun:")
recObj = audiorecorder(Fs,nbits,1);
recordblocking(recObj,recDuration);
disp("Kayıt sonlandı.")
play(recObj);

ses = getaudiodata(recObj);

figure
plot(1:length(ses),ses);
title("Başlangıç Ses")

%% Ortalama Enerji Filtresi
E = 0;
k = 0;
for i= 1:length(ses)
    k = ses(i)^2;
    E = E+k;
end

P = E/length(ses);
Ses=[];
sesGecimKatsayi=0.001;
for r= 1:length(ses)
   if ((ses(r) >= P || ses(r) <= -P))% &  (ses(r)>=sesGecimKatsayi || ses(r) <= -sesGecimKatsayi))
       Ses = [Ses ;ses(r)];
   else       
   end
end

maxUzun=11500;
sesUzunlukFix = maxUzun-length(Ses);

figure
plot(1:length(Ses),Ses);
title("Filtreli Ses")

%% Çerçeveleme 
ilksesUzunlugu = length(Ses);
CerceveUzunlugu = 500;
sifirEkle = CerceveUzunlugu - (mod(ilksesUzunlugu,CerceveUzunlugu));

if sifirEkle>0
for i= 1:sifirEkle
    Ses = [Ses; 0];
end
end
length(Ses)

sesUzunlugu = length(Ses);
kacCerceveVar = sesUzunlugu/CerceveUzunlugu;
alinacakOrnekSayisi = CerceveUzunlugu*2;
cerceve = [];
ToplananCerceve = [];
alinacakSesUzunlugu = sesUzunlugu - alinacakOrnekSayisi+1;
for i= 1:CerceveUzunlugu:alinacakSesUzunlugu
    for adim = 1:alinacakOrnekSayisi
        cerceve = [cerceve ;Ses(i+adim-1)];
    end
    ToplananCerceve = [ToplananCerceve cerceve ];
    cerceve = [];
end

figure,
for icerikToplananCercerve = 1:length(ToplananCerceve(1,:))
    subplot(2,length(ToplananCerceve(1,:)),icerikToplananCercerve)
    plot(ToplananCerceve(:,icerikToplananCercerve))
    title("ÇERÇEVE"+string(icerikToplananCercerve))
    axis([0 1000 -1 1])
end



%% PENCERELEME 
% yöntemlerden biri seçilecek (hamming,hann,etc.)
carpilmis = [];
carpilmistoplam = [];

% bm = blackman(alinacakOrnekSayisi);
han = hann(alinacakOrnekSayisi);
Logaritmik_Enerji=[];
H=[];
FFTler=[];
Mfler = [];
for i=1:length(ToplananCerceve(1,:))
   
    for k= 1:length(han)
     carpilmis = [carpilmis; ToplananCerceve(k,i)*han(k)];
    end
    carpilmistoplam = [carpilmistoplam carpilmis];
    carpilmis = [];

    %% fft
    y = carpilmistoplam(:,i);
    Y1 = abs(fft(y));
    FFTler=[FFTler Y1];

    %% Mel Frekans düzeltmesi
   Mf = [];
    for f = 1:length(Y1)
        Mf = [Mf; 2595*log10(1+(f/7000))];

    end
    Mfler = [Mfler Mf];
   

    %           Kepstrum
    %% Katsayı ağırlıklandırma
    Kts = Mf.*Y1;
    %% Logaritmik Enerji (enerjinin logaritması)
    Y_E = 0;
    w = 0;
    for q= 1:length(Y1)
        w = Kts(q)^2;
        Y_E = Y_E+w;
    end
    Logaritmik_Enerji = [Logaritmik_Enerji log10(Y_E)];
end
%% Ayrık Kosinüs Dönüşümü katsayıları;H
H = dct(Logaritmik_Enerji);

%% Pencereler Grafik
for i= 1:length(carpilmistoplam(1,:))
    subplot(2,length(carpilmistoplam(1,:)),icerikToplananCercerve+i)
    plot(carpilmistoplam(:,i))
    title("PENCERE"+string(i))
    axis([0 1000 -1 1])  
end

%% |FFT| Grafik

figure,
for icerikFft= 1:length(FFTler(1,:))
    subplot(2,length(FFTler(1,:)),icerikFft)
    plot(FFTler(:,icerikFft))
    title("ÇERÇEVE FFT GRAFİK"+string(icerikFft))
%     axis([0 1000 -1 1])  
end


%% Mel-Frekans saptırılmış |FFT| Grafik

for i= 1:length(FFTler(1,:))
    subplot(2,length(FFTler(1,:)),icerikFft+i)
    plot(Mfler(:,i),FFTler(:,i))
    title("MEL GRAFİK"+string(i))
%     axis([0 1000 -1 1])  
end

um=19;
if length(H)<um
for i= 1:um-length(H)
    H = [H 0];
end

else
 H=H(1:19);
end
%% SES MFCC KAYIT BÖLÜMÜ
% sonuc=8;
% H=[H sonuc];
% sesler=[sesler;H];
% sesler(end,:)

%% CLASSIFICATION Bölümü
 yfit = svm_ses_sonuc.predictFcn(H) ;

%% s2t sonuc
 switch yfit 
    case 1
        disp("a")
    case 2
        disp("e")
    case 3
        disp("ı")
    case 4
        disp("i")
    case 5
        disp("o")
    case 6
        disp("ö")
    case 7
        disp("u")
    case 8
        disp("ü")
    otherwise
        disp("Kapsam dışı harf algılandı...")
end