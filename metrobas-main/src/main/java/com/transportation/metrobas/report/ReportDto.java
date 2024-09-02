package com.transportation.metrobas.report;

import com.transportation.metrobas.user.User;
import com.transportation.metrobas.user.UserDto;
import jakarta.persistence.*;

public class ReportDto {
    private int reportId;
    private UserDto user;
    private String content;

    public ReportDto() {
    }

    public ReportDto(int reportId, UserDto user, String content) {
        this.reportId = reportId;
        this.user = user;
        this.content = content;
    }

    public int getReportId() {
        return reportId;
    }

    public void setReportId(int reportId) {
        this.reportId = reportId;
    }

    public UserDto getUser() {
        return user;
    }

    public void setUser(UserDto user) {
        this.user = user;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}
