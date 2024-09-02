package com.transportation.metrobas.chat;

import com.transportation.metrobas.user.User;
import com.transportation.metrobas.user.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ChatService {

    private final MessageRepository messageRepository;
    private final UserRepository userRepository;


    @Autowired
    public ChatService(MessageRepository messageRepository, UserRepository userRepository) {
        this.messageRepository = messageRepository;
        this.userRepository = userRepository;
    }

    public List<Message> findAllChatMessages(){
        return this.messageRepository.findAllChatMessagesSortedByDateDesc();
    }

    @Transactional
    public void SaveMessage(String messageContent, int userId){
         User user = this.userRepository.findById(userId).orElseThrow();
         Message message = new Message(messageContent, LocalDateTime.now());
         message.setUser(user);
         this.messageRepository.save(message);
    }


    @Transactional
    public void deleteMessage(int messageId){
        this.messageRepository.deleteById(messageId);
    }
}
