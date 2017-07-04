function [kf_times_microsec] = kSecondsToMicroSeconds(kf_times_sec)

kSecondsToMicroSeconds = 1e6;
kf_times_microsec = kf_times_sec*kSecondsToMicroSeconds;

end