package com.transportation.metrobas.report;

import com.transportation.metrobas.user.User;
import jakarta.persistence.*;

@Entity
@Table(name = "reports")
public class Report {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "report_id")
    private int reportId;

    @ManyToOne(cascade= {CascadeType.PERSIST, CascadeType.MERGE ,CascadeType.DETACH, CascadeType.REFRESH})
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "content")
    private String content;

    public Report() {
    }

    public Report(String content) {
        this.content = content;
    }

    public int getReportId() {
        return reportId;
    }

    public void setReportId(int reportId) {
        this.reportId = reportId;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    @Override
    public String toString() {
        return "Report{" +
                "reportId=" + reportId +
                ", user=" + user +
                ", content='" + content + '\'' +
                '}';
    }
}
