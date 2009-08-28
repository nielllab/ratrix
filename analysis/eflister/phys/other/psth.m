clc;
clear all;

load('g01 natural');
nat1=spks;
load('g02 natural');
nat2=spks;
load('g03 natural');
nat3=spks;

load('g01 white');
wht1=spks;
load('g02 white');
wht2=spks;
load('g03 white');
wht3=spks;

subplot(2,1,1)
spy(nat1,'b')
hold on
spy(nat2,'r')
spy(nat3,'g')
axis fill
subplot(2,1,2)
ns1=sum(full(nat1));
plot(ns1,'b')
hold on
ns2=sum(full(nat2));
plot(ns2,'r')
ns3=sum(full(nat3));
plot(ns3,'g')