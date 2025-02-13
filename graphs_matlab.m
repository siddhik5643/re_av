Video parameters
filename = 'trajectory_video.avi'; % Output video file name
frame_rate = 10; % Frames per second
% Create a VideoWriter object
v = VideoWriter(filename, 'Motion JPEG AVI'); % You can use 'MPEG-4' if supported
v.FrameRate = frame_rate; % Set the frame rate
open(v); % Open the video file for writing
% Load trajectory data
load matlab_check.mat
x = out.state(:,1);
y = out.state(:,2);
phi = out.state(:,3);
% Initialize figure
figure(1);
hold on; % Keep adding to the plot
grid on;
axis equal;
xlabel('X Coordinate');
ylabel('Y Coordinate');
title('Trajectory Plotter');
plot(x, y, '--', 'LineWidth', 1); % Plot full trajectory as dashed line
% Loop through trajectory points
for i = 1:100:length(x)
    % Plot current point and heading vector
    h = plot(x(i), y(i), 'bs', 'LineWidth', 2, 'MarkerSize', 10); % Current position as blue square
    g = quiver(x(i), y(i), 5*cos(phi(i)), 5*sin(phi(i)), 10, 'r', 'LineWidth', 1, 'MaxHeadSize',200);
    % quiver(x(i), y(i), 5*cos(phi(i)), 5*sin(phi(i)), 2, 'b', 'LineWidth', 1)
    % Set axis limits dynamically if needed
    xlim([min(x)-10, max(x)+10]);
    ylim([min(y)-10, max(y)+10]);
    legend('Trajectory', 'Vehicle','Heading Direction')
    % Capture the frame
    frame = getframe(gcf);      % Capture the current figure
    img = frame2im(frame);      % Convert the frame to an image
    writeVideo(v, img);         % Write the image to the video
    pause(0.1); % Pause for visualization
    delete(h); % Delete current position marker
    delete(g); % Delete heading vector
end
% Finalize video
hold off;
close(v);
disp(['Video saved as ', filename]);



