package com.transportation.metrobas.report;

import com.transportation.metrobas.user.UserAdabter;
import com.transportation.metrobas.user.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/reports")
public class ReportController {

    private final ReportService reportService;

    private final UserAdabter userAdabter;

    @Autowired
    public ReportController(ReportService feedbackService, UserAdabter userAdabter) {
        this.reportService = feedbackService;
        this.userAdabter = userAdabter;
    }

    @GetMapping
    public ResponseEntity<List<ReportDto>> findAllReports(){
        List<Report> reports =  this.reportService.findAllReports();
        List<ReportDto> reportDtos = new ArrayList<>();
        for (Report report : reports){
            reportDtos.add(new ReportDto(report.getReportId(), userAdabter.UserToDto(report.getUser()) ,report.getContent()));
        }
        return ResponseEntity.ok(reportDtos);
    }

    @PostMapping
    public ResponseEntity<String> createReport(@Valid @RequestBody ReportRequest reportRequest, Principal principal){
        this.reportService.createFeedback(reportRequest.getContent(), principal.getName());
        return new ResponseEntity<>("Report has created, Thank you", HttpStatus.CREATED);
    }
}
