clear all

readObj = audiorecorder(10000,8,1); % Create audio recorder
newAudioChoice = 0;
fs = 10000; %Sampling rate

%Ask user what they want to do
disp(['What would you like to do?' newline '1: Create new audio | 2: Decrypt audio | 3: Quit' newline ]) 
userInput =  'Your input: ';
answer = input(userInput);

%========= 1 Create new audio ===========================================
while 1 && answer == 1;
    
disp('Time duration for the recording? (Minimum = 1 sec | Maximum = 10 sec)'); 
timeInput =  'Your input: ';
time = input(timeInput);

%Time boundary check
if time >= 10
    time = 10;
end
if(time <= 1)
    time = 1;
end

%The countdown
disp('Get ready to talk'); pause(3); 
disp('3..'); pause(1); disp('2..'); pause(1); disp('1..'); pause(1);

%Start recording
disp('Start speaking..');
recordblocking(readObj, time);
disp('Finised recording..');
disp(newline);
disp('Start select what you want to do with your recording: ');
disp(['1. Encrypt' newline '2. Show audio data & play recording' newline '3. Record again' newline '4. Quit']);
data = getaudiodata(readObj);

%Get user input for what they want to do
promt = 'Your input: ';
newAudioChoice = input(promt);

while(newAudioChoice == 2)
    %Play audio
    soundsc(data,fs);
    
    pause(2);
    disp([newline 'Generating data..' newline]);
    
    %Plot the time domain
    figure(1)
    plot(data, 'blue');
    title('Time domain');
    xlabel('Samples');
    ylabel('Amplitude');
    
    %Plot the frequency domain
    figure(2)
    Y = fft(data);
    N = length(Y);
    f = 0:fs/N:fs/2;
    X_magn = abs(Y)/(N/2);
    plot(f, X_magn(1:length(f)), 'blue');
    title('Frequency domain')
    xlabel('Frequency');
    ylabel('Amplitude');
     
    %Ask again
    disp('Start select what you want to do with your recording: ');
    disp(['1. Encrypt' newline '2. Show audio data & play recording' newline '3. Record again' newline '4. Quit']);
    
    promt = 'Your input: ';
    newAudioChoice = input(promt);
end

%If x == 3 record again
if(newAudioChoice ~= 3)
    break;
end

end

%1. Encrypt audio
if(newAudioChoice == 1)
    
    disp('Encrypting Audio...');
    pause(2);
    
    %Find value closest to 1
    distance = max(data);
    
    POS_KEY = (1-distance)*rand(time*fs,1); %Generate Positive KEY
    NEG_KEY = (1-distance)*rand(time*fs,1); %Generate Negative KEY
    
    data_encrypt = data - POS_KEY + NEG_KEY;
    
    %Ask user for audio playback
    disp([newline 'Play back encrypted audio?' newline 'Y = YES | N = NO' newline]); 
    userInput2 = 'Your input: ';
    playBackChoice = input(userInput2, 's');
    
while playBackChoice == 'y' || playBackChoice == 'Y';
    
    %Play audio
    soundsc(data_encrypt, fs);
    
    %Ask user for audio playback again
    disp([newline 'Play back encrypted audio again?' newline 'Y = YES | N = NO' newline]); 
    userInput2 = 'Your input: ';
    playBackChoice = input(userInput2, 's');
    
end

%Ask user if they want to see encrypted audio data
disp([newline 'Show encrypted audio data?' newline 'Y = YES | N = NO' newline])
userInput3 = 'Your input: ';
showEncryptedDataChoice = input(userInput3, 's');


if(showEncryptedDataChoice == 'y' || showEncryptedDataChoice == 'Y')
    
    %Plot encrypted audio in time domain
    figure(3)
    plot(data_encrypt, 'red');
    title('Time domain (Encrypted)')
    xlabel('Samples');
    ylabel('Amplitude');
    
    %Plot encrypted audio in frequency domain
    figure(4)
    Y = fft(data_encrypt);
    N = length(Y);
    f = 0:fs/N:fs/2;
    X_magn = abs(Y)/(N/2);
    plot(f, X_magn(1:length(f)), 'red');
    title('Frequency domain (Encrypted)')
    xlabel('Frequency');
    ylabel('Amplitude');
end


filename_audio = 'EncryptedAudio.wav';
filename_POS_KEY = 'POS_KEY.txt';
filename_NEG_KEY = 'NEG_KEY.txt';

%Write encrypted audio and key to file
audiowrite(filename_audio, data_encrypt, fs);
writematrix(POS_KEY, filename_POS_KEY);
writematrix(NEG_KEY, filename_NEG_KEY);

disp(newline);
disp('Saving decrypted audio...');
pause(2);
disp('Encrypted audio was a success!');
disp('Audiofile saved as: EncryptedAudio.wav'); 
disp('Keyfiles saved as: POS_KEY.txt and NEG_KEY.txt');
disp(newline);
disp('Quitting..');

end

%4. Quit
if(newAudioChoice == 4 || answer == 3)
    disp('Quitting..');  
end

%================= 2. Decrypt Audio ================================
if answer == 2
    
    %Get encrypted audio and text files
    fileinput = 'Please enter audio filename: ';
    filename = input(fileinput, 's');
    
    posKeyRequest = 'Please enter positive Keyfile: ';
    posKeyInput = input(posKeyRequest, 's');
    
    negKeyRequest = 'Please enter negative Keyfile: ';
    negKeyInput = input(negKeyRequest, 's');
    
    
    [y, fs] = audioread(filename);
    
    fileID_POS = fopen(posKeyInput,'r');
    formatSpec_POS = '%f';
    posKey = fscanf(fileID_POS,formatSpec_POS);
    fclose(fileID_POS);
    
    fileID_NEG = fopen(negKeyInput,'r');
    formatSpec_NEG = '%f';
    negKey = fscanf(fileID_NEG,formatSpec_NEG);
    fclose(fileID_NEG);
    
    %Decrypt audio using keys
    DecryptedAudio = y + posKey - negKey;
    
    disp('Decrypting audio..');
    pause(2);
    disp('Success!!');
    pause(1);
    
    disp(newline);
    disp(['What would you like to do?' newline '1. Play decrypted audio & show data' newline '2. Save and quit']);
    
    DecryptQuestion = 'Your input: ';
    DecryptChoice = input(DecryptQuestion);
    
    %Play audio and show data.
    if DecryptChoice == 1 
        
    soundsc(DecryptedAudio, fs);
    
    disp('Generating data..');
    
    %Plot the time domain
    figure(1)
    plot(DecryptedAudio, 'blue');
    title('Time domain');
    xlabel('Samples');
    ylabel('Amplitude');
    
    %Plot the frequency domain
    figure(2)
    Y = fft(DecryptedAudio);
    N = length(Y);
    f = 0:fs/N:fs/2;
    X_magn = abs(Y)/(N/2);
    plot(f, X_magn(1:length(f)), 'blue');
    title('Frequency domain')
    xlabel('Frequency');
    ylabel('Amplitude');
    
    secondAnswer = 'Y';
    
    %Play audio again?
    while secondAnswer == 'Y' || secondAnswer == 'y';
        
    secondQuestion = 'Do you want to hear that again? Y = Yes | N = No : ';
    secondAnswer = input(secondQuestion, 's'); 
    
    if(secondAnswer == 'y' || secondAnswer == 'Y')
        soundsc(DecryptedAudio, fs);
    end
    
    end
    
    end
    
    %Save to file
    audiowrite('Decrypted_Audio.wav', DecryptedAudio, fs);
    
    disp('Saving and exiting..')
    pause(2);
    
end






