package com.transportation.metrobas.chat;

public class MessageReportRequestDto {

    private int userId;

    private int messageId;

    private String reportReason;

    public MessageReportRequestDto() {
    }

    public MessageReportRequestDto(int userId, int messageId, String reportReason) {
        this.userId = userId;
        this.messageId = messageId;
        this.reportReason = reportReason;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getMessageId() {
        return messageId;
    }

    public void setMessageId(int messageId) {
        this.messageId = messageId;
    }

    public String getReportReason() {
        return reportReason;
    }

    public void setReportReason(String reportReason) {
        this.reportReason = reportReason;
    }
}
