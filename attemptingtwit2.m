% a sample structure array to store the credentials
creds = struct;
creds.ConsumerKey = 'pP1Ql7H8PlatVwcfVPiEFBLay';
creds.ConsumerSecret = 'MV9YtaM4WKfHqZLwFclOKW9AAN3tpvpfUewoVnEOhZ3hpgEJfc';
creds.AccessToken = '933307820828774400-MkgyJCYhslCtpnPbNsRpEcpxVdRjwG3';
creds.AccessTokenSecret = 'p6FhgL7MObI29WbI8Fj4HQP4xth0tXwi2dTtoJZXmqblY';

% set up a Twitty object
addpath twitty_1.1.1; % Twitty
addpath parse_json; % Twitty's default json parser
addpath jsonlab; % I prefer JSONlab, however.
load('creds.mat') % load my real credentials
tw = twitty(creds); % instantiate a Twitty object
tw.jsonParser = @loadjson; % specify JSONlab as json parser

% search for English tweets that mention 'amazon' and 'hachette'
amazon = tw.search('amazon','count',100,'include_entities','true','lang','en');
hachette = tw.search('hachette','count',100,'include_entities','true','lang','en');
both = tw.search('amazon hachette','count',100,'include_entities','true','lang','en');
% load supporting data for text processing
scoreFile = 'AFINN/AFINN-111.txt';
stopwordsURL ='http://www.textfixer.com/resources/common-english-words.txt';
% load previously saved data
load amazonHachette.mat

% process the structure array with a utility method |extract|
[amazonUsers,amazonTweets] = processTweets.extract(amazon);
% compute the sentiment scores with |scoreSentiment|
amazonTweets.Sentiment = processTweets.scoreSentiment(amazonTweets, ...
    scoreFile,stopwordsURL);

% repeat the process for hachette
[hachetteUsers,hachetteTweets] = processTweets.extract(hachette);
hachetteTweets.Sentiment = processTweets.scoreSentiment(hachetteTweets, ...
    scoreFile,stopwordsURL);

% repeat the process for tweets containing both
[bothUsers,bothTweets] = processTweets.extract(both);
bothTweets.Sentiment = processTweets.scoreSentiment(bothTweets, ...
    scoreFile,stopwordsURL);

% calculate and print NSRs
amazonNSR = (sum(amazonTweets.Sentiment>=0) ...
    -sum(amazonTweets.Sentiment<0)) ...
    /height(amazonTweets);
hachetteNSR = (sum(hachetteTweets.Sentiment>=0) ...
    -sum(hachetteTweets.Sentiment<0)) ...
    /height(hachetteTweets);
bothNSR = (sum(bothTweets.Sentiment>=0) ...
    -sum(bothTweets.Sentiment<0)) ...
    /height(bothTweets);
fprintf('Amazon NSR  :  %.2f\n',amazonNSR)
fprintf('Hachette NSR:  %.2f\n',hachetteNSR)
fprintf('Both NSR    : %.2f\n\n',bothNSR)

% plot the sentiment histogram of two brands
binranges = min([amazonTweets.Sentiment; ...
    hachetteTweets.Sentiment; ...
    bothTweets.Sentiment]): ...
    max([amazonTweets.Sentiment; ...
    hachetteTweets.Sentiment; ...
    bothTweets.Sentiment]);
bincounts = [histc(amazonTweets.Sentiment,binranges)...
    histc(hachetteTweets.Sentiment,binranges)...
    histc(bothTweets.Sentiment,binranges)];
figure
bar(binranges,bincounts,'hist')
legend('Amazon','Hachette','Both','Location','Best')
title('Sentiment Distribution of 100 Tweets')
xlabel('Sentiment Score')
ylabel('# Tweets')