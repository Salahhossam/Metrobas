package com.transportation.metrobas.chat;

import com.transportation.metrobas.user.User;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "messages")
public class Message {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "message_id")
    private int messageId;

    @Column(name = "message_content")
    private String messageContent;

    @Column(name = "message_date")
    private LocalDateTime messageDate;

    @ManyToOne(cascade= {CascadeType.PERSIST, CascadeType.MERGE ,CascadeType.DETACH, CascadeType.REFRESH})
    @JoinColumn(name = "user_id")
    private User user;

    @OneToMany(mappedBy = "message")
    private List<MessageReports> messageReportsList;

    public Message() {
    }

    public Message(String messageContent, LocalDateTime messageDate) {
        this.messageContent = messageContent;
        this.messageDate = messageDate;
    }

    public int getMessageId() {
        return messageId;
    }

    public void setMessageId(int messageId) {
        this.messageId = messageId;
    }

    public String getMessageContent() {
        return messageContent;
    }

    public void setMessageContent(String messageContent) {
        this.messageContent = messageContent;
    }

    public LocalDateTime getMessageDate() {
        return messageDate;
    }

    public void setMessageDate(LocalDateTime messageDate) {
        this.messageDate = messageDate;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public List<MessageReports> getMessageReportsList() {
        return messageReportsList;
    }

    public void setMessageReportsList(List<MessageReports> messageReportsList) {
        this.messageReportsList = messageReportsList;
    }
}
