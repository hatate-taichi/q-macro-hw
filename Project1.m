% クリア
clc
clear all
close all

%データの設定
f = fred
startdate = '01/01/1994';
%中国の場合開始時期を変更すればよいかと思っていろいろ変えてみたがうまくいかなかった
%startdate = '01/01/2013';
enddate = '10/01/2022';

%中国を選択しようとしたが、うまくデータが取れない
%次は米国を選択しようとしたが、fred にReal Gross Domestic Product が無い
%最後にドイツを選択することにした。関数は'CHI'のままにしておく
CHI = fetch(f,'CLVMNACSCAB1GQDE',startdate,enddate)
%CHI = fetch(f,'COMREPUSQ159N',startdate,enddate)　米国：これではないっぽい。データはどこだ？
%CHI = fetch(f,'NGDPRXDCCNA',startdate,enddate)　中国：ほとんどデータがない？？
JPN = fetch(f,'JPNRGDPEXP',startdate,enddate)
JPN_LOG = log(JPN.Data(:,2));
CHI_LOG = log(CHI.Data(:,2));
q= JPN.Data(:,1);
T = size(CHI_LOG,1)

%f_hpfilterの記載を移植する
lam = 1600;
A = zeros(T,T);

A(1,1) = lam+1;A(1,2) = -2*lam;A(1,3) = lam;
A(2,1) = -2*lam;A(2,2) = 5*lam+1;A(2,3) = -4*lam;A(2,4) = lam;

A(T-1,T) = -2*lam;A(T-1,T-1) = 5*lam+1;A(T-1,T-2) = -4*lam;A(T-1,T-3) = lam;
A(T,T) = lam+1;A(T,T-1) = -2*lam;A(T,T-2) = lam;

for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

tauCHIGDP = A\CHI_LOG;
tauJPNGDP = A\JPN_LOG;

jpntilde = JPN_LOG - tauJPNGDP;
chitilde = CHI_LOG - tauCHIGDP;

dates = 1994:1/4:2022.4/4;
figure
title('Deterended log(realGDP) 1994Q1-2022Q4');
plot(q, jpntilde, 'b', q, chitilde, 'r')
%legend('Japan', 'China', 'Location', 'southwest');
legend('Japan', 'Germany', 'Location', 'southwest');
datetick('x', 'yyyy-qq')

jpnysd = std(jpntilde)*100;
chiysd = std(chitilde)*100;
corr_jpn_chi = corrcoef(jpntilde(1:T),chitilde(1:T));
corr_jpn_chi = corr_jpn_chi(1,2);

disp(['Percent standard deviation of detrended log real GDP for Japan: ', num2str(jpnysd),'.']); disp(' ')
%disp(['Percent standard deviation of detrended log real GDP for China: ', num2str(chiysd),'.']); disp(' ')
disp(['Percent standard deviation of detrended log real GDP for Germany: ', num2str(chiysd),'.']); disp(' ')
%disp(['Contemporaneous correlation bitween detrended log real GDP in Japan and China: ', num2str(corr_jpn_chi),'.']); disp(' ')
disp(['Contemporaneous correlation bitween detrended log real GDP in Japan and Germany: ', num2str(corr_jpn_chi),'.']); disp(' ')

