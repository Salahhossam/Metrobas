package com.transportation.metrobas.chat;

import com.transportation.metrobas.user.User;
import com.transportation.metrobas.user.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class MessageReportService {

    private MessageReportRepository messageReportRepository;

    private MessageRepository messageRepository;

    private UserRepository userRepository;;

    @Autowired
    public MessageReportService(MessageReportRepository messageReportRepository, MessageRepository messageRepository, UserRepository userRepository) {
        this.messageReportRepository = messageReportRepository;
        this.messageRepository = messageRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public void addReport(MessageReportRequestDto messageReportRequestDto){
        Message message = this.messageRepository.findById(messageReportRequestDto.getMessageId()).orElseThrow();
        User user = this.userRepository.findById(messageReportRequestDto.getUserId()).orElseThrow();
        MessageReports messageReports = new MessageReports(messageReportRequestDto.getReportReason());
        messageReports.setMessage(message);
        messageReports.setUser(user);
        this.messageReportRepository.save(messageReports);
    }

    public List<MessageReports> findAllMessageReports(){
         return this.messageReportRepository.findAll();
    }

}
