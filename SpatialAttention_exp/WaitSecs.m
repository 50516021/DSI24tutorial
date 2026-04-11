function varargout = WaitSecs(waitTime)
%WAITSECS  Minimal replacement for Psychtoolbox WaitSecs without PTB.
%   WAITSECS(t) waits approximately t seconds.
%   
%   Notes:
%   - This implementation is intended to remove the dependency on
%     Psychtoolbox. It is reasonably accurate (millisecond order) but
%     not as precise or robust as the original PTB WaitSecs on a
%     heavily loaded system.
%   - Only the form WAITSECS(SECS) is supported. String options such as
%     WAITSECS('UntilTime', when) are not implemented.
%
%   The function optionally returns a monotonically increasing timebase
%   (in seconds) similar to GetSecs, but current scripts do not rely on
%   the return value.

    persistent startRef;
    if isempty(startRef)
        startRef = tic; % reference for the returned timebase
    end

    if nargin < 1 || ~isnumeric(waitTime) || ~isscalar(waitTime)
        error('WaitSecs:Usage', 'Use WaitSecs(secs) with a numeric scalar argument.');
    end

    % Handle non-positive waits gracefully
    if waitTime <= 0
        nowTime = toc(startRef);
        if nargout > 0
            varargout{1} = nowTime;
        end
        return;
    end

    % Start local timer for the requested interval
    tLocal = tic;

    % Coarse sleep phase to reduce CPU load for most of the interval
    % Keep a small safety margin for the final busy-wait phase.
    margin = 0.01; % 10 ms margin
    if waitTime > margin
        pause(waitTime - margin);
    end

    % Final busy-wait for finer alignment
    while true
        if toc(tLocal) >= waitTime
            break;
        end
    end

    % Monotonic timebase relative to first call
    nowTime = toc(startRef);
    if nargout > 0
        varargout{1} = nowTime;
    end
end
