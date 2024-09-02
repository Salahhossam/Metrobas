package com.transportation.metrobas.chat;

import com.transportation.metrobas.user.User;
import com.transportation.metrobas.user.UserDto;
import jakarta.persistence.*;

import java.time.LocalDateTime;

public class MessageDto {
    private int messageId;

    private String messageContent;

    private LocalDateTime messageDate;

    private UserDto userDto;

    public MessageDto() {
    }

    public MessageDto(int messageId, String messageContent, LocalDateTime messageDate, UserDto userDto) {
        this.messageId = messageId;
        this.messageContent = messageContent;
        this.messageDate = messageDate;
        this.userDto = userDto;
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

    public UserDto getUserDto() {
        return userDto;
    }

    public void setUserDto(UserDto userDto) {
        this.userDto = userDto;
    }
}
