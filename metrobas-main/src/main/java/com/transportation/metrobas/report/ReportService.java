package com.transportation.metrobas.report;

import com.transportation.metrobas.user.User;
import com.transportation.metrobas.user.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ReportService {

    private final ReportRepository reportRepository;

    private final UserRepository userRepository;

    @Autowired
    public ReportService(ReportRepository reportRepository, UserRepository userRepository) {
        this.reportRepository = reportRepository;
        this.userRepository = userRepository;
    }

    public List<Report> findAllReports(){
        return reportRepository.findAll();
    }

    @Transactional
    public void createFeedback(String content, String userName) {
        Report report = new Report(content);
        User user = userRepository.findByUserName(userName).orElse(null);
        if(user != null){
            report.setUser(user);
            reportRepository.save(report);
        }
    }
}
