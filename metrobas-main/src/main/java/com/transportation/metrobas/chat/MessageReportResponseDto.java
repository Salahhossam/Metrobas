package com.transportation.metrobas.chat;

import com.transportation.metrobas.user.User;
import com.transportation.metrobas.user.UserDto;
import jakarta.persistence.Column;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;

public class MessageReportResponseDto {

    private int messageReportId;

    private String reportReason;

    private MessageDto message;

    private UserDto user;

    public MessageReportResponseDto() {
    }

    public MessageReportResponseDto(int messageReportId, String reportReason, MessageDto message, UserDto user) {
        this.messageReportId = messageReportId;
        this.reportReason = reportReason;
        this.message = message;
        this.user = user;
    }

    public int getMessageReportId() {
        return messageReportId;
    }

    public void setMessageReportId(int messageReportId) {
        this.messageReportId = messageReportId;
    }

    public String getReportReason() {
        return reportReason;
    }

    public void setReportReason(String reportReason) {
        this.reportReason = reportReason;
    }

    public MessageDto getMessage() {
        return message;
    }

    public void setMessage(MessageDto message) {
        this.message = message;
    }

    public UserDto getUser() {
        return user;
    }

    public void setUser(UserDto user) {
        this.user = user;
    }
}
