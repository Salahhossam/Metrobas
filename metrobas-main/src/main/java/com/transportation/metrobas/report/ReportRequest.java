package com.transportation.metrobas.report;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public class ReportRequest {

    @NotBlank(message = "content should not be empty")
    private String content;


    public ReportRequest() {
    }

    public ReportRequest(String content) {
        this.content = content;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}
