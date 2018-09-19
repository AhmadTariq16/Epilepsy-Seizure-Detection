clear all;
clc;
global start;
global stop;
filename ='C:\Users\Ahmad Tariq\Downloads\Patient Data\Ch 13\chb13_40.edf';
[data, header] = edfread(filename);
[h_rows h_columns]=size(header);
electrode=zeros;

for i=1:h_columns
        electrode(1,i) =header(1,i);
end

%STEP 2
% Frame blocking of the acquired sound wave for testing
N=5000;
length_signal=length(electrode);
number_of_frames = round(length_signal/N);
Frames = zeros(number_of_frames+1,N);
for i = 1:number_of_frames
    temp = electrode(i);
    Frames(i,1:N) = temp;
end

C = zeros(number_of_frames+1,5051);
L=  zeros(number_of_frames+1, 7);
for i=1:number_of_frames
  [C(i,:) L(i,:)]=wavedec(Frames(i,:),5,'db6');
end



D5=zeros(number_of_frames,L(1,5));
for i=1:number_of_frames
    for j=1:L(i,1)
        D5(i,j)=C(i,L(i,1)+j);
    end
end

D4=zeros(number_of_frames,L(1,4));
for i=1:number_of_frames
    for j=1:L(i,3)
    D4(i,j)=C(i,L(i,2)+j);
    end
end

D3=zeros(number_of_frames,L(3));
for i=1:L(4)
    for j=1:L(i,4)
    D3(i,j)=C(i,L(i,4)+j);
    end
end

%Feature 1%%
D5t=D5';
D5t_mean=mean(D5t);
D5_mean=D5t_mean';
feature_1=D5_mean;


norm1=max(feature_1);
feature_1_normalized=feature_1/norm1;


%Feature 2%%
D5t_SD=std(D5t);
D5_SD=D5t_SD';
feature_2=D5_SD;
norm2=max(feature_2);
feature_2_normalized=feature_2/norm2;


buff=zeros(1,185);

for i=1:184
    if feature_1_normalized(i,1)>0.5&&feature_2_normalized(i,1)>0.4
        buff(1,i)=1;
    end
end

se = strel('line',5,0);
dilatedBW = imdilate(buff,se);

output=electrode;
  flag=0;
    
for i=1:184
    if dilatedBW(1,i)==0 && dilatedBW(1,i+1)==1
        j=(i*5000)/256;
        disp('The seizure starts from');
        disp(j);
        start=round(j);
    end
    
    if dilatedBW(1,i)==1 && dilatedBW(1,i+1)==0
        j=(i*5000)/256;
        disp('The seizure ends at:');
        disp(j);
        stop=round(j);
    end
end
dilatedBW=dilatedBW';
feature_1 = padarray(feature_1,1,'post');

plot(feature_1 | dilatedBW);
    
