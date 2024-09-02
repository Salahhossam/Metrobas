package com.transportation.metrobas.chat;

import com.transportation.metrobas.user.UserAdabter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/message-reports")
public class MessageReportController {

    private final MessageReportService messageReportService;
    private final UserAdabter userAdabter;

    @Autowired
    public MessageReportController(MessageReportService messageReportService, UserAdabter userAdabter) {
        this.userAdabter = userAdabter;
        this.messageReportService = messageReportService;
    }

    @GetMapping
    public List<MessageReportResponseDto> findAllMessageReports(){
        List<MessageReports> messageReports =  this.messageReportService.findAllMessageReports();
        List<MessageReportResponseDto> messageReportResponseDtos = new ArrayList<>();
        for(MessageReports messageReports1 : messageReports){
            Message message = messageReports1.getMessage();
            messageReportResponseDtos.add(new MessageReportResponseDto(
               messageReports1.getMessageReportId(),
               messageReports1.getReportReason(),
               new MessageDto(message.getMessageId(), message.getMessageContent() ,message.getMessageDate(), userAdabter.UserToDto(message.getUser())),
               userAdabter.UserToDto(messageReports1.getUser())
            ));
        }
        return messageReportResponseDtos;
    }

    @PostMapping
    public ResponseEntity<String> addMessageReport(@RequestBody MessageReportRequestDto messageReportRequestDto){
         this.messageReportService.addReport(messageReportRequestDto);
         return new ResponseEntity<>("report added successfully", HttpStatus.CREATED);
    }

}
