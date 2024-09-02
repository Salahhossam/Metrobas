package com.transportation.metrobas.chat;

import com.transportation.metrobas.user.User;
import jakarta.persistence.*;

@Entity
@Table(name = "message_reports")
public class MessageReports {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "message_report_id")
    private int messageReportId;

    @Column(name = "report_season")
    private String reportReason;

    @ManyToOne
    @JoinColumn(name = "message_id")
    private Message message;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    public MessageReports() {
    }

    public MessageReports(String reportReason) {
        this.reportReason = reportReason;
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

    public Message getMessage() {
        return message;
    }

    public void setMessage(Message message) {
        this.message = message;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}
