package com.health.app.schedules;

import lombok.Getter;
import java.util.List;

@Getter
public class TimeConflictException extends RuntimeException {
    private final List<AttendeeConflictDto> conflicts;

    public TimeConflictException(String message, List<AttendeeConflictDto> conflicts) {
        super(message);
        this.conflicts = conflicts;
    }
}
